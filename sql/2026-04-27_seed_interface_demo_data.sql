-- Demo theme:
-- 新能源产业链成本传导与粒度切换
-- 目标：让 Interface 能在“碳酸锂 -> 材料 -> 电芯 -> 电池 -> 整车”链路中承载抽象分析层

-- 1) Interfaces
INSERT INTO interfaces (id, name, description, industry_id, status)
VALUES
  ('if_price_trackable_asset', '价格跟踪标的', '用于统一抽象可被价格跟踪、比较与横向聚合的新能源链条标的。', NULL, 'active'),
  ('if_energy_storage_unit', '储能单元', '用于抽象电芯、电池包等具备储能能力的中游产品。', NULL, 'active'),
  ('if_battery_material', '电池材料', '用于抽象正极材料、电解液、锂盐等电池材料层标的。', NULL, 'active'),
  ('if_battery_cell', '电芯', '用于抽象动力电池中的电芯层产品，承载材料约束。', NULL, 'active'),
  ('if_battery_pack', '电池包', '用于抽象面向整车或储能系统交付的电池包。', NULL, 'active'),
  ('if_vehicle_product', '整车产品', '用于抽象新能源整车产品层。', NULL, 'active'),
  ('if_lithium_feedstock', '锂资源品', '用于抽象碳酸锂等上游锂资源品，承载更细粒度的投研分析。', NULL, 'active')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  industry_id = VALUES(industry_id),
  status = VALUES(status);

-- 2) Interface properties
INSERT INTO interface_properties (id, interface_id, name, type, description, required, sort_order)
VALUES
  ('ifp_asset_id', 'if_price_trackable_asset', '标的唯一标识', 'string', '用于统一抽象层中的实例主键或业务唯一键。', 1, 0),
  ('ifp_spec_label', 'if_price_trackable_asset', '规格/型号标签', 'string', '用于统一承载型号、名称、品级等标识规格的信息。', 0, 1),
  ('ifp_manufacturer', 'if_price_trackable_asset', '生产方/品牌', 'string', '用于统一承载制造商、供应商或品牌名称。', 0, 2),
  ('ifp_price', 'if_price_trackable_asset', '最新价格', 'double', '用于抽象统一价格字段，支持跨品类价格对比。', 1, 3),
  ('ifp_price_date', 'if_price_trackable_asset', '价格日期', 'date', '用于抽象统一价格日期字段。', 1, 4),

  ('ifp_unit_capacity', 'if_energy_storage_unit', '容量', 'number', '用于统一承载电芯/电池容量。', 0, 0),
  ('ifp_unit_production_date', 'if_energy_storage_unit', '生产日期', 'date', '用于统一承载储能单元生产日期。', 0, 1),

  ('ifp_battery_chemistry', 'if_battery_pack', '电池化学体系', 'string', '用于统一承载电池包的化学体系。', 0, 0),

  ('ifp_vehicle_brand', 'if_vehicle_product', '品牌', 'string', '用于统一承载整车品牌。', 0, 0),
  ('ifp_vehicle_range_km', 'if_vehicle_product', '续航里程(km)', 'number', '用于统一承载整车续航里程。', 0, 1),
  ('ifp_vehicle_battery_cost', 'if_vehicle_product', '电池成本(万元)', 'double', '用于承载整车中与电池相关的成本字段。', 0, 2),

  ('ifp_feedstock_grade', 'if_lithium_feedstock', '资源品品级', 'string', '用于统一承载碳酸锂等上游资源品的品级。', 1, 0)
ON DUPLICATE KEY UPDATE
  interface_id = VALUES(interface_id),
  name = VALUES(name),
  type = VALUES(type),
  description = VALUES(description),
  required = VALUES(required),
  sort_order = VALUES(sort_order);

-- 3) Interface inheritance
INSERT INTO interface_extends (id, parent_interface_id, child_interface_id)
VALUES
  ('ie_if_energy_storage_unit_if_price_trackable_asset', 'if_price_trackable_asset', 'if_energy_storage_unit'),
  ('ie_if_battery_material_if_price_trackable_asset', 'if_price_trackable_asset', 'if_battery_material'),
  ('ie_if_battery_cell_if_energy_storage_unit', 'if_energy_storage_unit', 'if_battery_cell'),
  ('ie_if_battery_pack_if_energy_storage_unit', 'if_energy_storage_unit', 'if_battery_pack'),
  ('ie_if_vehicle_product_if_price_trackable_asset', 'if_price_trackable_asset', 'if_vehicle_product'),
  ('ie_if_lithium_feedstock_if_battery_material', 'if_battery_material', 'if_lithium_feedstock')
ON DUPLICATE KEY UPDATE
  parent_interface_id = VALUES(parent_interface_id),
  child_interface_id = VALUES(child_interface_id);

-- 4) Object type implements interface
INSERT INTO object_type_interfaces_mapping (id, object_type_id, interface_id, status)
VALUES
  ('otim_battery_cell_if_price_trackable_asset', 'battery_cell', 'if_price_trackable_asset', 'active'),
  ('otim_battery_cell_if_energy_storage_unit', 'battery_cell', 'if_energy_storage_unit', 'active'),
  ('otim_battery_cell_if_battery_cell', 'battery_cell', 'if_battery_cell', 'active'),

  ('otim_power_battery_if_price_trackable_asset', 'power_battery', 'if_price_trackable_asset', 'active'),
  ('otim_power_battery_if_energy_storage_unit', 'power_battery', 'if_energy_storage_unit', 'active'),
  ('otim_power_battery_if_battery_pack', 'power_battery', 'if_battery_pack', 'active'),

  ('otim_cathode_material_if_price_trackable_asset', 'cathode_material', 'if_price_trackable_asset', 'active'),
  ('otim_cathode_material_if_battery_material', 'cathode_material', 'if_battery_material', 'active'),

  ('otim_battery_electrolyte_if_price_trackable_asset', 'battery_electrolyte', 'if_price_trackable_asset', 'active'),
  ('otim_battery_electrolyte_if_battery_material', 'battery_electrolyte', 'if_battery_material', 'active'),

  ('otim_lithium_carbonate_if_price_trackable_asset', 'lithium_carbonate', 'if_price_trackable_asset', 'active'),
  ('otim_lithium_carbonate_if_battery_material', 'lithium_carbonate', 'if_battery_material', 'active'),
  ('otim_lithium_carbonate_if_lithium_feedstock', 'lithium_carbonate', 'if_lithium_feedstock', 'active'),

  ('otim_new_energy_vehicle_if_price_trackable_asset', 'new_energy_vehicle', 'if_price_trackable_asset', 'active'),
  ('otim_new_energy_vehicle_if_vehicle_product', 'new_energy_vehicle', 'if_vehicle_product', 'active')
ON DUPLICATE KEY UPDATE
  object_type_id = VALUES(object_type_id),
  interface_id = VALUES(interface_id),
  status = VALUES(status);

-- 5) Property mappings
INSERT INTO interface_property_mapping (id, object_type_interface_mapping_id, interface_property_id, property_id)
VALUES
  ('ipm_bc_asset_id', 'otim_battery_cell_if_price_trackable_asset', 'ifp_asset_id', 'p_id_1775651827534'),
  ('ipm_bc_spec_label', 'otim_battery_cell_if_price_trackable_asset', 'ifp_spec_label', 'p_model_1775651928286'),
  ('ipm_bc_manufacturer', 'otim_battery_cell_if_price_trackable_asset', 'ifp_manufacturer', 'p_manufacturer_1775651931268'),
  ('ipm_bc_price', 'otim_battery_cell_if_price_trackable_asset', 'ifp_price', 'p_price_1775651827535'),
  ('ipm_bc_price_date', 'otim_battery_cell_if_price_trackable_asset', 'ifp_price_date', 'p_price_date_1775651827536'),
  ('ipm_bc_capacity', 'otim_battery_cell_if_energy_storage_unit', 'ifp_unit_capacity', 'p_price_1775651827535'),

  ('ipm_pb_asset_id', 'otim_power_battery_if_price_trackable_asset', 'ifp_asset_id', 'p_id_1775469202509'),
  ('ipm_pb_spec_label', 'otim_power_battery_if_price_trackable_asset', 'ifp_spec_label', 'p_model_1775469226104'),
  ('ipm_pb_manufacturer', 'otim_power_battery_if_price_trackable_asset', 'ifp_manufacturer', 'p_manufacturer_1775469343287'),
  ('ipm_pb_price', 'otim_power_battery_if_price_trackable_asset', 'ifp_price', 'p_price_1775469202509'),
  ('ipm_pb_price_date', 'otim_power_battery_if_price_trackable_asset', 'ifp_price_date', 'p_price_date_1775469202510'),
  ('ipm_pb_capacity', 'otim_power_battery_if_energy_storage_unit', 'ifp_unit_capacity', 'p_capacity_1775469262904'),
  ('ipm_pb_production_date', 'otim_power_battery_if_energy_storage_unit', 'ifp_unit_production_date', 'p_productiondate_1775469378170'),
  ('ipm_pb_chemistry', 'otim_power_battery_if_battery_pack', 'ifp_battery_chemistry', 'p_chemistry_1775469324420'),

  ('ipm_cm_asset_id', 'otim_cathode_material_if_price_trackable_asset', 'ifp_asset_id', 'p_material_id_1775651402080'),
  ('ipm_cm_spec_label', 'otim_cathode_material_if_price_trackable_asset', 'ifp_spec_label', 'p_material_name_1775651404512'),
  ('ipm_cm_price', 'otim_cathode_material_if_price_trackable_asset', 'ifp_price', 'p_price_1775651402081'),
  ('ipm_cm_price_date', 'otim_cathode_material_if_price_trackable_asset', 'ifp_price_date', 'p_price_date_1775651402082'),

  ('ipm_be_asset_id', 'otim_battery_electrolyte_if_price_trackable_asset', 'ifp_asset_id', 'p_id_1775650733670'),
  ('ipm_be_spec_label', 'otim_battery_electrolyte_if_price_trackable_asset', 'ifp_spec_label', 'p_name_1775650734536'),
  ('ipm_be_manufacturer', 'otim_battery_electrolyte_if_price_trackable_asset', 'ifp_manufacturer', 'p_name_1775650734536'),
  ('ipm_be_price', 'otim_battery_electrolyte_if_price_trackable_asset', 'ifp_price', 'p_price_1775650733671'),
  ('ipm_be_price_date', 'otim_battery_electrolyte_if_price_trackable_asset', 'ifp_price_date', 'p_price_date_1775650733672'),

  ('ipm_lc_asset_id', 'otim_lithium_carbonate_if_price_trackable_asset', 'ifp_asset_id', 'p_id_1775652265840'),
  ('ipm_lc_spec_label', 'otim_lithium_carbonate_if_price_trackable_asset', 'ifp_spec_label', 'p_grade_1775652359942'),
  ('ipm_lc_manufacturer', 'otim_lithium_carbonate_if_price_trackable_asset', 'ifp_manufacturer', 'p_manufacturer_1775652360925'),
  ('ipm_lc_price', 'otim_lithium_carbonate_if_price_trackable_asset', 'ifp_price', 'p_price_1775652265840'),
  ('ipm_lc_price_date', 'otim_lithium_carbonate_if_price_trackable_asset', 'ifp_price_date', 'p_price_date_1775652265842'),
  ('ipm_lc_grade', 'otim_lithium_carbonate_if_lithium_feedstock', 'ifp_feedstock_grade', 'p_grade_1775652359942'),

  ('ipm_nev_asset_id', 'otim_new_energy_vehicle_if_price_trackable_asset', 'ifp_asset_id', 'p_vehicleid_1775385754771'),
  ('ipm_nev_spec_label', 'otim_new_energy_vehicle_if_price_trackable_asset', 'ifp_spec_label', 'p_modelname_1775385755582'),
  ('ipm_nev_manufacturer', 'otim_new_energy_vehicle_if_price_trackable_asset', 'ifp_manufacturer', 'p_brand_1775388584499'),
  ('ipm_nev_price', 'otim_new_energy_vehicle_if_price_trackable_asset', 'ifp_price', 'p_price_1775385757615'),
  ('ipm_nev_price_date', 'otim_new_energy_vehicle_if_price_trackable_asset', 'ifp_price_date', 'p_price_date_1775385756099'),
  ('ipm_nev_brand', 'otim_new_energy_vehicle_if_vehicle_product', 'ifp_vehicle_brand', 'p_brand_1775388584499'),
  ('ipm_nev_range', 'otim_new_energy_vehicle_if_vehicle_product', 'ifp_vehicle_range_km', 'p_range_1775385756349'),
  ('ipm_nev_battery_cost', 'otim_new_energy_vehicle_if_vehicle_product', 'ifp_vehicle_battery_cost', 'p_ battery_cost_1775388584501')
ON DUPLICATE KEY UPDATE
  object_type_interface_mapping_id = VALUES(object_type_interface_mapping_id),
  interface_property_id = VALUES(interface_property_id),
  property_id = VALUES(property_id);

-- 6) Link Type Constraints
INSERT INTO interface_link_constraints (
  id, interface_id, name, target_type, target_interface_id, target_object_type_id,
  cardinality, required, status
)
VALUES
  ('ilc_battery_pack_contains_cell', 'if_battery_pack', '由电芯组成', 'interface', 'if_battery_cell', NULL, '1:N', 1, 'active'),
  ('ilc_battery_cell_uses_cathode_material', 'if_battery_cell', '使用正极材料', 'object_type', NULL, 'cathode_material', '1:1', 1, 'active'),
  ('ilc_battery_cell_uses_electrolyte', 'if_battery_cell', '使用电解液', 'object_type', NULL, 'battery_electrolyte', '1:1', 1, 'active')
ON DUPLICATE KEY UPDATE
  interface_id = VALUES(interface_id),
  name = VALUES(name),
  target_type = VALUES(target_type),
  target_interface_id = VALUES(target_interface_id),
  target_object_type_id = VALUES(target_object_type_id),
  cardinality = VALUES(cardinality),
  required = VALUES(required),
  status = VALUES(status);

-- 7) Constraint to LinkType mappings
INSERT INTO interface_link_type_constraint_mapping (
  id, object_type_interface_mapping_id, interface_link_constraint_id, link_type_id
)
VALUES
  ('iltcm_power_battery_contains_cell', 'otim_power_battery_if_battery_pack', 'ilc_battery_pack_contains_cell', 'lt_power_battery_battery_cell_1775472262897'),
  ('iltcm_battery_cell_cathode_material', 'otim_battery_cell_if_battery_cell', 'ilc_battery_cell_uses_cathode_material', 'lt_battery_cell_cathode_material_1775472265881'),
  ('iltcm_battery_cell_electrolyte', 'otim_battery_cell_if_battery_cell', 'ilc_battery_cell_uses_electrolyte', 'lt_battery_cell_battery_electrolyte_1775655447785')
ON DUPLICATE KEY UPDATE
  object_type_interface_mapping_id = VALUES(object_type_interface_mapping_id),
  interface_link_constraint_id = VALUES(interface_link_constraint_id),
  link_type_id = VALUES(link_type_id);
