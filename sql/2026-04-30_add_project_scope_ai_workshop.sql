ALTER TABLE ai_conversations
  ADD COLUMN project_id VARCHAR(64) NOT NULL DEFAULT 'project_public' AFTER preview_ontology,
  ADD INDEX idx_ai_conversations_project_id (project_id);

UPDATE ai_conversations
SET project_id = 'project_public'
WHERE project_id IS NULL OR project_id = '';

ALTER TABLE agents
  ADD COLUMN project_id VARCHAR(64) NOT NULL DEFAULT 'project_public' AFTER is_active,
  ADD INDEX idx_agents_project_id (project_id);

UPDATE agents
SET project_id = 'project_public'
WHERE project_id IS NULL OR project_id = '';

ALTER TABLE agent_events
  ADD COLUMN project_id VARCHAR(64) NOT NULL DEFAULT 'project_public' AFTER related_entities,
  ADD INDEX idx_agent_events_project_id (project_id);

UPDATE agent_events
SET project_id = 'project_public'
WHERE project_id IS NULL OR project_id = '';

ALTER TABLE agent_analyses
  ADD COLUMN project_id VARCHAR(64) NOT NULL DEFAULT 'project_public' AFTER recommendation,
  ADD INDEX idx_agent_analyses_project_id (project_id);

UPDATE agent_analyses
SET project_id = 'project_public'
WHERE project_id IS NULL OR project_id = '';

ALTER TABLE news_events
  ADD COLUMN project_id VARCHAR(64) NOT NULL DEFAULT 'project_public' AFTER tags,
  ADD INDEX idx_news_events_project_id (project_id);

UPDATE news_events
SET project_id = 'project_public'
WHERE project_id IS NULL OR project_id = '';

ALTER TABLE relation_candidates
  ADD COLUMN project_id VARCHAR(64) NOT NULL DEFAULT 'project_public' AFTER status,
  ADD INDEX idx_relation_candidates_project_id (project_id);

UPDATE relation_candidates
SET project_id = 'project_public'
WHERE project_id IS NULL OR project_id = '';
