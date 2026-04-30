-- 原材料 Interface 关系约束
-- 目标：
-- 1. 在 Interface 层声明“原材料”可连接到哪些下游对象类型
-- 2. 将具体原材料 OT 映射到对应的 Link Type，支撑抽象层到真实关系层的路由

-- 1) Interface Link Constraints
INSERT INTO interface_link_constraints (
  id, interface_id, name, target_type, target_interface_id, target_object_type_id,
  cardinality, required, status
)
VALUES
  (
    'ilc_raw_material_to_cathode_material',
    'if_raw_material',
    '原材料流向正极材料',
    'object_type',
    NULL,
    'cathode_material',
    '1:N',
    0,
    'active'
  ),
  (
    'ilc_raw_material_to_battery_electrolyte',
    'if_raw_material',
    '原材料流向电解液',
    'object_type',
    NULL,
    'battery_electrolyte',
    '1:N',
    0,
    'active'
  ),
  (
    'ilc_raw_material_to_battery_cell',
    'if_raw_material',
    '原材料流向电芯',
    'object_type',
    NULL,
    'battery_cell',
    '1:N',
    0,
    'active'
  )
ON DUPLICATE KEY UPDATE
  interface_id = VALUES(interface_id),
  name = VALUES(name),
  target_type = VALUES(target_type),
  target_interface_id = VALUES(target_interface_id),
  target_object_type_id = VALUES(target_object_type_id),
  cardinality = VALUES(cardinality),
  required = VALUES(required),
  status = VALUES(status);

-- 2) Constraint to LinkType mappings
INSERT INTO interface_link_type_constraint_mapping (
  id, object_type_interface_mapping_id, interface_link_constraint_id, link_type_id
)
VALUES
  (
    'iltcm_lc_raw_to_cathode_material',
    'otim_lithium_carbonate_if_raw_material',
    'ilc_raw_material_to_cathode_material',
    'lt_cathode_material_lithium_carbonate_1775472267480'
  ),
  (
    'iltcm_lc_raw_to_battery_electrolyte',
    'otim_lithium_carbonate_if_raw_material',
    'ilc_raw_material_to_battery_electrolyte',
    'lt_battery_electrolyte_lithium_carbonate_1775655437902'
  ),
  (
    'iltcm_lfp_raw_to_cathode_material',
    'otim_lithium_iron_phosphate_if_raw_material',
    'ilc_raw_material_to_cathode_material',
    'lt_cathode_material_lithium_iron_phosphate'
  ),
  (
    'iltcm_lipf6_raw_to_battery_electrolyte',
    'otim_lithium_hexafluorophosphate_if_raw_material',
    'ilc_raw_material_to_battery_electrolyte',
    'lt_battery_electrolyte_lithium_hexafluorophosphate'
  ),
  (
    'iltcm_cf_raw_to_battery_cell',
    'otim_copper_foil_if_raw_material',
    'ilc_raw_material_to_battery_cell',
    'lt_battery_cell_copper_foil'
  ),
  (
    'iltcm_af_raw_to_battery_cell',
    'otim_aluminum_foil_if_raw_material',
    'ilc_raw_material_to_battery_cell',
    'lt_battery_cell_aluminum_foil'
  )
ON DUPLICATE KEY UPDATE
  object_type_interface_mapping_id = VALUES(object_type_interface_mapping_id),
  interface_link_constraint_id = VALUES(interface_link_constraint_id),
  link_type_id = VALUES(link_type_id);
