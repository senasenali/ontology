CREATE TABLE IF NOT EXISTS company_entity (
  company_id VARCHAR(100) NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  stock_code VARCHAR(64) NULL,
  market VARCHAR(32) NULL,
  industry VARCHAR(128) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS news_events (
  id VARCHAR(64) NOT NULL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  summary TEXT NULL,
  content TEXT NULL,
  category VARCHAR(64) NULL,
  source VARCHAR(128) NULL,
  event_date DATE NULL,
  tags JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS relation_candidates (
  id VARCHAR(64) NOT NULL PRIMARY KEY,
  news_event_id VARCHAR(64) NOT NULL,
  source_object_type_id VARCHAR(255) NOT NULL,
  source_instance_id VARCHAR(100) NOT NULL,
  target_object_type_id VARCHAR(255) NOT NULL,
  target_instance_id VARCHAR(100) NOT NULL,
  link_type_id VARCHAR(255) NOT NULL,
  relation_name VARCHAR(255) NOT NULL,
  evidence TEXT NULL,
  confidence DECIMAL(5,2) NULL,
  llm_source VARCHAR(32) NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'recognized',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_relation_candidates_news_event_id (news_event_id)
);

INSERT INTO object_types (
  id,
  name,
  description,
  icon,
  backing_dataset,
  status
)
SELECT
  'company_entity',
  '公司实体',
  '用于承载上市公司、产业链公司等实例关系发现与关系写回',
  'Building2',
  'company_entity',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM object_types WHERE id = 'company_entity'
);

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_company_id_demo', 'company_entity', '公司唯一标识符', 'string', '公司实例主键', 1, 'company_id', 0
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_company_id_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_company_name_demo', 'company_entity', '公司名称', 'string', '公司名称', 0, 'name', 1
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_company_name_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_company_stock_code_demo', 'company_entity', '股票代码', 'string', '股票代码', 0, 'stock_code', 2
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_company_stock_code_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_company_market_demo', 'company_entity', '上市市场', 'string', '上市市场', 0, 'market', 3
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_company_market_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_company_industry_demo', 'company_entity', '所属行业', 'string', '所属行业', 0, 'industry', 4
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_company_industry_demo');

INSERT INTO company_entity (company_id, name, stock_code, market, industry)
VALUES
  ('COMP_CATL', '宁德时代', '300750', 'SZ', '动力电池'),
  ('COMP_CET', '中恒电气', '002364', 'SZ', '储能设备')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  stock_code = VALUES(stock_code),
  market = VALUES(market),
  industry = VALUES(industry);

INSERT INTO link_types (
  id,
  name,
  source_object_id,
  target_object_id,
  cardinality,
  description,
  source_column,
  target_column,
  status
)
SELECT
  'lt_company_strategic_cooperation',
  '战略合作',
  'company_entity',
  'company_entity',
  'N:M',
  '用于表达公司间的战略合作、联合研发与协同合作关系',
  'company_id',
  'company_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_company_strategic_cooperation'
);

DELETE FROM action_rule_params
WHERE action_rule_id IN ('ar_create_company_strategic_link', 'ar_create_company_company_link', 'ar_delete_company_company_link');

DELETE FROM action_rules
WHERE id IN ('ar_create_company_strategic_link', 'ar_create_company_company_link', 'ar_delete_company_company_link');

DELETE FROM action_effects
WHERE id IN ('ae_create_company_strategic_link', 'ae_create_company_company_link', 'ae_delete_company_company_link');

DELETE FROM action_types
WHERE id IN ('act_create_company_strategic_link', 'act_create_company_company_link', 'act_delete_company_company_link');

DELETE FROM function_params WHERE function_id = 'func_create_company_strategic_link';
DELETE FROM function_types WHERE id = 'func_create_company_strategic_link';

DELETE FROM ontology_rule_params
WHERE rule_id IN ('rule_create_company_company_link', 'rule_delete_company_company_link');

DELETE FROM ontology_rules
WHERE id IN ('rule_create_company_company_link', 'rule_delete_company_company_link');

INSERT INTO ontology_rules (id, rule_category, function_name, interface_type, request_method, interface_url, created_at, updated_at)
VALUES
  ('rule_create_company_company_link', 'CREATE_LINK', '创建公司与公司间的链接', 'RESTFUL', 'POST', '/api/link-instances/lt_company_strategic_cooperation', NOW(), NOW()),
  ('rule_delete_company_company_link', 'DELETE_LINK', '删除公司与公司间的链接', 'RESTFUL', 'DELETE', '/api/link-instances/lt_company_strategic_cooperation', NOW(), NOW());

INSERT INTO ontology_rule_params (id, rule_id, param_direction, param_name, param_type, is_required, description, sort_order) VALUES
  ('rule_create_company_company_link_in_0', 'rule_create_company_company_link', 'INPUT', 'sourceInstanceId', 'string', 1, '源公司实例ID', 0),
  ('rule_create_company_company_link_in_1', 'rule_create_company_company_link', 'INPUT', 'targetInstanceId', 'string', 1, '目标公司实例ID', 1),
  ('rule_create_company_company_link_in_2', 'rule_create_company_company_link', 'INPUT', 'linkTypeId', 'string', 0, '关系链接类型ID，默认战略合作', 2),
  ('rule_create_company_company_link_out_0', 'rule_create_company_company_link', 'OUTPUT', 'success', 'boolean', 1, '是否成功创建链接', 0),
  ('rule_create_company_company_link_out_1', 'rule_create_company_company_link', 'OUTPUT', 'message', 'string', 0, '返回消息', 1),
  ('rule_delete_company_company_link_in_0', 'rule_delete_company_company_link', 'INPUT', 'sourceInstanceId', 'string', 1, '源公司实例ID', 0),
  ('rule_delete_company_company_link_in_1', 'rule_delete_company_company_link', 'INPUT', 'targetInstanceId', 'string', 1, '目标公司实例ID', 1),
  ('rule_delete_company_company_link_in_2', 'rule_delete_company_company_link', 'INPUT', 'linkTypeId', 'string', 0, '关系链接类型ID，默认战略合作', 2),
  ('rule_delete_company_company_link_out_0', 'rule_delete_company_company_link', 'OUTPUT', 'success', 'boolean', 1, '是否成功删除链接', 0),
  ('rule_delete_company_company_link_out_1', 'rule_delete_company_company_link', 'OUTPUT', 'message', 'string', 0, '返回消息', 1);

INSERT INTO action_types (id, display_name, description, status)
VALUES
  ('act_create_company_company_link', '创建链接', '将识别到的公司间战略合作关系写入图谱', 'ACTIVE'),
  ('act_delete_company_company_link', '删除链接', '删除已写入图谱的公司间战略合作关系', 'ACTIVE');

INSERT INTO action_rules (id, action_type_id, rule_type, ontology_rule_category, ontology_rule_id, sort_order)
VALUES
  ('ar_create_company_company_link', 'act_create_company_company_link', 'ONTOLOGY', 'CREATE_LINK', 'rule_create_company_company_link', 0),
  ('ar_delete_company_company_link', 'act_delete_company_company_link', 'ONTOLOGY', 'DELETE_LINK', 'rule_delete_company_company_link', 0);

INSERT INTO action_effects (id, action_type_id, effect_type, content, is_enabled, sort_order)
VALUES
  ('ae_create_company_company_link', 'act_create_company_company_link', 'NOTIFICATION', '已创建新的公司合作关系链接', 1, 0),
  ('ae_delete_company_company_link', 'act_delete_company_company_link', 'NOTIFICATION', '已删除公司合作关系链接', 1, 0);

INSERT INTO news_events (id, title, summary, content, category, source, event_date, tags)
VALUES
  (
    'news_catl_cet_001',
    '宁德时代与中恒电气达成储能协同合作',
    '合作消息触发市场对储能产业链关系的重新梳理，研究员希望确认合作关系是否足以沉淀为图谱中的正式关系。',
    '宁德时代与中恒电气宣布围绕储能场景展开协同合作，合作方向包括储能系统集成、站端设备协同与项目拓展。市场关注这是否意味着双方将在储能领域形成更明确的合作关系。',
    '关系发现',
    '证券时报',
    '2026-04-13',
    JSON_ARRAY('储能', '合作关系')
  ),
  (
    'news_charging_policy_001',
    '政策支持充电基础设施建设',
    '政策端继续强调充电基础设施建设和补能网络完善，市场关注其对充电运营、设备制造及整车消费渗透的带动效应。',
    '政策端继续强调充电基础设施建设和补能网络完善，市场关注其对充电运营、设备制造及整车消费渗透的带动效应。',
    '政策驱动',
    '证券时报',
    '2026-04-15',
    JSON_ARRAY('充电基础设施', '高压快充', '新能源汽车')
  )
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  summary = VALUES(summary),
  content = VALUES(content),
  category = VALUES(category),
  source = VALUES(source),
  event_date = VALUES(event_date),
  tags = VALUES(tags);
