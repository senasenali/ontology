UPDATE function_types
SET
  name = '碳酸锂（实例层）价格传导分析',
  description = '基于具体碳酸锂实例及其最新价格，沿实例关系图谱计算下游实例的价格传导结果。'
WHERE id = 'func_calculate_price_transmission';

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
  'calculate_price_transmission_object_type',
  '碳酸锂（对象类型层）价格传导分析',
  '基于碳酸锂对象类型的价格变动幅度，计算对象类型层面的传导路径、传导系数与价格影响。',
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
  ('fp_ptot_in_1', 'func_calculate_price_transmission_object_type', 'INPUT', '对象类型ID', 'objectTypeId', 'string', 1, 'lithium_carbonate', '源对象类型ID，当前演示为 lithium_carbonate', 0, 'USER_INPUT'),
  ('fp_ptot_in_2', 'func_calculate_price_transmission_object_type', 'INPUT', '价格变化百分比', 'priceChangePercent', 'number', 1, NULL, '价格变动幅度，正数表示上涨，负数表示下跌', 1, 'USER_INPUT'),
  ('fp_ptot_in_3', 'func_calculate_price_transmission_object_type', 'INPUT', '传导深度', 'depth', 'number', 0, '4', '对象类型层级的最大传导深度，默认 4', 2, 'USER_INPUT'),
  ('fp_ptot_out_1', 'func_calculate_price_transmission_object_type', 'OUTPUT', '是否成功', 'success', 'boolean', 1, NULL, '函数是否执行成功', 0, NULL);
