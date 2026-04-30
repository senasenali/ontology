UPDATE function_types
SET
  name = '实例层价格传导分析',
  code = 'calculate_instance_price_transmission',
  description = '基于任意源实例及其最新价格，沿 link_instance_data 中的实例关系计算实例层传导路径、传导系数与价格影响。'
WHERE id = 'func_calculate_price_transmission';

DELETE FROM function_params
WHERE function_id = 'func_calculate_price_transmission'
  AND param_direction = 'INPUT';

INSERT INTO function_params (id, function_id, param_direction, param_name, param_code, param_type, is_required, default_value, description, sort_order, source_type)
VALUES
  ('fp_pt_in_1', 'func_calculate_price_transmission', 'INPUT', '源概念ID', 'sourceObjectTypeId', 'string', 1, 'lithium_carbonate', '源实例所属概念对象类型ID，如 lithium_carbonate、cathode_material、battery_cell', 0, 'USER_INPUT'),
  ('fp_pt_in_2', 'func_calculate_price_transmission', 'INPUT', '源实例ID', 'sourceInstanceId', 'string', 1, NULL, '源实例主键值，如 LC-IN-001-2024、CM-LFP-001', 1, 'USER_INPUT'),
  ('fp_pt_in_3', 'func_calculate_price_transmission', 'INPUT', '价格变化百分比', 'priceChangePercent', 'number', 1, NULL, '源实例价格变动幅度，正数表示上涨，负数表示下跌', 2, 'USER_INPUT'),
  ('fp_pt_in_4', 'func_calculate_price_transmission', 'INPUT', '最新价格', 'latestPrice', 'number', 0, NULL, '源实例最新价格；可选，仅用于展示源节点最新价格', 3, 'USER_INPUT'),
  ('fp_pt_in_5', 'func_calculate_price_transmission', 'INPUT', '之前价格', 'previousPrice', 'number', 0, NULL, '源实例之前价格；不填则从源实例 price 字段读取', 4, 'USER_INPUT'),
  ('fp_pt_in_6', 'func_calculate_price_transmission', 'INPUT', '传导深度', 'depth', 'number', 0, '3', '实例关系的最大传导深度，默认 3，最大 5', 5, 'USER_INPUT');

UPDATE function_params
SET description = '源实例信息'
WHERE id = 'fp_pt_out_source';

UPDATE function_params
SET description = '第一层默认影响百分比，等于源价格变化百分比 × 0.5'
WHERE id = 'fp_pt_out_coeff';

UPDATE function_params
SET description = '节点影响百分比，按 edgeCoefficient=0.5 和 depthDecay=0.8 计算'
WHERE id = 'fp_pt_out_aff_coeff';

INSERT INTO function_types (
  id,
  code,
  name,
  description,
  category,
  interface_type,
  request_method,
  interface_url,
  implementation_type,
  status,
  created_at,
  updated_at
)
SELECT
  'func_calculate_price_transmission_object_type',
  'calculate_concept_price_transmission',
  '概念层价格传导分析',
  '基于任意源概念的价格变动幅度，沿 link_types 中的概念关系计算概念层传导路径、传导系数与价格影响。',
  'ANALYZE',
  'RESTFUL',
  'POST',
  '/api/analysis/price-transmission/object-type',
  'JAVA',
  'ACTIVE',
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1
  FROM function_types
  WHERE id = 'func_calculate_price_transmission_object_type'
);

DELETE FROM function_params
WHERE function_id = 'func_calculate_price_transmission_object_type';

INSERT INTO function_params (id, function_id, param_direction, param_name, param_code, param_type, is_required, default_value, description, sort_order, source_type)
VALUES
  ('fp_ptot_in_1', 'func_calculate_price_transmission_object_type', 'INPUT', '源概念ID', 'sourceObjectTypeId', 'string', 1, 'lithium_carbonate', '源概念对象类型ID，如 lithium_carbonate、cathode_material、battery_cell', 0, 'USER_INPUT'),
  ('fp_ptot_in_2', 'func_calculate_price_transmission_object_type', 'INPUT', '价格变化百分比', 'priceChangePercent', 'number', 1, NULL, '价格变动幅度，正数表示上涨，负数表示下跌', 1, 'USER_INPUT'),
  ('fp_ptot_in_3', 'func_calculate_price_transmission_object_type', 'INPUT', '传导深度', 'depth', 'number', 0, '4', '概念关系的最大传导深度，默认 4', 2, 'USER_INPUT'),
  ('fp_ptot_out_1', 'func_calculate_price_transmission_object_type', 'OUTPUT', '是否成功', 'success', 'boolean', 1, NULL, '函数是否执行成功', 0, NULL);
