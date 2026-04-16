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

INSERT INTO object_types (
  id,
  name,
  description,
  icon,
  backing_dataset,
  status
)
SELECT
  'event_entity',
  '事件',
  '用于承载新闻、政策、价格波动、合作公告等事件实体',
  'Newspaper',
  'news_events',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM object_types WHERE id = 'event_entity'
);

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_id_demo', 'event_entity', '事件ID', 'string', '事件主键', 1, 'id', 0
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_id_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_title_demo', 'event_entity', '事件标题', 'string', '事件标题', 0, 'title', 1
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_title_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_summary_demo', 'event_entity', '事件摘要', 'string', '事件摘要', 0, 'summary', 2
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_summary_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_content_demo', 'event_entity', '事件正文', 'string', '事件正文', 0, 'content', 3
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_content_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_category_demo', 'event_entity', '事件分类', 'string', '事件分类', 0, 'category', 4
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_category_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_source_demo', 'event_entity', '事件来源', 'string', '事件来源', 0, 'source', 5
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_source_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_date_demo', 'event_entity', '事件日期', 'date', '事件发生日期', 0, 'event_date', 6
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_date_demo');

INSERT INTO properties (id, object_type_id, name, type, description, is_primary_key, base_column, sort_order)
SELECT 'p_event_tags_demo', 'event_entity', '事件标签', 'string', '事件标签 JSON', 0, 'tags', 7
WHERE NOT EXISTS (SELECT 1 FROM properties WHERE id = 'p_event_tags_demo');

INSERT INTO company_entity (company_id, name, stock_code, market, industry)
VALUES
  ('COMP_CATL', '宁德时代', '300750', 'SZ', '动力电池'),
  ('COMP_CET', '中恒电气', '002364', 'SZ', '储能设备'),
  ('COMP_BYD', '比亚迪', '002594', 'SZ', '新能源汽车')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  stock_code = VALUES(stock_code),
  market = VALUES(market),
  industry = VALUES(industry);

DELETE FROM link_instance_data
WHERE source_instance_id IN (
  'COMP_LGES', 'COMP_SKI', 'COMP_PANA', 'COMP_SVOLT', 'COMP_CALB', 'COMP_EVE',
  'COMP_GOTION', 'COMP_REPT', 'COMP_TESLA', 'COMP_NIO', 'COMP_XPENG', 'COMP_LI',
  'COMP_GAC_AION', 'COMP_ZEEKR', 'COMP_SERES', 'COMP_DEEPAL'
)
   OR target_instance_id IN (
  'COMP_LGES', 'COMP_SKI', 'COMP_PANA', 'COMP_SVOLT', 'COMP_CALB', 'COMP_EVE',
  'COMP_GOTION', 'COMP_REPT', 'COMP_TESLA', 'COMP_NIO', 'COMP_XPENG', 'COMP_LI',
  'COMP_GAC_AION', 'COMP_ZEEKR', 'COMP_SERES', 'COMP_DEEPAL'
);

DELETE FROM company_entity
WHERE company_id IN (
  'COMP_LGES', 'COMP_SKI', 'COMP_PANA', 'COMP_SVOLT', 'COMP_CALB', 'COMP_EVE',
  'COMP_GOTION', 'COMP_REPT', 'COMP_TESLA', 'COMP_NIO', 'COMP_XPENG', 'COMP_LI',
  'COMP_GAC_AION', 'COMP_ZEEKR', 'COMP_SERES', 'COMP_DEEPAL'
);

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
  'lt_event_mentions_company_entity',
  '事件关联公司',
  'event_entity',
  'company_entity',
  'N:M',
  '用于表达事件与公司之间的影响、提及、合作或关联关系',
  'id',
  'company_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_event_mentions_company_entity'
);

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
  'lt_event_affects_new_energy_vehicle',
  '事件影响整车',
  'event_entity',
  'new_energy_vehicle',
  'N:M',
  '用于表达事件对新能源整车产品的影响或关联',
  'id',
  'vehicle_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_event_affects_new_energy_vehicle'
);

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
  'lt_event_affects_lithium_carbonate',
  '事件影响碳酸锂',
  'event_entity',
  'lithium_carbonate',
  'N:M',
  '用于表达事件对碳酸锂产品或价格的影响',
  'id',
  'unique_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_event_affects_lithium_carbonate'
);

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
  'lt_company_supplier',
  '公司供应商',
  'company_entity',
  'company_entity',
  'N:M',
  '用于表达公司与其上游供应商公司之间的关系',
  'company_id',
  'company_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_company_supplier'
);

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
  'lt_company_manufactures_battery_cell',
  '生产电芯',
  'company_entity',
  'battery_cell',
  '1:N',
  '用于表达公司与其生产电芯实例之间的关系',
  'company_id',
  'unique_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_company_manufactures_battery_cell'
);

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
  'lt_company_manufactures_power_battery',
  '生产电池',
  'company_entity',
  'power_battery',
  '1:N',
  '用于表达公司与其生产动力电池实例之间的关系',
  'company_id',
  'unique_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_company_manufactures_power_battery'
);

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
  'lt_company_manufactures_lithium_carbonate',
  '生产碳酸锂',
  'company_entity',
  'lithium_carbonate',
  '1:N',
  '用于表达公司与其生产碳酸锂实例之间的关系',
  'company_id',
  'unique_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_company_manufactures_lithium_carbonate'
);

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
  'lt_company_manufactures_new_energy_vehicle',
  '生产整车',
  'company_entity',
  'new_energy_vehicle',
  '1:N',
  '用于表达公司与其生产新能源整车实例之间的关系',
  'company_id',
  'vehicle_id',
  'active'
WHERE NOT EXISTS (
  SELECT 1 FROM link_types WHERE id = 'lt_company_manufactures_new_energy_vehicle'
);

DELETE FROM link_instance_data
WHERE source_instance_id = 'news_lithium_price_001';

DELETE FROM news_events
WHERE id = 'news_lithium_price_001';

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_event_mentions_company_entity', 'news_catl_cet_001', 'COMP_CATL', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_event_mentions_company_entity'
    AND source_instance_id = 'news_catl_cet_001'
    AND target_instance_id = 'COMP_CATL'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_event_mentions_company_entity', 'news_catl_cet_001', 'COMP_CET', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_event_mentions_company_entity'
    AND source_instance_id = 'news_catl_cet_001'
    AND target_instance_id = 'COMP_CET'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_event_affects_new_energy_vehicle', 'news_charging_policy_001', 'LHGCR1640J8100001', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_event_affects_new_energy_vehicle'
    AND source_instance_id = 'news_charging_policy_001'
    AND target_instance_id = 'LHGCR1640J8100001'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_event_affects_new_energy_vehicle', 'news_charging_policy_001', 'LS5A2ABE9KA100001', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_event_affects_new_energy_vehicle'
    AND source_instance_id = 'news_charging_policy_001'
    AND target_instance_id = 'LS5A2ABE9KA100001'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_supplier', 'COMP_CET', 'COMP_CATL', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_supplier'
    AND source_instance_id = 'COMP_CET'
    AND target_instance_id = 'COMP_CATL'
);

DELETE FROM link_instance_data
WHERE link_type_id = 'lt_power_battery_battery_cell_1775472262897'
  AND (
    (source_instance_id = 'GOTION-LFP-001-24' AND target_instance_id = 'BC-ATL-001-2024')
    OR (source_instance_id = 'GOTION-NCM-001-24' AND target_instance_id = 'BC-LG-001-2024')
    OR (source_instance_id = 'REPT-LFP-001-2024' AND target_instance_id = 'BC-CALB-001-2024')
    OR (source_instance_id = 'REPT-NCM-001-2024' AND target_instance_id = 'BC-EVE-001-2024')
  );

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_battery_cell', 'COMP_CATL', 'BC-ATL-001-2024', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_battery_cell'
    AND source_instance_id = 'COMP_CATL'
    AND target_instance_id = 'BC-ATL-001-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_battery_cell', 'COMP_CATL', 'BC-ATL-002-2024', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_battery_cell'
    AND source_instance_id = 'COMP_CATL'
    AND target_instance_id = 'BC-ATL-002-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_battery_cell', 'COMP_BYD', 'BC-BYD-001-2024', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_battery_cell'
    AND source_instance_id = 'COMP_BYD'
    AND target_instance_id = 'BC-BYD-001-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_power_battery', 'COMP_CATL', 'BT-CATL-001-2024', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_power_battery'
    AND source_instance_id = 'COMP_CATL'
    AND target_instance_id = 'BT-CATL-001-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_power_battery', 'COMP_CATL', 'BT-CATL-002-2024', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_power_battery'
    AND source_instance_id = 'COMP_CATL'
    AND target_instance_id = 'BT-CATL-002-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_power_battery', 'COMP_CATL', 'BT-CATL-003-2024', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_power_battery'
    AND source_instance_id = 'COMP_CATL'
    AND target_instance_id = 'BT-CATL-003-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_power_battery', 'COMP_BYD', 'BYD-BLADE-001-24', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_power_battery'
    AND source_instance_id = 'COMP_BYD'
    AND target_instance_id = 'BYD-BLADE-001-24'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_power_battery', 'COMP_BYD', 'BYD-BLADE-002-24', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_power_battery'
    AND source_instance_id = 'COMP_BYD'
    AND target_instance_id = 'BYD-BLADE-002-24'
);

DELETE FROM link_instance_data
WHERE link_type_id = 'lt_company_manufactures_new_energy_vehicle'
  AND (
    source_instance_id IN (
      'COMP_TESLA', 'COMP_NIO', 'COMP_XPENG', 'COMP_LI',
      'COMP_GAC_AION', 'COMP_ZEEKR', 'COMP_SERES', 'COMP_DEEPAL'
    )
  );

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_new_energy_vehicle', 'COMP_BYD', 'LVGBE40K9LG100001', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_new_energy_vehicle'
    AND source_instance_id = 'COMP_BYD'
    AND target_instance_id = 'LVGBE40K9LG100001'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_new_energy_vehicle', 'COMP_BYD', 'LVGBE40K9LG100002', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_new_energy_vehicle'
    AND source_instance_id = 'COMP_BYD'
    AND target_instance_id = 'LVGBE40K9LG100002'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_new_energy_vehicle', 'COMP_BYD', 'LVGBE40K9LG100003', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_new_energy_vehicle'
    AND source_instance_id = 'COMP_BYD'
    AND target_instance_id = 'LVGBE40K9LG100003'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at)
SELECT 'lt_company_manufactures_new_energy_vehicle', 'COMP_BYD', 'LVGBE40K9LG100004', NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_company_manufactures_new_energy_vehicle'
    AND source_instance_id = 'COMP_BYD'
    AND target_instance_id = 'LVGBE40K9LG100004'
);
