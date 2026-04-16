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
