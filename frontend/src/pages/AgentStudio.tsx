import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  Activity,
  ArrowRight,
  Bot,
  Building2,
  ChevronDown,
  ChevronRight,
  ChevronUp,
  Clock,
  ExternalLink,
  FileText,
  Flame,
  Link as LinkIcon,
  Loader2,
  MessageSquare,
  Minus,
  Network,
  Play,
  Plus,
  RefreshCw,
  Search,
  Send,
  Sparkles,
  Square,
  Target,
  Database,
  ToggleLeft,
  ToggleRight,
  Trash2,
  TrendingDown,
  TrendingUp,
  Zap,
} from 'lucide-react';
import { Button } from '@/src/components/ui/button';
import { toast } from 'sonner';
import { api } from '@/src/api/client';
import { streamResearchChat } from '@/src/api/streamClient';
import { EventPropagationExplorer } from '@/src/components/EventPropagationExplorer';
import { cn } from '@/src/lib/utils';
import { searchStocks, StockItem } from '@/src/data/cnStocks';

const DEMO_LITHIUM_AGENT_ID = 'demo_agent_lithium';
const MANUAL_LITHIUM_BASE_PRICE = 12.55;

interface Agent {
  id: string;
  name: string;
  description: string;
  target_company: string;
  target_industry: string;
  analysis_focus: string;
  schedule_minutes: number;
  is_active: number;
  last_run_at: string | null;
  created_at: string;
  updated_at: string;
}

interface AgentEvent {
  id: string;
  agent_id: string;
  title: string;
  summary: string;
  source: string;
  source_url: string;
  event_date: string;
  impact_level: 'high' | 'medium' | 'low';
  related_entities: string[];
  created_at: string;
}

interface ImpactChainItem {
  from: string;
  to: string;
  mechanism: string;
  intensity: 'high' | 'medium' | 'low';
}

interface AgentAnalysis {
  id: string;
  agent_id: string;
  event_id: string | null;
  title: string;
  content: string;
  key_findings: string[];
  impact_chain: ImpactChainItem[];
  recommendation: string;
  created_at: string;
  transmissionData?: PriceTransmissionData;
  isTemporary?: boolean;
}

interface PriceTransmissionSource {
  objectTypeId: string;
  objectTypeName: string;
  previousPrice: number;
  latestPrice: number;
  priceChangePercent: number;
}

interface PriceTransmissionNode {
  id: string;
  name: string;
  subtitle: string;
  previousPrice: number;
  latestPrice: number;
  priceChangePercent: number;
  changePercent?: number;
  level: string;
  depth: number;
}

interface PriceTransmissionEdge {
  source: string;
  target: string;
  linkTypeId?: string;
  linkTypeName?: string;
  transmissionCoefficient?: number;
  coefficient: number;
  impactPercent?: number;
  label: string;
}

interface PriceTransmissionPath {
  objectTypeIds: string[];
  terminalLinkTypeId: string;
  terminalLinkTypeName: string;
  depth: number;
  transmissionCoefficient: number;
  depthDecay: number;
  impactPercent: number;
}

interface PriceTransmissionData {
  sourceObjectType: PriceTransmissionSource;
  nodes: PriceTransmissionNode[];
  edges: PriceTransmissionEdge[];
  paths?: PriceTransmissionPath[];
  summary: {
    objectTypeCount: number;
    edgeCount: number;
    pathCount?: number;
    depth: number;
    sourceObjectTypeId?: string;
    direction?: string;
  };
}

interface HotEventItem {
  id: string;
  title: string;
  category: string;
  occurredAt: string;
  summary: string;
  content?: string;
  source?: string;
  tags: string[];
  commentary: string;
  candidate?: {
    id: string;
    status: string;
    sourceInstanceId: string;
    sourceName: string;
    targetInstanceId: string;
    targetName: string;
    linkTypeId: string;
    linkTypeName: string;
    confidence?: number;
    evidence?: string;
    llmSource?: string;
  } | null;
}

type InsightSummaryItem = {
  label: string;
  value: string;
};

type InsightSection = {
  title: string;
  paragraphs: string[];
  bullets?: string[];
};

type EventInsightContent = {
  title: string;
  badge: string;
  conclusion: string;
  summaryItems: InsightSummaryItem[];
  sections: InsightSection[];
};

const impactColors = {
  high: 'bg-red-100 text-red-700 border-red-200',
  medium: 'bg-amber-100 text-amber-700 border-amber-200',
  low: 'bg-green-100 text-green-700 border-green-200',
};

const impactIcons = {
  high: TrendingUp,
  medium: Minus,
  low: TrendingDown,
};

const MOCK_AGENTS: Agent[] = [
  {
    id: 'demo_agent_lithium',
    name: '碳酸锂标的跟踪',
    description: '跟踪碳酸锂价格变化，并持续观察其向电解液、电芯和动力电池环节的成本传导。',
    target_company: '碳酸锂',
    target_industry: '锂电材料',
    analysis_focus: '价格波动、成本传导、电池链盈利压力',
    schedule_minutes: 120,
    is_active: 1,
    last_run_at: '2026-04-15 07:20:00',
    created_at: '2026-04-08 14:10:00',
    updated_at: '2026-04-15 07:20:00',
  },
  {
    id: 'demo_agent_byd',
    name: '比亚迪标的跟踪',
    description: '围绕新能源车价格战、海外出口、补能网络与供应链成本变化，跟踪比亚迪产业链的边际变化。',
    target_company: '比亚迪（002594.SZ）',
    target_industry: '新能源汽车',
    analysis_focus: '价格战持续性、出海节奏、充电生态协同',
    schedule_minutes: 60,
    is_active: 1,
    last_run_at: '2026-04-15 08:45:00',
    created_at: '2026-04-09 09:20:00',
    updated_at: '2026-04-15 08:45:00',
  },
];

const MOCK_EVENTS: Record<string, AgentEvent[]> = {
  demo_agent_byd: [
    {
      id: 'evt_byd_1',
      agent_id: 'demo_agent_byd',
      title: '政策支持充电基础设施建设',
      summary: '政策端继续强调充电基础设施建设和补能网络完善，市场关注其对充电运营、设备制造及整车消费渗透的带动效应。',
      source: '证券时报',
      source_url: 'https://example.com/news/charging-infra',
      event_date: '2026-04-15',
      impact_level: 'high',
      related_entities: ['比亚迪', '充电桩', '高压快充'],
      created_at: '2026-04-15 08:40:00',
    },
    {
      id: 'evt_byd_2',
      agent_id: 'demo_agent_byd',
      title: '新能源车价格战再起，行业利润承压',
      summary: '多家车企再度降价抢量，市场担心整车盈利能力和上游议价空间同步承压，部分零部件环节也面临价格传导压力。',
      source: '财联社',
      source_url: 'https://example.com/news/ev-price-war',
      event_date: '2026-04-14',
      impact_level: 'medium',
      related_entities: ['比亚迪', '整车', '零部件'],
      created_at: '2026-04-14 18:25:00',
    },
  ],
  demo_agent_lithium: [
    {
      id: 'evt_lithium_1',
      agent_id: 'demo_agent_lithium',
      title: '碳酸锂价格快速上涨',
      summary: '电池级碳酸锂价格单周上行约 25%，市场开始重新评估电解液、电芯与动力电池环节的成本承压与提价传导节奏。',
      source: '上海证券报',
      source_url: 'https://example.com/news/lithium-price',
      event_date: '2026-04-15',
      impact_level: 'high',
      related_entities: ['碳酸锂', '电池电解液', '电芯', '动力电池'],
      created_at: '2026-04-15 07:10:00',
    },
  ],
};

const MOCK_ANALYSES: Record<string, AgentAnalysis[]> = {
  demo_agent_byd: [
    {
      id: 'ana_byd_1',
      agent_id: 'demo_agent_byd',
      event_id: 'evt_byd_1',
      title: '充电基础设施加码带来的二阶需求扩散',
      content:
        '本轮政策强化的不只是充电桩数量扩张，更关键的是快充网络完善带来的补能体验提升。对于比亚迪而言，补能效率提升将强化高频用车场景的购买意愿，进而推动销量与车型结构改善。除整车本身外，高压快充配套、线束连接器及站端设备等环节也会获得更高确定性的需求增量。',
      key_findings: [
        '补能网络完善将改善新能源车使用体验，利好整车销量释放。',
        '高压快充配套环节的价值量提升往往被市场低估。',
        '设备端订单释放更快，整车端体现更晚但弹性更大。',
      ],
      impact_chain: [
        { from: '充电基础设施', to: '高压快充配套', mechanism: '扩容提速', intensity: 'high' },
        { from: '高压快充配套', to: '比亚迪', mechanism: '需求增强', intensity: 'medium' },
      ],
      recommendation: '短期关注充电设备和高压配套，中期继续跟踪整车销量与车型结构改善。',
      created_at: '2026-04-15 08:42:00',
    },
  ],
  demo_agent_lithium: [
    ],
};

const MOCK_HOT_EVENTS: HotEventItem[] = [
  {
    id: 'hot_3',
    title: '宁德时代与中恒电气达成储能协同合作',
    category: '关系发现',
    occurredAt: '2026-04-13',
    summary: '合作消息触发市场对储能产业链关系的重新梳理，研究员希望进一步确认合作关系是否足以沉淀为图谱中的正式关系。',
    tags: ['储能', '合作关系'],
    commentary: '宁德时代与中恒电气围绕储能场景展开协同合作，说明电池能力与储能设备能力正在向系统级解决方案靠拢。对产业链而言，这类合作不仅意味着项目协同和客户拓展的可能性提升，也可能推动储能系统集成、站端设备和交付能力的联动强化。',
    candidate: null,
  },
  {
    id: 'hot_1',
    title: '政策支持充电基础设施建设',
    category: '政策驱动',
    occurredAt: '2026-04-15',
    summary: '政策端继续强调充电基础设施建设和补能网络完善，市场关注其对充电运营、设备制造及整车消费渗透的带动效应。',
    tags: ['充电基础设施', '高压快充', '新能源汽车'],
    commentary: '市场对该事件的第一反应通常停留在“利好充电桩设备商”，但真正更有弹性的往往是高压快充相关零部件与使用体验改善后带来的整车需求二阶扩散。',
    candidate: null,
  },
];

function formatDateTime(date: Date) {
  const pad = (value: number) => String(value).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
}

function wait(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function timeAgo(dateStr: string | null) {
  if (!dateStr) return '从未执行';
  const normalized = dateStr.includes('T') ? dateStr : dateStr.replace(' ', 'T') + 'Z';
  const date = new Date(normalized);
  if (Number.isNaN(date.getTime())) return dateStr;
  const diff = Math.floor((Date.now() - date.getTime()) / 1000);
  if (diff < 60) return '刚刚';
  if (diff < 3600) return `${Math.floor(diff / 60)} 分钟前`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} 小时前`;
  return `${Math.floor(diff / 86400)} 天前`;
}

function safeParseJson<T>(value: unknown, fallback: T): T {
  if (value == null) return fallback;
  if (typeof value !== 'string') return value as T;
  try {
    return JSON.parse(value) as T;
  } catch {
    return fallback;
  }
}

function mapBackendEvent(raw: any): AgentEvent {
  return {
    id: raw.id,
    agent_id: raw.agentId || raw.agent_id,
    title: raw.title || '',
    summary: raw.summary || '',
    source: raw.source || '',
    source_url: raw.sourceUrl || raw.source_url || '',
    event_date: raw.eventDate || raw.event_date || '',
    impact_level: (raw.impactLevel || raw.impact_level || 'medium') as AgentEvent['impact_level'],
    related_entities: safeParseJson<string[]>(raw.relatedEntities || raw.related_entities, []),
    created_at: raw.createdAt || raw.created_at || '',
  };
}

function mapBackendAnalysis(raw: any): AgentAnalysis {
  const parsedImpactChain = safeParseJson<any>(raw.impactChain || raw.impact_chain, []);
  const transmissionDataCandidate =
    parsedImpactChain && !Array.isArray(parsedImpactChain) && parsedImpactChain.type === 'price_transmission_object_type'
      ? parsedImpactChain.data
      : undefined;
  const transmissionData =
    transmissionDataCandidate &&
    Array.isArray(transmissionDataCandidate.nodes) &&
    Array.isArray(transmissionDataCandidate.edges) &&
    transmissionDataCandidate.sourceObjectType
      ? transmissionDataCandidate
      : undefined;

  return {
    id: raw.id,
    agent_id: raw.agentId || raw.agent_id,
    event_id: raw.eventId || raw.event_id || null,
    title: raw.title || '',
    content: raw.content || '',
    key_findings: safeParseJson<string[]>(raw.keyFindings || raw.key_findings, []),
    impact_chain: Array.isArray(parsedImpactChain) ? parsedImpactChain : [],
    recommendation: raw.recommendation || '',
    created_at: raw.createdAt || raw.created_at || '',
    transmissionData,
  };
}

function formatSignedNumber(value: number, fractionDigits = 2) {
  const absValue = Math.abs(value).toFixed(fractionDigits);
  if (value > 0) return `+${absValue}`;
  if (value < 0) return `-${absValue}`;
  return absValue;
}

function getTransmissionAccent(objectTypeId: string) {
  if (objectTypeId === 'lithium_carbonate') {
    return {
      card: 'border-cyan-200 bg-cyan-50/70 shadow-cyan-100/70',
      badge: 'border-cyan-200 bg-cyan-100 text-cyan-700',
      icon: 'bg-cyan-500/10 text-cyan-700',
      line: 'from-cyan-300 via-cyan-200 to-cyan-100',
    };
  }

  if (objectTypeId === 'battery_electrolyte') {
    return {
      card: 'border-emerald-200 bg-emerald-50/70 shadow-emerald-100/70',
      badge: 'border-emerald-200 bg-emerald-100 text-emerald-700',
      icon: 'bg-emerald-500/10 text-emerald-700',
      line: 'from-emerald-300 via-emerald-200 to-emerald-100',
    };
  }

  if (objectTypeId === 'battery_cell') {
    return {
      card: 'border-violet-200 bg-violet-50/70 shadow-violet-100/70',
      badge: 'border-violet-200 bg-violet-100 text-violet-700',
      icon: 'bg-violet-500/10 text-violet-700',
      line: 'from-violet-300 via-violet-200 to-violet-100',
    };
  }

  return {
    card: 'border-slate-200 bg-slate-50 shadow-slate-100/70',
    badge: 'border-slate-200 bg-slate-100 text-slate-700',
    icon: 'bg-slate-500/10 text-slate-700',
    line: 'from-slate-300 via-slate-200 to-slate-100',
  };
}

function normalize(value: string) {
  return String(value || '')
    .replace(/\s+/g, '')
    .replace(/[：:，,。.!！？?（）()【】\[\]-]/g, '')
    .toLowerCase();
}

function getHotEventSortRank(title: string) {
  const normalized = normalize(title);
  if (normalized.includes('碳酸锂')) return 0;
  if (normalized.includes('充电基础设施') || normalized.includes('充电桩')) return 1;
  if (normalized.includes('中恒电气') || normalized.includes('合作')) return 2;
  return 99;
}

function getEventInsight(title: string): EventInsightContent | null {
  const normalized = normalize(title);

  if (normalized.includes('充电基础设施') || normalized.includes('充电桩')) {
    return {
      title: '充电基础设施政策加码',
      badge: '中长期利好',
      conclusion: '补能瓶颈缓解会通过“体验改善 - 需求释放 - 配套升级”的路径向整车和零部件环节传导。',
      summaryItems: [
        { label: '事件定性', value: '中长期利好' },
        { label: '预期差', value: '市场低估高压快充相关配套的价值量提升' },
        { label: '策略建议', value: '短期看设备订单，中期看高压配套，长期看整车销量' },
        { label: '核心逻辑', value: '基础设施完善带来的二阶需求扩散' },
      ],
      sections: [
        {
          title: '一、事件概述',
          paragraphs: ['政策强调补能网络建设、快充布局和运营体系优化，事件的意义不只在设备投资本身。'],
        },
        {
          title: '二、深度点评',
          paragraphs: ['市场最容易高估设备端的短期弹性，低估整车体验改善后对销量的中长期拉动。'],
          bullets: [
            '设备端最先体现订单弹性，但竞争相对充分。',
            '高压连接器、线束等配套环节更受益于价值量提升。',
            '整车端的需求改善体现更慢，但弹性更大。',
          ],
        },
      ],
    };
  }

  if (normalized.includes('碳酸锂')) {
    return {
      title: '碳酸锂价格持续下探',
      badge: '结构性利好',
      conclusion: '锂价下行推动利润由资源端向电池与整车迁移，但价格战会影响利润释放节奏。',
      summaryItems: [
        { label: '事件定性', value: '结构性利好中下游' },
        { label: '预期差', value: '利润传导是逐级进行的，不会一次性完成' },
        { label: '策略建议', value: '重点跟踪电池与整车环节的利润修复斜率' },
        { label: '核心逻辑', value: '成本下降 - 传导扩散 - 盈利重估' },
      ],
      sections: [
        {
          title: '一、事件概述',
          paragraphs: ['锂价连续回落直接影响资源端利润，同时也为材料、电芯和整车环节创造成本改善空间。'],
        },
        {
          title: '二、深度点评',
          paragraphs: ['市场对于“谁最受益”往往只看到整车，但中游电芯和材料同样可能出现阶段性的盈利修复。'],
          bullets: [
            '资源端利润承压最先体现。',
            '电芯盈利修复通常滞后但斜率清晰。',
            '若整车价格战加剧，下游利润释放会被部分吞噬。',
          ],
        },
      ],
    };
  }

  if (normalized.includes('中恒电气') || normalized.includes('合作')) {
    return {
      title: '储能协同合作带来的产业链信号',
      badge: '合作进展',
      conclusion: '宁德时代与中恒电气的合作更像是储能场景下的能力互补，反映出电池企业与设备企业正在共同争取系统级项目机会。',
      summaryItems: [
        { label: '事件定性', value: '储能产业链协同深化' },
        { label: '预期差', value: '市场容易只看概念催化，忽略系统集成与项目拓展价值' },
        { label: '策略建议', value: '重点跟踪合作范围是否落到项目订单、客户导入和方案共建' },
        { label: '核心逻辑', value: '电池能力 + 设备能力 + 场景落地' },
      ],
      sections: [
        {
          title: '一、事件概述',
          paragraphs: ['从新闻内容看，双方合作重点不只是单点采购，而是围绕储能系统集成、站端设备协同和项目拓展展开，合作边界明显更偏向场景化落地。'],
        },
        {
          title: '二、深度点评',
          paragraphs: ['这类合作背后的关键，不在于短期情绪刺激，而在于储能项目越来越强调成套方案能力。宁德时代提供电池与系统侧能力，中恒电气补强设备与站端协同，两者结合有助于提升项目交付完整度。'],
          bullets: [
            '若合作继续深化，首先受益的会是储能项目获取与方案协同效率。',
            '市场后续更需要验证合作是否对应新增订单、联合解决方案或重点客户突破。',
            '如果双方在系统级交付上形成稳定配合，合作意义会明显高于一次性新闻催化。',
          ],
        },
      ],
    };
  }

  return null;
}

function createStarterEvent(agent: Agent): AgentEvent {
  const now = formatDateTime(new Date());
  return {
    id: `evt_${agent.id}_${Date.now()}`,
    agent_id: agent.id,
    title: `${agent.target_company} 相关产业链新动态`,
    summary: `系统围绕 ${agent.target_company} 的研究重点生成了一条最新事件，用于展示事件发现、分析解读和后续研究流程。`,
    source: '研究监测',
    source_url: '',
    event_date: now.slice(0, 10),
    impact_level: 'medium',
    related_entities: [agent.target_company, agent.target_industry],
    created_at: now,
  };
}

function createStarterAnalysis(agent: Agent, event: AgentEvent): AgentAnalysis {
  const now = formatDateTime(new Date());
  return {
    id: `ana_${agent.id}_${Date.now()}`,
    agent_id: agent.id,
    event_id: event.id,
    title: `${agent.target_company} 最新跟踪分析`,
    content: `${agent.target_company} 的最新变化已同步到研究视图。后续可以结合研究智能体输出的分析报告与影响链路，持续补充对产业链节点和关键关系的判断。`,
    key_findings: [
      '最新监测结果已同步到当前标的跟踪视图。',
      '可继续结合产业链事件和关系变化补充研判。',
    ],
    impact_chain: [
      { from: '事件发现', to: agent.target_industry, mechanism: '触发跟踪', intensity: 'medium' },
      { from: agent.target_industry, to: agent.target_company, mechanism: '研究聚焦', intensity: 'medium' },
    ],
    recommendation: '建议继续结合热点事件和上下游关系变化，跟踪关键信号的持续性。',
    created_at: now,
  };
}

function StockAutocomplete({
  value,
  onChange,
  onSelect,
}: {
  value: string;
  onChange: (value: string) => void;
  onSelect: (stock: StockItem) => void;
}) {
  const [open, setOpen] = useState(false);
  const [results, setResults] = useState<StockItem[]>([]);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handler = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const handleInput = (query: string) => {
    onChange(query);
    const nextResults = searchStocks(query, 8);
    setResults(nextResults);
    setOpen(nextResults.length > 0);
  };

  return (
    <div ref={ref} className="relative">
      <input
        className="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-200"
        placeholder="输入代码或名称搜索，如 300750、宁德时代"
        value={value}
        onChange={(event) => handleInput(event.target.value)}
        onFocus={() => {
          if (results.length > 0) setOpen(true);
        }}
      />
      {open ? (
        <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-64 overflow-y-auto rounded-lg border border-slate-200 bg-white shadow-lg">
          {results.map((stock) => (
            <button
              key={`${stock.market}-${stock.code}`}
              className="flex w-full items-center gap-2 border-b border-slate-50 px-3 py-2 text-left text-sm transition-colors last:border-0 hover:bg-blue-50"
              onClick={() => {
                onSelect(stock);
                setOpen(false);
              }}
            >
              <span
                className={cn(
                  'shrink-0 rounded px-1.5 py-0.5 text-[10px] font-bold',
                  stock.market === 'A' ? 'bg-red-100 text-red-600' : 'bg-orange-100 text-orange-600',
                )}
              >
                {stock.market === 'A' ? 'A股' : 'H股'}
              </span>
              <span className="w-14 shrink-0 font-mono text-xs text-slate-400">{stock.code}</span>
              <span className="truncate font-medium text-slate-800">{stock.name}</span>
              <span className="ml-auto shrink-0 text-xs text-slate-400">{stock.industry}</span>
            </button>
          ))}
        </div>
      ) : null}
    </div>
  );
}

function CreateAgentForm({
  onCreated,
  onCancel,
}: {
  onCreated: (agent: Agent) => void;
  onCancel: () => void;
}) {
  const [form, setForm] = useState({
    name: '',
    description: '',
    targetCompany: '',
    targetIndustry: '新能源汽车',
    analysisFocus: '',
    scheduleMinutes: 60,
  });
  const [creating, setCreating] = useState(false);

  const handleStockSelect = (stock: StockItem) => {
    const suffix = stock.market === 'A' ? 'SH/SZ' : 'HK';
    const targetCompany = `${stock.name}（${stock.code}.${suffix}）`;
    setForm((prev) => ({
      ...prev,
      targetCompany,
      targetIndustry: stock.industry,
      name: prev.name || `${stock.name}标的跟踪`,
    }));
  };

  const handleSubmit = async () => {
    if (!form.name || !form.targetCompany || !form.targetIndustry) {
      toast.error('请填写必填字段');
      return;
    }
    setCreating(true);
    await wait(300);
    const now = formatDateTime(new Date());
    onCreated({
      id: `demo_agent_${Date.now()}`,
      name: form.name,
      description: form.description,
      target_company: form.targetCompany,
      target_industry: form.targetIndustry,
      analysis_focus: form.analysisFocus,
      schedule_minutes: form.scheduleMinutes,
      is_active: 1,
      last_run_at: null,
      created_at: now,
      updated_at: now,
    });
    toast.success('标的跟踪已创建');
    setCreating(false);
  };

  return (
    <div className="space-y-5 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="flex items-center gap-2 text-lg font-semibold">
        <Bot className="h-5 w-5 text-blue-600" />
        新建标的跟踪
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="col-span-2">
          <label className="mb-1 block text-xs font-medium text-slate-500">
            目标标的 *
            <span className="ml-1 font-normal text-slate-400">（支持 A 股 / H 股代码或名称搜索）</span>
          </label>
          <StockAutocomplete
            value={form.targetCompany}
            onChange={(value) => setForm((prev) => ({ ...prev, targetCompany: value }))}
            onSelect={handleStockSelect}
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-medium text-slate-500">标的跟踪名称 *</label>
          <input
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-200"
            placeholder="如：宁德时代标的跟踪"
            value={form.name}
            onChange={(event) => setForm((prev) => ({ ...prev, name: event.target.value }))}
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-medium text-slate-500">所属行业 *</label>
          <input
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-200"
            value={form.targetIndustry}
            onChange={(event) => setForm((prev) => ({ ...prev, targetIndustry: event.target.value }))}
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-medium text-slate-500">执行条件</label>
          <input
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-200"
            value={`每 ${form.scheduleMinutes} 分钟执行一次`}
            onChange={(event) => {
              const matched = event.target.value.match(/\d+/);
              setForm((prev) => ({ ...prev, scheduleMinutes: matched ? Number(matched[0]) : prev.scheduleMinutes }));
            }}
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-medium text-slate-500">研究重点</label>
          <input
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-200"
            placeholder="如：成本传导、国产替代、出海节奏"
            value={form.analysisFocus}
            onChange={(event) => setForm((prev) => ({ ...prev, analysisFocus: event.target.value }))}
          />
        </div>
        <div className="col-span-2">
          <label className="mb-1 block text-xs font-medium text-slate-500">描述</label>
          <textarea
            className="w-full resize-none rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-200"
            rows={2}
            placeholder="简要说明该标的跟踪的监控范围与研究目标"
            value={form.description}
            onChange={(event) => setForm((prev) => ({ ...prev, description: event.target.value }))}
          />
        </div>
      </div>

      <div className="flex justify-end gap-3">
        <Button variant="outline" size="sm" onClick={onCancel}>
          取消
        </Button>
        <Button size="sm" onClick={handleSubmit} disabled={creating} className="gap-2">
          {creating ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Plus className="h-3.5 w-3.5" />}
          创建标的跟踪
        </Button>
      </div>
    </div>
  );
}

function EventTimeline({ events }: { events: AgentEvent[] }) {
  if (events.length === 0) {
    return (
      <div className="py-12 text-center text-slate-400">
        <Search className="mx-auto mb-2 h-8 w-8 opacity-50" />
        <p className="text-sm">暂无事件，运行标的跟踪后会在这里展示新发现。</p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {events.map((event) => {
        const ImpactIcon = impactIcons[event.impact_level] || Minus;
        return (
          <div
            key={event.id}
            className="flex gap-3 rounded-lg border border-slate-100 bg-slate-50/60 p-3 transition-colors hover:bg-slate-50"
          >
            <div className={cn('flex h-8 w-8 shrink-0 items-center justify-center rounded-full border', impactColors[event.impact_level])}>
              <ImpactIcon className="h-3.5 w-3.5" />
            </div>
            <div className="min-w-0 flex-1">
              <div className="flex items-start justify-between gap-2">
                <h4 className="text-sm font-medium leading-snug text-slate-900">{event.title}</h4>
                <span className={cn('shrink-0 rounded-full border px-1.5 py-0.5 text-[10px] font-medium', impactColors[event.impact_level])}>
                  {event.impact_level === 'high' ? '高' : event.impact_level === 'medium' ? '中' : '低'}
                </span>
              </div>
              <p className="mt-1 line-clamp-2 text-xs text-slate-500">{event.summary}</p>
              <div className="mt-2 flex flex-wrap items-center gap-3 text-[10px] text-slate-400">
                <span>{event.event_date}</span>
                {event.source ? (
                  event.source_url ? (
                    <a
                      href={event.source_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center gap-0.5 text-blue-500 hover:underline"
                    >
                      · {event.source}
                      <ExternalLink className="h-2.5 w-2.5" />
                    </a>
                  ) : (
                    <span>· {event.source}</span>
                  )
                ) : null}
                {event.related_entities.length > 0 ? (
                  <span className="flex items-center gap-1">
                    · <Target className="h-2.5 w-2.5" />
                    {event.related_entities.join('、')}
                  </span>
                ) : null}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

function TransmissionNodeCard({
  title,
  subtitle,
  previousPrice,
  latestPrice,
  objectTypeId,
}: {
  title: string;
  subtitle: string;
  previousPrice: number;
  latestPrice: number;
  objectTypeId: string;
}) {
  const accent = getTransmissionAccent(objectTypeId);
  const priceDisplay = formatTransmissionPrice(previousPrice, latestPrice, objectTypeId);

  return (
    <div className={cn('w-full rounded-[26px] border bg-white p-4 shadow-[0_16px_32px_rgba(15,23,42,0.08)]', accent.card)}>
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <div className={cn('inline-flex items-center gap-1 rounded-full border px-2 py-1 text-[11px] font-medium', accent.badge)}>
            <Database className="h-3 w-3" />
            {subtitle}
          </div>
          <h5 className="mt-3 text-sm font-semibold text-slate-900">{title}</h5>
        </div>
        <div className={cn('flex h-10 w-10 shrink-0 items-center justify-center rounded-xl', accent.icon)}>
          <Network className="h-4 w-4" />
        </div>
      </div>

      <div className="mt-4 rounded-2xl border border-slate-100 bg-slate-50/80 px-3 py-3 text-xs">
        <p className="text-slate-400">价格变化</p>
        <div className="mt-2 flex items-center gap-2 text-sm font-semibold text-slate-800">
          <span>{priceDisplay.previous}</span>
          <ArrowRight className="h-3.5 w-3.5 text-slate-400" />
          <span>{priceDisplay.latest}</span>
        </div>
        <p className="mt-1 text-[11px] text-slate-400">{priceDisplay.unitLabel}</p>
      </div>
    </div>
  );
}

function formatTransmissionPrice(previousPrice: number, latestPrice: number, objectTypeId: string) {
  const config = (() => {
    if (objectTypeId === 'lithium_carbonate') return { divisor: 1, unitLabel: '单位：万元 / 吨', decimals: 2 };
    if (objectTypeId === 'cathode_material') return { divisor: 1, unitLabel: '单位：万元 / 吨', decimals: 2 };
    if (objectTypeId === 'battery_electrolyte') return { divisor: 1, unitLabel: '单位：万元 / 吨', decimals: 2 };
    if (objectTypeId === 'battery_cell') return { divisor: 1, unitLabel: '单位：元 / Wh', decimals: 2 };
    if (objectTypeId === 'power_battery') return { divisor: 10000, unitLabel: '单位：万元 / 套', decimals: 2 };
    if (objectTypeId === 'new_energy_vehicle') return { divisor: 1, unitLabel: '单位：万元 / 辆', decimals: 2 };
    return { divisor: 1, unitLabel: '单位：当前表价格口径', decimals: 2 };
  })();

  const formatValue = (value: number) => (value / config.divisor).toFixed(config.decimals);

  return {
    previous: formatValue(previousPrice),
    latest: formatValue(latestPrice),
    unitLabel: config.unitLabel,
  };
}

function PriceTransmissionGraph({ data }: { data: PriceTransmissionData }) {
  if (!Array.isArray(data.nodes) || !Array.isArray(data.edges) || !data.sourceObjectType) {
    return (
      <div className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-6 text-sm text-slate-500">
        当前传导结果结构不完整，暂时无法展示价格传导图。
      </div>
    );
  }

  const nodePositions: Record<string, { x: number; y: number }> = {
    lithium_carbonate: { x: 80, y: 170 },
    cathode_material: { x: 350, y: 40 },
    battery_electrolyte: { x: 350, y: 290 },
    battery_cell: { x: 650, y: 170 },
    power_battery: { x: 930, y: 170 },
    new_energy_vehicle: { x: 1210, y: 170 },
  };

  const chainNodes = data.nodes.map((node) => ({
    ...node,
    objectTypeId: node.id,
    x: nodePositions[node.id]?.x ?? 80,
    y: nodePositions[node.id]?.y ?? 170,
    title: node.name,
  }));

  const edges = data.edges.map((edge) => ({
    from: edge.source,
    to: edge.target,
    label: edge.label,
  }));
  const CARD_WIDTH = 220;
  const CARD_HEIGHT = 128;
  const CANVAS_WIDTH = 1450;
  const CANVAS_HEIGHT = 470;
  const nodeById = Object.fromEntries(chainNodes.map((node) => [node.id, node]));

  const buildPath = (fromId: string, toId: string) => {
    const from = nodeById[fromId];
    const to = nodeById[toId];
    const x1 = from.x + CARD_WIDTH;
    const y1 = from.y + CARD_HEIGHT / 2;
    const x2 = to.x;
    const y2 = to.y + CARD_HEIGHT / 2;
    const dx = x2 - x1;
    const c1x = x1 + dx * 0.4;
    const c2x = x2 - dx * 0.4;
    return `M ${x1} ${y1} C ${c1x} ${y1}, ${c2x} ${y2}, ${x2} ${y2}`;
  };

  const labelPosition = (fromId: string, toId: string, offsetY = -14) => {
    const from = nodeById[fromId];
    const to = nodeById[toId];
    const x1 = from.x + CARD_WIDTH;
    const y1 = from.y + CARD_HEIGHT / 2;
    const x2 = to.x;
    const y2 = to.y + CARD_HEIGHT / 2;
    return {
      x: (x1 + x2) / 2,
      y: (y1 + y2) / 2 + offsetY,
    };
  };

  const edgeColor = (fromId: string) => {
    return getTransmissionAccent(nodeById[fromId].objectTypeId).badge.includes('emerald')
      ? '#4ade80'
      : getTransmissionAccent(nodeById[fromId].objectTypeId).badge.includes('violet')
        ? '#a78bfa'
        : getTransmissionAccent(nodeById[fromId].objectTypeId).badge.includes('cyan')
          ? '#67e8f9'
          : '#93c5fd';
  };

  return (
    <div className="space-y-5 rounded-[28px] border border-slate-200 bg-[radial-gradient(circle_at_top,_rgba(59,130,246,0.08),_transparent_45%),linear-gradient(180deg,_#f8fbff_0%,_#ffffff_100%)] p-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h5 className="text-sm font-semibold text-slate-900">概念层价格传导分析</h5>
            <p className="mt-1 text-xs text-slate-500">以本体图谱风格展示源概念价格变化如何沿概念关系逐级传导。</p>
        </div>
        <div className="flex gap-2">
          <div className="rounded-xl border border-slate-200 bg-white px-3 py-2 text-right shadow-sm">
            <p className="text-[11px] text-slate-400">传导节点</p>
            <p className="text-sm font-semibold text-slate-900">{data.summary.objectTypeCount}</p>
          </div>
          <div className="rounded-xl border border-slate-200 bg-white px-3 py-2 text-right shadow-sm">
            <p className="text-[11px] text-slate-400">源头涨幅</p>
            <p className="text-sm font-semibold text-red-600">{formatSignedNumber(data.sourceObjectType.priceChangePercent)}%</p>
          </div>
        </div>
      </div>

      <div className="overflow-x-auto rounded-[28px] border border-slate-200 bg-[radial-gradient(circle_at_top,_rgba(148,163,184,0.12),_transparent_55%),#f8fafc] p-6">
        <div className="relative" style={{ width: `${CANVAS_WIDTH}px`, height: `${CANVAS_HEIGHT}px` }}>
          <svg className="absolute inset-0 h-full w-full" viewBox={`0 0 ${CANVAS_WIDTH} ${CANVAS_HEIGHT}`} fill="none">
            {edges.map((edge) => {
              const color = edgeColor(edge.from);
              const label = labelPosition(edge.from, edge.to);
              return (
                <g key={`${edge.from}-${edge.to}`}>
                  <path d={buildPath(edge.from, edge.to)} stroke={color} strokeWidth="12" strokeLinecap="round" strokeOpacity="0.16" />
                  <path d={buildPath(edge.from, edge.to)} stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeDasharray="7 7" />
                  <g transform={`translate(${label.x}, ${label.y}) rotate(-20)`}>
                    <rect x="-54" y="-12" width="108" height="24" rx="12" fill="white" fillOpacity="0.95" stroke="#e2e8f0" />
                    <text textAnchor="middle" dominantBaseline="middle" fontSize="11" fontWeight="700" fill="#64748b">
                      {edge.label}
                    </text>
                  </g>
                </g>
              );
            })}
          </svg>

          {edges.map((edge) => {
            return null;
          })}

          {chainNodes.map((node) => (
            <div
              key={node.id}
              className="absolute z-10"
              style={{
                left: `${node.x}px`,
                top: `${node.y}px`,
                width: `${CARD_WIDTH}px`,
              }}
            >
                <TransmissionNodeCard
                  title={node.title}
                  subtitle={node.subtitle}
                  previousPrice={node.previousPrice}
                  latestPrice={node.latestPrice}
                  objectTypeId={node.objectTypeId}
                />
            </div>
          ))}

          <div className="mt-6 flex items-center justify-between px-2 text-[11px] text-slate-400">
            <span>概念层价格冲击沿 link type 关系逐级扩散。</span>
            <span>传导系数来自概念层价格传导分析函数输出。</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function AnalysisReport({
  analysis,
  deleting = false,
  onDelete,
}: {
  analysis: AgentAnalysis;
  deleting?: boolean;
  onDelete?: (analysis: AgentAnalysis) => Promise<void> | void;
}) {
  const [expanded, setExpanded] = useState(true);

  return (
    <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
      <div
        className="flex cursor-pointer items-start gap-3 border-b border-slate-100 px-5 py-4 transition-colors hover:bg-slate-50/50"
        onClick={() => setExpanded((value) => !value)}
      >
        <FileText className="mt-0.5 h-5 w-5 shrink-0 text-blue-600" />
        <div className="min-w-0 flex-1">
          <h3 className="text-sm font-semibold text-slate-900">{analysis.title}</h3>
          <p className="mt-0.5 text-xs text-slate-400">{timeAgo(analysis.created_at)}</p>
        </div>
        {onDelete ? (
          <button
            type="button"
            className="rounded-md p-1 text-slate-400 transition-colors hover:bg-red-50 hover:text-red-500"
            onClick={async (event) => {
              event.stopPropagation();
              await onDelete(analysis);
            }}
            disabled={deleting}
            title="删除分析报告"
          >
            {deleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Trash2 className="h-4 w-4" />}
          </button>
        ) : null}
        {expanded ? <ChevronUp className="h-4 w-4 text-slate-400" /> : <ChevronDown className="h-4 w-4 text-slate-400" />}
      </div>

      {expanded ? (
        <div className="space-y-5 p-5">
          {analysis.key_findings.length > 0 ? (
            <div>
              <h4 className="mb-2 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider text-slate-500">
                <Zap className="h-3.5 w-3.5 text-amber-500" />
                核心结论
              </h4>
              <div className="space-y-1.5">
                {analysis.key_findings.map((finding, index) => (
                  <div key={finding} className="flex items-start gap-2 text-sm text-slate-700">
                    <span className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-blue-100 text-xs font-bold text-blue-700">
                      {index + 1}
                    </span>
                    {finding}
                  </div>
                ))}
              </div>
            </div>
          ) : null}

          {analysis.transmissionData ? (
            <div>
              <h4 className="mb-2 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider text-slate-500">
                <Activity className="h-3.5 w-3.5 text-purple-500" />
                影响链路
              </h4>
              <PriceTransmissionGraph data={analysis.transmissionData} />
            </div>
          ) : analysis.impact_chain.length > 0 ? (
            <div>
              <h4 className="mb-2 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider text-slate-500">
                <Activity className="h-3.5 w-3.5 text-purple-500" />
                影响链路
              </h4>
              <div className="flex flex-wrap gap-2">
                {analysis.impact_chain.map((item, index) => (
                  <div key={`${item.from}-${item.to}-${index}`} className="flex items-center gap-1 text-xs">
                    <span className="rounded border border-blue-100 bg-blue-50 px-2 py-1 font-medium text-blue-700">{item.from}</span>
                    <div className="flex flex-col items-center">
                      <ArrowRight className="h-3.5 w-3.5 text-slate-400" />
                      <span className={cn('rounded px-1 text-[9px]', impactColors[item.intensity])}>{item.mechanism}</span>
                    </div>
                    <span className="rounded border border-emerald-100 bg-emerald-50 px-2 py-1 font-medium text-emerald-700">{item.to}</span>
                  </div>
                ))}
              </div>
            </div>
          ) : null}

          {analysis.recommendation ? (
            <div className="rounded-lg border border-blue-100 bg-gradient-to-r from-blue-50 to-indigo-50 px-4 py-3">
              <h4 className="mb-1 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider text-blue-700">
                <TrendingUp className="h-3.5 w-3.5" />
                研究建议
              </h4>
              <p className="text-sm text-slate-700">{analysis.recommendation}</p>
            </div>
          ) : null}

        </div>
      ) : null}
    </div>
  );
}

function AgentCard({
  agent,
  selected,
  onSelect,
  onToggle,
  onRun,
  onDelete,
  running,
}: {
  agent: Agent;
  selected: boolean;
  onSelect: () => void;
  onToggle: () => void;
  onRun: () => void;
  onDelete: () => void;
  running: boolean;
}) {
  return (
    <div
      onClick={onSelect}
      className={cn(
        'cursor-pointer rounded-xl border p-4 transition-all hover:shadow-sm',
        selected ? 'border-blue-300 bg-blue-50/50 shadow-sm ring-1 ring-blue-200' : 'border-slate-200 bg-white hover:border-slate-300',
      )}
    >
      <div className="mb-2 flex items-start justify-between">
        <div className="flex items-center gap-2">
          <div className={cn('flex h-8 w-8 items-center justify-center rounded-lg', agent.is_active ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-400')}>
            <Bot className="h-4 w-4" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-slate-900">{agent.name}</h3>
            <p className="text-[11px] text-slate-400">{agent.target_company}</p>
          </div>
        </div>
        <button
          onClick={(event) => {
            event.stopPropagation();
            onToggle();
          }}
          className="text-slate-400 hover:text-slate-600"
        >
          {agent.is_active ? <ToggleRight className="h-6 w-6 text-emerald-500" /> : <ToggleLeft className="h-6 w-6" />}
        </button>
      </div>

      <p className="mb-3 line-clamp-2 text-xs text-slate-500">{agent.description || agent.analysis_focus || '暂无描述'}</p>

      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2 text-[10px] text-slate-400">
          <span className="flex items-center gap-1">
            <Clock className="h-3 w-3" />
            {agent.last_run_at ? timeAgo(agent.last_run_at) : '从未执行'}
          </span>
          {agent.schedule_minutes > 0 ? (
            <span className="flex items-center gap-1">
              · <RefreshCw className="h-3 w-3" />
              {agent.id === 'demo_agent_lithium' ? '价格波动 5% 以上' : `每 ${agent.schedule_minutes} 分钟`}
            </span>
          ) : null}
        </div>
        <div className="flex items-center gap-1">
          <Button
            variant="ghost"
            size="sm"
            onClick={(event) => {
              event.stopPropagation();
              onRun();
            }}
            disabled={running}
            className="h-6 gap-1 px-2 text-[11px]"
          >
            {running ? <Loader2 className="h-3 w-3 animate-spin" /> : <Play className="h-3 w-3" />}
            运行
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={(event) => {
              event.stopPropagation();
              onDelete();
            }}
            className="h-6 px-2 text-[11px] text-red-500 hover:bg-red-50 hover:text-red-700"
          >
            <Trash2 className="h-3 w-3" />
          </Button>
        </div>
      </div>
    </div>
  );
}

function EventInsightCard({ event }: { event: HotEventItem }) {
  const [expanded, setExpanded] = useState(false);
  const insight = getEventInsight(event.title);

  if (!insight) {
    return <div className="rounded-3xl border border-slate-200 bg-slate-50 p-5 text-sm leading-7 text-slate-700">{event.commentary}</div>;
  }

  return (
    <div className="overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
      <div className="border-b border-slate-200 bg-gradient-to-r from-slate-50 to-white p-5">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="min-w-0">
            <span className="inline-flex items-center rounded-full border border-blue-200 bg-blue-50 px-2.5 py-1 text-[11px] font-semibold text-blue-700">
              {insight.badge}
            </span>
            <h3 className="mt-3 text-lg font-bold text-slate-900">{insight.title}</h3>
            <p className="mt-2 max-w-4xl text-sm leading-6 text-slate-600">{insight.conclusion}</p>
          </div>
          <button
            type="button"
            onClick={() => setExpanded((value) => !value)}
            className="inline-flex items-center gap-1.5 rounded-full border border-slate-200 bg-white px-3 py-2 text-xs font-medium text-slate-600 transition-colors hover:border-slate-300 hover:text-slate-900"
          >
            {expanded ? '收起全文' : '展开全文'}
            <ChevronDown className={cn('h-3.5 w-3.5 transition-transform', expanded ? 'rotate-180' : 'rotate-0')} />
          </button>
        </div>
      </div>

      <div className="p-5">
        <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4">
          <div className="mt-2 text-sm font-semibold text-slate-900">{insight.conclusion}</div>
          <div className="mt-4 grid gap-3 md:grid-cols-2">
            {insight.summaryItems.map((item) => (
              <div key={item.label} className="rounded-xl border border-white bg-white p-3 shadow-sm">
                <div className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">{item.label}</div>
                <div className="mt-1 text-sm leading-6 text-slate-700">{item.value}</div>
              </div>
            ))}
          </div>
        </div>

        {expanded ? (
          <article className="mt-5 space-y-6">
            {insight.sections.map((section) => (
              <section key={section.title} className="space-y-3">
                <h4 className="text-base font-semibold text-slate-900">{section.title}</h4>
                {section.paragraphs.map((paragraph) => (
                  <p key={paragraph} className="text-sm leading-7 text-slate-700">
                    {paragraph}
                  </p>
                ))}
                {section.bullets?.length ? (
                  <ul className="space-y-2">
                    {section.bullets.map((bullet) => (
                      <li key={bullet} className="flex items-start gap-2 text-sm leading-7 text-slate-700">
                        <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-blue-500" />
                        <span>{bullet}</span>
                      </li>
                    ))}
                  </ul>
                ) : null}
              </section>
            ))}
          </article>
        ) : (
          <p className="mt-4 text-sm leading-7 text-slate-700">{event.commentary}</p>
        )}
      </div>
    </div>
  );
}

function HotEventInterpretationPanel() {
  const [events, setEvents] = useState<HotEventItem[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [analyzing, setAnalyzing] = useState(false);
  const [creatingLink, setCreatingLink] = useState(false);
  const selectedEvent = events.find((item) => item.id === selectedId) || null;

  useEffect(() => {
    let mounted = true;
    api
      .getTrackedEvents()
      .then((result) => {
        if (!mounted) return;
        const nextEvents = (result.events || []).map((item: any) => ({
          id: item.id,
          title: item.title,
          category: item.category,
          occurredAt: item.occurredAt,
          summary: item.summary,
          content: item.content,
          source: item.source,
          tags: Array.isArray(item.tags) ? item.tags : [],
          commentary:
            item.title.includes('宁德时代') || item.title.includes('中恒电气')
              ? '宁德时代与中恒电气围绕储能场景展开协同合作，反映出电池能力与储能设备能力正在向系统级方案整合。后续更值得关注的是合作是否进一步落到联合项目、方案共建和客户拓展上。'
              : '市场对该事件的第一反应通常停留在“利好充电桩设备商”，但真正更有弹性的往往是高压快充相关零部件与使用体验改善后带来的整车需求二阶扩散。',
          candidate: item.candidate || null,
        }));
        setEvents(nextEvents);
        setSelectedId(nextEvents[0]?.id || null);
      })
      .catch(() => {})
      .finally(() => {
        if (mounted) setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    if (!selectedEvent) return;
    if (loading) return;
    if (selectedEvent.candidate) return;
    if (!(selectedEvent.title.includes('宁德时代') || selectedEvent.title.includes('中恒电气'))) return;

    let cancelled = false;
    setAnalyzing(true);
    api
      .analyzeTrackedEvent(selectedEvent.id)
      .then((result) => {
        if (cancelled || !result.candidate) return;
        setEvents((prev) =>
          prev.map((item) => (item.id === selectedEvent.id ? { ...item, candidate: result.candidate } : item)),
        );
      })
      .catch((error) => {
        if (!cancelled) {
          toast.error(error.message || '关系识别失败');
        }
      })
      .finally(() => {
        if (!cancelled) setAnalyzing(false);
      });

    return () => {
      cancelled = true;
    };
  }, [selectedEvent, loading]);

  const handleToggleLink = async () => {
    if (!selectedEvent?.candidate) return;
    setCreatingLink(true);
    try {
      const nextStatus = selectedEvent.candidate.status === 'created' ? 'recognized' : 'created';
      if (nextStatus === 'created') {
        await api.createEventCandidateLink(selectedEvent.candidate.id);
      } else {
        await api.deleteEventCandidateLink(selectedEvent.candidate.id);
      }
      setEvents((prev) =>
        prev.map((item) =>
          item.id === selectedEvent.id && item.candidate
            ? { ...item, candidate: { ...item.candidate, status: nextStatus } }
            : item,
        ),
      );
      toast.success(nextStatus === 'created' ? '链接已创建' : '链接已删除');
    } finally {
      setCreatingLink(false);
    }
  };

  return (
    <div className="flex h-full min-h-0">
      <aside className="w-80 shrink-0 border-r border-slate-200 bg-white">
        <div className="border-b border-slate-200 px-5 py-4">
          <div className="flex items-center gap-2 font-semibold text-slate-900">
            <Flame className="h-4 w-4 text-red-500" />
            事件跟踪
          </div>
          <p className="mt-1 text-xs text-slate-500">按事件跟踪影响路径、重点标的和研究员视角的事件点评。</p>
        </div>
        <div className="h-[calc(100%-73px)] space-y-2 overflow-y-auto p-3">
          {events.map((item) => (
            <button
              key={item.id}
              onClick={() => setSelectedId(item.id)}
              className={cn(
                'w-full rounded-xl border px-3 py-3 text-left transition-colors',
                selectedId === item.id ? 'border-blue-300 bg-blue-50' : 'border-slate-200 bg-white hover:border-slate-300 hover:bg-slate-50',
              )}
            >
              <div className="line-clamp-2 text-sm font-medium text-slate-900">{item.title}</div>
              <div className="mt-2 text-[11px] text-slate-400">{item.occurredAt}</div>
            </button>
          ))}
        </div>
      </aside>

      <section className="min-w-0 flex-1 overflow-y-auto bg-slate-50 p-6">
        {loading ? (
          <div className="flex h-full items-center justify-center text-slate-400">正在加载事件...</div>
        ) : !selectedEvent ? (
          <div className="flex h-full items-center justify-center text-slate-400">暂无热点事件</div>
        ) : (
          <div className="space-y-5">
            <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex flex-wrap items-center gap-2">
                <span className="inline-flex items-center rounded-full border border-red-200 bg-red-50 px-2 py-1 text-xs font-medium text-red-600">
                  {selectedEvent.category}
                </span>
                <span className="text-xs text-slate-400">{selectedEvent.occurredAt}</span>
              </div>
              <h2 className="mt-3 text-2xl font-bold text-slate-900">{selectedEvent.title}</h2>
              <p className="mt-2 text-sm leading-6 text-slate-600">{selectedEvent.summary}</p>
              <div className="mt-4 flex flex-wrap gap-2">
                {selectedEvent.tags.map((tag) => (
                  <span key={tag} className="rounded-full bg-slate-100 px-2 py-1 text-xs text-slate-600">
                    #{tag}
                  </span>
                ))}
              </div>
            </div>

            {selectedEvent.candidate ? (
              <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                <div className="mb-3 font-semibold text-slate-900">重点标的</div>
                <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
                  {[selectedEvent.candidate.sourceName, selectedEvent.candidate.targetName].map((company) => (
                    <div key={company} className="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-800">
                      {company}
                    </div>
                  ))}
                </div>
              </div>
            ) : null}

            <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="mb-4 flex items-center gap-2 font-semibold text-slate-900">
                <Activity className="h-4 w-4 text-purple-500" />
                事件传导图
              </div>
              <EventPropagationExplorer
                eventTitle={selectedEvent.title}
                relationCandidate={selectedEvent.candidate || null}
                creatingLink={creatingLink || analyzing}
                onCreateLink={handleToggleLink}
              />
            </div>

            <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="mb-3 font-semibold text-slate-900">事件解读</div>
              <EventInsightCard event={selectedEvent} />
            </div>
          </div>
        )}
      </section>
    </div>
  );
}

const QA_STORAGE_KEY = 'ontology_qa_history';

interface QAMessage {
  role: 'user' | 'assistant';
  text: string;
  sources?: { uri: string; title: string }[];
  chain?: { step: number; from: string; to: string; mechanism: string; impact: string }[];
  entities?: string[];
  streaming?: boolean;
}

function loadQAMessages(): QAMessage[] {
  try {
    const raw = localStorage.getItem(QA_STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveQAMessages(messages: QAMessage[]) {
  try {
    localStorage.setItem(QA_STORAGE_KEY, JSON.stringify(messages));
  } catch {
    // ignore
  }
}

export function OntologyQAPanel({ fallbackAgentId }: { fallbackAgentId?: string }) {
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState<QAMessage[]>(loadQAMessages);
  const [loading, setLoading] = useState(false);
  const [agentId, setAgentId] = useState<string | null>(fallbackAgentId || null);
  const abortRef = useRef<AbortController | null>(null);
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, loading]);

  useEffect(() => {
    api
      .getResearchAgents()
      .then((result) => {
        if (result.agents?.length) {
          setAgentId(result.agents[0].id);
        } else if (fallbackAgentId) {
          setAgentId(fallbackAgentId);
        }
      })
      .catch(() => {
        if (fallbackAgentId) setAgentId(fallbackAgentId);
      });
  }, [fallbackAgentId]);

  const SUGGESTIONS = [
    '新能源车原材料价格上涨，对产业链上下游企业业绩和股价有何影响？',
    '碳酸锂价格大幅下跌，哪些环节最受益，哪些最受损？',
    '光伏组件价格持续下跌，对整个光伏产业链估值有何重塑？',
    '半导体设备国产替代进展如何？对相关标的有何影响？',
  ];

  const addMessages = (updater: (prev: QAMessage[]) => QAMessage[]) => {
    setMessages((prev) => {
      const next = updater(prev);
      saveQAMessages(next);
      return next;
    });
  };

  const send = async (nextQuestion?: string) => {
    const question = (nextQuestion || input).trim();
    if (!question || loading) return;
    if (!agentId) {
      toast.error('当前没有可用的问答上下文');
      return;
    }

    setInput('');
    addMessages((prev) => [...prev, { role: 'user', text: question }]);
    setLoading(true);
    abortRef.current = new AbortController();

    try {
      let fullResponse = '';
      addMessages((prev) => [...prev, { role: 'assistant', text: '', streaming: true }]);

      for await (const chunk of streamResearchChat(agentId, question)) {
        if (abortRef.current?.signal.aborted) break;
        if (chunk.error) throw new Error(chunk.error);

        if (chunk.content) {
          fullResponse += chunk.content;
          addMessages((prev) => {
            const next = [...prev];
            const last = next[next.length - 1];
            if (last && last.role === 'assistant' && last.streaming) {
              last.text = fullResponse;
            }
            return next;
          });
        }

        if (chunk.done) break;
      }

      addMessages((prev) => {
        const next = [...prev];
        const last = next[next.length - 1];
        if (last && last.role === 'assistant') {
          last.streaming = false;
          last.text = fullResponse;
        }
        return next;
      });
    } catch (error: any) {
      if (error.name !== 'AbortError') {
        addMessages((prev) => [...prev, { role: 'assistant', text: `出错了：${error.message}` }]);
      }
    } finally {
      setLoading(false);
      abortRef.current = null;
    }
  };

  const stop = () => {
    abortRef.current?.abort();
    setLoading(false);
  };

  const clearHistory = () => {
    addMessages(() => []);
    toast.success('对话历史已清空');
  };

  return (
    <div className="flex h-full flex-col">
      <div className="flex shrink-0 items-center justify-between border-b border-slate-200 bg-gradient-to-r from-blue-50 to-white px-5 py-3">
        <div>
          <h3 className="flex items-center gap-2 font-semibold text-slate-900">
            <Network className="h-4 w-4 text-blue-600" />
            产业图谱智能问答
          </h3>
          <p className="mt-0.5 text-xs text-slate-500">基于本体图谱逻辑 + 实时市场数据，回答产业链开放性问题</p>
        </div>
        {messages.length > 0 ? (
          <button
            onClick={clearHistory}
            className="flex items-center gap-1 rounded px-2 py-1 text-xs text-slate-400 transition-colors hover:bg-red-50 hover:text-red-500"
          >
            <Trash2 className="h-3 w-3" />
            清空
          </button>
        ) : null}
      </div>

      <div className="flex-1 space-y-4 overflow-y-auto p-4">
        {messages.length === 0 ? (
          <div className="space-y-3">
            <p className="py-4 text-center text-xs text-slate-400">选择一个问题开始，或自己输入</p>
            {SUGGESTIONS.map((suggestion) => (
              <button
                key={suggestion}
                onClick={() => send(suggestion)}
                className="w-full rounded-lg border border-slate-200 bg-white px-4 py-3 text-left text-sm text-slate-700 transition-colors hover:border-blue-300 hover:bg-blue-50"
              >
                {suggestion}
              </button>
            ))}
          </div>
        ) : null}

        {messages.map((message, index) => (
          <div key={`${message.role}-${index}`} className={cn('flex gap-3', message.role === 'user' ? 'flex-row-reverse' : 'flex-row')}>
            <div
              className={cn(
                'flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-xs font-bold',
                message.role === 'user' ? 'bg-blue-600 text-white' : 'bg-gradient-to-br from-purple-500 to-blue-600 text-white',
              )}
            >
              {message.role === 'user' ? 'U' : 'AI'}
            </div>
            <div className={cn('flex max-w-[85%] flex-1', message.role === 'user' ? 'justify-end' : 'justify-start')}>
              <div
                className={cn(
                  'rounded-xl px-4 py-3 text-sm',
                  message.role === 'user' ? 'bg-blue-600 text-white' : 'border border-slate-200 bg-white text-slate-800',
                )}
              >
                <div className="whitespace-pre-wrap leading-relaxed">{message.text}</div>
              </div>
            </div>
          </div>
        ))}

        {loading ? (
          <div className="flex gap-3">
            <div className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-purple-500 to-blue-600 text-xs font-bold text-white">AI</div>
            <div className="flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-3">
              <Loader2 className="h-3.5 w-3.5 animate-spin text-blue-500" />
              <span className="text-sm text-slate-500">正在搜索和分析...</span>
            </div>
          </div>
        ) : null}
        <div ref={endRef} />
      </div>

      <div className="shrink-0 border-t border-slate-200 p-3">
        <div className="flex gap-2">
          <input
            className="h-10 flex-1 rounded-lg border border-slate-200 px-3 text-sm outline-none focus:border-blue-400 focus:ring-2 focus:ring-blue-100"
            placeholder="输入产业链相关问题..."
            value={input}
            onChange={(event) => setInput(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === 'Enter' && !event.shiftKey) send();
            }}
            disabled={loading}
          />
          {loading ? (
            <Button size="sm" variant="outline" onClick={stop} className="h-10 gap-1.5 border-red-200 text-red-600 hover:bg-red-50">
              <Square className="h-3.5 w-3.5" />
              停止
            </Button>
          ) : (
            <Button size="sm" onClick={() => send()} disabled={!input.trim()} className="h-10 gap-1.5">
              <Send className="h-3.5 w-3.5" />
              发送
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

export function AgentStudio() {
  const [agents, setAgents] = useState<Agent[]>([]);
  const [eventsByAgent, setEventsByAgent] = useState<Record<string, AgentEvent[]>>({});
  const [analysesByAgent, setAnalysesByAgent] = useState<Record<string, AgentAnalysis[]>>({});
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [running, setRunning] = useState<string | null>(null);
  const [detailTab, setDetailTab] = useState<'events' | 'analyses'>('analyses');
  const [mainTab, setMainTab] = useState<'agents' | 'hot' | 'qa'>('agents');
  const [manualLithiumPrice, setManualLithiumPrice] = useState('20.00');
  const [manualGenerating, setManualGenerating] = useState(false);
  const [deletingAnalysisId, setDeletingAnalysisId] = useState<string | null>(null);

  const selectedAgent = useMemo(() => agents.find((agent) => agent.id === selectedId) || null, [agents, selectedId]);
  const isPriceTrackingAgent = selectedAgent?.id === 'demo_agent_lithium';
  const events = selectedId ? eventsByAgent[selectedId] || [] : [];
  const analyses = selectedId ? analysesByAgent[selectedId] || [] : [];

  useEffect(() => {
    let cancelled = false;

    const loadAgents = async () => {
      try {
        const result = await api.getResearchAgents();

        if (cancelled) return;

        const nextAgents = result.agents || [];
        setAgents(nextAgents);
        setSelectedId((prev) => (prev && nextAgents.some((agent: Agent) => agent.id === prev) ? prev : nextAgents[0]?.id || null));

        const details = await Promise.all(
          nextAgents.map(async (agent: Agent) => {
            const [eventsResult, analysesResult] = await Promise.all([
              api.getAgentEvents(agent.id),
              api.getAgentAnalyses(agent.id),
            ]);

            return {
              agentId: agent.id,
              events: (eventsResult.events || []).map(mapBackendEvent),
              analyses: (analysesResult.analyses || []).map(mapBackendAnalysis),
            };
          }),
        );

        if (cancelled) return;

        const nextEventsByAgent: Record<string, AgentEvent[]> = {};
        const nextAnalysesByAgent: Record<string, AgentAnalysis[]> = {};
        details.forEach(({ agentId, events, analyses }) => {
          nextEventsByAgent[agentId] = events;
          nextAnalysesByAgent[agentId] = analyses;
        });

        setEventsByAgent(nextEventsByAgent);
        setAnalysesByAgent(nextAnalysesByAgent);
      } catch {
        if (!cancelled) {
          setAgents([]);
          setSelectedId(null);
          setEventsByAgent({});
          setAnalysesByAgent({});
        }
      }
    };

    loadAgents();

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (selectedAgent?.id === 'demo_agent_lithium' && detailTab !== 'analyses') {
      setDetailTab('analyses');
    }
  }, [detailTab, selectedAgent]);

  const handleToggle = (agent: Agent) => {
    setAgents((prev) =>
      prev.map((item) =>
        item.id === agent.id
          ? { ...item, is_active: item.is_active ? 0 : 1, updated_at: formatDateTime(new Date()) }
          : item,
      ),
    );
    toast.success(agent.is_active ? '已暂停标的跟踪' : '已启用标的跟踪');
  };

  const handleRun = async (agentId: string) => {
    setRunning(agentId);
    try {
      if (agentId === DEMO_LITHIUM_AGENT_ID) {
        await api.runResearchAgent(agentId);
        const [eventsResult, analysesResult] = await Promise.all([
          api.getAgentEvents(agentId),
          api.getAgentAnalyses(agentId),
        ]);
        const nextEvents = (eventsResult.events || []).map(mapBackendEvent);
        const nextAnalyses = (analysesResult.analyses || []).map(mapBackendAnalysis);
        const latestRunAt = nextAnalyses[0]?.created_at || nextEvents[0]?.created_at || formatDateTime(new Date());

        setAgents((prev) =>
          prev.map((agent) =>
            agent.id === agentId
              ? {
                  ...agent,
                  last_run_at: latestRunAt,
                  updated_at: latestRunAt,
                }
              : agent,
          ),
        );
        setEventsByAgent((prev) => ({ ...prev, [agentId]: nextEvents }));
        setAnalysesByAgent((prev) => ({ ...prev, [agentId]: nextAnalyses }));
        toast.success('数据已刷新');
      } else {
        await api.runResearchAgent(agentId);
        const [eventsResult, analysesResult] = await Promise.all([
          api.getAgentEvents(agentId),
          api.getAgentAnalyses(agentId),
        ]);
        const nextEvents = (eventsResult.events || []).map(mapBackendEvent);
        const nextAnalyses = (analysesResult.analyses || []).map(mapBackendAnalysis);
        const latestRunAt = nextAnalyses[0]?.created_at || nextEvents[0]?.created_at || formatDateTime(new Date());

        setAgents((prev) =>
          prev.map((agent) =>
            agent.id === agentId
              ? {
                  ...agent,
                  last_run_at: latestRunAt,
                  updated_at: latestRunAt,
                }
              : agent,
          ),
        );
        setEventsByAgent((prev) => ({ ...prev, [agentId]: nextEvents }));
        setAnalysesByAgent((prev) => ({ ...prev, [agentId]: nextAnalyses }));

        toast.success('数据已刷新');
      }
    } catch (error: any) {
      toast.error(error.message || '运行失败');
    } finally {
      setRunning(null);
    }
  };

  const handleDelete = (agentId: string) => {
    const remainingAgents = agents.filter((agent) => agent.id !== agentId);
    setAgents(remainingAgents);
    setEventsByAgent((prev) => {
      const next = { ...prev };
      delete next[agentId];
      return next;
    });
    setAnalysesByAgent((prev) => {
      const next = { ...prev };
      delete next[agentId];
      return next;
    });
    setSelectedId((prev) => (prev === agentId ? remainingAgents[0]?.id || null : prev));
    toast.success('标的跟踪已删除');
  };

  const handleGenerateManualLithiumAnalysis = async () => {
    if (!selectedAgent || selectedAgent.id !== DEMO_LITHIUM_AGENT_ID) return;

    const latestPrice = Number.parseFloat(manualLithiumPrice);
    if (!Number.isFinite(latestPrice) || latestPrice <= 0) {
      toast.error('请输入有效的碳酸锂最新价格');
      return;
    }

    setManualGenerating(true);
    try {
      await api.createManualLithiumAnalysis(DEMO_LITHIUM_AGENT_ID, {
        previousPrice: MANUAL_LITHIUM_BASE_PRICE,
        latestPrice,
        depth: 4,
      });

      const analysesResult = await api.getAgentAnalyses(DEMO_LITHIUM_AGENT_ID);
      const nextAnalyses = (analysesResult.analyses || []).map(mapBackendAnalysis);

      setAnalysesByAgent((prev) => ({
        ...prev,
        [DEMO_LITHIUM_AGENT_ID]: nextAnalyses,
      }));
      toast.success('价格传导分析已生成');
    } catch (error: any) {
      toast.error(error.message || '价格传导分析生成失败');
    } finally {
      setManualGenerating(false);
    }
  };

  const handleDeleteAnalysis = async (analysis: AgentAnalysis) => {
    if (!selectedAgent) return;

    setDeletingAnalysisId(analysis.id);
    try {
      if (!analysis.isTemporary) {
        await api.deleteAgentAnalysis(selectedAgent.id, analysis.id);
      }

      setAnalysesByAgent((prev) => ({
        ...prev,
        [selectedAgent.id]: (prev[selectedAgent.id] || []).filter((item) => item.id !== analysis.id),
      }));
      toast.success('分析报告已删除');
    } catch (error: any) {
      toast.error(error.message || '删除分析报告失败');
    } finally {
      setDeletingAnalysisId(null);
    }
  };

  return (
    <div className="flex h-[calc(100vh-8.5rem)] flex-col -m-6">
      <div className="flex shrink-0 border-b border-slate-200 bg-white px-6">
        <button
          onClick={() => setMainTab('agents')}
          className={cn(
            'flex items-center gap-2 border-b-2 px-4 py-3 text-sm font-medium transition-colors',
            mainTab === 'agents' ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700',
          )}
        >
          <Bot className="h-4 w-4" />
          标的跟踪
        </button>
        <button
          onClick={() => setMainTab('hot')}
          className={cn(
            'flex items-center gap-2 border-b-2 px-4 py-3 text-sm font-medium transition-colors',
            mainTab === 'hot' ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700',
          )}
        >
          <Flame className="h-4 w-4" />
          事件跟踪
        </button>
        <button
          onClick={() => setMainTab('qa')}
          className={cn(
            'flex items-center gap-2 border-b-2 px-4 py-3 text-sm font-medium transition-colors',
            mainTab === 'qa' ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700',
          )}
        >
          <MessageSquare className="h-4 w-4" />
          产业链智能问答
        </button>
      </div>

      <div className={cn('flex-1 min-h-0', mainTab !== 'hot' && 'hidden')}>
        <HotEventInterpretationPanel />
      </div>

      <div className={cn('flex-1 min-h-0', mainTab !== 'qa' && 'hidden')}>
        <OntologyQAPanel fallbackAgentId={agents[0]?.id} />
      </div>

      <div className={cn('flex min-h-0 flex-1 gap-6 p-6', mainTab !== 'agents' && 'hidden')}>
        <div className="flex w-80 shrink-0 flex-col gap-4">
          <div className="flex items-center justify-between">
            <h2 className="flex items-center gap-2 text-lg font-bold text-slate-900">
              <Bot className="h-5 w-5 text-blue-600" />
              标的跟踪
            </h2>
            <Button size="sm" variant="outline" className="h-7 gap-1 text-xs" onClick={() => setShowCreate(true)}>
              <Plus className="h-3 w-3" />
              新建
            </Button>
          </div>

          {showCreate ? (
            <CreateAgentForm
              onCreated={(agent) => {
                setAgents((prev) => [agent, ...prev]);
                setSelectedId(agent.id);
                setEventsByAgent((prev) => ({ ...prev, [agent.id]: [] }));
                setAnalysesByAgent((prev) => ({ ...prev, [agent.id]: [] }));
                setShowCreate(false);
              }}
              onCancel={() => setShowCreate(false)}
            />
          ) : null}

          <div className="flex-1 space-y-2 overflow-y-auto pr-1">
            {agents.length === 0 && !showCreate ? (
              <div className="py-16 text-center text-slate-400">
                <Bot className="mx-auto mb-3 h-10 w-10 opacity-30" />
                <p className="text-sm font-medium">还没有标的跟踪</p>
                <p className="mt-1 text-xs">创建一个标的跟踪后，就能开始持续发现事件</p>
                <Button size="sm" className="mt-4 gap-1" onClick={() => setShowCreate(true)}>
                  <Plus className="h-3 w-3" />
                  创建标的跟踪
                </Button>
              </div>
            ) : (
              agents.map((agent) => (
                <AgentCard
                  key={agent.id}
                  agent={agent}
                  selected={selectedId === agent.id}
                  onSelect={() => setSelectedId(agent.id)}
                  onToggle={() => handleToggle(agent)}
                  onRun={() => handleRun(agent.id)}
                  onDelete={() => handleDelete(agent.id)}
                  running={running === agent.id}
                />
              ))
            )}
          </div>
        </div>

        <div className="flex min-w-0 flex-1 flex-col gap-4">
          {selectedAgent ? (
            <>
              <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
                <div className="mb-3 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div
                      className={cn(
                        'flex h-10 w-10 items-center justify-center rounded-xl',
                        selectedAgent.is_active ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-400',
                      )}
                    >
                      <Bot className="h-5 w-5" />
                    </div>
                    <div>
                      <h2 className="text-lg font-bold text-slate-900">{selectedAgent.name}</h2>
                      <div className="flex items-center gap-2 text-xs text-slate-500">
                        <Building2 className="h-3 w-3" />
                        {selectedAgent.target_company} · {selectedAgent.target_industry}
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <span
                      className={cn(
                        'rounded-full px-2 py-1 text-xs font-medium',
                        selectedAgent.is_active ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-500',
                      )}
                    >
                      {selectedAgent.is_active ? '● 运行中' : '○ 已暂停'}
                    </span>
                    <Button size="sm" onClick={() => handleRun(selectedAgent.id)} disabled={running === selectedAgent.id} className="gap-1.5">
	              {running === selectedAgent.id ? (
                        <>
                          <Loader2 className="h-3.5 w-3.5 animate-spin" />
                          运行中...
                        </>
                      ) : (
                        <>
                          <Play className="h-3.5 w-3.5" />
                          立即运行
                        </>
                      )}
                    </Button>
                  </div>
                </div>

                {selectedAgent.analysis_focus ? (
                  <div className="flex items-center gap-2 rounded-lg bg-slate-50 px-3 py-2 text-xs text-slate-500">
                    <Target className="h-3.5 w-3.5 text-blue-500" />
                    <span className="font-medium text-slate-600">研究重点：</span>
                    {selectedAgent.analysis_focus}
                  </div>
                ) : null}

                <div className="mt-3 flex items-center gap-4 text-[11px] text-slate-400">
                  <span className="flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    最近运行：{selectedAgent.last_run_at ? timeAgo(selectedAgent.last_run_at) : '从未执行'}
                  </span>
                  <span className="flex items-center gap-1">
                    <RefreshCw className="h-3 w-3" />
                    {isPriceTrackingAgent ? '调度频率：碳酸锂价格波动 5% 以上触发' : `调度频率：每 ${selectedAgent.schedule_minutes} 分钟`}
                  </span>
                </div>
              </div>

              {running === selectedAgent.id ? (
                <div className="flex items-center gap-3 rounded-lg border border-blue-200 bg-blue-50 px-4 py-3 text-sm text-blue-700">
                  <Loader2 className="h-4 w-4 animate-spin" />
                  <div>
                    <span className="font-medium">标的跟踪正在运行...</span>
                    <span className="ml-2 text-blue-500">正在同步最新数据</span>
                  </div>
                </div>
	              ) : null}

              {isPriceTrackingAgent ? (
                <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
                  <div className="flex flex-wrap items-end justify-between gap-4">
                    <div>
                      <h3 className="text-sm font-semibold text-slate-900">概念层价格传导分析</h3>
                      <p className="mt-1 text-xs text-slate-500">
                        输入源概念最新价格，系统将以 {MANUAL_LITHIUM_BASE_PRICE.toFixed(2)} 为基准价快速生成本轮概念层传导结果。
                      </p>
                    </div>
                    <div className="flex flex-wrap items-end gap-3">
                      <div>
                        <div className="mb-1 text-[11px] text-slate-400">基准价</div>
                        <div className="h-10 rounded-lg border border-slate-200 bg-slate-50 px-3 text-sm leading-10 text-slate-600">
                          {MANUAL_LITHIUM_BASE_PRICE.toFixed(2)}
                        </div>
                      </div>
                      <div>
                        <label className="mb-1 block text-[11px] text-slate-400">最新价格</label>
                        <input
                          className="h-10 w-32 rounded-lg border border-slate-200 px-3 text-sm outline-none focus:border-blue-400 focus:ring-2 focus:ring-blue-100"
                          value={manualLithiumPrice}
                          onChange={(event) => setManualLithiumPrice(event.target.value)}
                          placeholder="例如 20.00"
                        />
                      </div>
                      <Button onClick={handleGenerateManualLithiumAnalysis} disabled={manualGenerating} className="gap-1.5">
                        {manualGenerating ? (
                          <>
                            <Loader2 className="h-3.5 w-3.5 animate-spin" />
                            生成中...
                          </>
                        ) : (
                          <>
                            <Sparkles className="h-3.5 w-3.5" />
                            生成分析
                          </>
                        )}
                      </Button>
                    </div>
                  </div>
                </div>
              ) : null}

	              <div className="w-fit rounded-lg bg-slate-100 p-1">
                <button
                  onClick={() => setDetailTab('analyses')}
                  className={cn(
                    'rounded-md px-4 py-1.5 text-sm font-medium transition-colors',
                    detailTab === 'analyses' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700',
                  )}
                >
                  <span className="flex items-center gap-1.5">
                    <FileText className="h-3.5 w-3.5" />
                    分析报告 ({analyses.length})
                  </span>
                </button>
                {!isPriceTrackingAgent ? (
                  <button
                    onClick={() => setDetailTab('events')}
                    className={cn(
                      'rounded-md px-4 py-1.5 text-sm font-medium transition-colors',
                      detailTab === 'events' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700',
                    )}
                  >
                    <span className="flex items-center gap-1.5">
                      <Zap className="h-3.5 w-3.5" />
                      事件列表 ({events.length})
                    </span>
                  </button>
                ) : null}
              </div>

              <div className="flex-1 space-y-4 overflow-y-auto pr-1">
                {detailTab === 'analyses' ? (
                  analyses.length === 0 ? (
                    <div className="py-16 text-center text-slate-400">
                      <Sparkles className="mx-auto mb-3 h-10 w-10 opacity-30" />
                      <p className="text-sm font-medium">暂时还没有分析报告</p>
                      <p className="mt-1 text-xs">运行标的跟踪后会生成最新分析报告</p>
                    </div>
	                  ) : (
	                    analyses.map((analysis) => (
                        <AnalysisReport
                          key={analysis.id}
                          analysis={analysis}
                          deleting={deletingAnalysisId === analysis.id}
                          onDelete={handleDeleteAnalysis}
                        />
                      ))
	                  )
	                ) : (
                  <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
                    <EventTimeline events={events} />
                  </div>
                )}
              </div>
            </>
          ) : (
            <div className="flex h-full items-center justify-center text-slate-400">
              <div className="text-center">
                <Bot className="mx-auto mb-3 h-12 w-12 opacity-20" />
                <p className="font-medium">请选择一个标的跟踪查看详情</p>
                <p className="mt-1 text-sm">或者先新建一个标的跟踪</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
