package com.ontology.controller;

import com.ontology.entity.*;
import com.ontology.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ActionExecutionController {
    
    private final ActionExecutionMapper executionMapper;
    private final ActionTypeMapper actionTypeMapper;
    private final ActionRuleMapper ruleMapper;
    private final ActionRuleParamMapper ruleParamMapper;
    private final ActionEffectMapper effectMapper;
    private final NotificationMapper notificationMapper;
    private final OntologyRuleMapper ontologyRuleMapper;
    private final OntologyRuleParamMapper ontologyRuleParamMapper;
    private final FunctionTypeMapper functionTypeMapper;
    private final FunctionParamMapper functionParamMapper;
    private final ObjectTypeMapper objectTypeMapper;
    private final PropertyMapper propertyMapper;
    private final JdbcTemplate jdbcTemplate;
    private final RestTemplate restTemplate = new RestTemplate();
    
    @PostMapping("/action-types/{actionTypeId}/execute")
    @Transactional
    public Map<String, Object> execute(@PathVariable String actionTypeId, @RequestBody Map<String, Object> data) {
        ActionType actionType = actionTypeMapper.selectById(actionTypeId);
        if (actionType == null) {
            throw new RuntimeException("Action type not found");
        }
        
        @SuppressWarnings("unchecked")
        Map<String, Object> parameters = (Map<String, Object>) data.getOrDefault("parameters", new HashMap<>());
        String executedBy = (String) data.getOrDefault("executedBy", "user");
        String instanceId = (String) data.get("instanceId");
        
        // Get action rules and effects
        List<ActionRule> actionRules = ruleMapper.selectByActionTypeId(actionTypeId);
        // 加载每个规则的参数
        for (ActionRule rule : actionRules) {
            List<ActionRuleParam> params = ruleParamMapper.selectByActionRuleId(rule.getId());
            rule.setParams(params);
        }
        List<ActionEffect> actionEffects = effectMapper.selectByActionTypeId(actionTypeId);
        
        // Create execution record
        String executionId = "exec_" + UUID.randomUUID().toString().substring(0, 8);
        ActionExecution execution = new ActionExecution();
        execution.setId(executionId);
        execution.setActionTypeId(actionTypeId);
        execution.setTargetObjectId(instanceId);
        execution.setParameters(toJson(parameters));
        execution.setExecutedBy(executedBy);
        execution.setCreatedAt(LocalDateTime.now());
        
        // Execute action logic - process rules
        List<Map<String, Object>> executedRules = new ArrayList<>();
        boolean allSuccess = true;
        
        for (ActionRule rule : actionRules) {
            Map<String, Object> ruleResult = executeRule(rule, parameters, instanceId);
            executedRules.add(ruleResult);
            if (!"success".equals(ruleResult.get("status"))) {
                allSuccess = false;
            }
        }
        
        execution.setStatus(allSuccess ? "completed" : "failed");
        execution.setCompletedAt(LocalDateTime.now());
        
        // Build result
        Map<String, Object> result = new HashMap<>();
        result.put("executionId", executionId);
        result.put("status", allSuccess ? "completed" : "failed");
        result.put("result", Map.of(
            "actionTypeId", actionTypeId,
            "actionTypeName", actionType.getDisplayName(),
            "parameters", parameters,
            "executedAt", execution.getCreatedAt().toString(),
            "rules", executedRules
        ));
        
        // Process side effects only if all rules succeeded
        List<Map<String, Object>> sideEffects = new ArrayList<>();
        if (allSuccess) {
            for (ActionEffect effect : actionEffects) {
                if (effect.getIsEnabled() != null && effect.getIsEnabled() == 1) {
                    Map<String, Object> effectResult = executeEffect(effect, actionType, instanceId);
                    sideEffects.add(effectResult);
                }
            }
        }
        
        if (!sideEffects.isEmpty()) {
            result.put("sideEffects", sideEffects);
            execution.setSideEffects(toJson(sideEffects));
        }
        
        execution.setResult(toJson(result.get("result")));
        executionMapper.insert(execution);
        
        return result;
    }
    
    /**
     * 函数类型执行预览
     * POST /api/function-types/{functionTypeId}/execute
     */
    @PostMapping("/function-types/{functionTypeId}/execute")
    public Map<String, Object> executeFunctionTypePreview(
            @PathVariable String functionTypeId,
            @RequestBody Map<String, Object> parameters) {
        
        FunctionType functionType = functionTypeMapper.selectById(functionTypeId);
        if (functionType == null) {
            throw new RuntimeException("Function type not found: " + functionTypeId);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("functionTypeId", functionTypeId);
        result.put("functionName", functionType.getName());
        result.put("functionCode", functionType.getCode());
        result.put("parameters", parameters);
        
        // 执行函数类型
        Map<String, Object> execResult = executeFunctionType(functionType, parameters, null);
        result.put("status", execResult.get("status"));
        
        if ("success".equals(execResult.get("status"))) {
            result.put("response", execResult.get("response"));
        } else {
            result.put("error", execResult.get("error"));
        }
        
        return result;
    }
    
    private Map<String, Object> executeRule(ActionRule rule, Map<String, Object> parameters, String instanceId) {
        Map<String, Object> result = new HashMap<>();
        result.put("ruleId", rule.getId());
        result.put("ruleType", rule.getRuleType());
        
        if ("ONTOLOGY".equals(rule.getRuleType())) {
            result.put("ontologyRuleId", rule.getOntologyRuleId());
            
            // 查询本体规则配置
            OntologyRule ontologyRule = ontologyRuleMapper.selectById(rule.getOntologyRuleId());
            if (ontologyRule == null) {
                result.put("status", "failed");
                result.put("error", "Ontology rule not found");
                return result;
            }
            
            // 执行本体规则
            Map<String, Object> execResult = executeOntologyRule(ontologyRule, parameters, rule.getParams());
            result.putAll(execResult);
            
        } else if ("OTHER".equals(rule.getRuleType())) {
            result.put("functionTypeId", rule.getFunctionTypeId());
            
            // 查询函数类型配置
            FunctionType functionType = functionTypeMapper.selectById(rule.getFunctionTypeId());
            if (functionType == null) {
                result.put("status", "failed");
                result.put("error", "Function type not found");
                return result;
            }
            
            // 执行函数类型
            Map<String, Object> execResult = executeFunctionType(functionType, parameters, rule.getParams());
            result.putAll(execResult);
        }
        
        return result;
    }
    
    private Map<String, Object> executeOntologyRule(OntologyRule rule, Map<String, Object> parameters, List<ActionRuleParam> ruleParams) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            String ruleCategory = rule.getRuleCategory();
            Map<String, String> ruleParamDefaults = buildRuleParamDefaults(ruleParams);

            if ("CREATE_LINK".equals(ruleCategory) || "DELETE_LINK".equals(ruleCategory)) {
                return executeOntologyLinkRule(rule, parameters, ruleParamDefaults);
            }

            // 从 interfaceUrl 中提取对象类型ID
            String objectTypeId = extractObjectTypeId(rule.getInterfaceUrl());
            if (objectTypeId == null) {
                result.put("status", "failed");
                result.put("error", "Invalid object rule URL: " + rule.getInterfaceUrl());
                return result;
            }

            // 查询对象类型
            ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
            if (objectType == null) {
                result.put("status", "failed");
                result.put("error", "Object type not found: " + objectTypeId);
                return result;
            }

            String tableName = objectType.getBackingDataset();
            List<Property> properties = propertyMapper.selectByObjectTypeId(objectTypeId);
            List<OntologyRuleParam> inputParams = ontologyRuleParamMapper.selectInputParamsByRuleId(rule.getId());

            // 构建属性映射
            Map<String, Property> propertyById = new HashMap<>();
            Map<String, Property> propertyByColumn = new HashMap<>();
            for (Property prop : properties) {
                if (prop.getId() != null && !prop.getId().isEmpty()) {
                    propertyById.put(prop.getId(), prop);
                }
                if (prop.getBaseColumn() != null && !prop.getBaseColumn().isEmpty()) {
                    propertyByColumn.put(prop.getBaseColumn(), prop);
                }
            }

            // 构建插入数据
            Map<String, Object> insertData = new HashMap<>();

            // 优先按本体规则定义的入参消费本次请求；action_rule_params 仅作为默认值兜底
            if (inputParams != null && !inputParams.isEmpty()) {
                for (OntologyRuleParam inputParam : inputParams) {
                    String paramName = inputParam.getParamName();
                    if (paramName == null || paramName.isEmpty()) continue;
                    Object value = resolveOntologyParameterValue(paramName, parameters, ruleParamDefaults, propertyById, propertyByColumn);
                    if (value != null) {
                        putOntologyInsertValue(insertData, paramName, value, propertyById, propertyByColumn);
                    }
                }
            } else {
                // 没有定义输入参数时，直接消费本次执行提交的参数
                for (Map.Entry<String, Object> entry : parameters.entrySet()) {
                    if (entry.getValue() == null) continue;
                    if ("instanceId".equals(entry.getKey()) || "id".equals(entry.getKey())) continue;
                    putOntologyInsertValue(insertData, entry.getKey(), entry.getValue(), propertyById, propertyByColumn);
                }
            }

            // 对于本次没有传入、但规则表里有默认值的参数，再补一次兜底
            for (Map.Entry<String, String> entry : ruleParamDefaults.entrySet()) {
                if (entry.getValue() == null) continue;
                putOntologyInsertValueIfAbsent(insertData, entry.getKey(), entry.getValue(), propertyById, propertyByColumn);
            }

            // 根据规则类别执行不同操作
            if ("CREATE_OBJECT".equals(ruleCategory)) {
                // 创建实例
                List<String> columns = new ArrayList<>();
                List<String> placeholders = new ArrayList<>();
                List<Object> values = new ArrayList<>();
                
                for (Property prop : properties) {
                    if (prop.getBaseColumn() != null && !prop.getBaseColumn().isEmpty()) {
                        Object value = insertData.get(prop.getId());
                        if (value != null) {
                            columns.add("`" + prop.getBaseColumn() + "`");
                            placeholders.add("?");
                            values.add(value);
                        }
                    }
                }
                
                // 添加时间戳
                columns.add("`created_at`");
                placeholders.add("?");
                values.add(LocalDateTime.now());
                columns.add("`updated_at`");
                placeholders.add("?");
                values.add(LocalDateTime.now());
                
                String sql = String.format("INSERT INTO `%s` (%s) VALUES (%s)", 
                        tableName, 
                        String.join(", ", columns), 
                        String.join(", ", placeholders));
                
                jdbcTemplate.update(sql, values.toArray());
                
                result.put("status", "success");
                result.put("message", "Instance created successfully");
                
            } else if ("UPDATE_OBJECT".equals(ruleCategory)) {
                Property pkProp = findPrimaryKeyProperty(properties);
                if (pkProp == null || pkProp.getBaseColumn() == null || pkProp.getBaseColumn().isEmpty()) {
                    result.put("status", "failed");
                    result.put("error", "No primary key property found");
                    return result;
                }

                Object targetInstanceId = firstNonBlank(
                        stringValue(parameters.get("instanceId")),
                        stringValue(parameters.get("id")),
                        ruleParamDefaults.get("instanceId")
                );
                if (targetInstanceId == null) {
                    result.put("status", "failed");
                    result.put("error", "instanceId is required");
                    return result;
                }

                List<String> setClauses = new ArrayList<>();
                List<Object> values = new ArrayList<>();
                for (Property prop : properties) {
                    if (prop.getBaseColumn() == null || prop.getBaseColumn().isEmpty()) continue;
                    if (prop.getIsPrimaryKey() != null && prop.getIsPrimaryKey() == 1) continue;
                    Object value = insertData.get(prop.getId());
                    if (value != null) {
                        setClauses.add("`" + prop.getBaseColumn() + "` = ?");
                        values.add(value);
                    }
                }
                setClauses.add("`updated_at` = ?");
                values.add(LocalDateTime.now());
                values.add(targetInstanceId);

                String sql = String.format("UPDATE `%s` SET %s WHERE `%s` = ?",
                        tableName,
                        String.join(", ", setClauses),
                        pkProp.getBaseColumn());
                int rows = jdbcTemplate.update(sql, values.toArray());
                result.put("status", rows > 0 ? "success" : "failed");
                result.put("message", rows > 0 ? "Instance updated successfully" : "Instance not found");
            } else if ("DELETE_OBJECT".equals(ruleCategory)) {
                Property pkProp = findPrimaryKeyProperty(properties);
                if (pkProp == null || pkProp.getBaseColumn() == null || pkProp.getBaseColumn().isEmpty()) {
                    result.put("status", "failed");
                    result.put("error", "No primary key property found");
                    return result;
                }

                Object targetInstanceId = firstNonBlank(
                        stringValue(parameters.get("instanceId")),
                        stringValue(parameters.get("id")),
                        ruleParamDefaults.get("instanceId")
                );
                if (targetInstanceId == null) {
                    result.put("status", "failed");
                    result.put("error", "instanceId is required");
                    return result;
                }

                String sql = String.format("DELETE FROM `%s` WHERE `%s` = ?", tableName, pkProp.getBaseColumn());
                int rows = jdbcTemplate.update(sql, targetInstanceId);
                result.put("status", rows > 0 ? "success" : "failed");
                result.put("message", rows > 0 ? "Instance deleted successfully" : "Instance not found");
            } else {
                result.put("status", "failed");
                result.put("error", "Rule category not supported: " + ruleCategory);
            }
            
        } catch (Exception e) {
            result.put("status", "failed");
            result.put("error", e.getMessage());
        }
        
        return result;
    }
    
    private Map<String, Object> executeFunctionType(FunctionType functionType, Map<String, Object> parameters, List<ActionRuleParam> ruleParams) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 构建请求参数
            Map<String, Object> requestBody = new HashMap<>();
            List<FunctionParam> functionInputParams = functionParamMapper.selectByFunctionIdAndDirection(functionType.getId(), "INPUT");
            Map<String, String> ruleParamDefaults = buildRuleParamDefaults(ruleParams);
            
            // 优先用本次请求参数；ruleParams 与函数默认值仅作兜底
            if (functionInputParams != null && !functionInputParams.isEmpty()) {
                for (FunctionParam param : functionInputParams) {
                    String requestKey = (param.getParamCode() != null && !param.getParamCode().isEmpty())
                            ? param.getParamCode()
                            : param.getParamName();
                    if (requestKey == null || requestKey.isEmpty()) continue;
                    Object value = resolveFunctionParameterValue(requestKey, param.getParamName(), parameters, ruleParamDefaults, param.getDefaultValue());
                    if (value != null) {
                        requestBody.put(requestKey, value);
                    }
                }
            } else {
                requestBody.putAll(parameters);
            }

            // 如果函数入参中没有覆盖到，但本次请求里额外传了参数，也一并透传
            for (Map.Entry<String, Object> entry : parameters.entrySet()) {
                if (!requestBody.containsKey(entry.getKey()) && entry.getValue() != null) {
                    requestBody.put(entry.getKey(), entry.getValue());
                }
            }
            
            // 调用函数类型接口
            String url = "http://localhost:8080" + functionType.getInterfaceUrl();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(org.springframework.http.MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            
            ResponseEntity<Map> response;
            String method = functionType.getRequestMethod() != null ? functionType.getRequestMethod().toUpperCase() : "POST";
            
            switch (method) {
                case "GET":
                    response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
                    break;
                case "PUT":
                    response = restTemplate.exchange(url, HttpMethod.PUT, entity, Map.class);
                    break;
                case "DELETE":
                    response = restTemplate.exchange(url, HttpMethod.DELETE, entity, Map.class);
                    break;
                default:
                    response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);
            }
            
            if (response.getStatusCode().is2xxSuccessful()) {
                result.put("status", "success");
                result.put("response", response.getBody());
            } else {
                result.put("status", "failed");
                result.put("error", "HTTP " + response.getStatusCode());
            }
            
        } catch (Exception e) {
            result.put("status", "failed");
            result.put("error", e.getMessage());
        }
        
        return result;
    }

    private Map<String, String> buildRuleParamDefaults(List<ActionRuleParam> ruleParams) {
        Map<String, String> defaults = new HashMap<>();
        if (ruleParams == null) return defaults;
        for (ActionRuleParam param : ruleParams) {
            if (param.getParamName() == null || param.getParamName().isEmpty()) continue;
            defaults.put(param.getParamName(), param.getParamValue());
        }
        return defaults;
    }

    private Object resolveOntologyParameterValue(
            String paramName,
            Map<String, Object> parameters,
            Map<String, String> ruleParamDefaults,
            Map<String, Property> propertyById,
            Map<String, Property> propertyByColumn) {
        if (parameters.containsKey(paramName)) {
            Object value = normalizeExecutionValue(parameters.get(paramName));
            if (value != null) return value;
        }
        Property byId = propertyById.get(paramName);
        if (byId != null && byId.getBaseColumn() != null) {
            Object value = normalizeExecutionValue(parameters.get(byId.getBaseColumn()));
            if (value != null) return value;
        }
        Property byColumn = propertyByColumn.get(paramName);
        if (byColumn != null && byColumn.getId() != null) {
            Object value = normalizeExecutionValue(parameters.get(byColumn.getId()));
            if (value != null) return value;
        }
        return normalizeExecutionValue(ruleParamDefaults.get(paramName));
    }

    private void putOntologyInsertValue(
            Map<String, Object> insertData,
            String paramName,
            Object value,
            Map<String, Property> propertyById,
            Map<String, Property> propertyByColumn) {
        if (value == null) return;
        value = normalizeExecutionValue(value);
        if (value == null) return;
        Property property = propertyById.get(paramName);
        if (property == null) {
            property = propertyByColumn.get(paramName);
        }
        if (property != null && property.getId() != null) {
            insertData.put(property.getId(), value.toString());
        } else {
            insertData.put(paramName, value.toString());
        }
    }

    private void putOntologyInsertValueIfAbsent(
            Map<String, Object> insertData,
            String paramName,
            Object value,
            Map<String, Property> propertyById,
            Map<String, Property> propertyByColumn) {
        Property property = propertyById.get(paramName);
        if (property == null) {
            property = propertyByColumn.get(paramName);
        }
        String targetKey = property != null && property.getId() != null ? property.getId() : paramName;
        Object normalized = normalizeExecutionValue(value);
        if (!insertData.containsKey(targetKey) && normalized != null) {
            insertData.put(targetKey, normalized.toString());
        }
    }

    private Object resolveFunctionParameterValue(
            String requestKey,
            String paramName,
            Map<String, Object> parameters,
            Map<String, String> ruleParamDefaults,
            String functionDefaultValue) {
        if (parameters.containsKey(requestKey)) {
            Object value = normalizeExecutionValue(parameters.get(requestKey));
            if (value != null) return value;
        }
        if (paramName != null && parameters.containsKey(paramName)) {
            Object value = normalizeExecutionValue(parameters.get(paramName));
            if (value != null) return value;
        }
        if (ruleParamDefaults.containsKey(requestKey)) {
            Object value = normalizeExecutionValue(ruleParamDefaults.get(requestKey));
            if (value != null) return value;
        }
        if (paramName != null && ruleParamDefaults.containsKey(paramName)) {
            Object value = normalizeExecutionValue(ruleParamDefaults.get(paramName));
            if (value != null) return value;
        }
        return normalizeExecutionValue(functionDefaultValue);
    }

    private Map<String, Object> executeOntologyLinkRule(
            OntologyRule rule,
            Map<String, Object> parameters,
            Map<String, String> ruleParamDefaults) {
        Map<String, Object> result = new HashMap<>();

        String linkTypeId = firstNonBlank(
                stringValue(parameters.get("linkTypeId")),
                stringValue(ruleParamDefaults.get("linkTypeId")),
                extractTailSegment(rule.getInterfaceUrl())
        );
        String sourceInstanceId = firstNonBlank(
                stringValue(parameters.get("sourceInstanceId")),
                stringValue(ruleParamDefaults.get("sourceInstanceId"))
        );
        String targetInstanceId = firstNonBlank(
                stringValue(parameters.get("targetInstanceId")),
                stringValue(ruleParamDefaults.get("targetInstanceId"))
        );

        if (linkTypeId == null || sourceInstanceId == null || targetInstanceId == null) {
            result.put("status", "failed");
            result.put("error", "linkTypeId, sourceInstanceId and targetInstanceId are required");
            return result;
        }

        Map<String, Object> linkType = fetchLinkTypeMeta(linkTypeId);
        if (linkType == null) {
            result.put("status", "failed");
            result.put("error", "Link type not found: " + linkTypeId);
            return result;
        }

        String sourceTable = stringValue(linkType.get("source_table"));
        String targetTable = stringValue(linkType.get("target_table"));
        String sourceColumn = stringValue(linkType.get("source_column"));
        String targetColumn = stringValue(linkType.get("target_column"));
        boolean sameTypeRelation = Objects.equals(linkType.get("source_object_id"), linkType.get("target_object_id"));

        validateLinkEndpointExists(sourceTable, sourceColumn, sourceInstanceId, "Source instance not found");
        validateLinkEndpointExists(targetTable, targetColumn, targetInstanceId, "Target instance not found");

        if ("CREATE_LINK".equals(rule.getRuleCategory())) {
            Map<String, Object> existingLink = findExistingLink(linkTypeId, sourceInstanceId, targetInstanceId, sameTypeRelation);
            if (existingLink == null) {
                jdbcTemplate.update(
                        "INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at) VALUES (?, ?, ?, ?)",
                        linkTypeId,
                        sourceInstanceId,
                        targetInstanceId,
                        LocalDateTime.now()
                );
            }

            result.put("status", "success");
            result.put("message", existingLink == null ? "Link created successfully" : "Link already exists");
            result.put("linkExists", true);
            result.put("data", Map.of(
                    "linkTypeId", linkTypeId,
                    "sourceInstanceId", sourceInstanceId,
                    "targetInstanceId", targetInstanceId
            ));
            return result;
        }

        if ("DELETE_LINK".equals(rule.getRuleCategory())) {
            Map<String, Object> existingLink = findExistingLink(linkTypeId, sourceInstanceId, targetInstanceId, sameTypeRelation);
            if (existingLink != null) {
                jdbcTemplate.update("DELETE FROM link_instance_data WHERE id = ?", existingLink.get("id"));
            }

            result.put("status", "success");
            result.put("message", existingLink == null ? "Link not found" : "Link deleted successfully");
            result.put("linkExists", false);
            result.put("data", Map.of(
                    "linkTypeId", linkTypeId,
                    "sourceInstanceId", sourceInstanceId,
                    "targetInstanceId", targetInstanceId
            ));
            return result;
        }

        result.put("status", "failed");
        result.put("error", "Unsupported ontology link rule: " + rule.getRuleCategory());
        return result;
    }

    private Map<String, Object> fetchLinkTypeMeta(String linkTypeId) {
        String sql = """
                SELECT lt.id, lt.name, lt.source_object_id, lt.target_object_id,
                       lt.source_column, lt.target_column,
                       sot.backing_dataset AS source_table,
                       tot.backing_dataset AS target_table
                FROM link_types lt
                JOIN object_types sot ON sot.id = lt.source_object_id
                JOIN object_types tot ON tot.id = lt.target_object_id
                WHERE lt.id = ?
                LIMIT 1
                """;
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, linkTypeId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    private String extractObjectTypeId(String interfaceUrl) {
        String normalized = stringValue(interfaceUrl);
        if (normalized == null) return null;
        String prefix = "/api/instances/";
        int index = normalized.indexOf(prefix);
        if (index < 0) return null;
        String tail = normalized.substring(index + prefix.length());
        int slash = tail.indexOf("/");
        if (slash >= 0) {
            tail = tail.substring(0, slash);
        }
        return tail.isEmpty() || tail.contains("{") ? null : tail;
    }

    private Property findPrimaryKeyProperty(List<Property> properties) {
        if (properties == null || properties.isEmpty()) return null;
        return properties.stream()
                .filter(p -> p.getIsPrimaryKey() != null && p.getIsPrimaryKey() == 1)
                .findFirst()
                .orElse(properties.get(0));
    }

    private void validateLinkEndpointExists(String tableName, String columnName, String instanceId, String errorMessage) {
        Integer count = jdbcTemplate.queryForObject(
                String.format("SELECT COUNT(*) FROM `%s` WHERE `%s` = ?", tableName, columnName),
                Integer.class,
                instanceId
        );
        if (count == null || count == 0) {
            throw new RuntimeException(errorMessage + ": " + instanceId);
        }
    }

    private Map<String, Object> findExistingLink(String linkTypeId, String sourceInstanceId, String targetInstanceId, boolean sameTypeRelation) {
        String sql = """
                SELECT * FROM link_instance_data
                WHERE link_type_id = ?
                  AND (
                    (source_instance_id = ? AND target_instance_id = ?)
                    OR (? = 1 AND source_instance_id = ? AND target_instance_id = ?)
                  )
                ORDER BY id ASC
                LIMIT 1
                """;
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                sql,
                linkTypeId,
                sourceInstanceId,
                targetInstanceId,
                sameTypeRelation,
                targetInstanceId,
                sourceInstanceId
        );
        return rows.isEmpty() ? null : rows.get(0);
    }

    private String extractTailSegment(String value) {
        String normalized = stringValue(value);
        if (normalized == null || !normalized.contains("/")) return normalized;
        return normalized.substring(normalized.lastIndexOf("/") + 1);
    }

    private String firstNonBlank(String... values) {
        if (values == null) return null;
        for (String value : values) {
            String normalized = stringValue(value);
            if (normalized != null) return normalized;
        }
        return null;
    }

    private String stringValue(Object value) {
        Object normalized = normalizeExecutionValue(value);
        return normalized == null ? null : String.valueOf(normalized);
    }

    private Object normalizeExecutionValue(Object value) {
        if (value == null) return null;
        if (value instanceof String) {
            String trimmed = ((String) value).trim();
            return trimmed.isEmpty() ? null : trimmed;
        }
        return value;
    }
    
    private Map<String, Object> executeEffect(ActionEffect effect, ActionType actionType, String instanceId) {
        Map<String, Object> result = new HashMap<>();
        result.put("effectType", effect.getEffectType());
        result.put("status", "executed");
        
        if ("NOTIFICATION".equals(effect.getEffectType())) {
            // 创建站内通知
            Notification notification = new Notification();
            notification.setId("notif_" + System.currentTimeMillis());
            notification.setTitle("动作类型执行成功");
            notification.setContent(effect.getContent() != null ? effect.getContent() : "完成" + instanceId + "的操作");
            notification.setType("EXECUTION");
            notification.setStatus("UNREAD");
            notification.setRelatedObjectType("action_type");
            notification.setRelatedObjectId(actionType.getId());
            notification.setCreatedAt(LocalDateTime.now());
            notificationMapper.insert(notification);
            
            result.put("notificationId", notification.getId());
        } else if ("LINGKE".equals(effect.getEffectType())) {
            result.put("status", "not_implemented");
            result.put("message", "铃客消息推送暂未实现");
        } else if ("EMAIL".equals(effect.getEffectType())) {
            result.put("status", "not_implemented");
            result.put("message", "邮件推送暂未实现");
        }
        
        return result;
    }
    
    @GetMapping("/action-types/{actionTypeId}/executions")
    public Map<String, Object> getExecutions(@PathVariable String actionTypeId) {
        List<ActionExecution> executions = executionMapper.selectByActionTypeId(actionTypeId);
        return Map.of("executions", executions);
    }
    
    @GetMapping("/action-executions")
    public Map<String, Object> getAllExecutions() {
        List<ActionExecution> executions = executionMapper.selectAllOrdered();
        return Map.of("executions", executions);
    }
    
    private String toJson(Object obj) {
        if (obj == null) {
            return null;
        }
        return obj.toString();
    }
}
