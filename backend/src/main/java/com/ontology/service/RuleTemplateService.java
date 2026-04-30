package com.ontology.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ontology.entity.*;
import com.ontology.mapper.*;
import com.ontology.project.ProjectScope;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RuleTemplateService {

    private final OntologyRuleMapper ontologyRuleMapper;
    private final OntologyRuleParamMapper ontologyRuleParamMapper;
    private final ActionTypeMapper actionTypeMapper;
    private final ActionRuleMapper actionRuleMapper;
    private final ActionRuleParamMapper actionRuleParamMapper;
    private final ActionEffectMapper actionEffectMapper;
    private final PropertyMapper propertyMapper;
    private final ObjectTypeMapper objectTypeMapper;
    private final LinkTypeMapper linkTypeMapper;

    @Transactional
    public void syncAllRules() {
        ontologyRuleParamMapper.deleteOrphanParams();
        actionRuleParamMapper.deleteBlankValues();
        for (ObjectType objectType : objectTypeMapper.selectAllOrdered()) {
            ensureObjectTypeRules(objectType);
        }
        for (LinkType linkType : linkTypeMapper.selectAllOrdered()) {
            ensureLinkTypeRules(linkType);
        }
        actionRuleParamMapper.deleteInvalidOntologyBindings();
    }

    @Transactional
    public void ensureObjectTypeRules(ObjectType objectType) {
        if (objectType == null || isBlank(objectType.getId())) return;

        ensureObjectOperation(objectType, "create", "CREATE_OBJECT", "POST",
                "/api/instances/" + objectType.getId(),
                "创建" + displayName(objectType) + "实例",
                "创建新的" + displayName(objectType) + "实例记录");
        ensureObjectOperation(objectType, "update", "UPDATE_OBJECT", "PUT",
                "/api/instances/" + objectType.getId() + "/{id}",
                "更新" + displayName(objectType) + "实例",
                "更新" + displayName(objectType) + "实例信息");
        ensureObjectOperation(objectType, "delete", "DELETE_OBJECT", "DELETE",
                "/api/instances/" + objectType.getId() + "/{id}",
                "删除" + displayName(objectType) + "实例",
                "删除" + displayName(objectType) + "实例记录");
    }

    @Transactional
    public void ensureLinkTypeRules(LinkType linkType) {
        if (linkType == null || isBlank(linkType.getId())) return;

        ensureLinkOperation(linkType, "create", "CREATE_LINK", "POST",
                "创建" + displayName(linkType) + "链接",
                "创建" + displayName(linkType) + "链接实例");
        ensureLinkOperation(linkType, "delete", "DELETE_LINK", "DELETE",
                "删除" + displayName(linkType) + "链接",
                "删除" + displayName(linkType) + "链接实例");
    }

    @Transactional
    public void disableObjectTypeActions(String objectTypeId) {
        disableAction(actionId(objectTypeId, "create"));
        disableAction(actionId(objectTypeId, "update"));
        disableAction(actionId(objectTypeId, "delete"));
    }

    @Transactional
    public void deleteObjectTypeRuleArtifacts(String objectTypeId) {
        deleteObjectOperationArtifacts(objectTypeId, "create", "CREATE_OBJECT", "/api/instances/" + objectTypeId);
        deleteObjectOperationArtifacts(objectTypeId, "update", "UPDATE_OBJECT", "/api/instances/" + objectTypeId + "/{id}");
        deleteObjectOperationArtifacts(objectTypeId, "delete", "DELETE_OBJECT", "/api/instances/" + objectTypeId + "/{id}");
    }

    @Transactional
    public void disableLinkTypeActions(String linkTypeId) {
        disableAction(actionId(linkTypeId, "create"));
        disableAction(actionId(linkTypeId, "delete"));
    }

    @Transactional
    public void deleteLinkTypeRuleArtifacts(String linkTypeId) {
        deleteLinkOperationArtifacts(linkTypeId, "create", "CREATE_LINK", "/api/link-instances/" + linkTypeId);
        deleteLinkOperationArtifacts(linkTypeId, "delete", "DELETE_LINK", "/api/link-instances/" + linkTypeId);
    }

    private void deleteObjectOperationArtifacts(String objectTypeId, String operation, String category, String url) {
        String actionTypeId = actionId(objectTypeId, operation);
        actionRuleParamMapper.deleteByActionTypeId(actionTypeId);
        actionEffectMapper.deleteByActionTypeId(actionTypeId);
        actionRuleMapper.deleteByActionTypeId(actionTypeId);
        actionTypeMapper.deleteById(actionTypeId);

        String ontologyRuleId = firstNonBlank(findRuleId(category, url, resolveProjectIdForObjectType(objectTypeId)), ruleId(objectTypeId, operation));
        ontologyRuleParamMapper.deleteByRuleId(ontologyRuleId);
        ontologyRuleMapper.deleteById(ontologyRuleId);
    }

    private void deleteLinkOperationArtifacts(String linkTypeId, String operation, String category, String url) {
        String actionTypeId = actionId(linkTypeId, operation);
        actionRuleParamMapper.deleteByActionTypeId(actionTypeId);
        actionEffectMapper.deleteByActionTypeId(actionTypeId);
        actionRuleMapper.deleteByActionTypeId(actionTypeId);
        actionTypeMapper.deleteById(actionTypeId);

        String ontologyRuleId = firstNonBlank(findRuleId(category, url, resolveProjectIdForLinkType(linkTypeId)), ruleId(linkTypeId, operation));
        ontologyRuleParamMapper.deleteByRuleId(ontologyRuleId);
        ontologyRuleMapper.deleteById(ontologyRuleId);
    }

    private void ensureObjectOperation(
            ObjectType objectType,
            String operation,
            String category,
            String method,
            String url,
            String actionName,
            String description) {
        String ruleId = ruleId(objectType.getId(), operation);
        ruleId = firstNonBlank(findRuleId(category, url, objectType.getProjectId()), ruleId);
        ensureRule(ruleId, category, functionName(operation, objectType.getId()), method, url, description, objectType.getProjectId());
        replaceParams(ruleId, buildObjectParams(ruleId, objectType.getId(), operation, objectType.getProjectId()));
        ensureActionBinding(actionId(objectType.getId(), operation), actionName, description, ruleId, category, objectType.getProjectId());
    }

    private void ensureLinkOperation(
            LinkType linkType,
            String operation,
            String category,
            String method,
            String actionName,
            String description) {
        String ruleId = ruleId(linkType.getId(), operation);
        ruleId = firstNonBlank(findRuleId(category, "/api/link-instances/" + linkType.getId(), linkType.getProjectId()), ruleId);
        ensureRule(ruleId, category, functionName(operation, linkType.getId()), method,
                "/api/link-instances/" + linkType.getId(), description, linkType.getProjectId());
        replaceParams(ruleId, buildLinkParams(ruleId, operation, linkType.getProjectId()));
        ensureActionBinding(actionId(linkType.getId(), operation), actionName, description, ruleId, category, linkType.getProjectId());
        ensureLinkTypeDefaultParam(actionRuleId(actionId(linkType.getId(), operation)), linkType.getId(), linkType.getProjectId());
    }

    private void ensureRule(String id, String category, String functionName, String method, String url, String description, String projectId) {
        OntologyRule rule = ontologyRuleMapper.selectById(id);
        LocalDateTime now = LocalDateTime.now();
        if (rule == null) {
            rule = new OntologyRule();
            rule.setId(id);
            rule.setCreatedAt(now);
        }
        rule.setRuleCategory(category);
        rule.setFunctionName(functionName);
        rule.setInterfaceType("RESTFUL");
        rule.setRequestMethod(method);
        rule.setInterfaceUrl(url);
        rule.setFunctionDescription(description);
        rule.setProjectId(projectId);
        rule.setUpdatedAt(now);

        if (ontologyRuleMapper.selectById(id) == null) {
            ontologyRuleMapper.insert(rule);
        } else {
            ontologyRuleMapper.updateById(rule);
        }
    }

    private String findRuleId(String category, String url, String projectId) {
        List<OntologyRule> rules = ontologyRuleMapper.selectList(
                new LambdaQueryWrapper<OntologyRule>()
                        .eq(OntologyRule::getRuleCategory, category)
                        .eq(OntologyRule::getInterfaceUrl, url)
                        .eq(OntologyRule::getProjectId, projectId)
                        .orderByAsc(OntologyRule::getCreatedAt)
        );
        return rules.isEmpty() ? null : rules.get(0).getId();
    }

    private void ensureActionBinding(String actionId, String displayName, String description, String ruleId, String category, String projectId) {
        ActionType action = actionTypeMapper.selectById(actionId);
        LocalDateTime now = LocalDateTime.now();
        if (action == null) {
            action = new ActionType();
            action.setId(actionId);
            action.setCreatedAt(now);
        }
        action.setDisplayName(displayName);
        action.setDescription(description);
        action.setStatus("ACTIVE");
        action.setProjectId(projectId);
        action.setUpdatedAt(now);

        if (actionTypeMapper.selectById(actionId) == null) {
            actionTypeMapper.insert(action);
        } else {
            actionTypeMapper.updateById(action);
        }

        String actionRuleId = actionRuleId(actionId);
        ActionRule actionRule = actionRuleMapper.selectById(actionRuleId);
        if (actionRule == null) {
            actionRule = new ActionRule();
            actionRule.setId(actionRuleId);
            actionRule.setCreatedAt(now);
        }
        actionRule.setActionTypeId(actionId);
        actionRule.setRuleType("ONTOLOGY");
        actionRule.setOntologyRuleCategory(category);
        actionRule.setOntologyRuleId(ruleId);
        actionRule.setFunctionTypeId(null);
        actionRule.setSortOrder(0);
        actionRule.setProjectId(projectId);

        if (actionRuleMapper.selectById(actionRuleId) == null) {
            actionRuleMapper.insert(actionRule);
        } else {
            actionRuleMapper.updateById(actionRule);
        }
    }

    private void replaceParams(String ruleId, List<OntologyRuleParam> params) {
        ontologyRuleParamMapper.deleteByRuleId(ruleId);
        for (OntologyRuleParam param : params) {
            ontologyRuleParamMapper.deleteById(param.getId());
            ontologyRuleParamMapper.insert(param);
        }
    }

    private List<OntologyRuleParam> buildObjectParams(String ruleId, String objectTypeId, String operation, String projectId) {
        List<OntologyRuleParam> params = new ArrayList<>();
        int sort = 0;

        if ("update".equals(operation) || "delete".equals(operation)) {
            params.add(inputParam(ruleId, sort++, "instanceId", "string", 1, "实例ID", projectId));
        }

        if (!"delete".equals(operation)) {
            List<Property> properties = propertyMapper.selectByObjectTypeId(objectTypeId, projectId);
            for (Property property : properties) {
                if (property.getId() == null || property.getId().isEmpty()) continue;
                params.add(inputParam(
                        ruleId,
                        sort++,
                        property.getId(),
                        normalizeType(property.getType()),
                        isPrimary(property),
                        firstNonBlank(property.getDescription(), property.getName(), property.getBaseColumn(), property.getId()),
                        projectId
                ));
            }
        }

        addStandardObjectOutputs(params, ruleId, projectId);
        return params;
    }

    private List<OntologyRuleParam> buildLinkParams(String ruleId, String operation, String projectId) {
        List<OntologyRuleParam> params = new ArrayList<>();
        params.add(inputParam(ruleId, 0, "sourceInstanceId", "string", 1, "源实例ID", projectId));
        params.add(inputParam(ruleId, 1, "targetInstanceId", "string", 1, "目标实例ID", projectId));
        params.add(inputParam(ruleId, 2, "linkTypeId", "string", 0, "链接类型ID", projectId));
        if ("create".equals(operation)) {
            params.add(inputParam(ruleId, 3, "evidence", "string", 0, "关系证据", projectId));
        }
        params.add(outputParam(ruleId, 0, "success", "boolean", 1, "操作是否成功", projectId));
        params.add(outputParam(ruleId, 1, "message", "string", 0, "返回消息", projectId));
        params.add(outputParam(ruleId, 2, "linkInstanceId", "string", 0, "链接实例ID", projectId));
        return params;
    }

    private void addStandardObjectOutputs(List<OntologyRuleParam> params, String ruleId, String projectId) {
        params.add(outputParam(ruleId, 0, "success", "boolean", 1, "操作是否成功", projectId));
        params.add(outputParam(ruleId, 1, "message", "string", 0, "返回消息", projectId));
        params.add(outputParam(ruleId, 2, "instanceId", "string", 0, "实例ID", projectId));
    }

    private void ensureLinkTypeDefaultParam(String actionRuleId, String linkTypeId, String projectId) {
        String paramId = stableId("arp", actionRuleId, "linkTypeId");
        ActionRuleParam existing = actionRuleParamMapper.selectById(paramId);
        ActionRuleParam param = new ActionRuleParam();
        param.setId(paramId);
        param.setActionRuleId(actionRuleId);
        param.setParamName("linkTypeId");
        param.setParamValue(linkTypeId);
        param.setSortOrder(0);
        param.setProjectId(projectId);
        if (existing == null) {
            actionRuleParamMapper.insert(param);
        } else {
            actionRuleParamMapper.updateById(param);
        }
    }

    private void disableAction(String actionId) {
        ActionType action = actionTypeMapper.selectById(actionId);
        if (action == null) return;
        action.setStatus("DISABLED");
        action.setUpdatedAt(LocalDateTime.now());
        actionTypeMapper.updateById(action);
    }

    private OntologyRuleParam inputParam(String ruleId, int sort, String name, String type, int required, String description, String projectId) {
        OntologyRuleParam param = baseParam(ruleId, "INPUT", sort, name, type, required, description, projectId);
        param.setId(paramId(ruleId, "in", sort));
        return param;
    }

    private OntologyRuleParam outputParam(String ruleId, int sort, String name, String type, int required, String description, String projectId) {
        OntologyRuleParam param = baseParam(ruleId, "OUTPUT", sort, name, type, required, description, projectId);
        param.setId(paramId(ruleId, "out", sort));
        return param;
    }

    private OntologyRuleParam baseParam(String ruleId, String direction, int sort, String name, String type, int required, String description, String projectId) {
        OntologyRuleParam param = new OntologyRuleParam();
        param.setRuleId(ruleId);
        param.setParamDirection(direction);
        param.setParamName(name);
        param.setParamType(type);
        param.setIsRequired(required);
        param.setDescription(description);
        param.setSortOrder(sort);
        param.setProjectId(projectId);
        return param;
    }

    private String ruleId(String entityId, String operation) {
        return stableId("rule", entityId, operation);
    }

    private String actionId(String entityId, String operation) {
        return stableId("act", entityId, operation);
    }

    private String actionRuleId(String actionId) {
        return stableId("ar", actionId, "ontology");
    }

    private String paramId(String ruleId, String direction, int sort) {
        return stableId("orp_" + direction, ruleId, String.valueOf(sort));
    }

    private String stableId(String prefix, String middle, String suffix) {
        String raw = prefix + "_" + sanitize(middle) + "_" + sanitize(suffix);
        if (raw.length() <= 64) return raw;
        String hash = Integer.toHexString(raw.hashCode());
        int keep = Math.max(1, 64 - prefix.length() - suffix.length() - hash.length() - 4);
        String safeMiddle = sanitize(middle);
        if (safeMiddle.length() > keep) {
            safeMiddle = safeMiddle.substring(0, keep);
        }
        return prefix + "_" + safeMiddle + "_" + sanitize(suffix) + "_" + hash;
    }

    private String sanitize(String value) {
        if (value == null) return "unknown";
        return value.replaceAll("[^A-Za-z0-9_]", "_");
    }

    private String functionName(String operation, String id) {
        return operation + toPascalCase(id);
    }

    private String toPascalCase(String value) {
        if (value == null || value.isBlank()) return "Unknown";
        StringBuilder builder = new StringBuilder();
        for (String part : value.split("[^A-Za-z0-9]+|_+")) {
            if (part.isBlank()) continue;
            builder.append(part.substring(0, 1).toUpperCase());
            if (part.length() > 1) {
                builder.append(part.substring(1));
            }
        }
        return builder.length() == 0 ? "Unknown" : builder.toString();
    }

    private String displayName(ObjectType objectType) {
        return firstNonBlank(objectType.getName(), objectType.getId(), "对象");
    }

    private String displayName(LinkType linkType) {
        return firstNonBlank(linkType.getName(), linkType.getId(), "关系");
    }

    private String normalizeType(String type) {
        if (isBlank(type)) return "string";
        if ("double".equalsIgnoreCase(type) || "float".equalsIgnoreCase(type) || "integer".equalsIgnoreCase(type) || "int".equalsIgnoreCase(type)) {
            return "number";
        }
        return type;
    }

    private int isPrimary(Property property) {
        return property.getIsPrimaryKey() != null && property.getIsPrimaryKey() == 1 ? 1 : 0;
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (!isBlank(value)) return value;
        }
        return "";
    }

    private String resolveProjectIdForObjectType(String objectTypeId) {
        ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
        return objectType != null ? ProjectScope.normalize(objectType.getProjectId()) : ProjectScope.PUBLIC_PROJECT_ID;
    }

    private String resolveProjectIdForLinkType(String linkTypeId) {
        LinkType linkType = linkTypeMapper.selectById(linkTypeId);
        return linkType != null ? ProjectScope.normalize(linkType.getProjectId()) : ProjectScope.PUBLIC_PROJECT_ID;
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
