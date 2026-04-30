CREATE TABLE IF NOT EXISTS `interfaces` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `industry_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `interface_properties` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interface_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `required` tinyint NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_interface_properties_interface_id` (`interface_id`),
  CONSTRAINT `fk_interface_properties_interface`
    FOREIGN KEY (`interface_id`) REFERENCES `interfaces` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `interface_extends` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_interface_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `child_interface_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_interface_extends_child` (`child_interface_id`),
  KEY `idx_interface_extends_parent` (`parent_interface_id`),
  CONSTRAINT `fk_interface_extends_parent`
    FOREIGN KEY (`parent_interface_id`) REFERENCES `interfaces` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interface_extends_child`
    FOREIGN KEY (`child_interface_id`) REFERENCES `interfaces` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `object_type_interfaces_mapping` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `object_type_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interface_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_object_type_interface_mapping` (`object_type_id`, `interface_id`),
  KEY `idx_object_type_interfaces_mapping_interface_id` (`interface_id`),
  CONSTRAINT `fk_object_type_interfaces_mapping_object_type`
    FOREIGN KEY (`object_type_id`) REFERENCES `object_types` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_object_type_interfaces_mapping_interface`
    FOREIGN KEY (`interface_id`) REFERENCES `interfaces` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `interface_property_mapping` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `object_type_interface_mapping_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interface_property_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `property_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_interface_property_mapping` (`object_type_interface_mapping_id`, `interface_property_id`),
  CONSTRAINT `fk_interface_property_mapping_impl`
    FOREIGN KEY (`object_type_interface_mapping_id`) REFERENCES `object_type_interfaces_mapping` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interface_property_mapping_interface_property`
    FOREIGN KEY (`interface_property_id`) REFERENCES `interface_properties` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interface_property_mapping_property`
    FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `interface_link_constraints` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interface_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_interface_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_object_type_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cardinality` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `required` tinyint NOT NULL DEFAULT '0',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_interface_link_constraints_interface_id` (`interface_id`),
  CONSTRAINT `fk_interface_link_constraints_interface`
    FOREIGN KEY (`interface_id`) REFERENCES `interfaces` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interface_link_constraints_target_interface`
    FOREIGN KEY (`target_interface_id`) REFERENCES `interfaces` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interface_link_constraints_target_object_type`
    FOREIGN KEY (`target_object_type_id`) REFERENCES `object_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `interface_link_type_constraint_mapping` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `object_type_interface_mapping_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interface_link_constraint_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_type_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_interface_link_type_constraint_mapping` (`object_type_interface_mapping_id`, `interface_link_constraint_id`),
  CONSTRAINT `fk_interface_link_type_constraint_mapping_impl`
    FOREIGN KEY (`object_type_interface_mapping_id`) REFERENCES `object_type_interfaces_mapping` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interface_link_type_constraint_mapping_constraint`
    FOREIGN KEY (`interface_link_constraint_id`) REFERENCES `interface_link_constraints` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interface_link_type_constraint_mapping_link_type`
    FOREIGN KEY (`link_type_id`) REFERENCES `link_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
