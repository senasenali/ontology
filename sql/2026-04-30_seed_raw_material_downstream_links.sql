-- 原材料 -> 下游环节关系类型与实例关系
-- 设计说明：
-- 1. 延续现有系统语义，source 侧放下游对象，target 侧放上游原材料
-- 2. 让关系查询与价格传导分析可以直接沿现有链路复用

-- 1) 新增 Link Type
INSERT INTO link_types (
  id, name, source_object_id, target_object_id, cardinality, description, industry_id, source_column, target_column, status
)
VALUES
  (
    'lt_cathode_material_lithium_iron_phosphate',
    '正极材料由磷酸铁锂组成',
    'cathode_material',
    'lithium_iron_phosphate',
    'N:1',
    '正极材料的生产会使用磷酸铁锂作为关键材料输入，同一种磷酸铁锂可供多个正极材料实例使用。',
    NULL,
    'material_id',
    'unique_id',
    'active'
  ),
  (
    'lt_battery_electrolyte_lithium_hexafluorophosphate',
    '电解液由六氟磷酸锂组成',
    'battery_electrolyte',
    'lithium_hexafluorophosphate',
    'N:1',
    '电解液的生产需要使用六氟磷酸锂作为关键锂盐输入，同一种六氟磷酸锂可供多个电解液实例使用。',
    NULL,
    'unique_id',
    'unique_id',
    'active'
  ),
  (
    'lt_battery_cell_copper_foil',
    '电芯由铜箔组成',
    'battery_cell',
    'copper_foil',
    'N:1',
    '电芯生产过程中需要使用铜箔作为集流体材料，同一种铜箔可服务多个电芯实例。',
    NULL,
    'unique_id',
    'unique_id',
    'active'
  ),
  (
    'lt_battery_cell_aluminum_foil',
    '电芯由铝箔组成',
    'battery_cell',
    'aluminum_foil',
    'N:1',
    '电芯生产过程中需要使用铝箔作为关键材料输入，同一种铝箔可服务多个电芯实例。',
    NULL,
    'unique_id',
    'unique_id',
    'active'
  )
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  source_object_id = VALUES(source_object_id),
  target_object_id = VALUES(target_object_id),
  cardinality = VALUES(cardinality),
  description = VALUES(description),
  industry_id = VALUES(industry_id),
  source_column = VALUES(source_column),
  target_column = VALUES(target_column),
  status = VALUES(status);

-- 2) 新增实例级 demo 关系
-- 说明：使用 NOT EXISTS 保证重复执行幂等。

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_cathode_material_lithium_iron_phosphate', 'CM-LFP-2024', 'LFP-BT-001-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_cathode_material_lithium_iron_phosphate'
    AND source_instance_id = 'CM-LFP-2024'
    AND target_instance_id = 'LFP-BT-001-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_cathode_material_lithium_iron_phosphate', 'CM-LFMP-2024', 'LFP-BT-002-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_cathode_material_lithium_iron_phosphate'
    AND source_instance_id = 'CM-LFMP-2024'
    AND target_instance_id = 'LFP-BT-002-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_battery_electrolyte_lithium_hexafluorophosphate', 'EL-FD-001-2024', 'LIPF6-BT-001-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_battery_electrolyte_lithium_hexafluorophosphate'
    AND source_instance_id = 'EL-FD-001-2024'
    AND target_instance_id = 'LIPF6-BT-001-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_battery_electrolyte_lithium_hexafluorophosphate', 'EL-HT-001-2024', 'LIPF6-BT-004-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_battery_electrolyte_lithium_hexafluorophosphate'
    AND source_instance_id = 'EL-HT-001-2024'
    AND target_instance_id = 'LIPF6-BT-004-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_battery_cell_copper_foil', 'BC-ATL-001-2024', 'CF-BT-001-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_battery_cell_copper_foil'
    AND source_instance_id = 'BC-ATL-001-2024'
    AND target_instance_id = 'CF-BT-001-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_battery_cell_copper_foil', 'BC-BYD-001-2024', 'CF-BT-002-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_battery_cell_copper_foil'
    AND source_instance_id = 'BC-BYD-001-2024'
    AND target_instance_id = 'CF-BT-002-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_battery_cell_aluminum_foil', 'BC-ATL-002-2024', 'AF-BT-001-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_battery_cell_aluminum_foil'
    AND source_instance_id = 'BC-ATL-002-2024'
    AND target_instance_id = 'AF-BT-001-2024'
);

INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id)
SELECT 'lt_battery_cell_aluminum_foil', 'BC-CALB-001-2024', 'AF-BT-003-2024'
WHERE NOT EXISTS (
  SELECT 1 FROM link_instance_data
  WHERE link_type_id = 'lt_battery_cell_aluminum_foil'
    AND source_instance_id = 'BC-CALB-001-2024'
    AND target_instance_id = 'AF-BT-003-2024'
);
