CREATE TABLE IF NOT EXISTS projects (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  is_public TINYINT NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO projects (id, name, description, is_public, status)
VALUES ('project_public', '公共项目', '公共只读项目', 1, 'ACTIVE')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  is_public = VALUES(is_public),
  status = VALUES(status);

ALTER TABLE object_types ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE properties ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE link_types ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE interfaces ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE interface_properties ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE interface_extends ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE interface_link_constraints ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE object_type_interfaces_mapping ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE interface_property_mapping ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE interface_link_type_constraint_mapping ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE action_types ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE action_rules ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE action_rule_params ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE action_effects ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE ontology_rules ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE ontology_rule_params ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE function_types ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';
ALTER TABLE function_params ADD COLUMN project_id VARCHAR(255) NOT NULL DEFAULT 'project_public';

CREATE INDEX idx_object_types_project_id ON object_types(project_id);
CREATE INDEX idx_properties_project_id ON properties(project_id);
CREATE INDEX idx_link_types_project_id ON link_types(project_id);
CREATE INDEX idx_interfaces_project_id ON interfaces(project_id);
CREATE INDEX idx_interface_properties_project_id ON interface_properties(project_id);
CREATE INDEX idx_interface_extends_project_id ON interface_extends(project_id);
CREATE INDEX idx_interface_link_constraints_project_id ON interface_link_constraints(project_id);
CREATE INDEX idx_object_type_interfaces_mapping_project_id ON object_type_interfaces_mapping(project_id);
CREATE INDEX idx_interface_property_mapping_project_id ON interface_property_mapping(project_id);
CREATE INDEX idx_interface_link_type_constraint_mapping_project_id ON interface_link_type_constraint_mapping(project_id);
CREATE INDEX idx_action_types_project_id ON action_types(project_id);
CREATE INDEX idx_action_rules_project_id ON action_rules(project_id);
CREATE INDEX idx_action_rule_params_project_id ON action_rule_params(project_id);
CREATE INDEX idx_action_effects_project_id ON action_effects(project_id);
CREATE INDEX idx_ontology_rules_project_id ON ontology_rules(project_id);
CREATE INDEX idx_ontology_rule_params_project_id ON ontology_rule_params(project_id);
CREATE INDEX idx_function_types_project_id ON function_types(project_id);
CREATE INDEX idx_function_params_project_id ON function_params(project_id);
