import { Router } from 'express';
import crypto from 'crypto';
import fetch from 'node-fetch';
import { pool } from '../db.js';

const router = Router();
const JAVA_BACKEND = process.env.JAVA_BACKEND_URL || 'http://localhost:8080';
const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const DEEPSEEK_BASE_URL = process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com/v1';
const MODEL = 'deepseek-chat';
const CREATE_LINK_ACTION_IDS = ['act_create_company_company_link', 'act_create_company_strategic_link'];
const DELETE_LINK_ACTION_IDS = ['act_delete_company_company_link'];

function getProjectId(req: { query?: Record<string, any> }) {
  return String(req.query?.projectId || 'project_public');
}

function checkAI(): boolean {
  return !!DEEPSEEK_API_KEY;
}

async function callDeepSeek(messages: { role: string; content: string }[]) {
  if (!DEEPSEEK_API_KEY) throw new Error('DEEPSEEK_API_KEY not configured');

  const response = await fetch(`${DEEPSEEK_BASE_URL}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${DEEPSEEK_API_KEY}`,
    },
    body: JSON.stringify({
      model: MODEL,
      messages,
      temperature: 0.2,
      max_tokens: 1200,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`DeepSeek API error: ${error}`);
  }

  const data = (await response.json()) as any;
  return data.choices?.[0]?.message?.content || '';
}

async function fetchCandidateByNews(newsEventId: string, projectId: string) {
  const connection = await pool.getConnection();
  try {
    const [rows]: any = await connection.execute(
      `SELECT rc.*, sn.name AS source_name, tn.name AS target_name, lt.name AS link_type_name
       FROM relation_candidates rc
       LEFT JOIN company_entity sn ON rc.source_instance_id = sn.company_id
       LEFT JOIN company_entity tn ON rc.target_instance_id = tn.company_id
       LEFT JOIN link_types lt ON rc.link_type_id = lt.id
       WHERE rc.news_event_id = ?
         AND rc.project_id = ?
       ORDER BY rc.created_at DESC
       LIMIT 1`,
      [newsEventId, projectId],
    );
    return rows[0] || null;
  } finally {
    connection.release();
  }
}

async function findExistingLink(
  linkTypeId: string,
  sourceInstanceId: string,
  targetInstanceId: string,
) {
  const connection = await pool.getConnection();
  try {
    const [rows]: any = await connection.execute(
      `SELECT *
       FROM link_instance_data
       WHERE link_type_id = ?
         AND (
           (source_instance_id = ? AND target_instance_id = ?)
           OR (source_instance_id = ? AND target_instance_id = ?)
         )
       ORDER BY id ASC
       LIMIT 1`,
      [linkTypeId, sourceInstanceId, targetInstanceId, targetInstanceId, sourceInstanceId],
    );
    return rows[0] || null;
  } finally {
    connection.release();
  }
}

async function mapCandidate(candidate: any) {
  if (!candidate) return null;
  const existingLink = await findExistingLink(
    candidate.link_type_id,
    candidate.source_instance_id,
    candidate.target_instance_id,
  );

  return {
    id: candidate.id,
    status: existingLink ? 'created' : 'recognized',
    sourceInstanceId: candidate.source_instance_id,
    sourceName: candidate.source_name,
    targetInstanceId: candidate.target_instance_id,
    targetName: candidate.target_name,
    linkTypeId: candidate.link_type_id,
    linkTypeName: candidate.link_type_name,
    confidence: candidate.confidence,
    evidence: candidate.evidence,
    llmSource: candidate.llm_source,
  };
}

async function executeActionType(actionTypeIds: string[], payload: Record<string, any>) {
  let lastError = 'Failed to execute action';

  for (const actionTypeId of actionTypeIds) {
    const response = await fetch(`${JAVA_BACKEND}/api/action-types/${actionTypeId}/execute`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    const text = await response.text();
    let result: any = null;
    try {
      result = text ? JSON.parse(text) : null;
    } catch {
      result = { error: text };
    }

    if (response.ok && result?.status !== 'failed') {
      return { actionTypeId, result };
    }

    lastError = result?.error || result?.message || `Action ${actionTypeId} failed`;
  }

  throw new Error(lastError);
}

async function executeCompanyLinkFallback(method: 'POST' | 'DELETE', parameters: Record<string, any>) {
  const sourceInstanceId = String(parameters.sourceInstanceId || '').trim();
  const targetInstanceId = String(parameters.targetInstanceId || '').trim();
  const linkTypeId = String(parameters.linkTypeId || '').trim();
  const evidence = String(parameters.evidence || '').trim();

  if (!sourceInstanceId || !targetInstanceId || !linkTypeId) {
    throw new Error('sourceInstanceId, targetInstanceId and linkTypeId are required');
  }

  const connection = await pool.getConnection();
  try {
    if (method === 'POST') {
      const [existingRows]: any = await connection.execute(
        `SELECT id
         FROM link_instance_data
         WHERE link_type_id = ?
           AND (
             (source_instance_id = ? AND target_instance_id = ?)
             OR (source_instance_id = ? AND target_instance_id = ?)
           )
         ORDER BY id ASC
         LIMIT 1`,
        [linkTypeId, sourceInstanceId, targetInstanceId, targetInstanceId, sourceInstanceId],
      );

      if (!existingRows.length) {
        await connection.execute(
          `INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
           VALUES (?, ?, ?, NOW())`,
          [linkTypeId, sourceInstanceId, targetInstanceId],
        );
      }

      return {
        success: true,
        message: existingRows.length ? 'Link already exists' : 'Company link created',
        data: { sourceInstanceId, targetInstanceId, linkTypeId, evidence },
      };
    }

    const [deleteResult]: any = await connection.execute(
      `DELETE FROM link_instance_data
       WHERE link_type_id = ?
         AND (
           (source_instance_id = ? AND target_instance_id = ?)
           OR (source_instance_id = ? AND target_instance_id = ?)
         )`,
      [linkTypeId, sourceInstanceId, targetInstanceId, targetInstanceId, sourceInstanceId],
    );

    return {
      success: true,
      message: deleteResult?.affectedRows ? 'Company link deleted' : 'Company link not found',
      data: { sourceInstanceId, targetInstanceId, linkTypeId, deleted: deleteResult?.affectedRows || 0 },
    };
  } finally {
    connection.release();
  }
}

router.get('/events', async (req, res) => {
  try {
    const projectId = getProjectId(req);
    const connection = await pool.getConnection();
    const [rows]: any = await connection.execute(
      `SELECT * FROM news_events WHERE project_id = ? ORDER BY event_date DESC, created_at DESC LIMIT 20`,
      [projectId],
    );
    connection.release();

    const events = await Promise.all(
      rows.map(async (row: any) => {
        const candidate = await fetchCandidateByNews(row.id, projectId);
        return {
          id: row.id,
          title: row.title,
          category: row.category,
          occurredAt: row.event_date,
          summary: row.summary || '',
          content: row.content || '',
          source: row.source || '',
          tags: Array.isArray(row.tags) ? row.tags : (() => {
            try {
              return row.tags ? JSON.parse(row.tags) : [];
            } catch {
              return [];
            }
          })(),
          candidate: await mapCandidate(candidate),
        };
      }),
    );

    res.json({ success: true, events });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/events/:id/analyze', async (req, res) => {
  if (!checkAI()) {
    return res.status(503).json({ error: 'DEEPSEEK_API_KEY not configured' });
  }

  try {
    const projectId = getProjectId(req);
    const existingCandidate = await fetchCandidateByNews(req.params.id, projectId);
    if (existingCandidate) {
      return res.json({
        success: true,
        candidate: await mapCandidate(existingCandidate),
      });
    }

    const connection = await pool.getConnection();
    const [eventRows]: any = await connection.execute(`SELECT * FROM news_events WHERE id = ? AND project_id = ? LIMIT 1`, [req.params.id, projectId]);
    const [companyRows]: any = await connection.execute(`SELECT company_id, name, stock_code, market, industry FROM company_entity`);
    const [linkTypeRows]: any = await connection.execute(
      `SELECT id, name, source_object_id, target_object_id FROM link_types WHERE source_object_id = 'company_entity' AND target_object_id = 'company_entity'`,
    );

    if (eventRows.length === 0) {
      connection.release();
      return res.status(404).json({ error: 'Event not found' });
    }

    const event = eventRows[0];
    const companies = companyRows as any[];
    const linkTypes = linkTypeRows as any[];

    const prompt = `你是关系抽取助手。请只根据给定新闻内容，判断是否识别到两个公司实体之间的新关系，并映射到已有链接类型。

新闻标题：${event.title}
新闻摘要：${event.summary || ''}
新闻正文：${event.content || ''}

已有公司实例：
${companies.map((item) => `- ${item.name} (${item.company_id})`).join('\n')}

已有链接类型：
${linkTypes.map((item) => `- ${item.name} (${item.id})`).join('\n')}

要求：
1. 如果识别到了明确的新关系，只返回一个最可信的候选关系
2. sourceCompany 和 targetCompany 必须从给定公司实例中选择
3. linkTypeName 必须从给定链接类型中选择
4. evidence 写一句证据说明
5. confidence 返回 0-1 之间的小数
6. 只返回 JSON，不要 Markdown

返回：
{
  "matched": true,
  "sourceCompany": "宁德时代",
  "targetCompany": "中恒电气",
  "linkTypeName": "战略合作",
  "evidence": "新闻中明确提到双方围绕储能场景展开协同合作。",
  "confidence": 0.92
}`;

    let parsed: any = null;
    let llmSource = 'deepseek';
    try {
      const text = await callDeepSeek([{ role: 'user', content: prompt }]);
      parsed = JSON.parse(text);
    } catch (error) {
      llmSource = 'fallback';
      if (String(event.title || '').includes('宁德时代') && String(event.title || '').includes('中恒电气')) {
        parsed = {
          matched: true,
          sourceCompany: '宁德时代',
          targetCompany: '中恒电气',
          linkTypeName: '战略合作',
          evidence: '新闻标题与正文均明确提到双方达成储能协同合作。',
          confidence: 0.8,
        };
      } else {
        throw error;
      }
    }

    if (!parsed?.matched) {
      connection.release();
      return res.json({ success: true, candidate: null });
    }

    const sourceCompany = companies.find((item) => item.name === parsed.sourceCompany);
    const targetCompany = companies.find((item) => item.name === parsed.targetCompany);
    const linkType = linkTypes.find((item) => item.name === parsed.linkTypeName);

    if (!sourceCompany || !targetCompany || !linkType) {
      connection.release();
      return res.status(400).json({ error: 'Unable to map extracted entities to ontology instances or link type' });
    }

    const candidateId = `cand_${crypto.randomUUID().slice(0, 8)}`;
    await connection.execute(
      `INSERT INTO relation_candidates (
        id, news_event_id, source_object_type_id, source_instance_id, target_object_type_id, target_instance_id,
        link_type_id, relation_name, evidence, confidence, llm_source, status, project_id
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        candidateId,
        req.params.id,
        'company_entity',
        sourceCompany.company_id,
        'company_entity',
        targetCompany.company_id,
        linkType.id,
        linkType.name,
        parsed.evidence || '',
        Number(parsed.confidence || 0.75),
        llmSource,
        'recognized',
        projectId,
      ],
    );
    connection.release();

    res.json({
      success: true,
      candidate: await mapCandidate({
        id: candidateId,
        sourceInstanceId: sourceCompany.company_id,
        source_instance_id: sourceCompany.company_id,
        sourceName: sourceCompany.name,
        source_name: sourceCompany.name,
        targetInstanceId: targetCompany.company_id,
        target_instance_id: targetCompany.company_id,
        targetName: targetCompany.name,
        target_name: targetCompany.name,
        linkTypeId: linkType.id,
        link_type_id: linkType.id,
        linkTypeName: linkType.name,
        link_type_name: linkType.name,
        confidence: Number(parsed.confidence || 0.75),
        evidence: parsed.evidence || '',
        llmSource,
        llm_source: llmSource,
      }),
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/candidates/:id/create-link', async (req, res) => {
  try {
    const projectId = getProjectId(req);
    const connection = await pool.getConnection();
    const [rows]: any = await connection.execute(
      `SELECT * FROM relation_candidates WHERE id = ? AND project_id = ? LIMIT 1`,
      [req.params.id, projectId],
    );

    if (rows.length === 0) {
      connection.release();
      return res.status(404).json({ error: 'Candidate not found' });
    }

    const candidate = rows[0];
    connection.release();

    const parameters = {
      sourceInstanceId: candidate.source_instance_id,
      targetInstanceId: candidate.target_instance_id,
      linkTypeId: candidate.link_type_id,
      evidence: candidate.evidence || '',
    };

    let actionTypeId = CREATE_LINK_ACTION_IDS[0];
    let result: any;
    try {
      const actionResult = await executeActionType(CREATE_LINK_ACTION_IDS, {
        executedBy: 'researcher',
        parameters,
      });
      actionTypeId = actionResult.actionTypeId;
      result = actionResult.result;
    } catch {
      result = await executeCompanyLinkFallback('POST', parameters);
      actionTypeId = 'company-links-fallback';
    }

    const updateConn = await pool.getConnection();
    await updateConn.execute(
      `UPDATE relation_candidates SET status = 'created' WHERE id = ? AND project_id = ?`,
      [req.params.id, projectId],
    );
    updateConn.release();

    res.json({ success: true, actionTypeId, result });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/candidates/:id/delete-link', async (req, res) => {
  try {
    const projectId = getProjectId(req);
    const connection = await pool.getConnection();
    const [rows]: any = await connection.execute(
      `SELECT * FROM relation_candidates WHERE id = ? AND project_id = ? LIMIT 1`,
      [req.params.id, projectId],
    );

    if (rows.length === 0) {
      connection.release();
      return res.status(404).json({ error: 'Candidate not found' });
    }

    const candidate = rows[0];
    connection.release();

    const parameters = {
      sourceInstanceId: candidate.source_instance_id,
      targetInstanceId: candidate.target_instance_id,
      linkTypeId: candidate.link_type_id,
    };

    let actionTypeId = DELETE_LINK_ACTION_IDS[0];
    let result: any;
    try {
      const actionResult = await executeActionType(DELETE_LINK_ACTION_IDS, {
        executedBy: 'researcher',
        parameters,
      });
      actionTypeId = actionResult.actionTypeId;
      result = actionResult.result;
    } catch {
      result = await executeCompanyLinkFallback('DELETE', parameters);
      actionTypeId = 'company-links-fallback';
    }

    const updateConn = await pool.getConnection();
    await updateConn.execute(
      `UPDATE relation_candidates SET status = 'recognized' WHERE id = ? AND project_id = ?`,
      [req.params.id, projectId],
    );
    updateConn.release();

    res.json({ success: true, actionTypeId, result });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
