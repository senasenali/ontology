-- MySQL dump 10.13  Distrib 9.6.0, for macos26.3 (arm64)
--
-- Host: localhost    Database: ontology
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `action_effects`
--

DROP TABLE IF EXISTS `action_effects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_effects` (
  `id` varchar(64) NOT NULL COMMENT '副作用ID',
  `action_type_id` varchar(64) NOT NULL COMMENT '关联动作类型ID',
  `effect_type` varchar(32) NOT NULL COMMENT '副作用类型：NOTIFICATION/LINGKE/EMAIL',
  `content` text COMMENT '内容（当effect_type=NOTIFICATION时）',
  `is_enabled` tinyint DEFAULT '1' COMMENT '是否启用：0/1',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_action_type` (`action_type_id`),
  KEY `idx_effect_type` (`effect_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='动作副作用表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_effects`
--

LOCK TABLES `action_effects` WRITE;
/*!40000 ALTER TABLE `action_effects` DISABLE KEYS */;
INSERT INTO `action_effects` VALUES ('ae_1776044132900_0','act_1776002892929','NOTIFICATION','完成电芯实例的创建',1,0),('ae_1776236475199_0','act_1776236475185','NOTIFICATION','',1,0),('ae_1776244893413_0','act_1776231635728','NOTIFICATION','',1,0),('ae_1776253947626_0','act_1776253947603','NOTIFICATION','',1,0),('ae_create_company_company_link','act_create_company_company_link','NOTIFICATION','已创建新的公司合作关系链接',1,0),('ae_delete_company_company_link','act_delete_company_company_link','NOTIFICATION','已删除公司合作关系链接',1,0);
/*!40000 ALTER TABLE `action_effects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_executions`
--

DROP TABLE IF EXISTS `action_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_executions` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `action_type_id` varchar(64) NOT NULL,
  `target_object_id` varchar(255) DEFAULT NULL COMMENT '目标对象ID',
  `parameters` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending',
  `validation_errors` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `side_effects` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `executed_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'system',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `action_type_id` (`action_type_id`),
  CONSTRAINT `action_executions_ibfk_1` FOREIGN KEY (`action_type_id`) REFERENCES `action_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_executions`
--

LOCK TABLES `action_executions` WRITE;
/*!40000 ALTER TABLE `action_executions` DISABLE KEYS */;
INSERT INTO `action_executions` VALUES ('exec_01d7f2cf','act_delete_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}','failed',NULL,NULL,'{parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}, actionTypeName=删除链接, actionTypeId=act_delete_company_company_link, executedAt=2026-04-16T07:15:51.975344, rules=[{ontologyRuleId=rule_delete_company_company_link, ruleType=ONTOLOGY, ruleId=ar_delete_company_company_link, error=Object type not found: lt_company_strategic_cooperation, status=failed}]}','researcher','2026-04-16 07:15:52','2026-04-16 07:15:52'),('exec_075cd824','act_1776231635728','1','{p_id_1775651827534=BC-ATL-001-2024, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=, instanceId=1}','failed',NULL,NULL,'{executedAt=2026-04-15T14:05:38.264904, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例, parameters={p_id_1775651827534=BC-ATL-001-2024, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=, instanceId=1}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, error=PreparedStatementCallback; SQL [INSERT INTO `battery_cell` (`unique_id`, `manufacturer`, `model`, `price`, `price_date`, `created_at`, `updated_at`) VALUES (?, ?, ?, ?, ?, ?, ?)]; Data truncation: Incorrect date value: \'\' for column \'price_date\' at row 1, status=failed}]}','user','2026-04-15 14:05:38','2026-04-15 14:05:38'),('exec_07f0eec3','act_1776231635728',NULL,'{p_id_1775651827534=BC-CODEX-TEST-002, p_price_1775651827535=1.23}','completed',NULL,'[{notificationId=notif_1776233430013, effectType=NOTIFICATION, status=executed}]','{parameters={p_id_1775651827534=BC-CODEX-TEST-002, p_price_1775651827535=1.23}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, message=Instance created successfully, status=success}], executedAt=2026-04-15T14:10:30.008760, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例}','codex','2026-04-15 14:10:30','2026-04-15 14:10:30'),('exec_14401af2','act_1776002892929','1111112','{unique_id=1111112, instanceId=1111112}','completed',NULL,'[{notificationId=notif_1776003463278, effectType=NOTIFICATION, status=executed}]','{rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776002892942_0, status=executed}], parameters={unique_id=1111112, instanceId=1111112}, actionTypeName=创建类型, actionTypeId=act_1776002892929, executedAt=2026-04-12T22:17:43.278492}','user','2026-04-12 22:17:43','2026-04-12 22:17:43'),('exec_176a2d0f','act_1776231635728','9','{p_id_1775651827534=BC-EVE-001-2026, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=, instanceId=9}','failed',NULL,NULL,'{executedAt=2026-04-15T14:06:28.483564, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例, parameters={p_id_1775651827534=BC-EVE-001-2026, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=, instanceId=9}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, error=PreparedStatementCallback; SQL [INSERT INTO `battery_cell` (`unique_id`, `manufacturer`, `model`, `price`, `price_date`, `created_at`, `updated_at`) VALUES (?, ?, ?, ?, ?, ?, ?)]; Data truncation: Incorrect date value: \'\' for column \'price_date\' at row 1, status=failed}]}','user','2026-04-15 14:06:28','2026-04-15 14:06:28'),('exec_1bff6a79','act_1776002892929','unknown','{p_id_1775651827534=BC-EVE-001-20266666, 0p_manufacturer_1775651931268=测试}','completed',NULL,'[{notificationId=notif_1776043834965, effectType=NOTIFICATION, status=executed}]','{parameters={p_id_1775651827534=BC-EVE-001-20266666, 0p_manufacturer_1775651931268=测试}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776042251283_0, message=Instance created successfully, status=success}], executedAt=2026-04-13T09:30:34.955395, actionTypeId=act_1776002892929, actionTypeName=创建类型}','user','2026-04-13 09:30:35','2026-04-13 09:30:35'),('exec_1e03e420','act_1776231635728','unknown','{p_id_1775651827534=BC-ATL-001-2024, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=}','failed',NULL,NULL,'{executedAt=2026-04-15T13:50:10.379101, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例, parameters={p_id_1775651827534=BC-ATL-001-2024, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, error=PreparedStatementCallback; SQL [INSERT INTO `battery_cell` (`unique_id`, `manufacturer`, `model`, `price`, `price_date`, `created_at`, `updated_at`) VALUES (?, ?, ?, ?, ?, ?, ?)]; Data truncation: Incorrect date value: \'\' for column \'price_date\' at row 1, status=failed}]}','user','2026-04-15 13:50:10','2026-04-15 13:50:10'),('exec_342a969e','act_1776002892929','unknown','{p_id_1775651827534=111111, 0p_manufacturer_1775651931268=测试}','failed',NULL,NULL,'{rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776042251283_0, error=PreparedStatementCallback; uncategorized SQLException for SQL [INSERT INTO `battery_cell` (`created_at`, `updated_at`) VALUES (?, ?)]; SQL state [HY000]; error code [1364]; Field \'unique_id\' doesn\'t have a default value, status=failed}], executedAt=2026-04-13T09:13:27.857560, actionTypeId=act_1776002892929, actionTypeName=创建类型, parameters={p_id_1775651827534=111111, 0p_manufacturer_1775651931268=测试}}','user','2026-04-13 09:13:28','2026-04-13 09:13:28'),('exec_37142097','act_delete_company_company_link','unknown','{sourceInstanceId=COMP_BYD, targetInstanceId=COMP_CATL, linkTypeId=lt_company_strategic_cooperation}','completed',NULL,'[{notificationId=notif_1776306990040, effectType=NOTIFICATION, status=executed}]','{executedAt=2026-04-16T10:36:30.031306, actionTypeId=act_delete_company_company_link, actionTypeName=删除链接, parameters={sourceInstanceId=COMP_BYD, targetInstanceId=COMP_CATL, linkTypeId=lt_company_strategic_cooperation}, rules=[{linkExists=false, data={linkTypeId=lt_company_strategic_cooperation, targetInstanceId=COMP_CATL, sourceInstanceId=COMP_BYD}, ontologyRuleId=rule_delete_company_company_link, ruleType=ONTOLOGY, ruleId=ar_delete_company_company_link, message=Link deleted successfully, status=success}]}','user','2026-04-16 10:36:30','2026-04-16 10:36:30'),('exec_3ad7eb7a','act_create_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation, evidence=宁德时代与中恒电气宣布围绕储能场景展开协同合作，包括储能系统集成、站端设备协同与项目拓展。}','completed',NULL,'[{notificationId=notif_1776316731987, effectType=NOTIFICATION, status=executed}]','{executedAt=2026-04-16T13:18:51.960609, actionTypeId=act_create_company_company_link, actionTypeName=创建链接, parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation, evidence=宁德时代与中恒电气宣布围绕储能场景展开协同合作，包括储能系统集成、站端设备协同与项目拓展。}, rules=[{linkExists=true, data={linkTypeId=lt_company_strategic_cooperation, targetInstanceId=COMP_CET, sourceInstanceId=COMP_CATL}, ontologyRuleId=rule_create_company_company_link, ruleType=ONTOLOGY, ruleId=ar_create_company_company_link, message=Link created successfully, status=success}]}','researcher','2026-04-16 13:18:52','2026-04-16 13:18:52'),('exec_4015c11b','act_1776231635728','unknown','{p_id_1775651827534=BC-EVE-001-2026, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=, p_price_date_1775651827536=0.99, instanceId=}','failed',NULL,NULL,'{executedAt=2026-04-15T14:09:19.648953, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例, parameters={p_id_1775651827534=BC-EVE-001-2026, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=, p_price_date_1775651827536=0.99, instanceId=}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, error=PreparedStatementCallback; uncategorized SQLException for SQL [INSERT INTO `battery_cell` (`unique_id`, `manufacturer`, `model`, `price`, `price_date`, `created_at`, `updated_at`) VALUES (?, ?, ?, ?, ?, ?, ?)]; SQL state [HY000]; error code [1366]; Incorrect decimal value: \'\' for column \'price\' at row 1, status=failed}]}','user','2026-04-15 14:09:20','2026-04-15 14:09:20'),('exec_5666afe3','act_1776002892929','111112','{unique_id=111112}','failed',NULL,NULL,'{executedAt=2026-04-12T22:40:02.438414, actionTypeId=act_1776002892929, actionTypeName=创建类型, parameters={unique_id=111112}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776002892942_0, error=500 : \"{\"timestamp\":\"2026-04-12 22:40:02\",\"status\":500,\"error\":\"Internal Server Error\",\"path\":\"/api/instances/battery_cell\"}\", status=failed}]}','user','2026-04-12 22:40:02','2026-04-12 22:40:03'),('exec_62c2c282','act_create_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation, evidence=宁德时代与中恒电气宣布围绕储能场景展开协同合作，包括储能系统集成、站端设备协同与项目拓展。}','failed',NULL,NULL,'{parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation, evidence=宁德时代与中恒电气宣布围绕储能场景展开协同合作，包括储能系统集成、站端设备协同与项目拓展。}, actionTypeName=创建链接, actionTypeId=act_create_company_company_link, executedAt=2026-04-16T07:21:13.289655, rules=[{ontologyRuleId=rule_create_company_company_link, ruleType=ONTOLOGY, ruleId=ar_create_company_company_link, error=Object type not found: lt_company_strategic_cooperation, status=failed}]}','researcher','2026-04-16 07:21:13','2026-04-16 07:21:13'),('exec_67df225e','act_1776002892929','111115','{unique_id=111115}','failed',NULL,NULL,'{rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776002892942_0, error=PreparedStatementCallback; uncategorized SQLException for SQL [INSERT INTO `battery_cell` (`created_at`, `updated_at`) VALUES (?, ?)]; SQL state [HY000]; error code [1364]; Field \'unique_id\' doesn\'t have a default value, status=failed}], parameters={unique_id=111115}, actionTypeName=创建类型, actionTypeId=act_1776002892929, executedAt=2026-04-12T22:48:07.530052}','user','2026-04-12 22:48:08','2026-04-12 22:48:08'),('exec_6ab632a3','act_delete_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}','completed',NULL,'[{notificationId=notif_1776317092646, effectType=NOTIFICATION, status=executed}]','{executedAt=2026-04-16T13:24:52.640089, actionTypeId=act_delete_company_company_link, actionTypeName=删除链接, parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}, rules=[{linkExists=false, data={linkTypeId=lt_company_strategic_cooperation, targetInstanceId=COMP_CET, sourceInstanceId=COMP_CATL}, ontologyRuleId=rule_delete_company_company_link, ruleType=ONTOLOGY, ruleId=ar_delete_company_company_link, message=Link deleted successfully, status=success}]}','researcher','2026-04-16 13:24:53','2026-04-16 13:24:53'),('exec_6bf31721','act_1776231635728','unknown','{p_id_1775651827534=BC-EVE-002-2025, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=1.02, p_price_date_1775651827536=}','completed',NULL,'[{notificationId=notif_1776235019779, effectType=NOTIFICATION, status=executed}]','{parameters={p_id_1775651827534=BC-EVE-002-2025, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=1.02, p_price_date_1775651827536=}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, message=Instance created successfully, status=success}], executedAt=2026-04-15T14:36:59.774334, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例}','user','2026-04-15 14:37:00','2026-04-15 14:37:00'),('exec_72620050','act_1776002892929','111111','{unique_id=111111}','completed',NULL,'[{notificationId=notif_1776003391623, effectType=NOTIFICATION, status=executed}]','{rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776002892942_0, status=executed}], parameters={unique_id=111111}, actionTypeName=创建类型, actionTypeId=act_1776002892929, executedAt=2026-04-12T22:16:31.623126}','user','2026-04-12 22:16:32','2026-04-12 22:16:32'),('exec_7f906717','act_create_company_company_link','unknown','{sourceInstanceId=COMP_BYD, targetInstanceId=COMP_CATL, linkTypeId=lt_company_strategic_cooperation, instanceId=}','failed',NULL,NULL,'{parameters={sourceInstanceId=COMP_BYD, targetInstanceId=COMP_CATL, linkTypeId=lt_company_strategic_cooperation, instanceId=}, actionTypeName=创建链接, actionTypeId=act_create_company_company_link, executedAt=2026-04-16T10:22:41.123807, rules=[{ontologyRuleId=rule_create_company_company_link, ruleType=ONTOLOGY, ruleId=ar_create_company_company_link, error=Object type not found: lt_company_strategic_cooperation, status=failed}]}','user','2026-04-16 10:22:41','2026-04-16 10:22:41'),('exec_940c496c','act_1776253947603','unknown','{p_vehicleid_1775385754771=test, p_modelname_1775385755582=test, p_brand_1775388584499=test, p_price_1775385757615=, p_batterycapacity_1775385756098=, p_isavailable_1775385758165=}','completed',NULL,'[{notificationId=notif_1776312695725, effectType=NOTIFICATION, status=executed}]','{executedAt=2026-04-16T12:11:35.714239, actionTypeId=act_1776253947603, actionTypeName=创建整车实例, parameters={p_vehicleid_1775385754771=test, p_modelname_1775385755582=test, p_brand_1775388584499=test, p_price_1775385757615=, p_batterycapacity_1775385756098=, p_isavailable_1775385758165=}, rules=[{ontologyRuleId=rule_nev_create, ruleType=ONTOLOGY, ruleId=ar_1776253947615_0, message=Instance created successfully, status=success}]}','user','2026-04-16 12:11:36','2026-04-16 12:11:36'),('exec_a192f1bb','act_1776231635728','unknown','{p_id_1775651827534=test, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=, p_price_date_1775651827536=}','completed',NULL,'[{notificationId=notif_1776318954207, effectType=NOTIFICATION, status=executed}]','{executedAt=2026-04-16T13:55:54.203550, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例, parameters={p_id_1775651827534=test, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=, p_price_date_1775651827536=}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776244893408_0, message=Instance created successfully, status=success}]}','user','2026-04-16 13:55:54','2026-04-16 13:55:54'),('exec_a317a2ba','act_delete_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}','failed',NULL,NULL,'{parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}, actionTypeName=删除链接, actionTypeId=act_delete_company_company_link, executedAt=2026-04-16T07:22:00.553305, rules=[{ontologyRuleId=rule_delete_company_company_link, ruleType=ONTOLOGY, ruleId=ar_delete_company_company_link, error=Object type not found: lt_company_strategic_cooperation, status=failed}]}','researcher','2026-04-16 07:22:01','2026-04-16 07:22:01'),('exec_a65e0e02','act_create_company_company_link','unknown','{sourceInstanceId=COMP_BYD, targetInstanceId=COMP_CATL, linkTypeId=lt_company_strategic_cooperation}','completed',NULL,'[{notificationId=notif_1776306885307, effectType=NOTIFICATION, status=executed}]','{executedAt=2026-04-16T10:34:45.293332, actionTypeId=act_create_company_company_link, actionTypeName=创建链接, parameters={sourceInstanceId=COMP_BYD, targetInstanceId=COMP_CATL, linkTypeId=lt_company_strategic_cooperation}, rules=[{linkExists=true, data={linkTypeId=lt_company_strategic_cooperation, targetInstanceId=COMP_CATL, sourceInstanceId=COMP_BYD}, ontologyRuleId=rule_create_company_company_link, ruleType=ONTOLOGY, ruleId=ar_create_company_company_link, message=Link created successfully, status=success}]}','user','2026-04-16 10:34:45','2026-04-16 10:34:45'),('exec_a8eff800','act_1776231635728',NULL,'{p_id_1775651827534=BC-CODEX-TEST-001, p_price_1775651827535=0.99, instanceId=}','completed',NULL,'[{notificationId=notif_1776233421132, effectType=NOTIFICATION, status=executed}]','{parameters={p_id_1775651827534=BC-CODEX-TEST-001, p_price_1775651827535=0.99, instanceId=}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, message=Instance created successfully, status=success}], executedAt=2026-04-15T14:10:21.122441, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例}','codex','2026-04-15 14:10:21','2026-04-15 14:10:21'),('exec_a9bbd9e6','act_1776002892929','unknown','{p_id_1775651827534=111111, 0p_manufacturer_1775651931268=测试}','failed',NULL,NULL,'{actionTypeName=创建类型, actionTypeId=act_1776002892929, executedAt=2026-04-13T09:04:22.138973, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776042251283_0, error=PreparedStatementCallback; uncategorized SQLException for SQL [INSERT INTO `battery_cell` (`created_at`, `updated_at`) VALUES (?, ?)]; SQL state [HY000]; error code [1364]; Field \'id\' doesn\'t have a default value, status=failed}], parameters={p_id_1775651827534=111111, 0p_manufacturer_1775651931268=测试}}','user','2026-04-13 09:04:22','2026-04-13 09:04:22'),('exec_aae8381d','act_delete_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}','failed',NULL,NULL,'{parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}, actionTypeName=删除链接, actionTypeId=act_delete_company_company_link, executedAt=2026-04-16T07:13:36.291797, rules=[{ontologyRuleId=rule_delete_company_company_link, ruleType=ONTOLOGY, ruleId=ar_delete_company_company_link, error=Object type not found: lt_company_strategic_cooperation, status=failed}]}','researcher','2026-04-16 07:13:36','2026-04-16 07:13:36'),('exec_ad8504d4','act_1776002892929','111113','{unique_id=111113}','failed',NULL,NULL,'{rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776002892942_0, error=PreparedStatementCallback; uncategorized SQLException for SQL [INSERT INTO `battery_cell` (`created_at`, `updated_at`) VALUES (?, ?)]; SQL state [HY000]; error code [1364]; Field \'unique_id\' doesn\'t have a default value, status=failed}], parameters={unique_id=111113}, actionTypeName=创建类型, actionTypeId=act_1776002892929, executedAt=2026-04-12T22:44:03.484207}','user','2026-04-12 22:44:03','2026-04-12 22:44:04'),('exec_d03c7c5a','act_1776236475185','LC-BATTERY-001-2024','{instanceId=LC-BATTERY-001-2024, depth=3, latestPrice=10}','completed',NULL,'[{notificationId=notif_1776236507419, effectType=NOTIFICATION, status=executed}]','{parameters={instanceId=LC-BATTERY-001-2024, depth=3, latestPrice=10}, rules=[{response={success=false, error=Instance not found: LC-BATTERY-001-2024}, ruleType=OTHER, ruleId=ar_1776236475190_0, functionTypeId=func_calculate_price_transmission, status=success}], executedAt=2026-04-15T15:01:47.413572, actionTypeId=act_1776236475185, actionTypeName=碳酸锂价格传导}','user','2026-04-15 15:01:47','2026-04-15 15:01:47'),('exec_d1d3deb2','act_create_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation, evidence=宁德时代与中恒电气宣布围绕储能场景展开协同合作，包括储能系统集成、站端设备协同与项目拓展。}','completed',NULL,'[{notificationId=notif_1776317568235, effectType=NOTIFICATION, status=executed}]','{executedAt=2026-04-16T13:32:48.230719, actionTypeId=act_create_company_company_link, actionTypeName=创建链接, parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation, evidence=宁德时代与中恒电气宣布围绕储能场景展开协同合作，包括储能系统集成、站端设备协同与项目拓展。}, rules=[{linkExists=true, data={linkTypeId=lt_company_strategic_cooperation, targetInstanceId=COMP_CET, sourceInstanceId=COMP_CATL}, ontologyRuleId=rule_create_company_company_link, ruleType=ONTOLOGY, ruleId=ar_create_company_company_link, message=Link created successfully, status=success}]}','researcher','2026-04-16 13:32:48','2026-04-16 13:32:48'),('exec_de724399','act_delete_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}','failed',NULL,NULL,'{parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}, actionTypeName=删除链接, actionTypeId=act_delete_company_company_link, executedAt=2026-04-16T07:12:35.812465, rules=[{ontologyRuleId=rule_delete_company_company_link, ruleType=ONTOLOGY, ruleId=ar_delete_company_company_link, error=Object type not found: lt_company_strategic_cooperation, status=failed}]}','researcher','2026-04-16 07:12:36','2026-04-16 07:12:36'),('exec_f48eb8ca','act_1776002892929',NULL,'{}','completed',NULL,'[{notificationId=notif_1776043733372, effectType=NOTIFICATION, status=executed}]','{parameters={}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776042251283_0, message=Instance created successfully, status=success}], executedAt=2026-04-13T09:28:53.369305, actionTypeId=act_1776002892929, actionTypeName=创建类型}','test_user','2026-04-13 09:28:53','2026-04-13 09:28:53'),('exec_fa09e98f','act_delete_company_company_link',NULL,'{sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}','failed',NULL,NULL,'{parameters={sourceInstanceId=COMP_CATL, targetInstanceId=COMP_CET, linkTypeId=lt_company_strategic_cooperation}, actionTypeName=删除链接, actionTypeId=act_delete_company_company_link, executedAt=2026-04-16T07:20:37.918983, rules=[{ontologyRuleId=rule_delete_company_company_link, ruleType=ONTOLOGY, ruleId=ar_delete_company_company_link, error=Object type not found: lt_company_strategic_cooperation, status=failed}]}','researcher','2026-04-16 07:20:38','2026-04-16 07:20:38'),('exec_fecc5181','act_1776231635728','unknown','{p_id_1775651827534=BC-EVE-001-2026, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=}','completed',NULL,'[{notificationId=notif_1776233487901, effectType=NOTIFICATION, status=executed}]','{parameters={p_id_1775651827534=BC-EVE-001-2026, p_manufacturer_1775651931268=, p_model_1775651928286=, p_price_1775651827535=0.99, p_price_date_1775651827536=}, rules=[{ontologyRuleId=rule_bc_create, ruleType=ONTOLOGY, ruleId=ar_1776231635747_0, message=Instance created successfully, status=success}], executedAt=2026-04-15T14:11:27.891845, actionTypeId=act_1776231635728, actionTypeName=创建电芯实例}','user','2026-04-15 14:11:28','2026-04-15 14:11:28');
/*!40000 ALTER TABLE `action_executions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_parameters_backup`
--

DROP TABLE IF EXISTS `action_parameters_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_parameters_backup` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_type_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string',
  `required` tinyint NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `action_type_id` (`action_type_id`),
  CONSTRAINT `action_parameters_backup_ibfk_1` FOREIGN KEY (`action_type_id`) REFERENCES `action_types_backup` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_parameters_backup`
--

LOCK TABLES `action_parameters_backup` WRITE;
/*!40000 ALTER TABLE `action_parameters_backup` DISABLE KEYS */;
/*!40000 ALTER TABLE `action_parameters_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_rule_params`
--

DROP TABLE IF EXISTS `action_rule_params`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_rule_params` (
  `id` varchar(64) NOT NULL COMMENT '参数ID',
  `action_rule_id` varchar(64) NOT NULL COMMENT '关联动作规则ID',
  `param_name` varchar(64) NOT NULL COMMENT '参数名',
  `param_value` text COMMENT '参数值（JSON格式）',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_action_rule` (`action_rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='动作规则参数表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_rule_params`
--

LOCK TABLES `action_rule_params` WRITE;
/*!40000 ALTER TABLE `action_rule_params` DISABLE KEYS */;
INSERT INTO `action_rule_params` VALUES ('arp_1776044132887_0','ar_1776044132878_0','p_id_1775651827534','BC-EVE-001-2026',0),('arp_1776044132890_1','ar_1776044132878_0','0p_model_1775651928286','测试',1),('arp_1776044132895_2','ar_1776044132878_0','0p_manufacturer_1775651931268','测试',2),('arp_1776044132896_3','ar_1776044132878_0','0p_price_1775651827535','0.99',3),('arp_1776236475196_0','ar_1776236475190_0','instanceId','',0),('arp_1776236475198_1','ar_1776236475190_0','depth','3',1),('arp_1776236475199_2','ar_1776236475190_0','latestPrice','',2),('arp_1776244893410_0','ar_1776244893408_0','p_id_1775651827534','',0),('arp_1776244893410_1','ar_1776244893408_0','p_manufacturer_1775651931268','',1),('arp_1776244893411_2','ar_1776244893408_0','p_model_1775651928286','',2),('arp_1776244893411_3','ar_1776244893408_0','p_price_1775651827535','',3),('arp_1776244893412_4','ar_1776244893408_0','p_price_date_1775651827536','',4),('arp_1776253947617_0','ar_1776253947615_0','p_vehicleid_1775385754771','',0),('arp_1776253947623_1','ar_1776253947615_0','p_modelname_1775385755582','',1),('arp_1776253947623_2','ar_1776253947615_0','p_brand_1775388584499','',2),('arp_1776253947624_3','ar_1776253947615_0','p_price_1775385757615','',3),('arp_1776253947625_4','ar_1776253947615_0','p_batterycapacity_1775385756098','',4),('arp_1776253947625_5','ar_1776253947615_0','p_isavailable_1775385758165','',5);
/*!40000 ALTER TABLE `action_rule_params` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_rules`
--

DROP TABLE IF EXISTS `action_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_rules` (
  `id` varchar(64) NOT NULL COMMENT '规则ID',
  `action_type_id` varchar(64) NOT NULL COMMENT '关联动作类型ID',
  `rule_type` varchar(32) NOT NULL COMMENT '规则类型：ONTOLOGY/OTHER',
  `ontology_rule_category` varchar(32) DEFAULT NULL COMMENT '本体规则类别（当rule_type=ONTOLOGY时）',
  `ontology_rule_id` varchar(64) DEFAULT NULL COMMENT '关联的ontology_rules.id（当rule_type=ONTOLOGY时）',
  `function_type_id` varchar(64) DEFAULT NULL COMMENT '关联的function_types.id（当rule_type=OTHER时）',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_action_type` (`action_type_id`),
  KEY `idx_rule_type` (`rule_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='动作规则表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_rules`
--

LOCK TABLES `action_rules` WRITE;
/*!40000 ALTER TABLE `action_rules` DISABLE KEYS */;
INSERT INTO `action_rules` VALUES ('ar_1776044132878_0','act_1776002892929','ONTOLOGY','CREATE_OBJECT','rule_bc_create',NULL,0,'2026-04-13 09:35:33'),('ar_1776236475190_0','act_1776236475185','OTHER',NULL,NULL,'func_calculate_price_transmission',0,'2026-04-15 15:01:15'),('ar_1776244893408_0','act_1776231635728','ONTOLOGY','CREATE_OBJECT','rule_bc_create',NULL,0,'2026-04-15 17:21:33'),('ar_1776253947615_0','act_1776253947603','ONTOLOGY','CREATE_OBJECT','rule_nev_create',NULL,0,'2026-04-15 19:52:28'),('ar_create_company_company_link','act_create_company_company_link','ONTOLOGY','CREATE_LINK','rule_create_company_company_link',NULL,0,'2026-04-16 07:10:23'),('ar_delete_company_company_link','act_delete_company_company_link','ONTOLOGY','DELETE_LINK','rule_delete_company_company_link',NULL,0,'2026-04-16 07:10:23');
/*!40000 ALTER TABLE `action_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_rules_backup`
--

DROP TABLE IF EXISTS `action_rules_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_rules_backup` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_type_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `action_type_id` (`action_type_id`),
  CONSTRAINT `action_rules_backup_ibfk_1` FOREIGN KEY (`action_type_id`) REFERENCES `action_types_backup` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_rules_backup`
--

LOCK TABLES `action_rules_backup` WRITE;
/*!40000 ALTER TABLE `action_rules_backup` DISABLE KEYS */;
/*!40000 ALTER TABLE `action_rules_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_types`
--

DROP TABLE IF EXISTS `action_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_types` (
  `id` varchar(64) NOT NULL COMMENT '动作类型ID',
  `display_name` varchar(128) NOT NULL COMMENT '显示名称',
  `description` text COMMENT '描述',
  `status` varchar(16) DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/DISABLED',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='动作类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_types`
--

LOCK TABLES `action_types` WRITE;
/*!40000 ALTER TABLE `action_types` DISABLE KEYS */;
INSERT INTO `action_types` VALUES ('act_1776002892929','创建类型','创建一个电芯类型实例','ACTIVE','2026-04-12 22:08:13','2026-04-13 09:35:33'),('act_1776231635728','创建电芯实例','','ACTIVE','2026-04-15 13:40:36','2026-04-15 17:21:33'),('act_1776236475185','碳酸锂价格传导','','DISABLED','2026-04-15 15:01:15','2026-04-16 12:21:53'),('act_1776253947603','创建整车实例','','ACTIVE','2026-04-15 19:52:28','2026-04-15 19:52:28'),('act_create_company_company_link','创建链接','将识别到的公司间战略合作关系写入图谱','ACTIVE','2026-04-16 07:10:23','2026-04-16 07:10:23'),('act_delete_company_company_link','删除链接','删除已写入图谱的公司间战略合作关系','ACTIVE','2026-04-16 07:10:23','2026-04-16 07:10:23');
/*!40000 ALTER TABLE `action_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_types_backup`
--

DROP TABLE IF EXISTS `action_types_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_types_backup` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `target_object_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `industry_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_types_backup`
--

LOCK TABLES `action_types_backup` WRITE;
/*!40000 ALTER TABLE `action_types_backup` DISABLE KEYS */;
/*!40000 ALTER TABLE `action_types_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_analyses`
--

DROP TABLE IF EXISTS `agent_analyses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_analyses` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `agent_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `key_findings` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `impact_chain` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `recommendation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `agent_id` (`agent_id`),
  CONSTRAINT `agent_analyses_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_analyses`
--

LOCK TABLES `agent_analyses` WRITE;
/*!40000 ALTER TABLE `agent_analyses` DISABLE KEYS */;
INSERT INTO `agent_analyses` VALUES ('ana_0236da42','agent_995e16db',NULL,'中芯国际国产替代进程深度分析：扩产、供应链突破与需求共振下的战略机遇','# 中芯国际（688981.SH/SZ）事件点评分析报告\n\n## 执行摘要\n本报告基于近期围绕中芯国际的四个关键事件，运用产业链本体论分析框架，系统评估了其在国产替代大背景下的战略位置、短期业绩驱动及中长期发展路径。分析表明，中芯国际正处于**需求拉动、供应链突破、政策倒逼**三重动力叠加的战略机遇期。短期产能利用率与营收确定性高；中期供应链国产化突破将重塑成本结构与技术安全边界；长期则有望在成熟制程领域构建全球竞争力，并逐步向更先进节点延伸。投资建议为 **“增持”**。\n\n## 一、 事件梳理与定性\n\n1.  **事件一：中芯国际宣布14纳米及以上工艺节点扩产计划**\n    *   **本质**：公司针对明确的市场需求进行的主动性产能扩张，是**需求驱动型**的资本开支决策。\n    *   **重要性（High）**：直接回应了国内芯片设计公司对成熟制程的强劲需求，是公司把握市场机遇、巩固市场份额的关键举措。扩产计划本身是未来营收增长的先导指标。\n\n2.  **事件二：美国对华半导体设备出口管制出现新动向**\n    *   **本质**：外部地缘政治风险持续，构成对中国半导体制造业，特别是先进工艺发展的**持续性约束**。\n    *   **重要性（High）**：此事件非孤立噪音，而是长期趋势的强化。它从外部“倒逼”中芯国际乃至整个中国半导体产业链加速国产替代，特别是上游设备与材料的自主可控。这对中芯国际的供应链战略构成长期、根本性的影响。\n\n3.  **事件三：中芯国际联合国内设备商在28nm关键设备上取得验证突破**\n    *   **本质**：**供应链国产化取得实质性、可量产的进展**。从“可用”到“导入验证”是质变的一步。\n    *   **重要性（Medium）**：虽然单点突破，但意义重大。它验证了“国内设备商-国内制造厂”协同创新模式的可行性，为后续更多设备、材料的替代打开了通路，直接回应了事件二带来的挑战。\n\n4.  **事件四：华为等国内设计公司加大中芯国际订单**\n    *   **本质**：**下游需求端的确认与强化**。反映了国产替代从“政策倡导”进入“商业选择”阶段。\n    *   **重要性（Medium）**：为事件一的扩产提供了即时、有力的需求支撑，确保了新增产能的消化路径清晰，降低了扩产风险。同时，大客户订单的稳定性有助于公司优化工艺、提升良率。\n\n## 二、 产业链传导分析（基于本体论框架）\n\n**核心传导逻辑**：外部约束（事件二）与内部需求（事件四）共同作用，驱动中芯国际在**产能（事件一）**和**供应链（事件三）**两个维度采取行动，其影响将沿半导体制造产业链上下传导。\n\n1.  **向上游（设备、材料）传导**：\n    *   **路径**：中芯国际扩产（事件一）→ 增加对半导体制造设备（如刻蚀、沉积、光刻）及半导体材料（硅片、光刻胶、特种气体等）的采购需求。\n    *   **关键变化**：在事件二的倒逼下，采购需求将显著向国内合格供应商倾斜。事件三的成功案例将成为样板，加速国产设备/材料的验证与导入进程（`lt_battery_cell_battery_electrolyte` 类比关系：制造厂“使用”设备/材料，其性能和供应安全影响制造厂的“性能与成本”）。\n    *   **影响实体**：北方华创、中微公司、沪硅产业、安集科技等国内设备材料厂商将直接受益于需求增长和份额提升。\n\n2.  **向中游（制造环节自身）传导**：\n    *   **路径**：国内设计公司订单增加（事件四）→ 中芯国际成熟制程产能利用率提升、营收增长 → 为公司带来稳定现金流，部分可用于再投资研发与扩产（事件一），形成正向循环。\n    *   **关键变化**：中芯国际的客户结构进一步“内化”，其业绩与中国本土IC设计产业的景气度绑定更深，抗全球半导体周期波动的能力可能增强。\n\n3.  **向下游（芯片设计及终端应用）传导**：\n    *   **路径**：中芯国际产能扩张与供应链本土化（事件一、三）→ 为下游国内芯片设计公司（如华为海思、兆易创新、韦尔股份等）提供更**稳定、可靠、有产能保障**的制造服务。\n    *   **关键变化**：下游设计公司产品上市节奏和供应链安全得到加强，有助于其更激进地定义产品、开拓市场（如汽车、IoT、工业控制），从而进一步反哺对中芯国际的制造需求（`lt_power_battery_new_energy_vehicle` 类比关系：芯片是数字世界的“电池”，为终端设备赋能）。\n\n## 三、 影响评估矩阵\n\n| 评估维度 | 事件一：扩产计划 | 事件二：美出口管制动向 | 事件三：设备验证突破 | 事件四：国内订单增加 |\n| :--- | :--- | :--- | :--- | :--- |\n| **短期业绩影响 (1-2Q)** | **正面**。扩产计划本身是资本开支，短期增加折旧压力，但信号意义提振市场信心。关键看现有产能利用率（已被事件四支撑）。 | **中性偏负面**。加剧市场对供应链稳定性的担忧情绪，可能影响估值。但对已受限公司（如中芯）的短期实际运营影响边际递减。 | **轻微正面**。对当期财务影响小，但作为里程碑事件，改善市场对供应链安全的预期。 | **显著正面**。直接驱动当期营收与毛利率，是短期业绩最核心的驱动力。高产能利用率是利润基石。 |\n| **中期战略影响 (1-2Y)** | **显著正面**。新增产能将在1-2年内陆续释放，抓住成熟制程时间窗口，满足国内结构性需求，巩固市场地位。 | **战略倒逼正面**。迫使公司及产业链上下游将资源更坚决地投入国产替代，虽短期阵痛，但中长期利于构建自主可控供应链。 | **非常正面**。从0到1的突破最具价值。若能形成“验证-导入-改进-再创新”的飞轮，将系统性降低对单一外部供应链的依赖，提升定价权与成本控制力。 | **正面**。深化与国内头部设计公司的绑定关系，有利于工艺协同优化，构建本土产业生态护城河。 |\n| **长期竞争格局影响 (3-5Y)** | **正面**。中芯国际有望成为全球成熟制程（28nm及以上）最重要的产能提供者之一，从技术追随者转向市场与产能的领导者之一。 | **决定性外部环境**。长期来看，中国半导体制造必须发展出完全独立于最严格制裁的“备份”供应链。中芯国际是这一体系的核心枢纽。 | **变革性**。如果国产设备/材料在主流制程实现大规模替代，将重塑全球半导体设备市场格局，并使中芯国际的产能扩张完全摆脱外部政治约束。 | **生态构建**。推动形成“中国设计-中国制造”的内循环主导模式，改变全球半导体产业分工格局。中芯国际是此模式下的核心基础设施。 |\n\n## 四、 关键发现\n\n1.  **三重动力共振，确定性增强**：当前时点，中芯国际同时受益于**下游需求内化**（国内设计公司订单）、**自身能力建设**（主动扩产）、**外部环境倒逼**（供应链国产化提速）三重动力。这三者相互强化，显著提升了公司未来2-3年发展的能见度和确定性。\n\n2.  **成熟制程成为战略基石与现金牛**：在先进制程追赶受限的背景下，公司将战略重心聚焦于市场需求广阔、技术可控的成熟制程（14nm及以上），并通过扩产将其规模化和成本优势发挥到极致。这不仅是现实的商业选择，更是为公司积累技术、资金和供应链资源，以支持更长期发展的“战略根据地”。\n\n3.  **供应链国产化从“主题”进入“业绩”阶段**：设备验证突破（事件三）标志着国产替代已走过早期研发和样机阶段，进入可产生实际经济效益的“导入放量”前夜。后续随着更多环节突破，中芯国际的资本开支中国产设备占比有望持续提升，这不仅关乎安全，也将在长期影响其成本结构。\n\n4.  **公司角色演进：从代工厂到产业生态组织者**：在国产替代浪潮中，中芯国际的角色正在超越单纯的晶圆代工。它通过产能承诺引导上游设备材料研发，通过制造服务支撑下游设计公司创新，实际上扮演了**组织与驱动国内半导体制造业生态**的关键角色。其价值将随之重估。\n\n## 五、 影响链条（基于本体语义关系类比）\n\n**注**：以下链条将半导体产业链实体映射至提供的本体关系，以阐释传导机制。\n\n1.  **【需求传导链】**\n    *   `from`: **国内芯片设计公司** (类比 `new_energy_vehicle`， 需求端)\n    *   `to`: **中芯国际** (类比 `power_battery`， 核心部件/制造端)\n    *   `mechanism`: **“装配于/订单下达”** (类比 `lt_power_battery_new_energy_vehicle`)\n    *   `intensity`: **High**\n    *   *说明*：国内设计公司产品放量，直接增加对中芯国际制造服务的“装配”需求，驱动其产能利用率和营收。\n\n2.  **【产能扩张链】**\n    *   `from`: **中芯国际** (类比 `power_battery`)\n    *   `to`: **半导体制造设备商** (类比 `battery_electrolyte` 或 `cathode_material`， 关键原材料/部件)\n    *   `mechanism`: **“使用/采购”** (类比 `lt_battery_cell_battery_electrolyte` 或 `lt_battery_cell_cathode_material`)\n    *   `intensity`: **High**\n    *   *说明*：中芯国际扩产，必须采购大量设备，为上游设备商创造订单。在国产替代导向下，国内设备商份额提升。\n\n3.  **【供应链安全链】**\n    *   `from`: **美国出口管制** (外部冲击， 类比 `lithium_carbonate` 价格波动作为外部变量)\n    *   `to`: **中芯国际供应链安全** (目标状态)\n    *   `mechanism`: **“倒逼替代”** (触发 `act_vehicle_price` 类行动，但目标是供应链结构而非价格)\n    *   `intensity`: **High**\n    *   *说明*：外部约束如同原材料价格剧烈波动，迫使中芯国际调整其“原料”（设备/材料）供应结构，寻找替代来源（国产），以维持生产稳定。\n\n4.  **【技术验证链】**\n    *   `from`: **国内半导体设备商** (类比 `battery_electrolyte` 供应商)\n    *   `to`: **中芯国际生产良率与成本** (类比 `battery_cell` 的性能与成本)\n    *   `mechanism`: **“验证通过并导入”** (实现 `lt_battery_cell_battery_electrolyte` 关系的本土化建立)\n    *   `intensity`: **Medium** (单点突破，但趋势积极)\n    *   *说明*：国产设备通过验证，意味着中芯国际拥有了新的、可控的“电解液”供应商，长期有助于优化其“电芯”（芯片）生产的性能与成本结构。\n\n## 六、 投资建议\n\n*   **评级**：**增持 (Overweight)**\n*   **核心逻辑**：\n    1.  **短期有支撑**：国内订单饱满，成熟制程产能利用率维持高位，短期业绩具备韧性。扩产计划为中期增长打开空间。\n    2.  **中期有看点**：供应链国产化进入实质性导入期，一旦形成趋势，将系统性改善公司供应链安全并可能优化长期成本曲线。公司作为国产替代核心载体，估值中应逐步体现其生态组织者价值。\n    3.  **长期有格局**：在全球成熟制程需求持续增长及地缘政治重塑供应链的背景下，中芯国际有望确立其在全球成熟节点制造领域的领先地位，从周期成长股向战略资产过渡。\n*   **风险提示**：全球半导体下行周期超预期；国产设备/材料导入进度不及预期；美国制裁进一步升级；新增产能爬坡不及预期导致折旧压力增大。\n\n---\n**报告结束**\n*本报告基于公开信息及产业链本体论框架分析，不构成任何投资决策的唯一依据。*','[\"中芯国际正处下游需求内化、自身主动扩产、外部倒逼国产化三重动力共振期，未来2-3年发展确定性显著增强。\",\"公司战略重心明确聚焦成熟制程，旨在将其规模与成本优势最大化，该领域正从“现金牛”升级为支撑长期发展的“战略根据地”。\",\"供应链国产化已越过研发门槛，进入可产生经济效益的“导入验证”关键阶段，其进展将从主题炒作转向实质影响公司资本开支结构与成本。\",\"中芯国际在国产替代生态中的角色，正从被动代工厂向主动组织者和驱动者演进，其价值面临重估。\"]','[{\"from\":\"国内芯片设计公司\",\"to\":\"中芯国际\",\"mechanism\":\"订单需求直接驱动产能利用率和营收增长\",\"intensity\":\"high\"},{\"from\":\"中芯国际扩产计划\",\"to\":\"半导体制造设备商（尤其是国内厂商）\",\"mechanism\":\"资本开支增加带来采购需求，国产替代导向提升国内厂商份额\",\"intensity\":\"high\"},{\"from\":\"美国出口管制升级\",\"to\":\"中芯国际供应链安全战略\",\"mechanism\":\"外部风险倒逼公司加速供应链本土化，调整供应商结构\",\"intensity\":\"high\"},{\"from\":\"国产设备验证突破\",\"to\":\"中芯国际生产自主性与成本结构\",\"mechanism\":\"关键环节实现国产设备从“可用”到“量产导入”，提升供应链安全并有望优化长期成本\",\"intensity\":\"medium\"}]','评级：增持 (Overweight)。核心逻辑：短期业绩受国内高需求支撑；中期供应链国产化突破与扩产产能释放构成增长双引擎；长期有望在全球成熟制程领域确立领先地位，并从代工厂向国产半导体生态核心组织者演进，价值面临重估。需关注国产替代进度及全球行业周期风险。','2026-04-11 10:45:02'),('ana_6451654c','demo_agent_lithium',NULL,'碳酸锂价格异动传导分析：原材料暴涨68%对锂电产业链的冲击评估','监测数据显示，碳酸锂价格由12.50万元/吨大幅上涨至21.00万元/吨，涨幅达68%。基于产业链本体传导模型分析，此轮成本冲击已沿产业链逐级传导。一阶受影响环节（L2）中，正极材料与电解液价格分别上涨22.44%和38.83%，其中电解液因六氟磷酸锂等含锂组分成本敏感，涨幅更为显著。二阶受影响环节（L3-L4）中，电芯成本上涨31.58%，电池包成本上涨19.04%。至终端整车环节（L5），成本传导已大幅衰减，新能源汽车单位成本仅上升7.46%，表明中游制造环节承担了主要成本压力。本次价格跳涨可能由短期供给扰动或囤货行为驱动，需警惕若高价持续，将对电池环节毛利率构成显著挤压，并可能延缓部分中低端车型的电池技术升级进程。','[\"碳酸锂价格暴涨68%，成本冲击在电池制造环节（L2-L4）最为集中，电解液与电芯成本涨幅显著高于终端整车。\",\"产业链成本传导效率逐级衰减，从原材料到整车的整体传导系数约为10.97%（7.46%/68%），中游环节盈利缓冲垫被大幅压缩。\",\"本次事件属于短期强冲击，若高价不可持续，则对终端需求影响有限；若形成趋势，将加速产业链纵向整合与低锂耗技术替代。\"]','{\"type\":\"price_transmission_object_type\",\"analysis_source\":\"deepseek\",\"data\":{\"sourceObjectType\":{\"objectTypeId\":\"lithium_carbonate\",\"objectTypeName\":\"碳酸锂\",\"previousPrice\":12.5,\"latestPrice\":21,\"priceChangePercent\":68},\"nodes\":[{\"id\":\"lithium_carbonate\",\"name\":\"碳酸锂\",\"subtitle\":\"L1 / 原材料\",\"previousPrice\":12.5,\"latestPrice\":21,\"priceChangePercent\":68,\"level\":0},{\"id\":\"cathode_material\",\"name\":\"正极材料\",\"subtitle\":\"L2 / 正极材料\",\"previousPrice\":16,\"latestPrice\":19.59,\"priceChangePercent\":22.44,\"level\":1},{\"id\":\"battery_electrolyte\",\"name\":\"电池电解液\",\"subtitle\":\"L2 / 电池电解液\",\"previousPrice\":6,\"latestPrice\":8.33,\"priceChangePercent\":38.83,\"level\":1},{\"id\":\"battery_cell\",\"name\":\"电芯\",\"subtitle\":\"L3 / 电芯\",\"previousPrice\":0.95,\"latestPrice\":1.25,\"priceChangePercent\":31.58,\"level\":2},{\"id\":\"power_battery\",\"name\":\"电池\",\"subtitle\":\"L4 / 电池\",\"previousPrice\":71500,\"latestPrice\":85113.6,\"priceChangePercent\":19.04,\"level\":3},{\"id\":\"new_energy_vehicle\",\"name\":\"新能源汽车\",\"subtitle\":\"L5 / 新能源整车\",\"previousPrice\":23.59,\"latestPrice\":25.35,\"priceChangePercent\":7.46,\"level\":4}],\"edges\":[{\"source\":\"lithium_carbonate\",\"target\":\"cathode_material\",\"coefficient\":22.44,\"label\":\"传导系数 +22.44%\"},{\"source\":\"lithium_carbonate\",\"target\":\"battery_electrolyte\",\"coefficient\":38.76,\"label\":\"传导系数 +38.76%\"},{\"source\":\"cathode_material\",\"target\":\"battery_cell\",\"coefficient\":20.4,\"label\":\"传导系数 +20.4%\"},{\"source\":\"battery_electrolyte\",\"target\":\"battery_cell\",\"coefficient\":21.76,\"label\":\"传导系数 +21.76%\"},{\"source\":\"battery_cell\",\"target\":\"power_battery\",\"coefficient\":19.04,\"label\":\"传导系数 +19.04%\"},{\"source\":\"power_battery\",\"target\":\"new_energy_vehicle\",\"coefficient\":7.48,\"label\":\"传导系数 +7.48%\"}],\"summary\":{\"objectTypeCount\":6,\"edgeCount\":6,\"depth\":4}}}','建议短期规避成本转嫁能力弱的二线电池及材料企业，并关注具备长协矿、技术替代及纵向一体化布局的龙头公司抗风险能力。','2026-04-16 14:15:55');
/*!40000 ALTER TABLE `agent_analyses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_events`
--

DROP TABLE IF EXISTS `agent_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_events` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `agent_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `source_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `event_date` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `impact_level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `related_entities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `agent_id` (`agent_id`),
  CONSTRAINT `agent_events_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_events`
--

LOCK TABLES `agent_events` WRITE;
/*!40000 ALTER TABLE `agent_events` DISABLE KEYS */;
INSERT INTO `agent_events` VALUES ('evt_1d11a484','demo_agent_lithium','碳酸锂价格上涨 60.00%','监测到碳酸锂最新价格由 12.50 变为 20.00，单次波动 +60.00%，已触发价格传导分析。','seed','','2026-04-15','high','[\"碳酸锂\",\"电池电解液\",\"正极材料\",\"电芯\",\"电池\",\"新能源汽车\"]','2026-04-16 14:15:12'),('evt_4ab146d7','agent_995e16db','中芯国际联合国内设备商，在28nm工艺关键设备上取得验证突破','据产业链消息，中芯国际与一家国内头部半导体设备厂商合作，其某款用于28nm制程的刻蚀设备已通过中芯国际的生产线验证，并开始小批量导入。这是国产替代的重要一步。','中国证券报','','2026-04-09','medium','[]','2026-04-11 10:43:19'),('evt_4c7dd76b','agent_995e16db','美国对华半导体设备出口管制出现新动向，中芯国际供应链国产化进程受关注','近期有外媒报道，美国可能进一步收紧对华先进半导体制造设备的出口许可。此背景下，市场密切关注中芯国际在设备、材料等环节的国产替代进展及供应链安全。','财联社','','2026-04-03','high','[]','2026-04-11 10:43:19'),('evt_533d996a','demo_agent_lithium','碳酸锂价格上涨 60.00%','监测到碳酸锂最新价格由 12.50 变为 20.00，单次波动 +60.00%，已触发价格传导分析。','seed','','2026-04-15','high','[\"碳酸锂\",\"电池电解液\",\"正极材料\",\"电芯\",\"电池\",\"新能源汽车\"]','2026-04-16 10:56:08'),('evt_7a6dff8c','demo_agent_lithium','碳酸锂价格上涨 52.00%','监测到碳酸锂最新价格由 12.50 变为 19.00，单次波动 +52.00%，已触发价格传导分析。','seed','','2026-04-15','high','[\"碳酸锂\",\"电池电解液\",\"正极材料\",\"电芯\",\"电池\",\"新能源汽车\"]','2026-04-15 22:46:54'),('evt_be077f2b','demo_agent_lithium','碳酸锂价格上涨 60.00%','监测到碳酸锂最新价格由 12.50 变为 20.00，单次波动 +60.00%，已触发价格传导分析。','seed','','2026-04-15','high','[\"碳酸锂\",\"电池电解液\",\"正极材料\",\"电芯\",\"电池\",\"新能源汽车\"]','2026-04-15 22:48:00'),('evt_c6dda372','agent_995e16db','华为等国内设计公司加大中芯国际订单，成熟制程产能利用率维持高位','行业调研显示，2026年第一季度，包括华为海思在内的多家国内芯片设计公司，增加了对中芯国际成熟制程（特别是55nm至28nm）的投片量，公司相关产线维持高负荷运转。','21世纪经济报道','','2026-04-05','medium','[]','2026-04-11 10:43:19'),('evt_c9bf1a37','agent_995e16db','中芯国际宣布14纳米及以上工艺节点扩产计划，以应对国内需求增长','中芯国际在近期投资者交流会上透露，为满足国内客户对成熟制程（14nm及以上）的强劲需求，公司已启动新一轮扩产计划，重点提升28nm及40nm等节点的产能。','证券时报','','2026-04-07','high','[]','2026-04-11 10:43:19'),('evt_e91c9eb8','demo_agent_lithium','碳酸锂价格上涨 60.00%','监测到碳酸锂最新价格由 12.50 变为 20.00，单次波动 +60.00%，已触发价格传导分析。','seed','','2026-04-15','high','[\"碳酸锂\",\"电池电解液\",\"正极材料\",\"电芯\",\"电池\",\"新能源汽车\"]','2026-04-16 14:14:57'),('evt_f37d09ac','demo_agent_lithium','碳酸锂价格上涨 60.00%','监测到碳酸锂最新价格由 12.50 变为 20.00，单次波动 +60.00%，已触发价格传导分析。','seed','','2026-04-15','high','[\"碳酸锂\",\"电池电解液\",\"正极材料\",\"电芯\",\"电池\",\"新能源汽车\"]','2026-04-16 07:12:46');
/*!40000 ALTER TABLE `agent_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agents` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `target_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `target_industry` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `analysis_focus` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `schedule_minutes` int NOT NULL DEFAULT '0',
  `is_active` tinyint NOT NULL DEFAULT '0',
  `last_run_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents`
--

LOCK TABLES `agents` WRITE;
/*!40000 ALTER TABLE `agents` DISABLE KEYS */;
INSERT INTO `agents` VALUES ('agent_995e16db','中芯国际投研追踪','','中芯国际（688981.SH/SZ）','半导体制造','国产替代进口',120,0,NULL,'2026-04-04 11:13:44','2026-04-04 11:13:44'),('demo_agent_lithium','碳酸锂标的跟踪','跟踪碳酸锂价格变化，并持续观察其向电解液、电芯和动力电池环节的成本传导。','碳酸锂','锂电材料','价格波动、成本传导、电池链盈利压力',120,1,NULL,'2026-04-15 09:00:00','2026-04-15 09:00:00');
/*!40000 ALTER TABLE `agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_conversations`
--

DROP TABLE IF EXISTS `ai_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_conversations` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '新对话',
  `messages` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `preview_ontology` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_conversations`
--

LOCK TABLES `ai_conversations` WRITE;
/*!40000 ALTER TABLE `ai_conversations` DISABLE KEYS */;
INSERT INTO `ai_conversations` VALUES ('conv_11ee739e','请帮我生成一个电商平台的本体，包括商品、订单、用户、店铺、评…','[{role=system, text=欢迎使用 AI Studio！我是你的本体建模助手。\n\n你可以：\n• 描述你的业务领域，我来生成完整的数据本体\n• 要求我添加、修改或删除实体和关系\n• 让我为已有本体添加语义层信息\n• 提问关于本体设计的最佳实践\n\n每次对话我都会在已有本体基础上迭代改进。}, {role=user, text=请帮我生成一个电商平台的本体，包括商品、订单、用户、店铺、评价、物流等核心实体}, {role=assistant, text=好的，作为Palantir Foundry Ontology专家，我将为您设计一个电商平台的本体。您提供的当前本体是关于新能源电池供应链的，我们将在此基础上**新增**电商相关的核心对象类型、属性和关系，并保持原有结构不变。\n\n以下是针对您需求的电商平台本体设计方案，包含新增的6个核心对象类型和它们之间的关系。\n\n### 新增对象类型 (Object Types)\n\n```json\n[\n  {\n    \"id\": \"user\",\n    \"name\": \"用户\",\n    \"description\": \"电商平台的注册用户，可以是买家或卖家。\",\n    \"icon\": \"User\",\n    \"backingDataset\": \"user\",\n    \"dataSource\": \"mysql\",\n    \"database\": null,\n    \"industryId\": null,\n    \"createdAt\": \"2026-04-10T10:00:00\",\n    \"updatedAt\": \"2026-04-10T10:00:00\",\n    \"properties\": [\n      {\n        \"id\": \"p_user_id\",\n        \"objectTypeId\": \"user\",\n        \"name\": \"用户ID\",\n        \"type\": \"string\",\n        \"description\": \"用户的唯一标识符\",\n        \"isPrimaryKey\": 1,\n        \"baseColumn\": \"user_id\",\n        \"typeClasses\": null,\n        \"sortOrder\": 0\n      },\n      {\n        \"id\": \"p_username\",\n        \"objectTypeId\": \"user\",\n        \"name\": \"用户名\",\n        \"type\": \"string\",\n        \"description\": \"用户登录名或昵称\",\n        \"isPrimaryKey\": 0,\n        \"baseColumn\": \"username\",\n        \"typeClasses\": null,\n        \"sortOrder\": 1\n      },\n      {\n        \"id\": \"p_email\",\n        \"objectTypeId\": \"user\",\n        \"name\": \"邮箱\",\n        \"type\": \"string\",\n        \"description\": \"用户注册邮箱\",\n        \"isPrimaryKey\": 0,\n        \"baseColumn\": \"email\",\n        \"typeClasses\": null,\n        \"sortOrder\": 2\n      },\n      {\n        \"id\": \"p_phone\",\n        \"objectTypeId\": \"user\",\n        \"name\": \"手机号\",\n        \"type\": \"string\",\n        \"description\": \"用户绑定手机号\",\n        \"isPrimaryKey\": 0,\n        \"baseColumn\": \"phone\",\n        \"typeClasses\": null,\n        \"sortOrder\": 3\n      },\n      {\n        \"id\": \"p_registration_date\",\n        \"objectTypeId\": \"user\",\n        \"name\": \"注册日期\",\n        \"type\": \"date\",\n        \"description\": \"用户注册时间\",\n        \"isPrimaryKey\": 0,\n        \"baseColumn\": \"registration_date\",\n        \"typeClasses\": null,\n        \"sortOrder\": 4\n      },\n      {\n        \"id\": \"p_user_level\",\n        \"objectTypeId\": \"user\",\n        \"name\": \"用户等级\",\n        \"type\": \"string\",\n        \"description\": \"如：普通会员、VIP会员、钻石会员\",\n        \"isPrimaryKey\": 0,\n        \"baseColumn\": \"user_level\",\n        \"typeClasses\": null,\n        \"sortOrder\": 5\n      }\n    ]\n  },\n  {\n    \"id\": \"shop\",\n    \"name\": \"店铺\",\n    \"description\": \"商家在平台上开设的店铺，用于销售商品。\",\n    \"icon\": \"Store\",\n    \"backingDataset\": \"shop\",\n    \"dataSource\": \"mysql\",\n    \"database\": null,\n    \"industryId\": null,\n    \"createdAt\": \"2026-04-10T10:00:00\",\n    \"updatedAt\": \"2026-04-10T10:00:00\",\n    \"properties\": [\n      {\n        \"id\": \"p_shop_id\",\n        \"objectTypeId\": \"shop\",\n        \"name\": \"店铺ID\",\n        \"type\": \"string\",\n        \"description\": \"店铺的唯一标识符\",\n        \"isPrimaryKey\": 1,\n        \"baseColumn\": \"shop_id\",\n        \"typeClasses\": null,\n        \"sortOrder\": 0\n      },\n      {\n        \", ontology=null, streaming=false}]',NULL,'2026-04-10 23:11:21','2026-04-10 23:11:42'),('conv_56e779b1','unique_id:LC-IN-001-2024，这款碳酸锂…','[{role=system, text=欢迎使用 AI Studio！我是你的本体建模助手。\n\n你可以：\n• 描述你的业务领域，我来生成完整的数据本体\n• 要求我添加、修改或删除实体和关系\n• 让我为已有本体添加语义层信息\n• 提问关于本体设计的最佳实践\n\n每次对话我都会在已有本体基础上迭代改进。}, {role=user, text=unique_id:LC-IN-001-2024，这款碳酸锂的最新价格变成 20.6万元/吨，那么其关联的对象类型价格如何变化，这里请用 函数类型中定义的碳酸锂价格传导分析 的函数计算}, {role=assistant, text=根据您的需求，您希望当 `unique_id` 为 `LC-IN-001-2024` 的碳酸锂对象价格更新为 20.6 万元/吨时，触发一个预定义的“碳酸锂价格传导分析”函数，来计算并更新其关联对象（电解液、正极材料、电芯、电池、整车）的价格。\n\n分析当前本体，我发现以下问题需要解决：\n1.  **缺少关键对象类型**：当前本体中没有 `function_type`（函数类型）对象，无法定义和引用“碳酸锂价格传导分析”这个函数。\n2.  **缺少关联关系**：`lithium_carbonate` 对象类型与 `function_type` 对象类型之间没有建立关系，无法在动作中引用该函数。\n3.  **现有动作不匹配**：现有的 `act_vehicle_price` 动作是直接调整整车价格，其逻辑（通过参数手动输入变化比例）与您描述的“通过函数计算”的需求不符。\n4.  **缺少触发机制**：没有定义当碳酸锂价格属性更新时，如何自动触发计算。\n\n为了满足您的需求，我们需要对本体进行以下修改和补充：\n\n### 1. 新增 `function_type` 对象类型\n首先，需要创建一个新的对象类型来承载业务函数或计算模型。\n\n```json\n{\n  \"id\": \"function_type\",\n  \"name\": \"函数类型\",\n  \"description\": \"用于定义和存储业务计算函数或分析模型\",\n  \"icon\": \"Function\",\n  \"backingDataset\": \"function_type\",\n  \"industryId\": null,\n  \"createdAt\": \"2026-04-11T10:30:00\", // 请使用当前时间\n  \"updatedAt\": \"2026-04-11T10:30:00\",\n  \"status\": \"active\",\n  \"properties\": [\n    {\n      \"id\": \"p_function_id\",\n      \"objectTypeId\": \"function_type\",\n      \"name\": \"函数唯一标识符\",\n      \"type\": \"string\",\n      \"description\": null,\n      \"isPrimaryKey\": 1,\n      \"baseColumn\": \"function_id\",\n      \"typeClasses\": null,\n      \"sortOrder\": 0\n    },\n    {\n      \"id\": \"p_function_name\",\n      \"objectTypeId\": \"function_type\",\n      \"name\": \"函数名称\",\n      \"type\": \"string\",\n      \"description\": null,\n      \"isPrimaryKey\": 0,\n      \"baseColumn\": \"function_name\",\n      \"typeClasses\": null,\n      \"sortOrder\": 1\n    },\n    {\n      \"id\": \"p_description\",\n      \"objectTypeId\": \"function_type\",\n      \"name\": \"函数描述\",\n      \"type\": \"string\",\n      \"description\": \"描述函数的用途、输入、输出和计算逻辑\",\n      \"is, ontology=null, streaming=false}]',NULL,'2026-04-12 21:08:49','2026-04-12 21:09:05'),('conv_58161fe8','这个本体包括哪些object','[{role=system, text=欢迎使用 AI Studio！我是你的本体建模助手。\n\n你可以：\n• 描述你的业务领域，我来生成完整的数据本体\n• 要求我添加、修改或删除实体和关系\n• 让我为已有本体添加语义层信息\n• 提问关于本体设计的最佳实践\n\n每次对话我都会在已有本体基础上迭代改进。}, {role=user, text=这个本体包括哪些object}, {role=assistant, text=根据您提供的本体 JSON 数据，当前系统中已定义了以下 **6个 Object Type（对象类型）**：\n\n1.  **`new_energy_vehicle`** - 新能源整车\n    *   **描述**: 新能源整车\n    *   **主键属性**: `vehicle_id` (车辆唯一标识符)\n    *   **关键属性**: 品牌、车型、价格、电池容量、续航里程等。\n\n2.  **`power_battery`** - 电池\n    *   **描述**: 电池\n    *   **主键属性**: `unique_id`\n    *   **关键属性**: 型号、制造商、容量、电压、化学类型、价格等。\n\n3.  **`battery_cell`** - 电芯\n    *   **描述**: 电芯\n    *   **主键属性**: `unique_id`\n    *   **关键属性**: 型号、生产厂家、价格等。\n\n4.  **`cathode_material`** - 正极材料\n    *   **描述**: 正极材料\n    *   **主键属性**: `material_id`\n    *   **关键属性**: 材料名称、价格等。\n\n5.  **`battery_electrolyte`** - 电池电解液\n    *   **描述**: 电池电解液\n    *   **主键属性**: `unique_id`\n    *   **关键属性**: 名称、类型、价格等。\n\n6.  **`lithium_carbonate`** - 碳酸锂\n    *   **描述**: 碳酸锂\n    *   **主键属性**: `unique_id`\n    *   **关键属性**: 品级、生产厂家、价格等。\n\n**关系总结**:\n从 `linkTypes` 部分可以看出，这些对象通过一个清晰的供应链关系连接起来：\n`碳酸锂` -> `正极材料` & `电解液` -> `电芯` -> `电池` -> `新能源整车`。\n\n这是一个非常典型的从原材料到最终产品的垂直行业本体模型。\n\n**接下来，您希望如何修改或完善这个本体呢？** 例如：\n*   是否需要为现有对象类型**添加新的属性**（如成本、供应商、技术参数）？\n*   是否需要**创建新的对象类型**来扩展模型（如`负极材料`、`隔膜`、`电池管理系统BMS`、`充电桩`、`车主`等）？\n*   是否需要**调整现有的关系**（`linkTypes`）的基数或描述？\n*   是否需要为业务流程**设计新的动作类型**（`Action Types`）？, ontology=null, streaming=false}]',NULL,'2026-04-10 23:01:31','2026-04-10 23:01:48'),('conv_d961d618','请帮我生成一个医院管理系统的完整本体，包括医生、患者、科室、…','[{role=system, text=欢迎使用 AI Studio！我是你的本体建模助手。\n\n你可以：\n• 描述你的业务领域，我来生成完整的数据本体\n• 要求我添加、修改或删除实体和关系\n• 让我为已有本体添加语义层信息\n• 提问关于本体设计的最佳实践\n\n每次对话我都会在已有本体基础上迭代改进。}, {role=user, text=请帮我生成一个医院管理系统的完整本体，包括医生、患者、科室、病房、处方、检查报告等核心实体}, {role=assistant, text=我将为您设计一个完整的医院管理系统本体。基于您提到的核心实体（医生、患者、科室、病房、处方、检查报告），我将创建相应的对象类型、属性、关系类型和动作类型。\n\n以下是完整的医院管理系统本体设计：\n\n```json\n{\n  \"objectTypes\": [\n    {\n      \"id\": \"patient\",\n      \"name\": \"患者\",\n      \"description\": \"医院的患者信息\",\n      \"icon\": \"User\",\n      \"backingDataset\": \"patient_dataset\",\n      \"industryId\": null,\n      \"createdAt\": \"2026-04-11T10:30:00\",\n      \"updatedAt\": \"2026-04-11T10:30:00\",\n      \"status\": \"active\",\n      \"properties\": [\n        {\n          \"id\": \"p_patient_id\",\n          \"objectTypeId\": \"patient\",\n          \"name\": \"患者ID\",\n          \"type\": \"string\",\n          \"description\": \"患者的唯一标识符（病历号）\",\n          \"isPrimaryKey\": 1,\n          \"baseColumn\": \"patient_id\",\n          \"typeClasses\": null,\n          \"sortOrder\": 0\n        },\n        {\n          \"id\": \", ontology=null, streaming=false}]',NULL,'2026-04-12 14:18:22','2026-04-12 14:18:31'),('conv_f41919be','我想要新增一个 测试 本体类型','[{role=system, text=欢迎使用 AI Studio！我是你的本体建模助手。\n\n你可以：\n• 描述你的业务领域，我来生成完整的数据本体\n• 要求我添加、修改或删除实体和关系\n• 让我为已有本体添加语义层信息\n• 提问关于本体设计的最佳实践\n\n每次对话我都会在已有本体基础上迭代改进。}, {role=user, text=我想要新增一个 测试 本体类型}, {role=assistant, text=好的，收到您的需求。您想要新增一个名为“测试”的本体类型。\n\n首先，我需要澄清一下，在 Foundry Ontology 的语境中，“测试”是一个比较宽泛的概念。为了确保我们创建的对象类型（Object Type）有意义、可维护，并且能真正融入您现有的业务图谱，我们需要明确几个关键点：\n\n1.  **业务含义**：这个“测试”具体指什么？例如：\n    *   **产品测试报告**：对电池、电芯等产品的性能、安全测试结果。\n    *   **原材料质检**：对碳酸锂、电解液等原材料的质量检验。\n    *   **生产流程测试**：电芯或电池组装过程中的某个环节测试。\n    *   **研发测试**：新型正极材料或电解液的研发阶段测试。\n\n2.  **数据来源**：这个对象类型将由哪个数据集支持？（`backing_dataset` 字段）。这是本体设计的核心，必须有一个真实的数据集作为基础。\n\n3.  **与现有图谱的关系**：这个“测试”对象应该与哪些现有对象关联？例如：\n    *   一份 `测试报告` 可能针对一个具体的 `电池` 或 `电芯`。\n    *   一次 `质检` 对应一批 `碳酸锂` 原材料。\n\n为了给您提供一个具体、可用的方案，我将基于最常见的假设为您设计：**这是一个针对“电池”或“电芯”的“性能与安全测试报告”**。\n\n如果您有更具体的业务场景，请随时告诉我，我们可以基于此进行调整。\n\n---\n\n### **方案设计：新增 `test_report` (测试报告) 对象类型**\n\n**设计思路**：\n*   **ID**: `test_report` (遵循现有命名风格，使用英文小写和下划线)\n*   **名称**: `测试报告`\n*   **描述**: 记录对电池、电芯等产品的性能与安全测试结果。\n*   **关联**: 主要与 `power_battery` (电池) 和 `battery_cell` (电芯) 关联，一份报告测试一个具体对象。\n*   **属性**: 包含测试标准、结果、日期、状态等关键信息。\n\n#### **1. 新增 Object Type (对象类型)**\n\n```json\n{\n  \"id\": \"test_report\",\n  \"name\": \"测试报告\",\n  \"description\": \"记录对电池、电芯等产品的性能与安全测试结果与报告。\",\n  \"icon\": \"Document\", // 使用文档图标，与报告性质相符\n  \"backing_dataset\": \"test_report_dataset\", // 【重要】请替换为您的实际数据集名称\n  \"industryId\": null,\n  \"createdAt\": \"2026-04-11T10:30:00\", // 示例时间，系统会自动生成\n  \"updatedAt\": \"2026-04-11T10:30:00\",\n  \"status\": \"active\",\n  \"properties\": [\n    {\n      \"id\": \"p_report_id_test_report\",\n      \"objectTypeId\": \"test_report\",\n      \"name\": \"测试报告编号\",\n      \"type\": \"string\",\n      \"description\": \"测试报告的唯一编号\",\n      \"isPrimaryKey\": 1, // 作为主键\n      \"baseColumn\": \"report_id\", // 假设数据集中有此列\n      \"typeClasses\": null,\n      \"sortOrder\": 0\n    },\n    {\n      \"id\": \"p_test_item_test_report\",\n      \"objectTypeId\": \"test_report\",\n      \"name\": \"测试项目\",\n      \"type\": \"string\",\n      \"description\": \"例如：过充测试、短路测试、循环寿命测试、能量密度测试\",\n      \"isPrimaryKey\": 0,\n      \"baseColumn\": \"test_item\",\n      \"typeClasses\": null,\n      \"sortOrder\": 1\n    },\n    {\n      \"id\": \"p_test_standard_test_report\",\n      \"objectTypeId\": \"test_report\",\n      \"name\": \"测试标准\",\n      \"type\": \"string\",\n      \"description\": \"依据的国标、行标或企标，如GB/T 31484-2015\",\n      \"isPrimaryKey\": 0,\n      \"baseColumn\": \"test_standard\",\n      \"typeClasses\": null,\n      \"sortOrder\": 2\n    },\n    {\n      \"id\": \"p_test_result_test_report\",\n      \"objectTypeId\": \"test_report\",\n      \"name\": \"测试结果\",\n      \"type\": \"string\",\n      \"description\": \"通过/不通过，或具体的性能数值\",\n      \"isPrimaryKey\": 0,\n      \"baseColumn\": \"test_result\",\n      \"typeClasses\": null,\n      \"sortOrder\": 3\n    },\n    {\n      \"id\": \"p_test_date_test_report\",\n      \"objectTypeId\": \"test_report\",\n      \"name\": \"测试日期\",\n      \"type\": \"date\",\n      \"description\": null,\n      \"isPrimaryKey\": 0,\n      \"baseColumn\": \"test_date\",\n      \"typeClasses\": null,\n      \"sortOrder\": 4\n    },\n    {\n      \"id\": \"p_test_in, ontology=null, streaming=false}]',NULL,'2026-04-11 10:27:43','2026-04-11 10:28:15');
/*!40000 ALTER TABLE `ai_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `battery_cell`
--

DROP TABLE IF EXISTS `battery_cell`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `battery_cell` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '电芯唯一标识符',
  `model` varchar(200) DEFAULT NULL COMMENT '电芯型号',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（元/kWh）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `unique_id` (`unique_id`),
  KEY `idx_unique_id` (`unique_id`),
  KEY `idx_manufacturer` (`manufacturer`),
  KEY `idx_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='电池电芯信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `battery_cell`
--

LOCK TABLES `battery_cell` WRITE;
/*!40000 ALTER TABLE `battery_cell` DISABLE KEYS */;
INSERT INTO `battery_cell` VALUES (1,'BC-ATL-001-2024','ATL-2714895-120Ah','宁德时代',0.85,'2024-03-01','2026-04-08 12:40:11','2026-04-08 12:40:11'),(2,'BC-ATL-002-2024','ATL-4680-25Ah','宁德时代',0.92,'2024-03-01','2026-04-08 12:40:11','2026-04-08 12:40:11'),(3,'BC-BYD-001-2024','BYD-刀片-135Ah','比亚迪',0.78,'2024-02-15','2026-04-08 12:40:11','2026-04-08 12:40:11'),(9,'BC-CALB-001-2024','中创新航-方壳-150Ah','中创新航',0.75,'2024-03-12','2026-04-08 12:40:11','2026-04-08 12:40:11'),(17,'BC-CODEX-TEST-001',NULL,NULL,0.99,NULL,'2026-04-15 06:10:21','2026-04-15 06:10:21'),(18,'BC-CODEX-TEST-002',NULL,NULL,1.23,NULL,'2026-04-15 06:10:30','2026-04-15 06:10:30'),(10,'BC-EVE-001-2024','亿纬-圆柱-4.2Ah','亿纬锂能',0.68,'2024-02-22','2026-04-08 12:40:11','2026-04-08 12:40:11'),(19,'BC-EVE-001-2026',NULL,NULL,0.99,NULL,'2026-04-15 06:11:28','2026-04-15 06:11:28'),(20,'BC-EVE-002-2025',NULL,NULL,1.02,NULL,'2026-04-15 06:37:00','2026-04-15 06:37:00'),(4,'BC-LG-001-2024','LG-21700-5Ah','LG新能源',1.05,'2024-03-10','2026-04-08 12:40:11','2026-04-08 12:40:11'),(5,'BC-LG-002-2024','LG-4680-23Ah','LG新能源',0.98,'2024-01-20','2026-04-08 12:40:11','2026-04-08 12:40:11'),(7,'BC-PANA-001-2024','松下-18650-3.4Ah','松下',1.12,'2024-03-05','2026-04-08 12:40:11','2026-04-08 12:40:11'),(6,'BC-SK-001-2024','SK-软包-60Ah','SK创新',0.88,'2024-02-28','2026-04-08 12:40:11','2026-04-08 12:40:11'),(8,'BC-SVOLT-001-2024','蜂巢-短刀-80Ah','蜂巢能源',0.82,'2024-01-15','2026-04-08 12:40:11','2026-04-08 12:40:11');
/*!40000 ALTER TABLE `battery_cell` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `battery_electrolyte`
--

DROP TABLE IF EXISTS `battery_electrolyte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `battery_electrolyte` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '电解液唯一标识符',
  `name` varchar(200) DEFAULT NULL COMMENT '电解液名称或型号',
  `electrolyte_type` varchar(50) DEFAULT NULL COMMENT '电解液类型（如：液态、固态、凝胶、有机、无机等）',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（万元/吨）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `unique_id` (`unique_id`),
  KEY `idx_unique_id` (`unique_id`),
  KEY `idx_electrolyte_type` (`electrolyte_type`),
  KEY `idx_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='电池电解液信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `battery_electrolyte`
--

LOCK TABLES `battery_electrolyte` WRITE;
/*!40000 ALTER TABLE `battery_electrolyte` DISABLE KEYS */;
INSERT INTO `battery_electrolyte` VALUES (16,'EL-FD-001-2024','FD-701 快充型电解液','液态',5.80,'2024-02-08','2026-04-08 12:25:35','2026-04-08 12:25:35'),(17,'EL-FD-002-2024','FD-702 超快充电解液','液态',6.50,'2024-02-08','2026-04-08 12:25:35','2026-04-08 12:25:35'),(7,'EL-GL-001-2024','GL-201 凝胶电解质','凝胶',6.80,'2024-01-20','2026-04-08 12:25:35','2026-04-08 12:25:35'),(8,'EL-GL-002-2024','GL-202 聚合物凝胶电解质','凝胶',7.50,'2024-01-20','2026-04-08 12:25:35','2026-04-08 12:25:35'),(19,'EL-HT-001-2024','HT-901 高温型电解液','液态',4.80,'2024-03-15','2026-04-08 12:25:35','2026-04-08 12:25:35'),(14,'EL-HV-001-2024','HV-601 高电压电解液','液态',6.20,'2024-03-12','2026-04-08 12:25:35','2026-04-08 12:25:35'),(15,'EL-HV-002-2024','HV-602 4.5V高电压电解液','液态',7.80,'2024-03-12','2026-04-08 12:25:35','2026-04-08 12:25:35'),(12,'EL-IN-001-2024','IN-501 无机电解液','无机',3.80,'2024-01-15','2026-04-08 12:25:35','2026-04-08 12:25:35'),(13,'EL-IN-002-2024','IN-502 离子液体电解质','无机',8.50,'2024-01-15','2026-04-08 12:25:35','2026-04-08 12:25:35'),(1,'EL-LP-001-2024','LP-301 液态电解液','液态',3.50,'2024-03-01','2026-04-08 12:25:35','2026-04-08 12:25:35'),(2,'EL-LP-002-2024','LP-302 高纯液态电解液','液态',4.20,'2024-03-01','2026-04-08 12:25:35','2026-04-08 12:25:35'),(3,'EL-LP-003-2024','LP-303 低温液态电解液','液态',4.80,'2024-02-15','2026-04-08 12:25:35','2026-04-08 12:25:35'),(18,'EL-LT-001-2024','LT-801 低温型电解液','液态',5.50,'2024-03-15','2026-04-08 12:25:35','2026-04-08 12:25:35'),(9,'EL-OR-001-2024','OR-401 有机电解液','有机',5.20,'2024-03-05','2026-04-08 12:25:35','2026-04-08 12:25:35'),(10,'EL-OR-002-2024','OR-402 碳酸酯类电解液','有机',4.80,'2024-03-05','2026-04-08 12:25:35','2026-04-08 12:25:35'),(11,'EL-OR-003-2024','OR-403 醚类电解液','有机',5.50,'2024-02-22','2026-04-08 12:25:35','2026-04-08 12:25:35'),(20,'EL-SI-001-2024','SI-111 硅负极专用电解液','液态',8.20,'2024-02-25','2026-04-08 12:25:35','2026-04-08 12:25:35'),(4,'EL-SS-001-2024','SS-101 固态电解质','固态',12.50,'2024-03-10','2026-04-08 12:25:35','2026-04-08 12:25:35'),(5,'EL-SS-002-2024','SS-102 硫化物固态电解质','固态',15.80,'2024-03-10','2026-04-08 12:25:35','2026-04-08 12:25:35'),(6,'EL-SS-003-2024','SS-103 氧化物固态电解质','固态',14.20,'2024-02-28','2026-04-08 12:25:35','2026-04-08 12:25:35');
/*!40000 ALTER TABLE `battery_electrolyte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cathode_material`
--

DROP TABLE IF EXISTS `cathode_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cathode_material` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `material_id` varchar(100) NOT NULL COMMENT '正极材料的唯一标识符',
  `material_name` varchar(100) DEFAULT NULL COMMENT '正极材料的名称，如NCM811、LFP、LCO等',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（万元/吨）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`material_id`),
  UNIQUE KEY `material_id` (`material_id`),
  KEY `idx_material_id` (`material_id`),
  KEY `idx_material_name` (`material_name`),
  KEY `idx_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='正极材料信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cathode_material`
--

LOCK TABLES `cathode_material` WRITE;
/*!40000 ALTER TABLE `cathode_material` DISABLE KEYS */;
INSERT INTO `cathode_material` VALUES (5,'CM-LCO-2024','LCO',22.50,'2024-01-20','2026-04-08 12:32:09','2026-04-08 12:32:09'),(9,'CM-LFMP-2024','LFMP',5.80,'2024-03-12','2026-04-08 12:32:09','2026-04-08 12:32:09'),(4,'CM-LFP-2024','LFP',4.20,'2024-03-10','2026-04-08 12:32:09','2026-04-08 12:32:09'),(7,'CM-LMO-2024','LMO',8.50,'2024-03-05','2026-04-08 12:32:09','2026-04-08 12:32:09'),(6,'CM-NCA-2024','NCA',19.80,'2024-02-28','2026-04-08 12:32:09','2026-04-08 12:32:09'),(3,'CM-NCM523-2024','NCM523',13.80,'2024-02-15','2026-04-08 12:32:09','2026-04-08 12:32:09'),(2,'CM-NCM622-2024','NCM622',15.20,'2024-03-01','2026-04-08 12:32:09','2026-04-08 12:32:09'),(8,'CM-NCM712-2024','NCM712',16.80,'2024-01-15','2026-04-08 12:32:09','2026-04-08 12:32:09'),(1,'CM-NCM811-2024','NCM811',18.50,'2024-03-01','2026-04-08 12:32:09','2026-04-08 12:32:09'),(10,'CM-NCM901-2024','NCM901',21.20,'2024-02-22','2026-04-08 12:32:09','2026-04-08 12:32:09');
/*!40000 ALTER TABLE `cathode_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_entity`
--

DROP TABLE IF EXISTS `company_entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_entity` (
  `company_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stock_code` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `market` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `industry` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_entity`
--

LOCK TABLES `company_entity` WRITE;
/*!40000 ALTER TABLE `company_entity` DISABLE KEYS */;
INSERT INTO `company_entity` VALUES ('COMP_BYD','比亚迪','002594','SZ','新能源汽车','2026-04-16 10:11:46','2026-04-16 10:11:46'),('COMP_CATL','宁德时代','300750','SZ','动力电池','2026-04-15 22:56:35','2026-04-15 22:56:35'),('COMP_CET','中恒电气','002364','SZ','储能设备','2026-04-15 22:56:35','2026-04-15 22:56:35');
/*!40000 ALTER TABLE `company_entity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `function_params`
--

DROP TABLE IF EXISTS `function_params`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `function_params` (
  `id` varchar(64) NOT NULL,
  `function_id` varchar(64) NOT NULL COMMENT '关联函数ID',
  `param_direction` varchar(8) NOT NULL COMMENT '参数方向：INPUT/OUTPUT',
  `param_name` varchar(64) NOT NULL COMMENT '参数名',
  `param_code` varchar(64) NOT NULL COMMENT '参数编码',
  `param_type` varchar(32) DEFAULT NULL COMMENT '参数类型：string/number/boolean/object/array',
  `is_required` tinyint DEFAULT '0' COMMENT '是否必填',
  `default_value` varchar(256) DEFAULT NULL COMMENT '默认值',
  `description` varchar(256) DEFAULT NULL COMMENT '参数描述',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `source_type` varchar(32) DEFAULT NULL COMMENT '参数来源：USER_INPUT/SYSTEM_AUTO/CONTEXT',
  PRIMARY KEY (`id`),
  KEY `idx_function_id` (`function_id`),
  KEY `idx_direction` (`function_id`,`param_direction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='函数参数表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `function_params`
--

LOCK TABLES `function_params` WRITE;
/*!40000 ALTER TABLE `function_params` DISABLE KEYS */;
INSERT INTO `function_params` VALUES ('fp_1775995163404_0','func_1775995163393','INPUT','对象类型ID','objectTypeId','string',1,NULL,'对象类型ID',0,'USER_INPUT'),('fp_1775995163406_1','func_1775995163393','INPUT','实例ID（主键值）','instanceId','string',1,NULL,'实例ID（主键值）',1,'USER_INPUT'),('fp_1775995163406_2','func_1775995163393','INPUT','递归深度','depth','string',0,'3','递归深度',2,'USER_INPUT'),('fp_1775995163406_out_0','func_1775995163393','OUTPUT','请求是否成功','success','boolean',0,NULL,'',0,NULL),('fp_pt_in_1','func_calculate_price_transmission','INPUT','实例ID','instanceId','string',1,NULL,'碳酸锂实例ID，如 LC-BATTERY-001-2024',0,'USER_INPUT'),('fp_pt_in_2','func_calculate_price_transmission','INPUT','递归深度','depth','number',0,'3','关系递归深度，默认3，最大5',1,'USER_INPUT'),('fp_pt_in_3','func_calculate_price_transmission','INPUT','最新价格','latestPrice','number',1,NULL,'碳酸锂最新价格（元/吨）',2,'USER_INPUT'),('fp_pt_out_aff_change','func_calculate_price_transmission','OUTPUT','价格变动金额','data.affectedInstances[].priceChangeAmount','number',1,NULL,'价格变动金额',19,NULL),('fp_pt_out_aff_coeff','func_calculate_price_transmission','OUTPUT','传导系数','data.affectedInstances[].transmissionCoefficient','number',1,NULL,'传导系数（随深度衰减）',17,NULL),('fp_pt_out_aff_depth','func_calculate_price_transmission','OUTPUT','关系深度','data.affectedInstances[].relationDepth','number',1,NULL,'距离源实例的层级',15,NULL),('fp_pt_out_aff_id','func_calculate_price_transmission','OUTPUT','实例ID','data.affectedInstances[].id','string',1,NULL,'实例ID',10,NULL),('fp_pt_out_aff_latest','func_calculate_price_transmission','OUTPUT','最新价格','data.affectedInstances[].latestPrice','number',1,NULL,'计算后的最新价格',18,NULL),('fp_pt_out_aff_name','func_calculate_price_transmission','OUTPUT','实例名称','data.affectedInstances[].name','string',1,NULL,'实例名称',13,NULL),('fp_pt_out_aff_otid','func_calculate_price_transmission','OUTPUT','对象类型ID','data.affectedInstances[].objectTypeId','string',1,NULL,'对象类型ID',11,NULL),('fp_pt_out_aff_otname','func_calculate_price_transmission','OUTPUT','对象类型名称','data.affectedInstances[].objectTypeName','string',1,NULL,'对象类型名称',12,NULL),('fp_pt_out_aff_path','func_calculate_price_transmission','OUTPUT','关系路径','data.affectedInstances[].relationPath','string',1,NULL,'关系路径',14,NULL),('fp_pt_out_aff_prev','func_calculate_price_transmission','OUTPUT','之前价格','data.affectedInstances[].previousPrice','number',1,NULL,'之前价格',16,NULL),('fp_pt_out_affected','func_calculate_price_transmission','OUTPUT','受影响实例数组','data.affectedInstances','array',1,NULL,'受影响的关联实例列表',9,NULL),('fp_pt_out_coeff','func_calculate_price_transmission','OUTPUT','传导系数','data.transmissionCoefficient','number',1,NULL,'传导系数（价格变化百分比 × 0.9）',8,NULL),('fp_pt_out_data','func_calculate_price_transmission','OUTPUT','数据对象','data','object',1,NULL,'包含计算结果的完整数据对象',1,NULL),('fp_pt_out_source','func_calculate_price_transmission','OUTPUT','源实例','data.sourceInstance','object',1,NULL,'源实例（碳酸锂）信息',2,NULL),('fp_pt_out_source_id','func_calculate_price_transmission','OUTPUT','源实例ID','data.sourceInstance.id','string',1,NULL,'实例ID',3,NULL),('fp_pt_out_source_latest','func_calculate_price_transmission','OUTPUT','最新价格','data.sourceInstance.latestPrice','number',1,NULL,'最新价格（入参传入）',6,NULL),('fp_pt_out_source_name','func_calculate_price_transmission','OUTPUT','源实例名称','data.sourceInstance.name','string',1,NULL,'实例名称',4,NULL),('fp_pt_out_source_pct','func_calculate_price_transmission','OUTPUT','价格变化百分比','data.sourceInstance.priceChangePercent','number',1,NULL,'价格变化百分比',7,NULL),('fp_pt_out_source_prev','func_calculate_price_transmission','OUTPUT','之前价格','data.sourceInstance.previousPrice','number',1,NULL,'之前价格',5,NULL),('fp_pt_out_success','func_calculate_price_transmission','OUTPUT','是否成功','success','boolean',1,NULL,'请求是否成功',0,NULL),('fp_pt_out_sum_count','func_calculate_price_transmission','OUTPUT','受影响实例总数','data.summary.totalAffectedInstances','number',1,NULL,'受影响实例总数',21,NULL),('fp_pt_out_sum_total','func_calculate_price_transmission','OUTPUT','总价格变动金额','data.summary.totalPriceChangeAmount','number',1,NULL,'总价格变动金额',22,NULL),('fp_pt_out_summary','func_calculate_price_transmission','OUTPUT','汇总信息','data.summary','object',1,NULL,'汇总统计信息',20,NULL),('fp_ptot_in_1','func_calculate_price_transmission_object_type','INPUT','对象类型ID','objectTypeId','string',1,'lithium_carbonate','源对象类型ID，当前演示为 lithium_carbonate',0,'USER_INPUT'),('fp_ptot_in_2','func_calculate_price_transmission_object_type','INPUT','价格变化百分比','priceChangePercent','number',1,NULL,'价格变动幅度，正数表示上涨，负数表示下跌',1,'USER_INPUT'),('fp_ptot_in_3','func_calculate_price_transmission_object_type','INPUT','传导深度','depth','number',0,'4','对象类型层级的最大传导深度，默认 4',2,'USER_INPUT'),('fp_ptot_out_1','func_calculate_price_transmission_object_type','OUTPUT','是否成功','success','boolean',1,NULL,'函数是否执行成功',0,NULL),('fp_rel_out_center','func_1775995163393','OUTPUT','中心节点','centerNode','object',1,NULL,'中心节点（当前查询的实例）',1,NULL),('fp_rel_out_center_data','func_1775995163393','OUTPUT','中心节点数据','centerNode.data','object',1,NULL,'完整实例数据（所有属性值）',7,NULL),('fp_rel_out_center_depth','func_1775995163393','OUTPUT','中心节点层级','centerNode.depth','number',1,NULL,'层级，中心节点为0',8,NULL),('fp_rel_out_center_id','func_1775995163393','OUTPUT','中心节点ID','centerNode.id','string',1,NULL,'节点唯一标识：{objectTypeId}:{instanceId}',2,NULL),('fp_rel_out_center_instid','func_1775995163393','OUTPUT','中心节点实例ID','centerNode.instanceId','string',1,NULL,'实例ID',5,NULL),('fp_rel_out_center_label','func_1775995163393','OUTPUT','中心节点标签','centerNode.label','string',1,NULL,'显示标签（通常是主键值）',6,NULL),('fp_rel_out_center_otid','func_1775995163393','OUTPUT','中心节点对象类型ID','centerNode.objectTypeId','string',1,NULL,'对象类型ID',3,NULL),('fp_rel_out_center_otname','func_1775995163393','OUTPUT','中心节点对象类型名称','centerNode.objectTypeName','string',1,NULL,'对象类型名称，如电芯',4,NULL),('fp_rel_out_data','func_1775995163393','OUTPUT','数据对象','data','object',1,NULL,'包含centerNode、nodes、links的完整数据对象',0,NULL),('fp_rel_out_links','func_1775995163393','OUTPUT','链接数组','links','array',1,NULL,'节点间的关系链接',10,NULL),('fp_rel_out_links_card','func_1775995163393','OUTPUT','基数','links[].cardinality','string',1,NULL,'基数：1:1/1:N/N:M/N:1',17,NULL),('fp_rel_out_links_dir','func_1775995163393','OUTPUT','方向','links[].direction','string',1,NULL,'方向：downstream(下游)/upstream(上游)',18,NULL),('fp_rel_out_links_id','func_1775995163393','OUTPUT','链接ID','links[].id','string',1,NULL,'链接唯一标识',12,NULL),('fp_rel_out_links_item','func_1775995163393','OUTPUT','链接项','links[]','object',1,NULL,'单个链接对象',11,NULL),('fp_rel_out_links_ltid','func_1775995163393','OUTPUT','链接类型ID','links[].linkTypeId','string',1,NULL,'链接类型ID',15,NULL),('fp_rel_out_links_ltname','func_1775995163393','OUTPUT','链接类型名称','links[].linkTypeName','string',1,NULL,'链接类型名称，如供应给',16,NULL),('fp_rel_out_links_source','func_1775995163393','OUTPUT','源节点ID','links[].source','string',1,NULL,'源节点ID',13,NULL),('fp_rel_out_links_target','func_1775995163393','OUTPUT','目标节点ID','links[].target','string',1,NULL,'目标节点ID',14,NULL),('fp_rel_out_nodes','func_1775995163393','OUTPUT','节点数组','nodes','array',1,NULL,'所有关联节点（包含中心节点）',9,NULL),('fp_rel_out_totallinks','func_1775995163393','OUTPUT','链接总数','totalLinks','number',1,NULL,'链接总数',20,NULL),('fp_rel_out_totalnodes','func_1775995163393','OUTPUT','节点总数','totalNodes','number',1,NULL,'节点总数',19,NULL);
/*!40000 ALTER TABLE `function_params` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `function_type_backup`
--

DROP TABLE IF EXISTS `function_type_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `function_type_backup` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT '函数名',
  `rest_route` varchar(500) NOT NULL COMMENT 'Rest路由',
  `input_params` json DEFAULT NULL COMMENT '入参配置（JSON格式）',
  `output_params` json DEFAULT NULL COMMENT '出参配置（JSON格式）',
  `description` text COMMENT '函数描述',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='函数类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `function_type_backup`
--

LOCK TABLES `function_type_backup` WRITE;
/*!40000 ALTER TABLE `function_type_backup` DISABLE KEYS */;
/*!40000 ALTER TABLE `function_type_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `function_types`
--

DROP TABLE IF EXISTS `function_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `function_types` (
  `id` varchar(64) NOT NULL COMMENT '函数ID',
  `name` varchar(128) NOT NULL COMMENT '函数名称',
  `code` varchar(64) NOT NULL COMMENT '函数编码（用于调用）',
  `description` varchar(512) DEFAULT NULL COMMENT '函数描述',
  `category` varchar(32) DEFAULT NULL COMMENT '函数类别：QUERY/CREATE/UPDATE/DELETE/ANALYZE',
  `interface_type` varchar(16) DEFAULT 'RESTFUL' COMMENT '接口类型：RESTFUL/DUBBO/INTERNAL',
  `request_method` varchar(8) DEFAULT NULL COMMENT '请求方式：GET/POST/PUT/DELETE',
  `interface_url` varchar(256) DEFAULT NULL COMMENT '接口路径模板',
  `implementation_type` varchar(32) DEFAULT 'JAVA' COMMENT '实现类型：JAVA/BFF/SQL',
  `status` varchar(16) DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/DISABLED',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_category` (`category`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='函数类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `function_types`
--

LOCK TABLES `function_types` WRITE;
/*!40000 ALTER TABLE `function_types` DISABLE KEYS */;
INSERT INTO `function_types` VALUES ('func_1775995163393','根据对象浏览器的关系图谱查询','query_instance_relations','查询指定实例的关系图谱数据（上下游关联实例）','QUERY','RESTFUL','GET','/api/instances/{objectTypeId}/{instanceId}/relations','JAVA','ACTIVE','2026-04-12 19:59:23','2026-04-12 20:12:59'),('func_calculate_price_transmission','碳酸锂（实例层）价格传导分析','calculate_price_transmission','基于具体碳酸锂实例及其最新价格，沿实例关系图谱计算下游实例的价格传导结果。','ANALYZE','RESTFUL','POST','/api/analysis/price-transmission','JAVA','ACTIVE','2026-04-12 20:33:45','2026-04-15 22:24:43'),('func_calculate_price_transmission_object_type','碳酸锂（对象类型层）价格传导分析','calculate_price_transmission_object_type','基于碳酸锂对象类型的价格变动幅度，计算对象类型层面的传导路径、传导系数与价格影响。','ANALYZE','RESTFUL','POST','/api/analysis/price-transmission/object-type','JAVA','ACTIVE','2026-04-15 22:24:43','2026-04-15 22:24:43');
/*!40000 ALTER TABLE `function_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `industry_categories`
--

DROP TABLE IF EXISTS `industry_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `industry_categories` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` int NOT NULL DEFAULT '1',
  `parent_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `industry_categories`
--

LOCK TABLES `industry_categories` WRITE;
/*!40000 ALTER TABLE `industry_categories` DISABLE KEYS */;
INSERT INTO `industry_categories` VALUES ('sw_110000','110000','农林牧渔',1,NULL,1,'','2026-04-03 12:19:38'),('sw_110100','110100','种植业',2,'sw_110000',1,'','2026-04-03 12:19:38'),('sw_110200','110200','养殖业',2,'sw_110000',2,'','2026-04-03 12:19:38'),('sw_110300','110300','林业',2,'sw_110000',3,'','2026-04-03 12:19:38'),('sw_110400','110400','饲料',2,'sw_110000',4,'','2026-04-03 12:19:38'),('sw_110500','110500','渔业',2,'sw_110000',5,'','2026-04-03 12:19:38'),('sw_110600','110600','农业综合',2,'sw_110000',6,'','2026-04-03 12:19:38'),('sw_220000','220000','基础化工',1,NULL,13,'','2026-04-03 12:19:38'),('sw_220100','220100','化学原料',2,'sw_220000',1,'','2026-04-03 12:19:38'),('sw_220200','220200','化学制品',2,'sw_220000',2,'','2026-04-03 12:19:38'),('sw_220300','220300','化学纤维',2,'sw_220000',3,'','2026-04-03 12:19:38'),('sw_220400','220400','塑料',2,'sw_220000',4,'','2026-04-03 12:19:38'),('sw_220500','220500','橡胶',2,'sw_220000',5,'','2026-04-03 12:19:38'),('sw_230000','230000','钢铁',1,NULL,15,'','2026-04-03 12:19:38'),('sw_240000','240000','有色金属',1,NULL,12,'','2026-04-03 12:19:38'),('sw_240100','240100','工业金属',2,'sw_240000',1,'','2026-04-03 12:19:38'),('sw_240200','240200','贵金属',2,'sw_240000',2,'','2026-04-03 12:19:38'),('sw_240300','240300','小金属',2,'sw_240000',3,'','2026-04-03 12:19:38'),('sw_240400','240400','能源金属',2,'sw_240000',4,'','2026-04-03 12:19:38'),('sw_240401','240401','锂',3,'sw_240400',1,'','2026-04-03 12:19:38'),('sw_240402','240402','钴',3,'sw_240400',2,'','2026-04-03 12:19:38'),('sw_240403','240403','镍',3,'sw_240400',3,'','2026-04-03 12:19:38'),('sw_270000','270000','电子',1,NULL,26,'','2026-04-03 12:19:38'),('sw_270100','270100','半导体',2,'sw_270000',1,'','2026-04-03 12:19:38'),('sw_270101','270101','数字芯片设计',3,'sw_270100',1,'','2026-04-03 12:19:38'),('sw_270102','270102','模拟芯片设计',3,'sw_270100',2,'','2026-04-03 12:19:38'),('sw_270103','270103','集成电路制造',3,'sw_270100',3,'','2026-04-03 12:19:38'),('sw_270104','270104','集成电路封测',3,'sw_270100',4,'','2026-04-03 12:19:38'),('sw_270105','270105','半导体材料',3,'sw_270100',5,'','2026-04-03 12:19:38'),('sw_270106','270106','半导体设备',3,'sw_270100',6,'','2026-04-03 12:19:38'),('sw_270107','270107','分立器件',3,'sw_270100',7,'','2026-04-03 12:19:38'),('sw_270200','270200','元件',2,'sw_270000',2,'','2026-04-03 12:19:38'),('sw_270201','270201','印制电路板',3,'sw_270200',1,'','2026-04-03 12:19:38'),('sw_270202','270202','被动元件',3,'sw_270200',2,'','2026-04-03 12:19:38'),('sw_270300','270300','光学光电子',2,'sw_270000',3,'','2026-04-03 12:19:38'),('sw_270301','270301','面板',3,'sw_270300',1,'','2026-04-03 12:19:38'),('sw_270302','270302','LED',3,'sw_270300',2,'','2026-04-03 12:19:38'),('sw_270303','270303','光学元件',3,'sw_270300',3,'','2026-04-03 12:19:38'),('sw_270400','270400','消费电子',2,'sw_270000',4,'','2026-04-03 12:19:38'),('sw_270401','270401','品牌消费电子',3,'sw_270400',1,'','2026-04-03 12:19:38'),('sw_270402','270402','消费电子零部件及组装',3,'sw_270400',2,'','2026-04-03 12:19:38'),('sw_270500','270500','电子化学品',2,'sw_270000',5,'','2026-04-03 12:19:38'),('sw_280000','280000','汽车',1,NULL,22,'','2026-04-03 12:19:38'),('sw_280100','280100','乘用车',2,'sw_280000',1,'','2026-04-03 12:19:38'),('sw_280101','280101','电动乘用车',3,'sw_280100',1,'','2026-04-03 12:19:38'),('sw_280102','280102','综合乘用车',3,'sw_280100',2,'','2026-04-03 12:19:38'),('sw_280200','280200','商用车',2,'sw_280000',2,'','2026-04-03 12:19:38'),('sw_280300','280300','汽车零部件',2,'sw_280000',3,'','2026-04-03 12:19:38'),('sw_280301','280301','底盘与发动机系统',3,'sw_280300',1,'','2026-04-03 12:19:38'),('sw_280302','280302','车身附件及饰件',3,'sw_280300',2,'','2026-04-03 12:19:38'),('sw_280303','280303','汽车电子电气系统',3,'sw_280300',3,'','2026-04-03 12:19:38'),('sw_280304','280304','轮胎轮毂',3,'sw_280300',4,'','2026-04-03 12:19:38'),('sw_280400','280400','汽车服务',2,'sw_280000',4,'','2026-04-03 12:19:38'),('sw_330000','330000','家用电器',1,NULL,4,'','2026-04-03 12:19:38'),('sw_330100','330100','白色家电',2,'sw_330000',1,'','2026-04-03 12:19:38'),('sw_330200','330200','黑色家电',2,'sw_330000',2,'','2026-04-03 12:19:38'),('sw_330300','330300','小家电',2,'sw_330000',3,'','2026-04-03 12:19:38'),('sw_330400','330400','厨卫电器',2,'sw_330000',4,'','2026-04-03 12:19:38'),('sw_330500','330500','照明设备',2,'sw_330000',5,'','2026-04-03 12:19:38'),('sw_340000','340000','食品饮料',1,NULL,2,'','2026-04-03 12:19:38'),('sw_340100','340100','白酒',2,'sw_340000',1,'','2026-04-03 12:19:38'),('sw_340200','340200','啤酒',2,'sw_340000',2,'','2026-04-03 12:19:38'),('sw_340300','340300','其他酒类',2,'sw_340000',3,'','2026-04-03 12:19:38'),('sw_340400','340400','饮料乳品',2,'sw_340000',4,'','2026-04-03 12:19:38'),('sw_340500','340500','食品加工',2,'sw_340000',5,'','2026-04-03 12:19:38'),('sw_340600','340600','休闲食品',2,'sw_340000',6,'','2026-04-03 12:19:38'),('sw_340700','340700','调味发酵品',2,'sw_340000',7,'','2026-04-03 12:19:38'),('sw_350000','350000','纺织服饰',1,NULL,5,'','2026-04-03 12:19:38'),('sw_360000','360000','轻工制造',1,NULL,6,'','2026-04-03 12:19:38'),('sw_370000','370000','医药生物',1,NULL,3,'','2026-04-03 12:19:38'),('sw_370100','370100','化学制药',2,'sw_370000',1,'','2026-04-03 12:19:38'),('sw_370101','370101','化学原料药',3,'sw_370100',1,'','2026-04-03 12:19:38'),('sw_370102','370102','化学制剂',3,'sw_370100',2,'','2026-04-03 12:19:38'),('sw_370200','370200','中药',2,'sw_370000',2,'','2026-04-03 12:19:38'),('sw_370300','370300','生物制品',2,'sw_370000',3,'','2026-04-03 12:19:38'),('sw_370301','370301','血液制品',3,'sw_370300',1,'','2026-04-03 12:19:38'),('sw_370302','370302','疫苗',3,'sw_370300',2,'','2026-04-03 12:19:38'),('sw_370303','370303','其他生物制品',3,'sw_370300',3,'','2026-04-03 12:19:38'),('sw_370400','370400','医疗器械',2,'sw_370000',4,'','2026-04-03 12:19:38'),('sw_370401','370401','医疗设备',3,'sw_370400',1,'','2026-04-03 12:19:38'),('sw_370402','370402','医疗耗材',3,'sw_370400',2,'','2026-04-03 12:19:38'),('sw_370403','370403','体外诊断',3,'sw_370400',3,'','2026-04-03 12:19:38'),('sw_370500','370500','医药商业',2,'sw_370000',5,'','2026-04-03 12:19:38'),('sw_370600','370600','医疗服务',2,'sw_370000',6,'','2026-04-03 12:19:38'),('sw_370601','370601','诊断服务',3,'sw_370600',1,'','2026-04-03 12:19:38'),('sw_370602','370602','医疗研发外包',3,'sw_370600',2,'','2026-04-03 12:19:38'),('sw_410000','410000','公用事业',1,NULL,19,'','2026-04-03 12:19:38'),('sw_420000','420000','交通运输',1,NULL,25,'','2026-04-03 12:19:38'),('sw_420100','420100','港口',2,'sw_420000',1,'','2026-04-03 12:19:38'),('sw_420200','420200','航运',2,'sw_420000',2,'','2026-04-03 12:19:38'),('sw_420300','420300','公路铁路',2,'sw_420000',3,'','2026-04-03 12:19:38'),('sw_420400','420400','航空机场',2,'sw_420000',4,'','2026-04-03 12:19:38'),('sw_420500','420500','物流',2,'sw_420000',5,'','2026-04-03 12:19:38'),('sw_430000','430000','房地产',1,NULL,21,'','2026-04-03 12:19:38'),('sw_430100','430100','房地产开发',2,'sw_430000',1,'','2026-04-03 12:19:38'),('sw_430200','430200','房地产服务',2,'sw_430000',2,'','2026-04-03 12:19:38'),('sw_450000','450000','商贸零售',1,NULL,7,'','2026-04-03 12:19:38'),('sw_450100','450100','一般零售',2,'sw_450000',1,'','2026-04-03 12:19:38'),('sw_450200','450200','专业连锁',2,'sw_450000',2,'','2026-04-03 12:19:38'),('sw_450300','450300','互联网电商',2,'sw_450000',3,'','2026-04-03 12:19:38'),('sw_450301','450301','综合电商',3,'sw_450300',1,'','2026-04-03 12:19:38'),('sw_450302','450302','跨境电商',3,'sw_450300',2,'','2026-04-03 12:19:38'),('sw_460000','460000','社会服务',1,NULL,9,'','2026-04-03 12:19:38'),('sw_480000','480000','银行',1,NULL,23,'','2026-04-03 12:19:38'),('sw_480100','480100','国有大型银行',2,'sw_480000',1,'','2026-04-03 12:19:38'),('sw_480200','480200','股份制银行',2,'sw_480000',2,'','2026-04-03 12:19:38'),('sw_480300','480300','城商行',2,'sw_480000',3,'','2026-04-03 12:19:38'),('sw_480400','480400','农商行',2,'sw_480000',4,'','2026-04-03 12:19:38'),('sw_490000','490000','非银金融',1,NULL,24,'','2026-04-03 12:19:38'),('sw_490100','490100','证券',2,'sw_490000',1,'','2026-04-03 12:19:38'),('sw_490200','490200','保险',2,'sw_490000',2,'','2026-04-03 12:19:38'),('sw_490300','490300','多元金融',2,'sw_490000',3,'','2026-04-03 12:19:38'),('sw_510000','510000','综合',1,NULL,31,'','2026-04-03 12:19:38'),('sw_610000','610000','建筑材料',1,NULL,14,'','2026-04-03 12:19:38'),('sw_620000','620000','建筑装饰',1,NULL,20,'','2026-04-03 12:19:38'),('sw_630000','630000','电力设备',1,NULL,17,'','2026-04-03 12:19:38'),('sw_630100','630100','电池',2,'sw_630000',1,'','2026-04-03 12:19:38'),('sw_630101','630101','锂电池',3,'sw_630100',1,'','2026-04-03 12:19:38'),('sw_630102','630102','电池化学品',3,'sw_630100',2,'','2026-04-03 12:19:38'),('sw_630103','630103','锂电专用设备',3,'sw_630100',3,'','2026-04-03 12:19:38'),('sw_630200','630200','光伏设备',2,'sw_630000',2,'','2026-04-03 12:19:38'),('sw_630201','630201','硅料硅片',3,'sw_630200',1,'','2026-04-03 12:19:38'),('sw_630202','630202','光伏电池组件',3,'sw_630200',2,'','2026-04-03 12:19:38'),('sw_630203','630203','逆变器',3,'sw_630200',3,'','2026-04-03 12:19:38'),('sw_630204','630204','光伏辅材',3,'sw_630200',4,'','2026-04-03 12:19:38'),('sw_630300','630300','风电设备',2,'sw_630000',3,'','2026-04-03 12:19:38'),('sw_630301','630301','风电零部件',3,'sw_630300',1,'','2026-04-03 12:19:38'),('sw_630302','630302','风电整机',3,'sw_630300',2,'','2026-04-03 12:19:38'),('sw_630400','630400','电网设备',2,'sw_630000',4,'','2026-04-03 12:19:38'),('sw_630500','630500','电机',2,'sw_630000',5,'','2026-04-03 12:19:38'),('sw_640000','640000','机械设备',1,NULL,16,'','2026-04-03 12:19:38'),('sw_640100','640100','通用设备',2,'sw_640000',1,'','2026-04-03 12:19:38'),('sw_640200','640200','专用设备',2,'sw_640000',2,'','2026-04-03 12:19:38'),('sw_640300','640300','自动化设备',2,'sw_640000',3,'','2026-04-03 12:19:38'),('sw_640301','640301','工业机器人',3,'sw_640300',1,'','2026-04-03 12:19:38'),('sw_640302','640302','激光设备',3,'sw_640300',2,'','2026-04-03 12:19:38'),('sw_640303','640303','3C自动化设备',3,'sw_640300',3,'','2026-04-03 12:19:38'),('sw_650000','650000','计算机',1,NULL,27,'','2026-04-03 12:19:38'),('sw_650100','650100','计算机设备',2,'sw_650000',1,'','2026-04-03 12:19:38'),('sw_650101','650101','计算机整机',3,'sw_650100',1,'','2026-04-03 12:19:38'),('sw_650102','650102','网络设备',3,'sw_650100',2,'','2026-04-03 12:19:38'),('sw_650200','650200','IT服务',2,'sw_650000',2,'','2026-04-03 12:19:38'),('sw_650300','650300','软件开发',2,'sw_650000',3,'','2026-04-03 12:19:38'),('sw_650301','650301','行业应用软件',3,'sw_650300',1,'','2026-04-03 12:19:38'),('sw_650302','650302','基础软件',3,'sw_650300',2,'','2026-04-03 12:19:38'),('sw_650303','650303','信息安全',3,'sw_650300',3,'','2026-04-03 12:19:38'),('sw_670000','670000','国防军工',1,NULL,29,'','2026-04-03 12:19:38'),('sw_670100','670100','航空装备',2,'sw_670000',1,'','2026-04-03 12:19:38'),('sw_670200','670200','航天装备',2,'sw_670000',2,'','2026-04-03 12:19:38'),('sw_670300','670300','地面兵装',2,'sw_670000',3,'','2026-04-03 12:19:38'),('sw_670400','670400','船舶制造',2,'sw_670000',4,'','2026-04-03 12:19:38'),('sw_670500','670500','军工电子',2,'sw_670000',5,'','2026-04-03 12:19:38'),('sw_710000','710000','传媒',1,NULL,30,'','2026-04-03 12:19:38'),('sw_710100','710100','游戏',2,'sw_710000',1,'','2026-04-03 12:19:38'),('sw_710200','710200','数字媒体',2,'sw_710000',2,'','2026-04-03 12:19:38'),('sw_710300','710300','广告营销',2,'sw_710000',3,'','2026-04-03 12:19:38'),('sw_710400','710400','影视院线',2,'sw_710000',4,'','2026-04-03 12:19:38'),('sw_710500','710500','出版',2,'sw_710000',5,'','2026-04-03 12:19:38'),('sw_720000','720000','通信',1,NULL,28,'','2026-04-03 12:19:38'),('sw_720100','720100','通信设备',2,'sw_720000',1,'','2026-04-03 12:19:38'),('sw_720101','720101','通信网络设备及器件',3,'sw_720100',1,'','2026-04-03 12:19:38'),('sw_720102','720102','通信终端及配件',3,'sw_720100',2,'','2026-04-03 12:19:38'),('sw_720200','720200','通信服务',2,'sw_720000',2,'','2026-04-03 12:19:38'),('sw_720201','720201','电信运营',3,'sw_720200',1,'','2026-04-03 12:19:38'),('sw_720202','720202','增值服务',3,'sw_720200',2,'','2026-04-03 12:19:38'),('sw_730000','730000','煤炭',1,NULL,11,'','2026-04-03 12:19:38'),('sw_740000','740000','石油石化',1,NULL,10,'','2026-04-03 12:19:38'),('sw_750000','750000','环保',1,NULL,18,'','2026-04-03 12:19:38'),('sw_760000','760000','美容护理',1,NULL,8,'','2026-04-03 12:19:38');
/*!40000 ALTER TABLE `industry_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `link_instance_data`
--

DROP TABLE IF EXISTS `link_instance_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `link_instance_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键ID',
  `link_type_id` varchar(100) NOT NULL COMMENT '链接类型ID',
  `source_instance_id` varchar(100) NOT NULL COMMENT '源对象实例唯一标识',
  `target_instance_id` varchar(100) NOT NULL COMMENT '目标对象实例唯一标识',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_link_type` (`link_type_id`),
  KEY `idx_source_instance` (`source_instance_id`),
  KEY `idx_target_instance` (`target_instance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=243 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='链接实例数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `link_instance_data`
--

LOCK TABLES `link_instance_data` WRITE;
/*!40000 ALTER TABLE `link_instance_data` DISABLE KEYS */;
INSERT INTO `link_instance_data` VALUES (1,'lt_battery_cell_battery_electrolyte_1775655447785','BC-ATL-001-2024','EL-LP-001-2024','2026-04-09 00:09:47'),(2,'lt_battery_cell_battery_electrolyte_1775655447785','BC-ATL-002-2024','EL-LP-001-2024','2026-04-09 00:09:47'),(3,'lt_battery_cell_battery_electrolyte_1775655447785','BC-BYD-001-2024','EL-LP-002-2024','2026-04-09 00:09:47'),(4,'lt_battery_cell_battery_electrolyte_1775655447785','BC-CALB-001-2024','EL-HV-001-2024','2026-04-09 00:09:47'),(5,'lt_battery_cell_battery_electrolyte_1775655447785','BC-EVE-001-2024','EL-HV-002-2024','2026-04-09 00:09:47'),(6,'lt_battery_cell_battery_electrolyte_1775655447785','BC-LG-001-2024','EL-IN-001-2024','2026-04-09 00:09:47'),(7,'lt_battery_cell_battery_electrolyte_1775655447785','BC-LG-002-2024','EL-IN-001-2024','2026-04-09 00:09:47'),(8,'lt_battery_cell_battery_electrolyte_1775655447785','BC-PANA-001-2024','EL-SS-001-2024','2026-04-09 00:09:47'),(9,'lt_battery_cell_battery_electrolyte_1775655447785','BC-SK-001-2024','EL-SS-002-2024','2026-04-09 00:09:47'),(10,'lt_battery_cell_battery_electrolyte_1775655447785','BC-SVOLT-001-2024','EL-SS-003-2024','2026-04-09 00:09:47'),(11,'lt_battery_cell_cathode_material_1775472265881','BC-ATL-001-2024','CM-NCM811-2024','2026-04-09 00:09:47'),(12,'lt_battery_cell_cathode_material_1775472265881','BC-ATL-002-2024','CM-LFP-2024','2026-04-09 00:09:47'),(13,'lt_battery_cell_cathode_material_1775472265881','BC-BYD-001-2024','CM-LFP-2024','2026-04-09 00:09:47'),(14,'lt_battery_cell_cathode_material_1775472265881','BC-CALB-001-2024','CM-LFP-2024','2026-04-09 00:09:47'),(15,'lt_battery_cell_cathode_material_1775472265881','BC-EVE-001-2024','CM-NCM523-2024','2026-04-09 00:09:47'),(16,'lt_battery_cell_cathode_material_1775472265881','BC-LG-001-2024','CM-NCM712-2024','2026-04-09 00:09:47'),(17,'lt_battery_cell_cathode_material_1775472265881','BC-LG-002-2024','CM-NCM811-2024','2026-04-09 00:09:47'),(18,'lt_battery_cell_cathode_material_1775472265881','BC-PANA-001-2024','CM-NCA-2024','2026-04-09 00:09:47'),(19,'lt_battery_cell_cathode_material_1775472265881','BC-SK-001-2024','CM-NCM811-2024','2026-04-09 00:09:47'),(20,'lt_battery_cell_cathode_material_1775472265881','BC-SVOLT-001-2024','CM-LFP-2024','2026-04-09 00:09:47'),(21,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-FD-001-2024','LC-BT-001-2024','2026-04-09 00:09:47'),(22,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-FD-002-2024','LC-BT-001-2024','2026-04-09 00:09:47'),(23,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-GL-001-2024','LC-BT-002-2024','2026-04-09 00:09:47'),(24,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-GL-002-2024','LC-BT-002-2024','2026-04-09 00:09:47'),(25,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-HT-001-2024','LC-BT-003-2024','2026-04-09 00:09:47'),(26,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-HV-001-2024','LC-IN-001-2024','2026-04-09 00:09:47'),(27,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-HV-002-2024','LC-IN-001-2024','2026-04-09 00:09:47'),(28,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-IN-001-2024','LC-IN-002-2024','2026-04-09 00:09:47'),(29,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-IN-002-2024','LC-IN-002-2024','2026-04-09 00:09:47'),(30,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-LP-001-2024','LC-ME-001-2024','2026-04-09 00:09:47'),(31,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-LP-002-2024','LC-ME-001-2024','2026-04-09 00:09:47'),(32,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-LP-003-2024','LC-ME-002-2024','2026-04-09 00:09:47'),(33,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-LT-001-2024','LC-BT-004-2024','2026-04-09 00:09:47'),(34,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-OR-001-2024','LC-BT-005-2024','2026-04-09 00:09:47'),(35,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-OR-002-2024','LC-BT-005-2024','2026-04-09 00:09:47'),(36,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-OR-003-2024','LC-IN-003-2024','2026-04-09 00:09:47'),(37,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-SI-001-2024','LC-ME-002-2024','2026-04-09 00:09:47'),(38,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-SS-001-2024','LC-BT-001-2024','2026-04-09 00:09:47'),(39,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-SS-002-2024','LC-BT-002-2024','2026-04-09 00:09:47'),(40,'lt_battery_electrolyte_lithium_carbonate_17755655437902','EL-SS-003-2024','LC-BT-003-2024','2026-04-09 00:09:47'),(41,'lt_cathode_material_lithium_carbonate_1775472267480','CM-LCO-2024','LC-BT-001-2024','2026-04-09 00:09:47'),(42,'lt_cathode_material_lithium_carbonate_1775472267480','CM-LCO-2024','LC-IN-001-2024','2026-04-09 00:09:47'),(43,'lt_cathode_material_lithium_carbonate_1775472267480','CM-LFMP-2024','LC-ME-001-2024','2026-04-09 00:09:47'),(44,'lt_cathode_material_lithium_carbonate_1775472267480','CM-LFP-2024','LC-BT-002-2024','2026-04-09 00:09:47'),(45,'lt_cathode_material_lithium_carbonate_1775472267480','CM-LFP-2024','LC-ME-002-2024','2026-04-09 00:09:47'),(46,'lt_cathode_material_lithium_carbonate_1775472267480','CM-LFP-2024','LC-IN-002-2024','2026-04-09 00:09:47'),(47,'lt_cathode_material_lithium_carbonate_1775472267480','CM-LMO-2024','LC-BT-003-2024','2026-04-09 00:09:47'),(48,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCA-2024','LC-IN-003-2024','2026-04-09 00:09:47'),(49,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCA-2024','LC-BT-004-2024','2026-04-09 00:09:47'),(50,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM523-2024','LC-BT-001-2024','2026-04-09 00:09:47'),(51,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM523-2024','LC-ME-001-2024','2026-04-09 00:09:47'),(52,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM622-2024','LC-IN-001-2024','2026-04-09 00:09:47'),(53,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM622-2024','LC-BT-002-2024','2026-04-09 00:09:47'),(54,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM712-2024','LC-ME-002-2024','2026-04-09 00:09:47'),(55,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM712-2024','LC-IN-003-2024','2026-04-09 00:09:47'),(56,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM811-2024','LC-BT-005-2024','2026-04-09 00:09:47'),(57,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM811-2024','LC-IN-002-2024','2026-04-09 00:09:47'),(58,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM811-2024','LC-ME-001-2024','2026-04-09 00:09:47'),(59,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM901-2024','LC-BT-004-2024','2026-04-09 00:09:47'),(60,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM901-2024','LC-IN-001-2024','2026-04-09 00:09:47'),(61,'lt_cathode_material_lithium_carbonate_1775472267480','CM-NCM901-2024','LC-BT-005-2024','2026-04-09 00:09:47'),(62,'lt_power_battery_battery_cell_1775472262897','BT-CATL-001-2024','BC-ATL-001-2024','2026-04-09 00:09:47'),(63,'lt_power_battery_battery_cell_1775472262897','BT-CATL-001-2024','BC-ATL-002-2024','2026-04-09 00:09:47'),(64,'lt_power_battery_battery_cell_1775472262897','BT-CATL-002-2024','BC-ATL-001-2024','2026-04-09 00:09:47'),(65,'lt_power_battery_battery_cell_1775472262897','BT-CATL-003-2024','BC-ATL-002-2024','2026-04-09 00:09:47'),(66,'lt_power_battery_battery_cell_1775472262897','BYD-BLADE-001-24','BC-BYD-001-2024','2026-04-09 00:09:47'),(67,'lt_power_battery_battery_cell_1775472262897','BYD-BLADE-002-24','BC-BYD-001-2024','2026-04-09 00:09:47'),(68,'lt_power_battery_battery_cell_1775472262897','CALB-LFP-001-2024','BC-CALB-001-2024','2026-04-09 00:09:47'),(69,'lt_power_battery_battery_cell_1775472262897','CALB-NCM-001-2024','BC-CALB-001-2024','2026-04-09 00:09:47'),(70,'lt_power_battery_battery_cell_1775472262897','EVE-LFP-001-2024','BC-EVE-001-2024','2026-04-09 00:09:47'),(71,'lt_power_battery_battery_cell_1775472262897','EVE-NCM-001-2024','BC-EVE-001-2024','2026-04-09 00:09:47'),(74,'lt_power_battery_battery_cell_1775472262897','LGES-NCM-001-24','BC-LG-001-2024','2026-04-09 00:09:47'),(75,'lt_power_battery_battery_cell_1775472262897','LGES-NCM-001-24','BC-LG-002-2024','2026-04-09 00:09:47'),(76,'lt_power_battery_battery_cell_1775472262897','LGES-NCM-002-24','BC-LG-002-2024','2026-04-09 00:09:47'),(77,'lt_power_battery_battery_cell_1775472262897','PANASONIC-001-24','BC-PANA-001-2024','2026-04-09 00:09:47'),(80,'lt_power_battery_battery_cell_1775472262897','SKI-NCM-001-2024','BC-SK-001-2024','2026-04-09 00:09:47'),(81,'lt_power_battery_battery_cell_1775472262897','SKI-NCM-002-24','BC-SK-001-2024','2026-04-09 00:09:47'),(82,'lt_power_battery_battery_cell_1775472262897','SVOLT-LFP-001-24','BC-SVOLT-001-2024','2026-04-09 00:09:47'),(83,'lt_power_battery_battery_cell_1775472262897','SVOLT-NCM-001-24','BC-SVOLT-001-2024','2026-04-09 00:09:47'),(105,'lt_company_manufactures_battery_cell','COMP_CATL','BC-ATL-001-2024','2026-04-15 23:09:50'),(106,'lt_company_manufactures_battery_cell','COMP_CATL','BC-ATL-002-2024','2026-04-15 23:09:50'),(107,'lt_company_manufactures_power_battery','COMP_CATL','BT-CATL-001-2024','2026-04-15 23:09:50'),(108,'lt_company_manufactures_power_battery','COMP_CATL','BT-CATL-002-2024','2026-04-15 23:09:50'),(109,'lt_company_manufactures_power_battery','COMP_CATL','BT-CATL-003-2024','2026-04-15 23:09:50'),(111,'lt_event_mentions_company_entity','news_catl_cet_001','COMP_CATL','2026-04-16 01:56:41'),(112,'lt_event_mentions_company_entity','news_catl_cet_001','COMP_CET','2026-04-16 01:56:41'),(113,'lt_event_affects_new_energy_vehicle','news_charging_policy_001','LHGCR1640J8100001','2026-04-16 01:56:41'),(114,'lt_event_affects_new_energy_vehicle','news_charging_policy_001','LS5A2ABE9KA100001','2026-04-16 01:56:41'),(121,'lt_company_manufactures_battery_cell','COMP_BYD','BC-BYD-001-2024','2026-04-16 02:11:46'),(129,'lt_company_manufactures_power_battery','COMP_BYD','BYD-BLADE-001-24','2026-04-16 02:11:46'),(130,'lt_company_manufactures_power_battery','COMP_BYD','BYD-BLADE-002-24','2026-04-16 02:11:46'),(159,'lt_company_manufactures_new_energy_vehicle','COMP_BYD','LVGBE40K9LG100001','2026-04-16 02:25:06'),(160,'lt_company_manufactures_new_energy_vehicle','COMP_BYD','LVGBE40K9LG100002','2026-04-16 02:25:06'),(161,'lt_company_manufactures_new_energy_vehicle','COMP_BYD','LVGBE40K9LG100003','2026-04-16 02:25:06'),(162,'lt_company_manufactures_new_energy_vehicle','COMP_BYD','LVGBE40K9LG100004','2026-04-16 02:25:06'),(178,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LHGCR1640J8100001','2026-04-16 03:07:13'),(179,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LHGCR1640J8100002','2026-04-16 03:07:13'),(180,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-002-2024','LHGCR1640J8100001','2026-04-16 03:07:13'),(181,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-002-2024','LHGCR1640J8100002','2026-04-16 03:07:13'),(182,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-LFP-001-2024','LHGCR1640J8100001','2026-04-16 03:07:13'),(183,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-LFP-001-2024','LHGCR1640J8100002','2026-04-16 03:07:13'),(184,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-NCM-001-2024','LHGCR1640J8100001','2026-04-16 03:07:13'),(185,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-NCM-001-2024','LHGCR1640J8100002','2026-04-16 03:07:13'),(186,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LHGCR1640J8100003','2026-04-16 03:07:13'),(187,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LHGCR1640J8100004','2026-04-16 03:07:13'),(188,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LHGCR1640J8100003','2026-04-16 03:07:13'),(189,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LHGCR1640J8100004','2026-04-16 03:07:13'),(190,'lt_power_battery_new_energy_vehicle_1775374603746','EVE-NCM-001-2024','LHGCR1640J8100003','2026-04-16 03:07:13'),(191,'lt_power_battery_new_energy_vehicle_1775374603746','EVE-NCM-001-2024','LHGCR1640J8100004','2026-04-16 03:07:13'),(192,'lt_power_battery_new_energy_vehicle_1775374603746','EVE-LFP-001-2024','LHGCR1640J8100003','2026-04-16 03:07:13'),(193,'lt_power_battery_new_energy_vehicle_1775374603746','EVE-LFP-001-2024','LHGCR1640J8100004','2026-04-16 03:07:13'),(194,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LHGCR1640J8100005','2026-04-16 03:07:13'),(195,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LHGCR1640J8100006','2026-04-16 03:07:13'),(196,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LHGCR1640J8100005','2026-04-16 03:07:13'),(197,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LHGCR1640J8100006','2026-04-16 03:07:13'),(198,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-NCM-001-2024','LHGCR1640J8100005','2026-04-16 03:07:13'),(199,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-NCM-001-2024','LHGCR1640J8100006','2026-04-16 03:07:13'),(200,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-LFP-001-2024','LHGCR1640J8100005','2026-04-16 03:07:13'),(201,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-LFP-001-2024','LHGCR1640J8100006','2026-04-16 03:07:13'),(202,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-002-2024','LS5A2ABE9KA100001','2026-04-16 03:07:13'),(203,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-002-2024','LS5A2ABE9KA100002','2026-04-16 03:07:13'),(204,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LS5A2ABE9KA100001','2026-04-16 03:07:13'),(205,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LS5A2ABE9KA100002','2026-04-16 03:07:13'),(206,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-LFP-001-2024','LS5A2ABE9KA100001','2026-04-16 03:07:13'),(207,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-LFP-001-2024','LS5A2ABE9KA100002','2026-04-16 03:07:13'),(208,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-NCM-001-2024','LS5A2ABE9KA100001','2026-04-16 03:07:13'),(209,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-NCM-001-2024','LS5A2ABE9KA100002','2026-04-16 03:07:13'),(210,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LS5A2ABE9KA100005','2026-04-16 03:07:13'),(211,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LS5A2ABE9KA100006','2026-04-16 03:07:13'),(212,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LS5A2ABE9KA100005','2026-04-16 03:07:13'),(213,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LS5A2ABE9KA100006','2026-04-16 03:07:13'),(214,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-NCM-001-2024','LS5A2ABE9KA100005','2026-04-16 03:07:13'),(215,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-NCM-001-2024','LS5A2ABE9KA100006','2026-04-16 03:07:13'),(216,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-LFP-001-2024','LS5A2ABE9KA100005','2026-04-16 03:07:13'),(217,'lt_power_battery_new_energy_vehicle_1775374603746','SUNWODA-LFP-001-2024','LS5A2ABE9KA100006','2026-04-16 03:07:13'),(218,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-002-2024','LS5A2ABE9KA100007','2026-04-16 03:07:13'),(219,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-002-2024','LS5A2ABE9KA100008','2026-04-16 03:07:13'),(220,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LS5A2ABE9KA100007','2026-04-16 03:07:13'),(221,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-003-2024','LS5A2ABE9KA100008','2026-04-16 03:07:13'),(222,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-LFP-001-2024','LS5A2ABE9KA100007','2026-04-16 03:07:13'),(223,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-LFP-001-2024','LS5A2ABE9KA100008','2026-04-16 03:07:13'),(224,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-NCM-001-2024','LS5A2ABE9KA100007','2026-04-16 03:07:13'),(225,'lt_power_battery_new_energy_vehicle_1775374603746','CALB-NCM-001-2024','LS5A2ABE9KA100008','2026-04-16 03:07:13'),(226,'lt_power_battery_new_energy_vehicle_1775374603746','PANASONIC-001-24','LSVAG2180J2100001','2026-04-16 03:07:13'),(227,'lt_power_battery_new_energy_vehicle_1775374603746','PANASONIC-001-24','LSVAG2180J2100002','2026-04-16 03:07:13'),(228,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LSVAG2180J2100001','2026-04-16 03:07:13'),(229,'lt_power_battery_new_energy_vehicle_1775374603746','BT-CATL-001-2024','LSVAG2180J2100002','2026-04-16 03:07:13'),(230,'lt_power_battery_new_energy_vehicle_1775374603746','LGES-NCM-001-24','LSVAG2180J2100001','2026-04-16 03:07:13'),(231,'lt_power_battery_new_energy_vehicle_1775374603746','LGES-NCM-001-24','LSVAG2180J2100002','2026-04-16 03:07:13'),(232,'lt_power_battery_new_energy_vehicle_1775374603746','LGES-NCM-002-24','LSVAG2180J2100001','2026-04-16 03:07:13'),(233,'lt_power_battery_new_energy_vehicle_1775374603746','LGES-NCM-002-24','LSVAG2180J2100002','2026-04-16 03:07:13'),(242,'lt_company_strategic_cooperation','COMP_CATL','COMP_CET','2026-04-16 05:32:48');
/*!40000 ALTER TABLE `link_instance_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `link_types`
--

DROP TABLE IF EXISTS `link_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `link_types` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_object_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_object_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cardinality` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N:M',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `industry_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `source_column` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '源对象类型唯一标识列（对应底层数据表字段）',
  `target_column` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '目标对象类型唯一标识列（对应底层数据表字段）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT '状态: pending-待审核, active-生效',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `link_types`
--

LOCK TABLES `link_types` WRITE;
/*!40000 ALTER TABLE `link_types` DISABLE KEYS */;
INSERT INTO `link_types` VALUES ('lt_battery_cell_battery_electrolyte_1775655447785','使用电解液','battery_cell','battery_electrolyte','N:1','电芯的生产需要使用特定的电解液，电解液的类型和价格影响电芯的性能和成本',NULL,'2026-04-08 21:37:27','2026-04-11 10:12:16','unique_id','unique_id','active'),('lt_battery_cell_cathode_material_1775472265881','电芯使用正极材料','battery_cell','cathode_material','N:1','电芯的制造需要使用特定的正极材料（如磷酸铁锂、三元材料等），同一种正极材料可用于多种电芯。',NULL,'2026-04-06 18:44:25','2026-04-11 10:12:16','unique_id','material_id','active'),('lt_battery_electrolyte_lithium_carbonate_1775655437902','原料包含碳酸锂','battery_electrolyte','lithium_carbonate','N:1','电解液（特别是锂离子电池电解液）的生产需要使用碳酸锂作为锂源，碳酸锂的价格影响电解液成本',NULL,'2026-04-08 21:37:17','2026-04-11 10:12:16','unique_id','unique_id','active'),('lt_cathode_material_lithium_carbonate_1775472267480','正极材料消耗碳酸锂','cathode_material','lithium_carbonate','N:M','正极材料的生产需要消耗碳酸锂作为关键锂源，而碳酸锂也可用于生产多种不同的正极材料。',NULL,'2026-04-06 18:44:27','2026-04-11 10:12:16','material_id','unique_id','active'),('lt_company_manufactures_battery_cell','公司生产电芯','company_entity','battery_cell','1:N','用于表达公司与其生产电芯实例之间的关系',NULL,'2026-04-16 07:09:10','2026-04-16 10:08:33','company_id','unique_id','active'),('lt_company_manufactures_lithium_carbonate','公司生产碳酸锂','company_entity','lithium_carbonate','1:N','用于表达公司与其生产碳酸锂实例之间的关系',NULL,'2026-04-16 09:56:41','2026-04-16 10:08:52','company_id','unique_id','active'),('lt_company_manufactures_new_energy_vehicle','公司生产整车','company_entity','new_energy_vehicle','1:N','用于表达公司与其生产新能源整车实例之间的关系',NULL,'2026-04-16 09:56:41','2026-04-16 10:08:56','company_id','vehicle_id','active'),('lt_company_manufactures_power_battery','公司生产电池','company_entity','power_battery','1:N','用于表达公司与其生产动力电池实例之间的关系',NULL,'2026-04-16 07:09:50','2026-04-16 10:09:01','company_id','unique_id','active'),('lt_company_strategic_cooperation','公司战略合作','company_entity','company_entity','N:M','用于表达公司间的战略合作、联合研发与协同合作关系',NULL,'2026-04-15 22:56:35','2026-04-16 10:09:17','company_id','company_id','active'),('lt_company_supplier','公司供应商','company_entity','company_entity','N:M','用于表达公司与其上游供应商公司之间的关系',NULL,'2026-04-16 10:11:46','2026-04-16 10:11:46','company_id','company_id','active'),('lt_event_affects_lithium_carbonate','事件影响碳酸锂价格','event_entity','lithium_carbonate','N:M','用于表达事件对碳酸锂产品或价格的影响',NULL,'2026-04-16 09:56:41','2026-04-16 10:07:46','id','unique_id','active'),('lt_event_affects_new_energy_vehicle','事件影响整车价格','event_entity','new_energy_vehicle','N:M','用于表达事件对新能源整车产品的影响或关联',NULL,'2026-04-16 09:56:41','2026-04-16 10:07:51','id','vehicle_id','active'),('lt_event_mentions_company_entity','事件影响公司','event_entity','company_entity','N:M','用于表达事件与公司之间的影响、提及、合作或关联关系',NULL,'2026-04-16 09:56:41','2026-04-16 10:07:21','id','company_id','active'),('lt_power_battery_battery_cell_1775472262897','电池由电芯组成','power_battery','battery_cell','1:N','一个动力电池包（电池）由多个基本的电芯通过串并联方式组合而成。',NULL,'2026-04-06 18:44:22','2026-04-11 10:12:16','unique_id','unique_id','active'),('lt_power_battery_new_energy_vehicle_1775374603746','装配于','power_battery','new_energy_vehicle','N:1','电池作为核心部件被装配到新能源整车中',NULL,'2026-04-05 15:36:43','2026-04-11 10:12:16','unique_id','vehicle_id','active');
/*!40000 ALTER TABLE `link_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lithium_carbonate`
--

DROP TABLE IF EXISTS `lithium_carbonate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lithium_carbonate` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '唯一标识符，如产品编码或批次号',
  `grade` varchar(50) DEFAULT NULL COMMENT '品级，如电池级、工业级、医药级',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家或供应商名称',
  `price` decimal(12,2) DEFAULT NULL COMMENT '价格（万元/吨）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `unique_id` (`unique_id`),
  KEY `idx_unique_id` (`unique_id`),
  KEY `idx_grade` (`grade`),
  KEY `idx_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='碳酸锂信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lithium_carbonate`
--

LOCK TABLES `lithium_carbonate` WRITE;
/*!40000 ALTER TABLE `lithium_carbonate` DISABLE KEYS */;
INSERT INTO `lithium_carbonate` VALUES (1,'LC-BT-001-2024','电池级','天齐锂业',12.50,'2024-03-01','2026-04-08 12:52:27','2026-04-08 12:52:27'),(2,'LC-BT-002-2024','电池级','赣锋锂业',12.80,'2024-03-01','2026-04-08 12:52:27','2026-04-08 12:52:27'),(3,'LC-BT-003-2024','电池级','盐湖股份',11.20,'2024-02-15','2026-04-08 12:52:27','2026-04-08 12:52:27'),(4,'LC-BT-004-2024','电池级','雅化集团',13.20,'2024-03-10','2026-04-08 12:52:27','2026-04-08 12:52:27'),(10,'LC-BT-005-2024','电池级','盛新锂能',12.60,'2024-02-22','2026-04-08 12:52:27','2026-04-08 12:52:27'),(5,'LC-IN-001-2024','工业级','天齐锂业',9.80,'2024-01-20','2026-04-08 12:52:27','2026-04-08 12:52:27'),(6,'LC-IN-002-2024','工业级','赣锋锂业',10.20,'2024-02-28','2026-04-08 12:52:27','2026-04-08 12:52:27'),(7,'LC-IN-003-2024','工业级','西藏矿业',9.50,'2024-03-05','2026-04-08 12:52:27','2026-04-08 12:52:27'),(8,'LC-ME-001-2024','医药级','天齐锂业',18.50,'2024-01-15','2026-04-08 12:52:27','2026-04-08 12:52:27'),(9,'LC-ME-002-2024','医药级','赣锋锂业',19.20,'2024-03-12','2026-04-08 12:52:27','2026-04-08 12:52:27');
/*!40000 ALTER TABLE `lithium_carbonate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lithium_price_monitor`
--

DROP TABLE IF EXISTS `lithium_price_monitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lithium_price_monitor` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `instance_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `price_date` datetime DEFAULT NULL,
  `source` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lithium_price_monitor_instance_created` (`instance_id`,`created_at`),
  KEY `idx_lithium_price_monitor_price_date` (`price_date`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lithium_price_monitor`
--

LOCK TABLES `lithium_price_monitor` WRITE;
/*!40000 ALTER TABLE `lithium_price_monitor` DISABLE KEYS */;
INSERT INTO `lithium_price_monitor` VALUES (1,'LC-BT-001-2024',12.50,'2026-04-14 09:00:00','seed','2026-04-14 09:00:00'),(2,'LC-BT-001-2024',20.00,'2026-04-15 09:00:00','seed','2026-04-15 09:00:00');
/*!40000 ALTER TABLE `lithium_price_monitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `new_energy_vehicle`
--

DROP TABLE IF EXISTS `new_energy_vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `new_energy_vehicle` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `vehicle_id` varchar(50) NOT NULL COMMENT '车辆唯一标识符（VIN码）',
  `brand` varchar(100) DEFAULT NULL COMMENT '品牌',
  `model_name` varchar(200) DEFAULT NULL COMMENT '车型名称',
  `vehicle_type` varchar(50) DEFAULT NULL COMMENT '车辆类型（如：纯电动BEV、插电混动PHEV、增程式EREV）',
  `battery_capacity` decimal(10,2) DEFAULT NULL COMMENT '电池容量（单位：kWh）',
  `range_km` int DEFAULT NULL COMMENT '续航里程（单位：公里）',
  `price` decimal(12,2) DEFAULT NULL COMMENT '指导价（单位：万元）',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `is_available` tinyint(1) DEFAULT '1' COMMENT '是否在售',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  `initial_gross_margin` decimal(10,4) DEFAULT NULL COMMENT '初始毛利率',
  `initial_cost` decimal(12,2) DEFAULT NULL COMMENT '初始成本（单位：万元）',
  `battery_cost` decimal(12,2) DEFAULT NULL COMMENT '电池成本（单位：万元）',
  PRIMARY KEY (`vehicle_id`),
  KEY `idx_vehicle_id` (`vehicle_id`),
  KEY `idx_brand` (`brand`),
  KEY `idx_vehicle_type` (`vehicle_type`),
  KEY `idx_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='新能源汽车信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `new_energy_vehicle`
--

LOCK TABLES `new_energy_vehicle` WRITE;
/*!40000 ALTER TABLE `new_energy_vehicle` DISABLE KEYS */;
INSERT INTO `new_energy_vehicle` VALUES (7,'LHGCR1640J8100001','蔚来','ET5 75kWh','纯电动BEV',75.00,560,29.80,'2024-01-20',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-03-10',0.1650,21.20,8.80),(8,'LHGCR1640J8100002','蔚来','ES6 100kWh','纯电动BEV',100.00,625,39.60,'2024-02-28',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-03-10',0.1980,28.50,11.20),(9,'LHGCR1640J8100003','小鹏','P7i 702 Max','纯电动BEV',86.20,702,23.99,'2024-03-05',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-02-28',0.1380,18.20,7.50),(10,'LHGCR1640J8100004','小鹏','G9 702 Pro','纯电动BEV',98.00,702,32.99,'2024-01-12',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-02-28',0.1750,24.80,9.80),(11,'LHGCR1640J8100005','理想','L7 Pro','增程式EREV',42.80,1315,33.98,'2024-02-18',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-01-15',0.1280,26.80,10.50),(12,'LHGCR1640J8100006','理想','L9 Max','增程式EREV',52.30,1412,45.98,'2024-03-15',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-01-15',0.1580,32.50,12.80),(13,'LS5A2ABE9KA100001','广汽埃安','AION S Plus','纯电动BEV',69.90,610,14.98,'2024-01-25',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-03-05',0.0950,12.20,5.20),(14,'LS5A2ABE9KA100002','广汽埃安','AION Y Plus','纯电动BEV',76.80,610,13.18,'2024-02-10',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-03-05',0.0880,10.80,4.80),(15,'LS5A2ABE9KA100003','极氪','001 WE版','纯电动BEV',100.00,741,30.00,'2024-03-08',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-02-22',0.1680,22.50,9.20),(16,'LS5A2ABE9KA100004','极氪','007 后驱版','纯电动BEV',75.60,688,20.99,'2024-01-30',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-02-22',0.1450,16.20,6.80),(17,'LS5A2ABE9KA100005','问界','M5 EV 后驱','纯电动BEV',80.00,620,25.98,'2024-02-25',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-03-12',0.1320,20.50,8.20),(18,'LS5A2ABE9KA100006','问界','M7 增程版','增程式EREV',40.00,1300,28.98,'2024-03-20',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-03-12',0.1480,22.80,8.80),(19,'LS5A2ABE9KA100007','长安深蓝','SL03 增程版','增程式EREV',28.39,1200,14.99,'2024-01-18',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-02-08',0.1050,11.80,4.50),(20,'LS5A2ABE9KA100008','长安深蓝','S7 纯电版','纯电动BEV',79.97,620,18.99,'2024-02-22',1,'2026-04-05 11:35:41','2026-04-08 11:58:11','2024-02-08',0.1180,14.50,6.20),(1,'LSVAG2180J2100001','特斯拉','Model 3 标准续航版','纯电动BEV',60.00,556,23.19,'2024-01-15',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-03-01',0.1520,18.50,6.20),(2,'LSVAG2180J2100002','特斯拉','Model Y 长续航版','纯电动BEV',78.40,660,29.99,'2024-02-20',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-03-01',0.1850,22.80,8.50),(3,'LVGBE40K9LG100001','比亚迪','汉EV 冠军版','纯电动BEV',85.40,715,20.98,'2024-03-10',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-02-15',0.1250,16.80,7.20),(4,'LVGBE40K9LG100002','比亚迪','海豹 700km','纯电动BEV',82.50,700,22.28,'2024-01-08',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-02-15',0.1420,17.50,7.80),(5,'LVGBE40K9LG100003','比亚迪','秦PLUS DM-i','插电混动PHEV',18.30,1245,9.98,'2024-02-15',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-01-20',0.0980,8.20,2.80),(6,'LVGBE40K9LG100004','比亚迪','宋PLUS DM-i','插电混动PHEV',26.60,1200,15.48,'2024-03-22',1,'2026-04-05 11:35:41','2026-04-08 11:57:41','2024-01-20',0.1150,12.50,4.20);
/*!40000 ALTER TABLE `new_energy_vehicle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_events`
--

DROP TABLE IF EXISTS `news_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `news_events` (
  `id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci,
  `content` text COLLATE utf8mb4_unicode_ci,
  `category` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_date` date DEFAULT NULL,
  `tags` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `news_events`
--

LOCK TABLES `news_events` WRITE;
/*!40000 ALTER TABLE `news_events` DISABLE KEYS */;
INSERT INTO `news_events` VALUES ('news_catl_cet_001','宁德时代与中恒电气达成储能协同合作','合作消息触发市场对储能产业链关系的重新梳理，研究员希望确认合作关系是否足以沉淀为图谱中的正式关系。','宁德时代与中恒电气宣布围绕储能场景展开协同合作，合作方向包括储能系统集成、站端设备协同与项目拓展。市场关注这是否意味着双方将在储能领域形成更明确的合作关系。','关系发现','证券时报','2026-04-15','[\"储能\", \"合作关系\"]','2026-04-15 22:56:35','2026-04-16 11:07:13'),('news_charging_policy_001','政策支持充电基础设施建设','政策端继续强调充电基础设施建设和补能网络完善，市场关注其对充电运营、设备制造及整车消费渗透的带动效应。','政策端继续强调充电基础设施建设和补能网络完善，市场关注其对充电运营、设备制造及整车消费渗透的带动效应。','政策驱动','证券时报','2026-04-14','[\"充电基础设施\", \"高压快充\", \"新能源汽车\"]','2026-04-15 22:56:35','2026-04-16 07:13:59');
/*!40000 ALTER TABLE `news_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` varchar(64) NOT NULL,
  `title` varchar(128) NOT NULL COMMENT '通知标题',
  `content` varchar(512) DEFAULT NULL COMMENT '通知内容',
  `type` varchar(16) NOT NULL COMMENT '通知类型: SYSTEM/APPROVAL/EXECUTION/DATASET',
  `status` varchar(8) NOT NULL DEFAULT 'UNREAD' COMMENT '状态: UNREAD/READ',
  `user_id` varchar(64) DEFAULT NULL COMMENT '接收用户ID',
  `related_object_type` varchar(32) DEFAULT NULL COMMENT '关联对象类型',
  `related_object_id` varchar(64) DEFAULT NULL COMMENT '关联对象ID',
  `action_url` varchar(256) DEFAULT NULL COMMENT '跳转链接',
  `read_at` datetime DEFAULT NULL COMMENT '阅读时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_status` (`user_id`,`status`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES ('notif_001','对象类型审批通过','新能源整车 对象类型已通过审批。','APPROVAL','READ',NULL,'new_energy_vehicle',NULL,NULL,'2026-04-12 15:53:09','2026-04-11 15:41:25'),('notif_002','动作执行成功','碳酸锂价格变化触发整车价格调整 执行成功。','EXECUTION','READ',NULL,NULL,NULL,NULL,'2026-04-12 17:39:25','2026-04-12 15:11:25'),('notif_1776003391623','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776002892929',NULL,'2026-04-12 22:16:50','2026-04-12 22:16:32'),('notif_1776003463278','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776002892929',NULL,'2026-04-13 09:05:03','2026-04-12 22:17:43'),('notif_1776043733372','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776002892929',NULL,'2026-04-13 09:29:46','2026-04-13 09:28:53'),('notif_1776043834965','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776002892929',NULL,'2026-04-13 09:39:23','2026-04-13 09:30:35'),('notif_1776233421132','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776231635728',NULL,'2026-04-15 14:37:14','2026-04-15 14:10:21'),('notif_1776233430013','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776231635728',NULL,'2026-04-15 14:37:14','2026-04-15 14:10:30'),('notif_1776233487901','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776231635728',NULL,'2026-04-15 14:37:14','2026-04-15 14:11:28'),('notif_1776235019779','动作类型执行成功','','EXECUTION','READ',NULL,'action_type','act_1776231635728',NULL,'2026-04-15 14:37:14','2026-04-15 14:37:00'),('notif_1776236507419','动作类型执行成功','','EXECUTION','UNREAD',NULL,'action_type','act_1776236475185',NULL,NULL,'2026-04-15 15:01:47'),('notif_1776265200641','动作类型执行成功','已创建新的公司合作关系链接','EXECUTION','UNREAD',NULL,'action_type','act_create_company_strategic_link',NULL,NULL,'2026-04-15 23:00:01'),('notif_1776265246506','动作类型执行成功','已创建新的公司合作关系链接','EXECUTION','UNREAD',NULL,'action_type','act_create_company_strategic_link',NULL,NULL,'2026-04-15 23:00:47'),('notif_1776306885307','动作类型执行成功','已创建新的公司合作关系链接','EXECUTION','UNREAD',NULL,'action_type','act_create_company_company_link',NULL,NULL,'2026-04-16 10:34:45'),('notif_1776306990040','动作类型执行成功','已删除公司合作关系链接','EXECUTION','UNREAD',NULL,'action_type','act_delete_company_company_link',NULL,NULL,'2026-04-16 10:36:30'),('notif_1776312695725','动作类型执行成功','','EXECUTION','UNREAD',NULL,'action_type','act_1776253947603',NULL,NULL,'2026-04-16 12:11:36'),('notif_1776316731987','动作类型执行成功','已创建新的公司合作关系链接','EXECUTION','UNREAD',NULL,'action_type','act_create_company_company_link',NULL,NULL,'2026-04-16 13:18:52'),('notif_1776317092646','动作类型执行成功','已删除公司合作关系链接','EXECUTION','UNREAD',NULL,'action_type','act_delete_company_company_link',NULL,NULL,'2026-04-16 13:24:53'),('notif_1776317568235','动作类型执行成功','已创建新的公司合作关系链接','EXECUTION','UNREAD',NULL,'action_type','act_create_company_company_link',NULL,NULL,'2026-04-16 13:32:48'),('notif_1776318954207','动作类型执行成功','','EXECUTION','UNREAD',NULL,'action_type','act_1776231635728',NULL,NULL,'2026-04-16 13:55:54');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_types`
--

DROP TABLE IF EXISTS `object_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `object_types` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Database',
  `backing_dataset` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `industry_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `data_source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'mysql' COMMENT '数据源名称',
  `database_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ontology' COMMENT '数据库名称',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT '状态: pending-待审核, active-生效',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_types`
--

LOCK TABLES `object_types` WRITE;
/*!40000 ALTER TABLE `object_types` DISABLE KEYS */;
INSERT INTO `object_types` VALUES ('battery_cell','电芯','电芯','Database','battery_cell',NULL,'2026-04-06 18:28:04','2026-04-11 10:12:16','mysql','ontology','active'),('battery_electrolyte','电池电解液','电池电解液','Database','battery_electrolyte',NULL,'2026-04-08 20:13:52','2026-04-11 10:12:16','mysql','ontology','active'),('cathode_material','正极材料','正极材料','Database','cathode_material',NULL,'2026-04-06 18:30:29','2026-04-11 10:12:16','mysql','ontology','active'),('company_entity','公司','用于承载上市公司、产业链公司等实例关系发现与关系写回','Database','company_entity',NULL,'2026-04-15 22:56:35','2026-04-16 10:00:57','mysql','ontology','active'),('event_entity','事件','用于承载新闻、政策、价格波动、合作公告等事件实体','Newspaper','news_events',NULL,'2026-04-16 09:56:41','2026-04-16 09:56:41','mysql','ontology','active'),('lithium_carbonate','碳酸锂','碳酸锂','Database','lithium_carbonate',NULL,'2026-04-06 18:34:31','2026-04-11 10:12:16','mysql','ontology','active'),('new_energy_vehicle','新能源整车','新能源整车','Database','new_energy_vehicle',NULL,'2026-04-05 15:07:20','2026-04-11 10:12:16','mysql','ontology','active'),('power_battery','电池','电池','Database','power_battery',NULL,'2026-04-05 15:25:19','2026-04-11 10:12:16','mysql','ontology','active');
/*!40000 ALTER TABLE `object_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ontology_rule_params`
--

DROP TABLE IF EXISTS `ontology_rule_params`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ontology_rule_params` (
  `id` varchar(64) NOT NULL,
  `rule_id` varchar(64) NOT NULL COMMENT '关联规则ID',
  `param_direction` varchar(8) NOT NULL COMMENT '参数方向: INPUT, OUTPUT',
  `param_name` varchar(64) NOT NULL COMMENT '参数名',
  `param_type` varchar(32) DEFAULT NULL COMMENT '类型',
  `is_required` tinyint DEFAULT '0' COMMENT '是否必填: 0-否, 1-是',
  `description` varchar(256) DEFAULT NULL COMMENT '说明',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_rule_id` (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ontology_rule_params`
--

LOCK TABLES `ontology_rule_params` WRITE;
/*!40000 ALTER TABLE `ontology_rule_params` DISABLE KEYS */;
INSERT INTO `ontology_rule_params` VALUES ('rule_bc_delete_in_0','rule_bc_delete','INPUT','p_id_1775651827534','string',1,'实例ID',0),('rule_bc_delete_out_0','rule_bc_delete','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_bc_update_in_0','rule_bc_update','INPUT','p_id_1775651827534','string',1,'实例ID',0),('rule_bc_update_in_1','rule_bc_update','INPUT','p_model_1775651928286','string',0,'电芯型号',1),('rule_bc_update_out_0','rule_bc_update','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_be_create_in_0','rule_be_create','INPUT','p_id_1775650733670','string',1,'电解液唯一标识符',0),('rule_be_create_in_1','rule_be_create','INPUT','p_name_1775650734536','string',0,'电解液名称或型号',1),('rule_be_create_in_2','rule_be_create','INPUT','p_electrolytetype_1775650736187','string',0,'电解液类型（液态、固态、凝胶等）',2),('rule_be_create_out_0','rule_be_create','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_be_delete_in_0','rule_be_delete','INPUT','p_id_1775650733670','string',1,'实例ID',0),('rule_be_delete_out_0','rule_be_delete','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_be_update_in_0','rule_be_update','INPUT','p_id_1775650733670','string',1,'实例ID',0),('rule_be_update_in_1','rule_be_update','INPUT','p_name_1775650734536','string',0,'电解液名称',1),('rule_be_update_out_0','rule_be_update','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_cm_create_in_0','rule_cm_create','INPUT','p_material_id_1775651402080','string',1,'正极材料唯一标识符',0),('rule_cm_create_in_1','rule_cm_create','INPUT','p_material_name_1775651404512','string',0,'正极材料名称',1),('rule_cm_create_out_0','rule_cm_create','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_cm_delete_in_0','rule_cm_delete','INPUT','p_material_id_1775651402080','string',1,'实例ID',0),('rule_cm_delete_out_0','rule_cm_delete','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_cm_update_in_0','rule_cm_update','INPUT','p_material_id_1775651402080','string',1,'实例ID',0),('rule_cm_update_in_1','rule_cm_update','INPUT','p_material_name_1775651404512','string',0,'正极材料名称',1),('rule_cm_update_out_0','rule_cm_update','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_create_company_company_link_in_0','rule_create_company_company_link','INPUT','sourceInstanceId','string',1,'源公司实例ID',0),('rule_create_company_company_link_in_1','rule_create_company_company_link','INPUT','targetInstanceId','string',1,'目标公司实例ID',1),('rule_create_company_company_link_in_2','rule_create_company_company_link','INPUT','linkTypeId','string',0,'关系链接类型ID，默认战略合作',2),('rule_create_company_company_link_out_0','rule_create_company_company_link','OUTPUT','success','boolean',1,'是否成功创建链接',0),('rule_create_company_company_link_out_1','rule_create_company_company_link','OUTPUT','message','string',0,'返回消息',1),('rule_delete_company_company_link_in_0','rule_delete_company_company_link','INPUT','sourceInstanceId','string',1,'源公司实例ID',0),('rule_delete_company_company_link_in_1','rule_delete_company_company_link','INPUT','targetInstanceId','string',1,'目标公司实例ID',1),('rule_delete_company_company_link_in_2','rule_delete_company_company_link','INPUT','linkTypeId','string',0,'关系链接类型ID，默认战略合作',2),('rule_delete_company_company_link_out_0','rule_delete_company_company_link','OUTPUT','success','boolean',1,'是否成功删除链接',0),('rule_delete_company_company_link_out_1','rule_delete_company_company_link','OUTPUT','message','string',0,'返回消息',1),('rule_lc_create_in_0','rule_lc_create','INPUT','p_id_1775652265840','string',1,'唯一标识符',0),('rule_lc_create_in_1','rule_lc_create','INPUT','p_grade_1775652359942','string',0,'品级（电池级、工业级、医药级）',1),('rule_lc_create_in_2','rule_lc_create','INPUT','p_manufacturer_1775652360925','string',0,'生产厂家或供应商名称',2),('rule_lc_create_out_0','rule_lc_create','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_lc_delete_in_0','rule_lc_delete','INPUT','p_id_1775652265840','string',1,'实例ID',0),('rule_lc_delete_out_0','rule_lc_delete','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_lc_update_in_0','rule_lc_update','INPUT','p_id_1775652265840','string',1,'实例ID',0),('rule_lc_update_in_1','rule_lc_update','INPUT','p_grade_1775652359942','string',0,'品级',1),('rule_lc_update_out_0','rule_lc_update','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_nev_create_in_0','rule_nev_create','INPUT','p_modelname_1775385755582','string',1,'车型名称',1),('rule_nev_create_in_1','rule_nev_create','INPUT','p_brand_1775388584499','string',1,'品牌',2),('rule_nev_create_in_2','rule_nev_create','INPUT','p_price_1775385757615','number',0,'指导价（单位：万元）',3),('rule_nev_create_in_3','rule_nev_create','INPUT','p_batterycapacity_1775385756098','number',0,'电池容量（单位：kWh）',4),('rule_nev_create_in_4','rule_nev_create','INPUT','p_isavailable_1775385758165','boolean',0,'是否在售',5),('rule_nev_create_in_vid','rule_nev_create','INPUT','p_vehicleid_1775385754771','string',1,'车辆唯一标识符（VIN码）',0),('rule_nev_create_out_0','rule_nev_create','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_nev_create_out_1','rule_nev_create','OUTPUT','message','string',0,'返回消息',1),('rule_nev_delete_in_0','rule_nev_delete','INPUT','p_vehicleid_1775385754771','string',1,'实例ID（主键）',0),('rule_nev_delete_out_0','rule_nev_delete','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_nev_delete_out_1','rule_nev_delete','OUTPUT','message','string',0,'返回消息',1),('rule_nev_update_in_0','rule_nev_update','INPUT','p_vehicleid_1775385754771','string',1,'实例ID（主键）',0),('rule_nev_update_in_1','rule_nev_update','INPUT','p_modelname_1775385755582','string',0,'车型名称',1),('rule_nev_update_in_2','rule_nev_update','INPUT','p_brand_1775388584499','string',0,'品牌',2),('rule_nev_update_in_3','rule_nev_update','INPUT','p_price_1775385757615','number',0,'指导价（单位：万元）',3),('rule_nev_update_in_4','rule_nev_update','INPUT','p_batterycapacity_1775385756098','number',0,'电池容量（单位：kWh）',4),('rule_nev_update_out_0','rule_nev_update','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_nev_update_out_1','rule_nev_update','OUTPUT','message','string',0,'返回消息',1),('rule_pb_create_in_0','rule_pb_create','INPUT','p_id_1775469202509','string',1,'电池唯一标识符',0),('rule_pb_create_in_1','rule_pb_create','INPUT','p_model_1775469226104','string',0,'电池型号',1),('rule_pb_create_in_2','rule_pb_create','INPUT','p_manufacturer_1775469343287','string',0,'制造商名称',2),('rule_pb_create_in_3','rule_pb_create','INPUT','p_capacity_1775469262904','number',0,'电池容量（Ah或mAh）',3),('rule_pb_create_in_4','rule_pb_create','INPUT','p_price_1775469202509','double',0,'价格',4),('rule_pb_create_out_0','rule_pb_create','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_pb_delete_in_0','rule_pb_delete','INPUT','p_id_1775469202509','string',1,'实例ID',0),('rule_pb_delete_out_0','rule_pb_delete','OUTPUT','success','boolean',1,'操作是否成功',0),('rule_pb_update_in_0','rule_pb_update','INPUT','p_id_1775469202509','string',1,'实例ID',0),('rule_pb_update_in_1','rule_pb_update','INPUT','p_model_1775469226104','string',0,'电池型号',1),('rule_pb_update_in_2','rule_pb_update','INPUT','p_price_1775469202509','double',0,'价格',2),('rule_pb_update_out_0','rule_pb_update','OUTPUT','success','boolean',1,'操作是否成功',0);
/*!40000 ALTER TABLE `ontology_rule_params` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ontology_rules`
--

DROP TABLE IF EXISTS `ontology_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ontology_rules` (
  `id` varchar(64) NOT NULL,
  `rule_category` varchar(32) NOT NULL COMMENT '规则类别: CREATE_OBJECT, UPDATE_OBJECT, DELETE_OBJECT, CREATE_LINK, DELETE_LINK, FUNCTION_RULE',
  `function_name` varchar(128) DEFAULT NULL COMMENT '函数/方法名',
  `interface_type` varchar(16) NOT NULL COMMENT '接口性质: DUBBO, RESTFUL',
  `request_method` varchar(8) DEFAULT NULL COMMENT '请求方式: GET, POST, PUT, DELETE (仅RESTful时使用)',
  `interface_url` varchar(512) DEFAULT NULL COMMENT '接口地址',
  `function_description` varchar(512) DEFAULT NULL COMMENT '函数描述',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ontology_rules`
--

LOCK TABLES `ontology_rules` WRITE;
/*!40000 ALTER TABLE `ontology_rules` DISABLE KEYS */;
INSERT INTO `ontology_rules` VALUES ('rule_bc_create','CREATE_OBJECT','createBatteryCell','RESTFUL','POST','/api/instances/battery_cell','创建新的电芯实例记录','2026-04-11 16:56:03','2026-04-15 10:45:34'),('rule_bc_delete','DELETE_OBJECT','deleteBatteryCell','RESTFUL','DELETE','/api/instances/battery_cell/{id}','删除电芯实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_bc_update','UPDATE_OBJECT','updateBatteryCell','RESTFUL','PUT','/api/instances/battery_cell/{id}','更新电芯实例信息','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_be_create','CREATE_OBJECT','createBatteryElectrolyte','RESTFUL','POST','/api/instances/battery_electrolyte','创建新的电池电解液实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_be_delete','DELETE_OBJECT','deleteBatteryElectrolyte','RESTFUL','DELETE','/api/instances/battery_electrolyte/{id}','删除电池电解液实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_be_update','UPDATE_OBJECT','updateBatteryElectrolyte','RESTFUL','PUT','/api/instances/battery_electrolyte/{id}','更新电池电解液实例信息','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_cm_create','CREATE_OBJECT','createCathodeMaterial','RESTFUL','POST','/api/instances/cathode_material','创建新的正极材料实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_cm_delete','DELETE_OBJECT','deleteCathodeMaterial','RESTFUL','DELETE','/api/instances/cathode_material/{id}','删除正极材料实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_cm_update','UPDATE_OBJECT','updateCathodeMaterial','RESTFUL','PUT','/api/instances/cathode_material/{id}','更新正极材料实例信息','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_create_company_company_link','CREATE_LINK','createCompanyCompanyLink','RESTFUL','POST','/api/link-instances/lt_company_strategic_cooperation','创建公司与公司间的链接','2026-04-16 07:10:23','2026-04-16 12:15:35'),('rule_delete_company_company_link','DELETE_LINK','deleteCompanyCompanyLink','RESTFUL','DELETE','/api/link-instances/lt_company_strategic_cooperation','删除公司与公司间的链接','2026-04-16 07:10:23','2026-04-16 12:15:35'),('rule_lc_create','CREATE_OBJECT','createLithiumCarbonate','RESTFUL','POST','/api/instances/lithium_carbonate','创建新的碳酸锂实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_lc_delete','DELETE_OBJECT','deleteLithiumCarbonate','RESTFUL','DELETE','/api/instances/lithium_carbonate/{id}','删除碳酸锂实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_lc_update','UPDATE_OBJECT','updateLithiumCarbonate','RESTFUL','PUT','/api/instances/lithium_carbonate/{id}','更新碳酸锂实例信息','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_nev_create','CREATE_OBJECT','createNewEnergyVehicle','RESTFUL','POST','/api/instances/new_energy_vehicle','创建新的新能源整车实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_nev_delete','DELETE_OBJECT','deleteNewEnergyVehicle','RESTFUL','DELETE','/api/instances/new_energy_vehicle/{id}','删除新能源整车实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_nev_update','UPDATE_OBJECT','updateNewEnergyVehicle','RESTFUL','PUT','/api/instances/new_energy_vehicle/{id}','更新新能源整车实例信息','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_pb_create','CREATE_OBJECT','createPowerBattery','RESTFUL','POST','/api/instances/power_battery','创建新的动力电池实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_pb_delete','DELETE_OBJECT','deletePowerBattery','RESTFUL','DELETE','/api/instances/power_battery/{id}','删除动力电池实例记录','2026-04-11 16:56:03','2026-04-11 17:17:36'),('rule_pb_update','UPDATE_OBJECT','updatePowerBattery','RESTFUL','PUT','/api/instances/power_battery/{id}','更新动力电池实例信息','2026-04-11 16:56:03','2026-04-11 17:17:36');
/*!40000 ALTER TABLE `ontology_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `power_battery`
--

DROP TABLE IF EXISTS `power_battery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `power_battery` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `unique_id` varchar(100) NOT NULL COMMENT '电池的唯一标识符',
  `model` varchar(100) DEFAULT NULL COMMENT '电池型号',
  `capacity` decimal(10,2) DEFAULT NULL COMMENT '电池容量，单位通常为安时(Ah)或毫安时(mAh)',
  `voltage` decimal(10,2) DEFAULT NULL COMMENT '额定电压，单位伏特(V)',
  `chemistry` varchar(50) DEFAULT NULL COMMENT '电池化学类型，如锂离子、铅酸、镍氢等',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '制造商名称',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `price` decimal(10,2) DEFAULT NULL COMMENT '电池价格（单位：元）',
  `price_date` date DEFAULT NULL COMMENT '价格日期',
  PRIMARY KEY (`unique_id`),
  UNIQUE KEY `unique_id` (`unique_id`),
  KEY `idx_unique_id` (`unique_id`),
  KEY `idx_model` (`model`),
  KEY `idx_manufacturer` (`manufacturer`),
  KEY `idx_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='动力电池信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `power_battery`
--

LOCK TABLES `power_battery` WRITE;
/*!40000 ALTER TABLE `power_battery` DISABLE KEYS */;
INSERT INTO `power_battery` VALUES (1,'BT-CATL-001-2024','NCM811-150Ah',150.00,3.70,'锂离子','宁德时代','2024-01-15','2026-04-06 09:58:18','2026-04-08 15:00:47',85000.00,'2024-03-15'),(2,'BT-CATL-002-2024','NCM523-120Ah',120.00,3.65,'锂离子','宁德时代','2024-02-20','2026-04-06 09:58:18','2026-04-08 15:00:47',72000.00,'2024-03-15'),(3,'BT-CATL-003-2024','LFP-280Ah',280.00,3.20,'磷酸铁锂','宁德时代','2024-03-10','2026-04-06 09:58:18','2026-04-08 15:00:47',65000.00,'2024-03-15'),(4,'BYD-BLADE-001-24','刀片电池-135Ah',135.00,3.20,'磷酸铁锂','比亚迪','2024-01-08','2026-04-06 09:58:18','2026-04-08 15:00:47',68000.00,'2024-03-10'),(5,'BYD-BLADE-002-24','刀片电池-172Ah',172.00,3.20,'磷酸铁锂','比亚迪','2024-02-15','2026-04-06 09:58:18','2026-04-08 15:00:47',82000.00,'2024-03-10'),(13,'CALB-LFP-001-2024','LFP-230Ah',230.00,3.20,'磷酸铁锂','中创新航','2024-02-10','2026-04-06 09:58:18','2026-04-08 15:01:06',58000.00,'2024-03-11'),(12,'CALB-NCM-001-2024','NCM523-110Ah',110.00,3.65,'锂离子','中创新航','2024-01-25','2026-04-06 09:58:18','2026-04-08 15:01:06',70000.00,'2024-03-11'),(15,'EVE-LFP-001-2024','LFP-304Ah',304.00,3.20,'磷酸铁锂','亿纬锂能','2024-01-30','2026-04-06 09:58:18','2026-04-08 15:01:06',60000.00,'2024-03-13'),(14,'EVE-NCM-001-2024','NCM811-105Ah',105.00,3.70,'锂离子','亿纬锂能','2024-03-08','2026-04-06 09:58:18','2026-04-08 15:01:06',82000.00,'2024-03-13'),(17,'GOTION-LFP-001-24','LFP-210Ah',210.00,3.20,'磷酸铁锂','宁德时代','2024-03-20','2026-04-06 09:58:18','2026-04-15 08:46:53',55000.00,'2024-03-09'),(16,'GOTION-NCM-001-24','NCM523-90Ah',90.00,3.65,'锂离子','宁德时代','2024-02-25','2026-04-06 09:58:18','2026-04-15 08:46:58',66000.00,'2024-03-09'),(6,'LGES-NCM-001-24','NCM712-78Ah',78.00,3.70,'锂离子','LG新能源','2024-01-20','2026-04-06 09:58:18','2026-04-08 15:00:47',95000.00,'2024-03-12'),(7,'LGES-NCM-002-24','NCM622-60Ah',60.00,3.65,'锂离子','LG新能源','2024-02-28','2026-04-06 09:58:18','2026-04-08 15:00:47',78000.00,'2024-03-12'),(20,'PANASONIC-001-24','NCA-3400mAh',3.40,3.60,'镍钴铝','松下','2024-03-12','2026-04-06 09:58:18','2026-04-08 15:01:06',120000.00,'2024-03-07'),(19,'REPT-LFP-001-2024','LFP-280Ah',280.00,3.20,'磷酸铁锂','瑞浦兰钧','2024-02-22','2026-04-06 09:58:18','2026-04-08 15:01:06',59000.00,'2024-03-16'),(18,'REPT-NCM-001-2024','NCM622-115Ah',115.00,3.65,'锂离子','瑞浦兰钧','2024-01-18','2026-04-06 09:58:18','2026-04-08 15:01:06',71000.00,'2024-03-16'),(8,'SKI-NCM-001-2024','NCM811-88Ah',88.00,3.70,'锂离子','SK创新','2024-03-05','2026-04-06 09:58:18','2026-04-08 15:00:47',88000.00,'2024-03-08'),(9,'SKI-NCM-002-2024','NCM622-70Ah',70.00,3.65,'锂离子','SK创新','2024-01-12','2026-04-06 09:58:18','2026-04-08 15:00:47',75000.00,'2024-03-08'),(22,'SUNWODA-LFP-001-2024','LFP-210Ah',210.00,3.20,'磷酸铁锂','欣旺达','2024-03-06','2026-04-16 03:07:13','2026-04-16 03:07:13',62000.00,'2024-03-14'),(21,'SUNWODA-NCM-001-2024','NCM523-92Ah',92.00,3.65,'锂离子','欣旺达','2024-02-18','2026-04-16 03:07:13','2026-04-16 03:07:13',76000.00,'2024-03-14'),(11,'SVOLT-LFP-001-24','LFP-202Ah',202.00,3.20,'磷酸铁锂','蜂巢能源','2024-03-15','2026-04-06 09:58:18','2026-04-08 15:01:06',62000.00,'2024-03-14'),(10,'SVOLT-NCM-001-24','NCM811-95Ah',95.00,3.70,'锂离子','蜂巢能源','2024-02-18','2026-04-06 09:58:18','2026-04-08 15:00:47',80000.00,'2024-03-14');
/*!40000 ALTER TABLE `power_battery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `properties`
--

DROP TABLE IF EXISTS `properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `properties` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `object_type_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_primary_key` tinyint NOT NULL DEFAULT '0',
  `base_column` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `type_classes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `object_type_id` (`object_type_id`),
  CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`object_type_id`) REFERENCES `object_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `properties`
--

LOCK TABLES `properties` WRITE;
/*!40000 ALTER TABLE `properties` DISABLE KEYS */;
INSERT INTO `properties` VALUES ('p_ battery_cost_1775388584501','new_energy_vehicle','电池成本（单位：万元）','double',NULL,0,'battery_cost',NULL,0),('p_batterycapacity_1775385756098','new_energy_vehicle','电池容量（单位：kWh）','number',NULL,0,'battery_capacity',NULL,0),('p_brand_1775388584499','new_energy_vehicle','品牌','string',NULL,0,'brand',NULL,0),('p_capacity_1775469262904','power_battery','电池容量，单位通常为安时(Ah)或毫安时(mAh)','number',NULL,0,'capacity',NULL,0),('p_chemistry_1775469324420','power_battery','电池化学类型，如锂离子、铅酸、镍氢等','string',NULL,0,'chemistry',NULL,0),('p_company_id_demo','company_entity','公司唯一标识符','string','公司实例主键',1,'company_id',NULL,0),('p_company_industry_demo','company_entity','所属行业','string','所属行业',0,'industry',NULL,4),('p_company_market_demo','company_entity','上市市场','string','上市市场',0,'market',NULL,3),('p_company_name_demo','company_entity','公司名称','string','公司名称',0,'name',NULL,1),('p_company_stock_code_demo','company_entity','股票代码','string','股票代码',0,'stock_code',NULL,2),('p_electrolytetype_1775650736187','battery_electrolyte','电解液类型（如：液态、固态、凝胶、有机、无机等）\n','string',NULL,0,'electrolyte_type',NULL,0),('p_event_category_demo','event_entity','事件分类','string','事件分类',0,'category',NULL,4),('p_event_content_demo','event_entity','事件正文','string','事件正文',0,'content',NULL,3),('p_event_date_demo','event_entity','事件日期','date','事件发生日期',0,'event_date',NULL,6),('p_event_id_demo','event_entity','事件ID','string','事件主键',1,'id',NULL,0),('p_event_source_demo','event_entity','事件来源','string','事件来源',0,'source',NULL,5),('p_event_summary_demo','event_entity','事件摘要','string','事件摘要',0,'summary',NULL,2),('p_event_tags_demo','event_entity','事件标签','string','事件标签 JSON',0,'tags',NULL,7),('p_event_title_demo','event_entity','事件标题','string','事件标题',0,'title',NULL,1),('p_grade_1775652359942','lithium_carbonate','品级，如电池级、工业级、医药级','string',NULL,0,'grade',NULL,0),('p_id_1775469202509','power_battery','电池的唯一标识符','string',NULL,1,'unique_id',NULL,0),('p_id_1775650733670','battery_electrolyte','电解液唯一标识符','string',NULL,1,'unique_id',NULL,0),('p_id_1775651827534','battery_cell','电芯唯一标识符','string',NULL,1,'unique_id',NULL,0),('p_id_1775652265840','lithium_carbonate','唯一标识符，如产品编码或批次号','string',NULL,1,'unique_id',NULL,0),('p_initial_cost_1775388584500','new_energy_vehicle','初始成本（单位：万元）','double',NULL,0,'initial_cost',NULL,0),('p_initial_gross_margin_1775385756100','new_energy_vehicle','初始毛利率','double',NULL,0,'initial_gross_margin',NULL,0),('p_isavailable_1775385758165','new_energy_vehicle','是否在售','boolean',NULL,0,'is_available',NULL,0),('p_manufacturer_1775469343287','power_battery','制造商名称','string',NULL,0,'manufacturer',NULL,0),('p_manufacturer_1775651931268','battery_cell','生产厂家','string',NULL,0,'manufacturer',NULL,0),('p_manufacturer_1775652360925','lithium_carbonate','生产厂家或供应商名称','string',NULL,0,'manufacturer',NULL,0),('p_material_id_1775651402080','cathode_material','正极材料的唯一标识符','string',NULL,1,'material_id',NULL,0),('p_material_name_1775651404512','cathode_material','正极材料的名称','string',NULL,0,'material_name',NULL,0),('p_model_1775469226104','power_battery','电池型号','string',NULL,0,'model',NULL,0),('p_model_1775651928286','battery_cell','电芯型号','string',NULL,0,'model',NULL,0),('p_modelname_1775385755582','new_energy_vehicle','车型名称','string',NULL,0,'model_name',NULL,0),('p_name_1775650734536','battery_electrolyte','电解液名称或型号','string',NULL,0,'name',NULL,0),('p_price_1775385757615','new_energy_vehicle','指导价（单位：万元）','number',NULL,0,'price',NULL,0),('p_price_1775469202509','power_battery','价格','double',NULL,0,'price',NULL,0),('p_price_1775650733671','battery_electrolyte','价格（万元/吨）','double',NULL,0,'price',NULL,0),('p_price_1775651402081','cathode_material','价格（万元/吨）','double',NULL,0,'price',NULL,0),('p_price_1775651827535','battery_cell','价格（kwh）','double',NULL,0,'price',NULL,0),('p_price_1775652265840','lithium_carbonate','价格（万元/吨）','double',NULL,0,'price',NULL,0),('p_price_date_1775385756099','new_energy_vehicle','价格日期','date',NULL,0,'price_date',NULL,0),('p_price_date_1775469202510','power_battery','价格日期','date',NULL,0,'price_date',NULL,0),('p_price_date_1775650733672','battery_electrolyte','价格日期','date',NULL,0,'price_date',NULL,0),('p_price_date_1775651402082','cathode_material','价格日期','date',NULL,0,'price_date',NULL,0),('p_price_date_1775651827536','battery_cell','价格日期','date',NULL,0,'price_date',NULL,0),('p_price_date_1775652265842','lithium_carbonate','价格日期','date',NULL,0,'price_date',NULL,0),('p_productiondate_1775385756864','new_energy_vehicle','生产日期','date',NULL,0,'production_date',NULL,0),('p_productiondate_1775469378170','power_battery','生产日期','date',NULL,0,'production_date',NULL,0),('p_range_1775385756349','new_energy_vehicle','续航里程（单位：公里）','number',NULL,0,'range_km',NULL,0),('p_vehicleid_1775385754771','new_energy_vehicle','车辆唯一标识符（VIN码）','string',NULL,1,'vehicle_id',NULL,0),('p_vehicletype_1775385756547','new_energy_vehicle','车辆类型（如：纯电动BEV、插电混动PHEV、增程式EREV）','string',NULL,0,'vehicle_type',NULL,0),('p_voltage_1775469302687','power_battery','额定电压，单位伏特(V)','number',NULL,0,'voltage',NULL,0);
/*!40000 ALTER TABLE `properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relation_candidates`
--

DROP TABLE IF EXISTS `relation_candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `relation_candidates` (
  `id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `news_event_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_object_type_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_instance_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_object_type_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_instance_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_type_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `relation_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `evidence` text COLLATE utf8mb4_unicode_ci,
  `confidence` decimal(5,2) DEFAULT NULL,
  `llm_source` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'recognized',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_relation_candidates_news_event_id` (`news_event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation_candidates`
--

LOCK TABLES `relation_candidates` WRITE;
/*!40000 ALTER TABLE `relation_candidates` DISABLE KEYS */;
INSERT INTO `relation_candidates` VALUES ('cand_a083f8eb','news_catl_cet_001','company_entity','COMP_CATL','company_entity','COMP_CET','lt_company_strategic_cooperation','战略合作','宁德时代与中恒电气宣布围绕储能场景展开协同合作，包括储能系统集成、站端设备协同与项目拓展。',0.95,'deepseek','created','2026-04-15 22:59:37','2026-04-16 13:32:48');
/*!40000 ALTER TABLE `relation_candidates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `three_electric_system`
--

DROP TABLE IF EXISTS `three_electric_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `three_electric_system` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键ID',
  `system_name` varchar(100) DEFAULT NULL COMMENT '三电系统名称/型号',
  `motor_power` decimal(10,2) DEFAULT NULL COMMENT '电机功率（单位：kW）',
  `voltage_platform` varchar(50) DEFAULT NULL COMMENT '电压平台（如：400V、800V）',
  `charge_power` decimal(10,2) DEFAULT NULL COMMENT '充电功率（单位：kW）',
  `is_intelligent` tinyint(1) DEFAULT '0' COMMENT '是否具备智能能量管理功能',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_system_name` (`system_name`),
  KEY `idx_voltage_platform` (`voltage_platform`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='三电系统信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `three_electric_system`
--

LOCK TABLES `three_electric_system` WRITE;
/*!40000 ALTER TABLE `three_electric_system` DISABLE KEYS */;
INSERT INTO `three_electric_system` VALUES (1,'特斯拉 第四代电驱系统',220.00,'400V',170.00,1,'2024-01-15','2026-04-05 11:51:16','2026-04-05 11:51:16'),(2,'特斯拉 800V高压平台',350.00,'800V',350.00,1,'2024-02-20','2026-04-05 11:51:16','2026-04-05 11:51:16'),(3,'比亚迪 八合一电动力总成',150.00,'400V',120.00,1,'2024-03-10','2026-04-05 11:51:16','2026-04-05 11:51:16'),(4,'比亚迪 e平台3.0 Evo',230.00,'800V',300.00,1,'2024-01-08','2026-04-05 11:51:16','2026-04-05 11:51:16'),(5,'蔚来 第二代电驱系统',210.00,'400V',180.00,1,'2024-02-15','2026-04-05 11:51:16','2026-04-05 11:51:16'),(6,'蔚来 900V高压架构',480.00,'900V',600.00,1,'2024-03-22','2026-04-05 11:51:16','2026-04-05 11:51:16'),(7,'小鹏 800V XPower',218.00,'800V',330.00,1,'2024-01-20','2026-04-05 11:51:16','2026-04-05 11:51:16'),(8,'小鹏 后置油冷电机',316.00,'800V',400.00,1,'2024-02-28','2026-04-05 11:51:16','2026-04-05 11:51:16'),(9,'理想 增程电动系统',330.00,'400V',90.00,1,'2024-03-05','2026-04-05 11:51:16','2026-04-05 11:51:16'),(10,'理想 纯电高压平台',400.00,'800V',520.00,1,'2024-01-12','2026-04-05 11:51:16','2026-04-05 11:51:16'),(11,'广汽埃安 夸克电驱',165.00,'400V',100.00,0,'2024-02-18','2026-04-05 11:51:16','2026-04-05 11:51:16'),(12,'广汽埃安 弹匣电池2.0',250.00,'800V',480.00,1,'2024-03-15','2026-04-05 11:51:16','2026-04-05 11:51:16'),(13,'极氪 威睿电驱系统',200.00,'400V',150.00,1,'2024-01-25','2026-04-05 11:51:16','2026-04-05 11:51:16'),(14,'极氪 金砖电池系统',310.00,'800V',500.00,1,'2024-02-10','2026-04-05 11:51:16','2026-04-05 11:51:16'),(15,'华为 DriveONE 三合一',200.00,'400V',140.00,1,'2024-03-08','2026-04-05 11:51:16','2026-04-05 11:51:16'),(16,'华为 巨鲸高压平台',365.00,'800V',600.00,1,'2024-01-30','2026-04-05 11:51:16','2026-04-05 11:51:16'),(17,'长安 原力超集电驱',190.00,'400V',110.00,0,'2024-02-25','2026-04-05 11:51:16','2026-04-05 11:51:16'),(18,'长安 金钟罩电池',258.00,'800V',450.00,1,'2024-03-20','2026-04-05 11:51:16','2026-04-05 11:51:16'),(19,'吉利 雷神电混8848',160.00,'400V',85.00,1,'2024-01-18','2026-04-05 11:51:16','2026-04-05 11:51:16'),(20,'吉利 神盾短刀电池',200.00,'800V',350.00,1,'2024-02-22','2026-04-05 11:51:16','2026-04-05 11:51:16');
/*!40000 ALTER TABLE `three_electric_system` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-16 14:27:50
