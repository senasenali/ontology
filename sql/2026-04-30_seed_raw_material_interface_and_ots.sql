-- 原材料顶层 Interface + 原材料 OT + 演示实例数据
-- 设计原则：
-- 1. interface 表达 Palantir 风格的顶层抽象语义层
-- 2. OT 与实例表结构统一参照现有 lithium_carbonate
-- 3. price / price_date 仅表示最新价格快照，不承担完整时序历史

-- 1) 顶层 Interface：原材料
INSERT INTO interfaces (id, name, description, industry_id, status)
VALUES
  ('if_raw_material', '原材料', '用于抽象新能源产业链中可被具体 OT 实现的原材料顶层语义接口。', NULL, 'active')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  industry_id = VALUES(industry_id),
  status = VALUES(status);

-- 2) Interface 属性
-- 参照现有碳酸锂 OT，仅保留最小共性字段。
INSERT INTO interface_properties (id, interface_id, name, type, description, required, sort_order)
VALUES
  ('ifp_raw_material_unique_id', 'if_raw_material', '唯一标识符', 'string', '原材料实例主键，如产品编码、批次号或业务唯一标识。', 1, 0),
  ('ifp_raw_material_grade', 'if_raw_material', '品级/规格', 'string', '原材料的品级、规格或型号信息。', 0, 1),
  ('ifp_raw_material_manufacturer', 'if_raw_material', '生产厂家/供应商', 'string', '原材料的生产厂家或供应商名称。', 0, 2),
  ('ifp_raw_material_price', 'if_raw_material', '最新价格', 'double', '原材料最新价格快照。', 0, 3),
  ('ifp_raw_material_price_date', 'if_raw_material', '价格日期', 'date', '最新价格快照对应的日期。', 0, 4)
ON DUPLICATE KEY UPDATE
  interface_id = VALUES(interface_id),
  name = VALUES(name),
  type = VALUES(type),
  description = VALUES(description),
  required = VALUES(required),
  sort_order = VALUES(sort_order);

-- 3) 新增 OT 元数据
INSERT INTO object_types (
  id, name, description, icon, backing_dataset, industry_id, data_source, database_name, status
)
VALUES
  ('lithium_iron_phosphate', '磷酸铁锂', '用于承载磷酸铁锂原材料/正极材料的最新价格快照与基础属性。', 'Database', 'lithium_iron_phosphate', NULL, 'mysql', 'ontology', 'active'),
  ('lithium_hexafluorophosphate', '六氟磷酸锂', '用于承载六氟磷酸锂原材料的最新价格快照与基础属性。', 'Database', 'lithium_hexafluorophosphate', NULL, 'mysql', 'ontology', 'active'),
  ('aluminum_foil', '铝箔', '用于承载锂电池产业链中的铝箔原材料最新价格快照与基础属性。', 'Database', 'aluminum_foil', NULL, 'mysql', 'ontology', 'active'),
  ('copper_foil', '铜箔', '用于承载锂电池产业链中的铜箔原材料最新价格快照与基础属性。', 'Database', 'copper_foil', NULL, 'mysql', 'ontology', 'active')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  icon = VALUES(icon),
  backing_dataset = VALUES(backing_dataset),
  industry_id = VALUES(industry_id),
  data_source = VALUES(data_source),
  database_name = VALUES(database_name),
  status = VALUES(status);

-- 4) 新增 OT 属性
-- 结构参照 lithium_carbonate，保持统一。
INSERT INTO properties (
  id, object_type_id, name, type, description, is_primary_key, base_column, type_classes, sort_order
)
VALUES
  ('p_lfp_unique_id', 'lithium_iron_phosphate', '唯一标识符，如产品编码或批次号', 'string', NULL, 1, 'unique_id', NULL, 0),
  ('p_lfp_grade', 'lithium_iron_phosphate', '品级，如动力型、储能型、高压实型', 'string', NULL, 0, 'grade', NULL, 1),
  ('p_lfp_manufacturer', 'lithium_iron_phosphate', '生产厂家或供应商名称', 'string', NULL, 0, 'manufacturer', NULL, 2),
  ('p_lfp_price', 'lithium_iron_phosphate', '价格（万元/吨）', 'double', NULL, 0, 'price', NULL, 3),
  ('p_lfp_price_date', 'lithium_iron_phosphate', '价格日期', 'date', NULL, 0, 'price_date', NULL, 4),

  ('p_lipf6_unique_id', 'lithium_hexafluorophosphate', '唯一标识符，如产品编码或批次号', 'string', NULL, 1, 'unique_id', NULL, 0),
  ('p_lipf6_grade', 'lithium_hexafluorophosphate', '品级，如电解液级、电子级', 'string', NULL, 0, 'grade', NULL, 1),
  ('p_lipf6_manufacturer', 'lithium_hexafluorophosphate', '生产厂家或供应商名称', 'string', NULL, 0, 'manufacturer', NULL, 2),
  ('p_lipf6_price', 'lithium_hexafluorophosphate', '价格（万元/吨）', 'double', NULL, 0, 'price', NULL, 3),
  ('p_lipf6_price_date', 'lithium_hexafluorophosphate', '价格日期', 'date', NULL, 0, 'price_date', NULL, 4),

  ('p_af_unique_id', 'aluminum_foil', '唯一标识符，如产品编码或批次号', 'string', NULL, 1, 'unique_id', NULL, 0),
  ('p_af_grade', 'aluminum_foil', '品级，如 12μm 电池级、15μm 电池级', 'string', NULL, 0, 'grade', NULL, 1),
  ('p_af_manufacturer', 'aluminum_foil', '生产厂家或供应商名称', 'string', NULL, 0, 'manufacturer', NULL, 2),
  ('p_af_price', 'aluminum_foil', '价格（万元/吨）', 'double', NULL, 0, 'price', NULL, 3),
  ('p_af_price_date', 'aluminum_foil', '价格日期', 'date', NULL, 0, 'price_date', NULL, 4),

  ('p_cf_unique_id', 'copper_foil', '唯一标识符，如产品编码或批次号', 'string', NULL, 1, 'unique_id', NULL, 0),
  ('p_cf_grade', 'copper_foil', '品级，如 6μm 锂电铜箔、8μm 锂电铜箔', 'string', NULL, 0, 'grade', NULL, 1),
  ('p_cf_manufacturer', 'copper_foil', '生产厂家或供应商名称', 'string', NULL, 0, 'manufacturer', NULL, 2),
  ('p_cf_price', 'copper_foil', '价格（万元/吨）', 'double', NULL, 0, 'price', NULL, 3),
  ('p_cf_price_date', 'copper_foil', '价格日期', 'date', NULL, 0, 'price_date', NULL, 4)
ON DUPLICATE KEY UPDATE
  object_type_id = VALUES(object_type_id),
  name = VALUES(name),
  type = VALUES(type),
  description = VALUES(description),
  is_primary_key = VALUES(is_primary_key),
  base_column = VALUES(base_column),
  type_classes = VALUES(type_classes),
  sort_order = VALUES(sort_order);

-- 5) OT 实现原材料 Interface
INSERT INTO object_type_interfaces_mapping (id, object_type_id, interface_id, status)
VALUES
  ('otim_lithium_carbonate_if_raw_material', 'lithium_carbonate', 'if_raw_material', 'active'),
  ('otim_lithium_iron_phosphate_if_raw_material', 'lithium_iron_phosphate', 'if_raw_material', 'active'),
  ('otim_lithium_hexafluorophosphate_if_raw_material', 'lithium_hexafluorophosphate', 'if_raw_material', 'active'),
  ('otim_aluminum_foil_if_raw_material', 'aluminum_foil', 'if_raw_material', 'active'),
  ('otim_copper_foil_if_raw_material', 'copper_foil', 'if_raw_material', 'active')
ON DUPLICATE KEY UPDATE
  object_type_id = VALUES(object_type_id),
  interface_id = VALUES(interface_id),
  status = VALUES(status);

-- 6) 属性映射
INSERT INTO interface_property_mapping (id, object_type_interface_mapping_id, interface_property_id, property_id)
VALUES
  ('ipm_lc_raw_unique_id', 'otim_lithium_carbonate_if_raw_material', 'ifp_raw_material_unique_id', 'p_id_1775652265840'),
  ('ipm_lc_raw_grade', 'otim_lithium_carbonate_if_raw_material', 'ifp_raw_material_grade', 'p_grade_1775652359942'),
  ('ipm_lc_raw_manufacturer', 'otim_lithium_carbonate_if_raw_material', 'ifp_raw_material_manufacturer', 'p_manufacturer_1775652360925'),
  ('ipm_lc_raw_price', 'otim_lithium_carbonate_if_raw_material', 'ifp_raw_material_price', 'p_price_1775652265840'),
  ('ipm_lc_raw_price_date', 'otim_lithium_carbonate_if_raw_material', 'ifp_raw_material_price_date', 'p_price_date_1775652265842'),

  ('ipm_lfp_raw_unique_id', 'otim_lithium_iron_phosphate_if_raw_material', 'ifp_raw_material_unique_id', 'p_lfp_unique_id'),
  ('ipm_lfp_raw_grade', 'otim_lithium_iron_phosphate_if_raw_material', 'ifp_raw_material_grade', 'p_lfp_grade'),
  ('ipm_lfp_raw_manufacturer', 'otim_lithium_iron_phosphate_if_raw_material', 'ifp_raw_material_manufacturer', 'p_lfp_manufacturer'),
  ('ipm_lfp_raw_price', 'otim_lithium_iron_phosphate_if_raw_material', 'ifp_raw_material_price', 'p_lfp_price'),
  ('ipm_lfp_raw_price_date', 'otim_lithium_iron_phosphate_if_raw_material', 'ifp_raw_material_price_date', 'p_lfp_price_date'),

  ('ipm_lipf6_raw_unique_id', 'otim_lithium_hexafluorophosphate_if_raw_material', 'ifp_raw_material_unique_id', 'p_lipf6_unique_id'),
  ('ipm_lipf6_raw_grade', 'otim_lithium_hexafluorophosphate_if_raw_material', 'ifp_raw_material_grade', 'p_lipf6_grade'),
  ('ipm_lipf6_raw_manufacturer', 'otim_lithium_hexafluorophosphate_if_raw_material', 'ifp_raw_material_manufacturer', 'p_lipf6_manufacturer'),
  ('ipm_lipf6_raw_price', 'otim_lithium_hexafluorophosphate_if_raw_material', 'ifp_raw_material_price', 'p_lipf6_price'),
  ('ipm_lipf6_raw_price_date', 'otim_lithium_hexafluorophosphate_if_raw_material', 'ifp_raw_material_price_date', 'p_lipf6_price_date'),

  ('ipm_af_raw_unique_id', 'otim_aluminum_foil_if_raw_material', 'ifp_raw_material_unique_id', 'p_af_unique_id'),
  ('ipm_af_raw_grade', 'otim_aluminum_foil_if_raw_material', 'ifp_raw_material_grade', 'p_af_grade'),
  ('ipm_af_raw_manufacturer', 'otim_aluminum_foil_if_raw_material', 'ifp_raw_material_manufacturer', 'p_af_manufacturer'),
  ('ipm_af_raw_price', 'otim_aluminum_foil_if_raw_material', 'ifp_raw_material_price', 'p_af_price'),
  ('ipm_af_raw_price_date', 'otim_aluminum_foil_if_raw_material', 'ifp_raw_material_price_date', 'p_af_price_date'),

  ('ipm_cf_raw_unique_id', 'otim_copper_foil_if_raw_material', 'ifp_raw_material_unique_id', 'p_cf_unique_id'),
  ('ipm_cf_raw_grade', 'otim_copper_foil_if_raw_material', 'ifp_raw_material_grade', 'p_cf_grade'),
  ('ipm_cf_raw_manufacturer', 'otim_copper_foil_if_raw_material', 'ifp_raw_material_manufacturer', 'p_cf_manufacturer'),
  ('ipm_cf_raw_price', 'otim_copper_foil_if_raw_material', 'ifp_raw_material_price', 'p_cf_price'),
  ('ipm_cf_raw_price_date', 'otim_copper_foil_if_raw_material', 'ifp_raw_material_price_date', 'p_cf_price_date')
ON DUPLICATE KEY UPDATE
  object_type_interface_mapping_id = VALUES(object_type_interface_mapping_id),
  interface_property_id = VALUES(interface_property_id),
  property_id = VALUES(property_id);

-- 7) 实际实例表：统一参照 lithium_carbonate 结构
CREATE TABLE IF NOT EXISTS `lithium_iron_phosphate` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '唯一标识符，如产品编码或批次号',
  `grade` varchar(50) DEFAULT NULL COMMENT '品级或规格',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家或供应商名称',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（万元/吨）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `uq_lithium_iron_phosphate_unique_id` (`unique_id`),
  KEY `idx_lithium_iron_phosphate_grade` (`grade`),
  KEY `idx_lithium_iron_phosphate_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='磷酸铁锂信息表';

CREATE TABLE IF NOT EXISTS `lithium_hexafluorophosphate` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '唯一标识符，如产品编码或批次号',
  `grade` varchar(50) DEFAULT NULL COMMENT '品级或规格',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家或供应商名称',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（万元/吨）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `uq_lithium_hexafluorophosphate_unique_id` (`unique_id`),
  KEY `idx_lithium_hexafluorophosphate_grade` (`grade`),
  KEY `idx_lithium_hexafluorophosphate_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='六氟磷酸锂信息表';

CREATE TABLE IF NOT EXISTS `aluminum_foil` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '唯一标识符，如产品编码或批次号',
  `grade` varchar(50) DEFAULT NULL COMMENT '品级或规格',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家或供应商名称',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（万元/吨）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `uq_aluminum_foil_unique_id` (`unique_id`),
  KEY `idx_aluminum_foil_grade` (`grade`),
  KEY `idx_aluminum_foil_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='铝箔信息表';

CREATE TABLE IF NOT EXISTS `copper_foil` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '唯一标识符，如产品编码或批次号',
  `grade` varchar(50) DEFAULT NULL COMMENT '品级或规格',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家或供应商名称',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（万元/吨）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `uq_copper_foil_unique_id` (`unique_id`),
  KEY `idx_copper_foil_grade` (`grade`),
  KEY `idx_copper_foil_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='铜箔信息表';

-- 8) 原材料实例演示数据
INSERT INTO lithium_iron_phosphate (unique_id, grade, manufacturer, price, price_date)
VALUES
  ('LFP-BT-001-2024', '动力型', '湖南裕能', 4.30, '2024-03-01'),
  ('LFP-BT-002-2024', '动力型', '德方纳米', 4.45, '2024-03-01'),
  ('LFP-BT-003-2024', '储能型', '富临精工', 4.10, '2024-02-20'),
  ('LFP-BT-004-2024', '高压实型', '龙蟠科技', 4.58, '2024-03-10'),
  ('LFP-BT-005-2024', '储能型', '万润新能', 4.18, '2024-02-25')
ON DUPLICATE KEY UPDATE
  grade = VALUES(grade),
  manufacturer = VALUES(manufacturer),
  price = VALUES(price),
  price_date = VALUES(price_date);

INSERT INTO lithium_hexafluorophosphate (unique_id, grade, manufacturer, price, price_date)
VALUES
  ('LIPF6-BT-001-2024', '电解液级', '多氟多', 7.80, '2024-03-01'),
  ('LIPF6-BT-002-2024', '电解液级', '天际股份', 7.55, '2024-03-01'),
  ('LIPF6-BT-003-2024', '电子级', '新宙邦', 8.20, '2024-02-18'),
  ('LIPF6-BT-004-2024', '电解液级', '永太科技', 7.35, '2024-03-08'),
  ('LIPF6-BT-005-2024', '电子级', '天赐材料', 8.05, '2024-02-27')
ON DUPLICATE KEY UPDATE
  grade = VALUES(grade),
  manufacturer = VALUES(manufacturer),
  price = VALUES(price),
  price_date = VALUES(price_date);

INSERT INTO aluminum_foil (unique_id, grade, manufacturer, price, price_date)
VALUES
  ('AF-BT-001-2024', '12μm 电池级', '鼎胜新材', 2.35, '2024-03-01'),
  ('AF-BT-002-2024', '15μm 电池级', '明泰铝业', 2.28, '2024-03-01'),
  ('AF-BT-003-2024', '12μm 电池级', '南山铝业', 2.42, '2024-02-22'),
  ('AF-BT-004-2024', '双光 12μm', '常铝股份', 2.50, '2024-03-11'),
  ('AF-BT-005-2024', '15μm 电池级', '万顺新材', 2.31, '2024-02-26')
ON DUPLICATE KEY UPDATE
  grade = VALUES(grade),
  manufacturer = VALUES(manufacturer),
  price = VALUES(price),
  price_date = VALUES(price_date);

INSERT INTO copper_foil (unique_id, grade, manufacturer, price, price_date)
VALUES
  ('CF-BT-001-2024', '6μm 锂电铜箔', '诺德股份', 8.90, '2024-03-01'),
  ('CF-BT-002-2024', '8μm 锂电铜箔', '嘉元科技', 8.35, '2024-03-01'),
  ('CF-BT-003-2024', '6μm 高抗拉', '超华科技', 9.10, '2024-02-21'),
  ('CF-BT-004-2024', '8μm 标准型', '德福科技', 8.42, '2024-03-12'),
  ('CF-BT-005-2024', '6μm 锂电铜箔', '铜冠铜箔', 8.78, '2024-02-28')
ON DUPLICATE KEY UPDATE
  grade = VALUES(grade),
  manufacturer = VALUES(manufacturer),
  price = VALUES(price),
  price_date = VALUES(price_date);
