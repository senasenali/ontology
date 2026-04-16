CREATE TABLE IF NOT EXISTS lithium_price_monitor (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  instance_id VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  price_date DATETIME NULL,
  source VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_lithium_price_monitor_instance_created (instance_id, created_at),
  KEY idx_lithium_price_monitor_price_date (price_date)
);

INSERT INTO lithium_price_monitor (instance_id, price, price_date, source, created_at)
SELECT 'LC-BT-001-2024', 12.50, '2026-04-14 09:00:00', 'seed', '2026-04-14 09:00:00'
WHERE NOT EXISTS (
  SELECT 1
  FROM lithium_price_monitor
  WHERE instance_id = 'LC-BT-001-2024'
    AND price = 12.50
    AND created_at = '2026-04-14 09:00:00'
);

INSERT INTO lithium_price_monitor (instance_id, price, price_date, source, created_at)
SELECT 'LC-BT-001-2024', 15.63, '2026-04-15 09:00:00', 'seed', '2026-04-15 09:00:00'
WHERE NOT EXISTS (
  SELECT 1
  FROM lithium_price_monitor
  WHERE instance_id = 'LC-BT-001-2024'
    AND price = 15.63
    AND created_at = '2026-04-15 09:00:00'
);

INSERT INTO agents (
  id,
  name,
  description,
  target_company,
  target_industry,
  analysis_focus,
  schedule_minutes,
  is_active,
  last_run_at,
  created_at,
  updated_at
)
SELECT
  'demo_agent_lithium',
  '碳酸锂标的跟踪',
  '跟踪碳酸锂价格变化，并持续观察其向电解液、电芯和动力电池环节的成本传导。',
  '碳酸锂',
  '锂电材料',
  '价格波动、成本传导、电池链盈利压力',
  120,
  1,
  NULL,
  '2026-04-15 09:00:00',
  '2026-04-15 09:00:00'
WHERE NOT EXISTS (
  SELECT 1 FROM agents WHERE id = 'demo_agent_lithium'
);
