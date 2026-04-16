import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Button } from '@/src/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/src/components/ui/dialog';
import { toast } from 'sonner';
import demoGraph from '@/src/data/demoEnhancedGraph.json';

type RawInstanceRelation = {
  target_name?: string;
  target_comcode?: string;
  target_entity_id?: string;
  link_type?: string;
  status?: string;
  writeback_status?: string;
};

type RawCompany = {
  name: string;
  comcode?: string;
  type?: string;
  entity_id?: string;
  role?: string;
  instance_relations?: RawInstanceRelation[];
};

type RawRelation = {
  to_node_code?: string;
  to_node_name?: string;
  relation_type?: string;
  direction?: string;
  weight?: number;
  impact_logic?: string;
};

type RawNode = {
  name: string;
  node_code?: string;
  level?: number;
  position?: string;
  children?: RawNode[];
  company?: RawCompany[];
  relations?: RawRelation[];
};

type DemoNode = {
  id: string;
  name: string;
  nodeCode?: string;
  level?: number;
  position?: string;
  path: string[];
  companies: RawCompany[];
  relations: RawRelation[];
  children: DemoNode[];
};

type DemoInstanceRelation = RawInstanceRelation & {
  sourceName: string;
  sourceType: string;
};

type SankeyNode = {
  id: string;
  label: string;
  typeLabel: string;
  instances: string[];
  x: number;
  y: number;
  width: number;
  height: number;
  fill: string;
  stroke: string;
  meta?: string;
  status?: string;
  showInstancesInNode?: boolean;
};

type SankeyLink = {
  source: string;
  target: string;
  label: string;
  value: number;
  color: string;
  dashed?: boolean;
  annotation?: string;
  annotationDx?: number;
};

type SankeyScene = {
  title: string;
  subtitle?: string;
  width: number;
  height: number;
  nodes: SankeyNode[];
  links: SankeyLink[];
  note?: string;
};

type DemoScenario =
  | { kind: 'center-expansion'; title: string; scene: SankeyScene }
  | { kind: 'layered-chain'; title: string; scene: SankeyScene }
  | { kind: 'relation-discovery'; title: string; scene: SankeyScene };

type RelationCandidate = {
  id: string;
  status: string;
  sourceName: string;
  targetName: string;
  linkTypeName: string;
  evidence?: string;
};

const NODE_WIDTH = 120;
const NODE_HEIGHT = 48;

function normalize(value: string) {
  return String(value || '')
    .replace(/\s+/g, '')
    .replace(/[：:，,。.!！？?（）()【】\[\]-]/g, '')
    .toLowerCase();
}

function safeArray<T>(value: unknown): T[] {
  return Array.isArray(value) ? (value as T[]) : [];
}

function countVisibleChars(text: string) {
  return Array.from(String(text || '').replace(/\s+/g, '')).length;
}

function wrapText(text: string, maxChars = 8, maxLines = 2) {
  const chars = Array.from(String(text || '').trim());
  if (chars.length <= maxChars) return [chars.join('')];
  const lines: string[] = [];
  while (chars.length > 0 && lines.length < maxLines) {
    lines.push(chars.splice(0, maxChars).join(''));
  }
  if (chars.length > 0 && lines.length > 0) {
    lines[lines.length - 1] += '...';
  }
  return lines;
}

function cleanName(name: string) {
  return String(name || '').replace(/-[A-Z0-9]+-\d{4}/g, '');
}

function estimateNodeHeight(label: string, typeLabel: string, meta?: string, showInstancesInNode = false) {
  const labelLines = Math.max(1, Math.ceil(countVisibleChars(label) / 8));
  const typeLines = Math.max(1, Math.ceil(countVisibleChars(typeLabel) / 14));
  const metaLines = meta ? 1 : 0;
  const instanceLines = showInstancesInNode ? 1 : 0;

  return Math.max(
    76,
    24 + labelLines * 18 + typeLines * 14 + metaLines * 14 + instanceLines * 16 + 18,
  );
}

function collectTree(nodes: RawNode[], parentPath: string[] = []): DemoNode[] {
  return nodes.map((node) => {
    const path = [...parentPath, node.name];
    const id = node.node_code || path.join('>');
    return {
      id,
      name: node.name,
      nodeCode: node.node_code,
      level: node.level,
      position: node.position,
      path,
      companies: safeArray<RawCompany>(node.company),
      relations: safeArray<RawRelation>(node.relations),
      children: collectTree(safeArray<RawNode>(node.children), path),
    };
  });
}

function flattenTree(nodes: DemoNode[]): DemoNode[] {
  return nodes.flatMap((node) => [node, ...flattenTree(node.children)]);
}

const graphTree = collectTree((demoGraph as { nodes: RawNode[] }).nodes || []);
const graphFlat = flattenTree(graphTree);
const nodeByName = new Map(graphFlat.map((node) => [normalize(node.name), node]));
const nodeByCode = new Map(
  graphFlat.filter((node) => node.nodeCode).map((node) => [normalize(node.nodeCode || ''), node]),
);

function findNode(name: string) {
  return nodeByName.get(normalize(name)) || null;
}

function findNodeByCode(code?: string) {
  if (!code) return null;
  return nodeByCode.get(normalize(code)) || null;
}

function collectCompanies(node: DemoNode, limit = 4) {
  const companies = new Map<string, RawCompany>();
  const addCompany = (company: RawCompany) => {
    if (!companies.has(normalize(company.name))) {
      companies.set(normalize(company.name), company);
    }
  };
  node.companies.forEach(addCompany);
  node.children.forEach((child) => {
    collectCompanies(child, limit).forEach(addCompany);
  });
  return Array.from(companies.values()).slice(0, limit);
}

function collectInstanceRelations(node: DemoNode): DemoInstanceRelation[] {
  const relations: DemoInstanceRelation[] = [];
  node.companies.forEach((company) => {
    (company.instance_relations || []).forEach((relation) => {
      relations.push({
        ...relation,
        sourceName: company.name,
        sourceType: node.name,
      });
    });
  });
  node.children.forEach((child) => {
    relations.push(...collectInstanceRelations(child));
  });
  return relations;
}

function findRelationLabel(source: DemoNode, targetName: string) {
  const target = findNode(targetName);
  const relation = source.relations.find((item) => {
    if (item.to_node_name && normalize(item.to_node_name) === normalize(targetName)) return true;
    if (item.to_node_code && normalize(item.to_node_code) === normalize(target?.nodeCode || '')) return true;
    return false;
  });
  return relation?.relation_type || '关联';
}

function makeSankeyNode(
  node: Omit<SankeyNode, 'height'> & { height?: number },
): SankeyNode {
  const originalWidth = node.width ?? NODE_WIDTH;
  const originalHeight = node.height ?? estimateNodeHeight(node.label, node.typeLabel, node.meta, node.showInstancesInNode);
  return {
    ...node,
    x: node.x + originalWidth / 2,
    y: node.y + originalHeight / 2,
    width: NODE_WIDTH,
    height: NODE_HEIGHT,
  };
}

function makeLink(
  source: string,
  target: string,
  label: string,
  value = 1,
  color = '#2563eb',
  dashed = false,
  annotation?: string,
  annotationDx = 0,
): SankeyLink {
  return { source, target, label, value, color, dashed, annotation, annotationDx };
}

function flowPath(source: SankeyNode, target: SankeyNode, bend = 0.55) {
  const x1 = source.x + NODE_WIDTH / 2;
  const y1 = source.y;
  const x2 = target.x - NODE_WIDTH / 2;
  const y2 = target.y;
  const dx = x2 - x1;
  const controlOffset = dx * (bend === 0.55 ? 0.4 : bend);
  const c1x = x1 + controlOffset;
  const c2x = x2 - controlOffset;
  return `M ${x1} ${y1} C ${c1x} ${y1}, ${c2x} ${y2}, ${x2} ${y2}`;
}

function renderNode(
  node: SankeyNode,
  onRelationStatusClick?: () => void,
  relationStatusLabel?: string,
) {
  const labelLines = wrapText(cleanName(node.label), node.id === 'event' ? 10 : 8, 2);
  const typeLines = wrapText(node.typeLabel, 14, 1);

  const boxX = node.x - NODE_WIDTH / 2;
  const boxY = node.y - NODE_HEIGHT / 2;
  const titleY = node.y - 4;
  const typeStartY = node.y + 15;

  return (
    <g key={node.id}>
      <rect
        x={boxX}
        y={boxY}
        width={NODE_WIDTH}
        height={NODE_HEIGHT}
        rx={12}
        fill="#ffffff"
        stroke={node.stroke}
        strokeWidth={2}
        filter="url(#nodeShadow)"
      />

      <text x={node.x} y={titleY} textAnchor="middle" fontSize="14" fontWeight={700} fill="#0f172a">
        {labelLines.map((line, index) => (
          <tspan key={`${node.id}-label-${index}`} x={node.x} dy={index === 0 ? 0 : 16}>
            {line}
          </tspan>
        ))}
      </text>

      <text x={node.x} y={typeStartY} textAnchor="middle" fontSize="10.5" fill="#64748b">
        {typeLines.map((line, index) => (
          <tspan key={`${node.id}-type-${index}`} x={node.x} dy={index === 0 ? 0 : 14}>
            {line}
          </tspan>
        ))}
      </text>

      {node.status ? (
        node.id === 'relation' && onRelationStatusClick ? (
          <text
            x={boxX + NODE_WIDTH - 10}
            y={boxY + 16}
            textAnchor="end"
            fontSize="10.5"
            fill="#b45309"
            style={{ cursor: 'pointer' }}
            onClick={(event) => {
              event.stopPropagation();
              onRelationStatusClick();
            }}
          >
            {relationStatusLabel || node.status}
          </text>
        ) : (
          <text x={boxX + NODE_WIDTH - 10} y={boxY + 16} textAnchor="end" fontSize="10.5" fill="#b45309">
            {node.status}
          </text>
        )
      ) : null}
    </g>
  );
}

function renderLink(link: SankeyLink, source: SankeyNode, target: SankeyNode) {
  const x1 = source.x + NODE_WIDTH / 2;
  const y1 = source.y;
  const x2 = target.x - NODE_WIDTH / 2;
  const y2 = target.y;
  const x = (x1 + x2) / 2;
  const y = (y1 + y2) / 2;
  return (
    <g key={`${link.source}->${link.target}-${link.label}`}>
      <path
        d={flowPath(source, target)}
        stroke={link.color}
        strokeWidth={12}
        fill="none"
        strokeLinecap="round"
        opacity={0.15}
        strokeDasharray={link.dashed ? '8 6' : undefined}
      />
      <path
        d={flowPath(source, target)}
        stroke={link.color}
        strokeWidth={2}
        fill="none"
        strokeLinecap="round"
        opacity={0.8}
        strokeDasharray={link.dashed ? '8 6' : undefined}
      />
      {link.annotation ? (
        <text
          x={x + (link.annotationDx || 0)}
          y={y + 12}
          textAnchor="middle"
          fontSize="10.5"
          fontWeight={700}
          fill={link.color}
        >
          {link.annotation}
        </text>
      ) : null}
    </g>
  );
}

function buildScenario(eventTitle: string): DemoScenario | null {
  const title = normalize(eventTitle);

  if (title.includes('充电基础设施') || title.includes('充电桩')) {
    const center = findNode('充电桩');
    const upstream = ['充电桩制造', '连接器', '线束/连接器', '电芯'].map(findNode).filter(Boolean) as DemoNode[];
    const downstream = ['充电桩运营', '新能源整车'].map(findNode).filter(Boolean) as DemoNode[];
    if (!center) return null;

    const nodes: SankeyNode[] = [
      makeSankeyNode({
        id: 'event',
        label: '政策支持充电基础设施建设',
        typeLabel: '事件输入',
        instances: ['热点新闻'],
        x: 24,
        y: 165,
        width: 210,
        fill: '#eef2ff',
        stroke: '#6366f1',
      }),
      makeSankeyNode({
        id: center.id,
        label: center.name,
        typeLabel: '核心命中节点',
        instances: collectCompanies(center, 6).map((company) => company.name),
        x: 270,
        y: 165,
        width: 190,
        fill: '#ecfeff',
        stroke: '#06b6d4',
        showInstancesInNode: false,
      }),
      ...upstream.map((node, index) =>
        makeSankeyNode({
          id: node.id,
          label: node.name,
          typeLabel: `上游层级 ${index + 1}`,
          instances: collectCompanies(node, 4).map((company) => company.name),
          x: 520 + index * 150,
          y: 72 + index * 44,
          width: 150,
          fill: '#ffffff',
          stroke: '#93c5fd',
          showInstancesInNode: false,
        }),
      ),
      ...downstream.map((node, index) =>
        makeSankeyNode({
          id: node.id,
          label: node.name,
          typeLabel: `下游层级 ${index + 1}`,
          instances: collectCompanies(node, 4).map((company) => company.name),
          x: 520 + index * 150,
          y: 285 + index * 48,
          width: 150,
          fill: '#ffffff',
          stroke: '#86efac',
          showInstancesInNode: false,
        }),
      ),
    ];

    const links: SankeyLink[] = [
      makeLink('event', center.id, '命中充电桩', 1.1, '#6366f1'),
      makeLink(center.id, upstream[0]?.id || center.id, findRelationLabel(center, upstream[0]?.name || ''), 1, '#22c55e'),
      makeLink(upstream[0]?.id || center.id, upstream[1]?.id || center.id, findRelationLabel(upstream[0] || center, upstream[1]?.name || ''), 0.92, '#22c55e'),
      makeLink(upstream[1]?.id || center.id, upstream[2]?.id || center.id, findRelationLabel(upstream[1] || center, upstream[2]?.name || ''), 0.88, '#22c55e'),
      makeLink(upstream[2]?.id || center.id, upstream[3]?.id || center.id, findRelationLabel(upstream[2] || center, upstream[3]?.name || ''), 0.82, '#22c55e'),
      makeLink(center.id, downstream[0]?.id || center.id, findRelationLabel(center, downstream[0]?.name || ''), 1, '#16a34a'),
      makeLink(downstream[0]?.id || center.id, downstream[1]?.id || center.id, findRelationLabel(downstream[0] || center, downstream[1]?.name || ''), 0.85, '#16a34a'),
    ];

    return {
      kind: 'center-expansion',
      title: '政策支持充电基础设施建设',
      scene: {
        title: '中心扩散桑基图',
        subtitle: '事件命中“充电桩”，通过点击节点在下方查看挂载公司',
        width: 1150,
        height: 420,
        nodes,
        links,
      },
    };
  }

  if (title.includes('碳酸锂') || title.includes('价格持续下探')) {
    const layer1 = findNode('碳酸锂');
    const layer2A = findNode('正极材料');
    const layer2B = findNode('电池电解液');
    const layer3 = findNode('电芯');
    const layer4 = findNode('电池');
    const layer5 = findNode('新能源整车');
    if (!layer1 || !layer2A || !layer2B || !layer3 || !layer4 || !layer5) return null;

    const nodes: SankeyNode[] = [
      makeSankeyNode({
        id: 'event',
        label: '碳酸锂价格持续下探',
        typeLabel: '商品价格事件',
        instances: ['价格信号'],
        x: 20,
        y: 168,
        width: 200,
        fill: '#eef2ff',
        stroke: '#6366f1',
        showInstancesInNode: false,
      }),
      makeSankeyNode({
        id: layer1.id,
        label: layer1.name,
        typeLabel: 'L1 / 原材料',
        instances: ['赣锋锂业', '天齐锂业'],
        x: 250,
        y: 162,
        width: 170,
        fill: '#f0fdf4',
        stroke: '#22c55e',
        meta: '原材料层',
      }),
      makeSankeyNode({
        id: layer2A.id,
        label: layer2A.name,
        typeLabel: 'L2 / 正极材料',
        instances: ['德方纳米', '容百科技'],
        x: 470,
        y: 80,
        width: 170,
        fill: '#fff7ed',
        stroke: '#fb923c',
        meta: '上游组件层',
      }),
      makeSankeyNode({
        id: layer2B.id,
        label: layer2B.name,
        typeLabel: 'L2 / 电池电解液',
        instances: ['天赐材料', '新宙邦'],
        x: 470,
        y: 242,
        width: 170,
        fill: '#fff7ed',
        stroke: '#fb923c',
        meta: '上游组件层',
      }),
      makeSankeyNode({
        id: layer3.id,
        label: layer3.name,
        typeLabel: 'L3 / 电芯',
        instances: ['亿纬锂能', '国轩高科'],
        x: 690,
        y: 162,
        width: 170,
        fill: '#ecfeff',
        stroke: '#14b8a6',
        meta: '成本传导层',
      }),
      makeSankeyNode({
        id: layer4.id,
        label: layer4.name,
        typeLabel: 'L4 / 电池',
        instances: ['宁德时代', '比亚迪弗迪电池'],
        x: 910,
        y: 162,
        width: 180,
        fill: '#f5f3ff',
        stroke: '#8b5cf6',
        meta: '成本传导层',
      }),
      makeSankeyNode({
        id: layer5.id,
        label: layer5.name,
        typeLabel: 'L5 / 新能源整车',
        instances: ['比亚迪', '理想汽车', '蔚来汽车', '小鹏汽车'],
        x: 1140,
        y: 162,
        width: 190,
        fill: '#f0fdf4',
        stroke: '#22c55e',
        meta: '终端收口',
      }),
    ];

    const links: SankeyLink[] = [
      makeLink('event', layer1.id, 'L1', 1.1, '#6366f1'),
      makeLink(layer1.id, layer2A.id, findRelationLabel(layer1, layer2A.name), 0.95, '#22c55e', false, '传导强度：0.5', -32),
      makeLink(layer1.id, layer2B.id, findRelationLabel(layer1, layer2B.name), 0.95, '#22c55e'),
      makeLink(layer2A.id, layer3.id, findRelationLabel(layer2A, layer3.name), 0.9, '#0ea5e9'),
      makeLink(layer2B.id, layer3.id, findRelationLabel(layer2B, layer3.name), 0.9, '#0ea5e9'),
      makeLink(layer3.id, layer4.id, findRelationLabel(layer3, layer4.name), 0.85, '#8b5cf6'),
      makeLink(layer4.id, layer5.id, findRelationLabel(layer4, layer5.name), 0.8, '#16a34a'),
    ];

    return {
      kind: 'layered-chain',
      title: '碳酸锂价格持续下探',
      scene: {
        title: '分层链路桑基图',
        subtitle: '按 L1-L5 展示价格传导链，点击节点后在下方查看挂载公司',
        width: 1360,
        height: 410,
        nodes,
        links,
      },
    };
  }

  if (title.includes('宁德时代') || title.includes('中恒电气') || title.includes('战略合作')) {
    const electricCell = findNode('电芯');
    const ct = electricCell?.companies.find((company) => normalize(company.name) === normalize('宁德时代')) || null;
    const relation = electricCell
      ? collectInstanceRelations(electricCell).find((item) => {
          return normalize(item.sourceName) === normalize('宁德时代') && normalize(item.target_name || '') === normalize('中恒电气');
        })
      : null;
    if (!electricCell || !ct || !relation) return null;

    const nodes: SankeyNode[] = [
      makeSankeyNode({
        id: 'left',
        label: '宁德时代',
        typeLabel: '公司实例',
        instances: ['宁德时代'],
        x: 60,
        y: 150,
        width: 190,
        fill: '#eff6ff',
        stroke: '#3b82f6',
        showInstancesInNode: false,
      }),
      makeSankeyNode({
        id: 'relation',
        label: '战略合作',
        typeLabel: '新增关系',
        instances: ['NEW'],
        x: 320,
        y: 146,
        width: 200,
        fill: '#fffbeb',
        stroke: '#f59e0b',
        meta: relation.status || 'NEW',
        showInstancesInNode: false,
      }),
      makeSankeyNode({
        id: 'right',
        label: '中恒电气',
        typeLabel: '公司实例',
        instances: ['中恒电气'],
        x: 590,
        y: 150,
        width: 190,
        fill: '#f8fafc',
        stroke: '#64748b',
        showInstancesInNode: false,
      }),
    ];

    const links: SankeyLink[] = [
      makeLink('left', 'relation', '战略合作', 1.15, '#f59e0b', true),
      makeLink('relation', 'right', '战略合作', 1.05, '#f59e0b', true),
    ];

    return {
      kind: 'relation-discovery',
      title: '宁德时代 / 中恒电气 / 战略合作',
      scene: {
        title: '关系发现桑基图',
        subtitle: '新增关系直接写在节点中，不展开复杂传播链',
        width: 840,
        height: 360,
        nodes,
        links,
      },
    };
  }

  return null;
}

function SankeySceneView({
  scene,
  relationCandidate,
  creatingLink,
  onCreateLink,
}: {
  scene: SankeyScene;
  relationCandidate?: RelationCandidate | null;
  creatingLink?: boolean;
  onCreateLink?: () => Promise<void> | void;
}) {
  const nodeMap = useMemo(() => new Map(scene.nodes.map((node) => [node.id, node])), [scene.nodes]);
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(scene.nodes[0]?.id || null);
  const [viewportWidth, setViewportWidth] = useState(0);
  const [relationDialogOpen, setRelationDialogOpen] = useState(false);
  const viewportRef = useRef<HTMLDivElement | null>(null);

  const relationWritebackLabel =
    relationCandidate?.status === 'created'
      ? '已创建'
      : relationCandidate?.status === 'recognized'
        ? '识别到新关系'
        : '待识别';
  const relationActionVerb = relationCandidate?.status === 'created' ? '删除链接' : '创建链接';
  const relationActionPastVerb = relationCandidate?.status === 'created' ? '删除' : '创建';

  useEffect(() => {
    setSelectedNodeId(scene.nodes[0]?.id || null);
    setRelationDialogOpen(false);
  }, [scene]);

  useEffect(() => {
    const element = viewportRef.current;
    if (!element) return;
    const observer = new ResizeObserver((entries) => {
      const entry = entries[0];
      if (!entry) return;
      setViewportWidth(entry.contentRect.width);
    });
    observer.observe(element);
    return () => observer.disconnect();
  }, []);

  const selectedNode = selectedNodeId ? nodeMap.get(selectedNodeId) || null : null;
  const selectedCompanies = selectedNode?.instances || [];
  const showInstancesPanel = selectedNode?.typeLabel !== '新增关系';
  const showRelationDetail = selectedNode?.id === 'relation';

  const paddingX = 36;
  const paddingY = 24;
  const contentWidth = scene.width + paddingX * 2;
  const contentHeight = scene.height + paddingY * 2;

  const containerWidth = Math.max(320, viewportWidth || 960);
  const scale = Math.min(1, containerWidth / contentWidth);
  const displayHeight = Math.max(360, Math.round(contentHeight * scale));
  const showCreateLinkAction = scene.nodes.some((node) => node.id === 'relation') && !!relationCandidate;

  return (
    <div className="space-y-4">
      <div className="rounded-3xl border border-slate-200 bg-white p-4 shadow-sm">
        {showCreateLinkAction ? (
          <div className="mb-3 flex justify-end">
            <Button variant="outline" size="sm" onClick={() => setRelationDialogOpen(true)}>
              {`执行动作：${relationActionVerb}`}
            </Button>
          </div>
        ) : null}
        <div ref={viewportRef} className="rounded-[22px] bg-[#f4f7f9] p-3">
          <div className="w-full">
            <svg
              width="100%"
              height={displayHeight}
              viewBox={`0 0 ${contentWidth} ${contentHeight}`}
              preserveAspectRatio="xMidYMid meet"
            >
              <defs>
                <filter id="nodeShadow" x="-20%" y="-20%" width="140%" height="140%">
                  <feDropShadow dx="0" dy="6" stdDeviation="7" floodColor="#0f172a" floodOpacity="0.08" />
                </filter>
              </defs>

              <rect x={0} y={0} width={contentWidth} height={contentHeight} fill="transparent" />

              <g transform={`translate(${paddingX}, ${paddingY})`}>
                {scene.links.map((link) => {
                  const source = nodeMap.get(link.source);
                  const target = nodeMap.get(link.target);
                  if (!source || !target) return null;
                  return renderLink(link, source, target);
                })}

                {scene.nodes.map((node) => (
                  <g
                    key={node.id}
                    onClick={() => setSelectedNodeId(node.id)}
                    style={{ cursor: 'pointer' }}
                    opacity={selectedNodeId && selectedNodeId !== node.id ? 0.92 : 1}
                  >
                    <rect
                      x={node.x - NODE_WIDTH / 2 - 3}
                      y={node.y - NODE_HEIGHT / 2 - 3}
                      width={NODE_WIDTH + 6}
                      height={NODE_HEIGHT + 6}
                      rx={14}
                      fill={selectedNodeId === node.id ? '#f8fafc' : 'transparent'}
                      stroke={selectedNodeId === node.id ? '#94a3b8' : 'transparent'}
                      strokeWidth={1}
                    />
                    {renderNode(
                      node,
                      node.id === 'relation' ? () => setRelationDialogOpen(true) : undefined,
                      node.id === 'relation' ? relationWritebackLabel : undefined,
                    )}
                  </g>
                ))}
              </g>
            </svg>
          </div>
        </div>
      </div>

      {selectedNode ? (
        <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <div className="text-sm font-semibold text-slate-900">节点详情</div>
              <div className="mt-1 text-xs text-slate-500">点击节点后，在这里查看挂载实例与节点说明</div>
            </div>
            <div className="rounded-full border border-slate-200 px-3 py-1 text-xs text-slate-600">{selectedNode.typeLabel}</div>
          </div>

          <div className="mt-4 grid gap-4 lg:grid-cols-[1.2fr_1fr]">
            <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4">
              <div className="text-lg font-semibold text-slate-900">{cleanName(selectedNode.label)}</div>
              {selectedNode.meta ? <div className="mt-2 text-sm text-slate-500">{selectedNode.meta}</div> : null}
              {selectedNode.status ? (
                showRelationDetail ? (
                  <button
                    type="button"
                    onClick={() => setRelationDialogOpen(true)}
                    className="mt-2 text-sm font-medium text-amber-700 underline decoration-amber-400 decoration-dotted underline-offset-4 hover:text-amber-800"
                  >
                    {relationWritebackLabel}
                  </button>
                ) : (
                  <div className="mt-2 text-sm font-medium text-amber-700">{selectedNode.status}</div>
                )
              ) : null}
            </div>

            {showInstancesPanel ? (
              <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4">
                <div className="text-xs font-semibold uppercase tracking-wider text-slate-400">挂载公司</div>
                <div className="mt-2 flex flex-wrap gap-2">
                  {selectedCompanies.length > 0 ? (
                    selectedCompanies.map((name) => (
                      <span
                        key={`${selectedNode.id}-${name}`}
                        className="rounded-full bg-white px-3 py-1 text-sm text-slate-700 shadow-sm"
                      >
                        {name}
                      </span>
                    ))
                  ) : (
                    <span className="text-sm text-slate-500">暂无挂载公司</span>
                  )}
                </div>
              </div>
            ) : null}
          </div>
        </div>
      ) : null}

      <Dialog open={relationDialogOpen} onOpenChange={setRelationDialogOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>{`是否确定${relationActionVerb}`}</DialogTitle>
            <DialogDescription>
              {relationCandidate?.status === 'created'
                ? `当前将删除“${relationCandidate?.sourceName || '宁德时代'}”与“${relationCandidate?.targetName || '中恒电气'}”之间的“${relationCandidate?.linkTypeName || '战略合作'}”关系链接。`
                : `当前将为“${relationCandidate?.sourceName || '宁德时代'}”与“${relationCandidate?.targetName || '中恒电气'}”创建一条“${relationCandidate?.linkTypeName || '战略合作'}”关系链接。`}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="gap-2 sm:gap-2">
            <Button variant="ghost" onClick={() => setRelationDialogOpen(false)}>
              取消
            </Button>
            <Button
              disabled={creatingLink}
              onClick={async () => {
                if (!onCreateLink) return;
                try {
                  await onCreateLink();
                  setRelationDialogOpen(false);
                } catch (error: any) {
                  toast.error(error.message || `${relationActionVerb}失败`);
                }
              }}
            >
              {creatingLink ? `${relationActionVerb}中...` : `确定${relationActionVerb}`}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export function EventPropagationExplorer({
  eventTitle,
  relationCandidate,
  creatingLink,
  onCreateLink,
}: {
  eventTitle: string;
  relationCandidate?: RelationCandidate | null;
  creatingLink?: boolean;
  onCreateLink?: () => Promise<void> | void;
}) {
  const scenario = useMemo(() => buildScenario(eventTitle), [eventTitle]);

  if (!scenario) {
    return (
      <div className="rounded-2xl border border-dashed border-slate-300 bg-slate-50 p-6 text-sm text-slate-500">
        当前演示仅覆盖三类场景：充电基础设施、碳酸锂价格传导、宁德时代 / 中恒电气关系发现。
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <SankeySceneView
        scene={scenario.scene}
        relationCandidate={relationCandidate}
        creatingLink={creatingLink}
        onCreateLink={onCreateLink}
      />
    </div>
  );
}
