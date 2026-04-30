package com.ontology.controller;

import com.ontology.entity.OntologyRule;
import com.ontology.entity.OntologyRuleParam;
import com.ontology.entity.ObjectType;
import com.ontology.entity.LinkType;
import com.ontology.mapper.ObjectTypeMapper;
import com.ontology.mapper.LinkTypeMapper;
import com.ontology.mapper.OntologyRuleMapper;
import com.ontology.mapper.OntologyRuleParamMapper;
import com.ontology.service.RuleTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/ontology-rules")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class OntologyRuleController {

    private final OntologyRuleMapper ruleMapper;
    private final OntologyRuleParamMapper paramMapper;
    private final ObjectTypeMapper objectTypeMapper;
    private final LinkTypeMapper linkTypeMapper;
    private final RuleTemplateService ruleTemplateService;

    @GetMapping
    public Map<String, Object> list(@RequestParam(required = false) String category,
                                    @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        List<OntologyRule> rules;
        if (category != null && !category.isEmpty()) {
            rules = ruleMapper.selectByCategory(projectId, category);
        } else {
            rules = ruleMapper.selectAllOrdered(projectId);
        }
        
        // 加载每个规则的参数
        for (OntologyRule rule : rules) {
            rule.setInputParams(paramMapper.selectInputParamsByRuleId(rule.getId()));
            rule.setOutputParams(paramMapper.selectOutputParamsByRuleId(rule.getId()));
        }
        enrichRelatedEntities(rules, projectId);
        
        return Map.of("rules", rules);
    }

    @GetMapping("/{id}")
    public Map<String, Object> getById(@PathVariable String id, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        OntologyRule rule = ruleMapper.selectById(id);
        if (rule == null || !projectId.equals(rule.getProjectId())) {
            throw new RuntimeException("Rule not found");
        }
        rule.setInputParams(paramMapper.selectInputParamsByRuleId(id));
        rule.setOutputParams(paramMapper.selectOutputParamsByRuleId(id));
        enrichRelatedEntities(List.of(rule), projectId);
        return Map.of("rule", rule);
    }

    @PostMapping("/sync-all")
    public Map<String, Object> syncAll() {
        ruleTemplateService.syncAllRules();
        return Map.of("success", true);
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody Map<String, Object> request, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        String id = "rule_" + UUID.randomUUID().toString().substring(0, 8);
        
        OntologyRule rule = new OntologyRule();
        rule.setId(id);
        rule.setRuleCategory((String) request.get("ruleCategory"));
        rule.setFunctionName((String) request.get("functionName"));
        rule.setInterfaceType((String) request.get("interfaceType"));
        rule.setRequestMethod((String) request.get("requestMethod"));
        rule.setInterfaceUrl((String) request.get("interfaceUrl"));
        rule.setProjectId(projectId);
        rule.setCreatedAt(LocalDateTime.now());
        rule.setUpdatedAt(LocalDateTime.now());
        
        ruleMapper.insert(rule);
        
        // 插入入参
        List<Map<String, Object>> inputParams = (List<Map<String, Object>>) request.get("inputParams");
        if (inputParams != null) {
            for (int i = 0; i < inputParams.size(); i++) {
                Map<String, Object> p = inputParams.get(i);
                OntologyRuleParam param = new OntologyRuleParam();
                param.setId(id + "_in_" + i);
                param.setRuleId(id);
                param.setParamDirection("INPUT");
                param.setParamName((String) p.get("paramName"));
                param.setParamType((String) p.get("paramType"));
                param.setIsRequired(p.get("isRequired") != null && (Boolean) p.get("isRequired") ? 1 : 0);
                param.setDescription((String) p.get("description"));
                param.setSortOrder(i);
                param.setProjectId(projectId);
                paramMapper.insert(param);
            }
        }
        
        // 插入出参
        List<Map<String, Object>> outputParams = (List<Map<String, Object>>) request.get("outputParams");
        if (outputParams != null) {
            for (int i = 0; i < outputParams.size(); i++) {
                Map<String, Object> p = outputParams.get(i);
                OntologyRuleParam param = new OntologyRuleParam();
                param.setId(id + "_out_" + i);
                param.setRuleId(id);
                param.setParamDirection("OUTPUT");
                param.setParamName((String) p.get("paramName"));
                param.setParamType((String) p.get("paramType"));
                param.setIsRequired(p.get("isRequired") != null && (Boolean) p.get("isRequired") ? 1 : 0);
                param.setDescription((String) p.get("description"));
                param.setSortOrder(i);
                param.setProjectId(projectId);
                paramMapper.insert(param);
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("rule", rule);
        return result;
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable String id, @RequestBody Map<String, Object> request, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        OntologyRule rule = ruleMapper.selectById(id);
        if (rule == null || !projectId.equals(rule.getProjectId())) {
            throw new RuntimeException("Rule not found");
        }
        
        if (request.get("ruleCategory") != null) {
            rule.setRuleCategory((String) request.get("ruleCategory"));
        }
        if (request.get("functionName") != null) {
            rule.setFunctionName((String) request.get("functionName"));
        }
        if (request.get("interfaceType") != null) {
            rule.setInterfaceType((String) request.get("interfaceType"));
        }
        if (request.containsKey("requestMethod")) {
            rule.setRequestMethod((String) request.get("requestMethod"));
        }
        if (request.get("interfaceUrl") != null) {
            rule.setInterfaceUrl((String) request.get("interfaceUrl"));
        }
        rule.setUpdatedAt(LocalDateTime.now());
        
        ruleMapper.updateById(rule);
        
        // 删除旧参数并重新插入
        paramMapper.deleteByRuleId(id);
        
        // 插入入参
        List<Map<String, Object>> inputParams = (List<Map<String, Object>>) request.get("inputParams");
        if (inputParams != null) {
            for (int i = 0; i < inputParams.size(); i++) {
                Map<String, Object> p = inputParams.get(i);
                OntologyRuleParam param = new OntologyRuleParam();
                param.setId(id + "_in_" + i);
                param.setRuleId(id);
                param.setParamDirection("INPUT");
                param.setParamName((String) p.get("paramName"));
                param.setParamType((String) p.get("paramType"));
                param.setIsRequired(p.get("isRequired") != null && (Boolean) p.get("isRequired") ? 1 : 0);
                param.setDescription((String) p.get("description"));
                param.setSortOrder(i);
                param.setProjectId(projectId);
                paramMapper.insert(param);
            }
        }
        
        // 插入出参
        List<Map<String, Object>> outputParams = (List<Map<String, Object>>) request.get("outputParams");
        if (outputParams != null) {
            for (int i = 0; i < outputParams.size(); i++) {
                Map<String, Object> p = outputParams.get(i);
                OntologyRuleParam param = new OntologyRuleParam();
                param.setId(id + "_out_" + i);
                param.setRuleId(id);
                param.setParamDirection("OUTPUT");
                param.setParamName((String) p.get("paramName"));
                param.setParamType((String) p.get("paramType"));
                param.setIsRequired(p.get("isRequired") != null && (Boolean) p.get("isRequired") ? 1 : 0);
                param.setDescription((String) p.get("description"));
                param.setSortOrder(i);
                param.setProjectId(projectId);
                paramMapper.insert(param);
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("rule", rule);
        return result;
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable String id, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        OntologyRule current = ruleMapper.selectById(id);
        if (current == null || !projectId.equals(current.getProjectId())) {
            throw new RuntimeException("Rule not found");
        }
        // 先删除参数
        paramMapper.deleteByRuleId(id);
        // 再删除规则
        ruleMapper.deleteById(id);
        return Map.of("success", true);
    }

    private void enrichRelatedEntities(List<OntologyRule> rules, String projectId) {
        Map<String, ObjectType> objectTypes = objectTypeMapper.selectAllOrdered(projectId).stream()
                .collect(Collectors.toMap(ObjectType::getId, Function.identity(), (a, b) -> a));
        Map<String, LinkType> linkTypes = linkTypeMapper.selectAllOrdered(projectId).stream()
                .collect(Collectors.toMap(LinkType::getId, Function.identity(), (a, b) -> a));

        for (OntologyRule rule : rules) {
            String url = rule.getInterfaceUrl();
            if (url == null || url.isBlank()) continue;

            String objectTypeId = extractAfter(url, "/api/instances/");
            if (objectTypeId != null && objectTypes.containsKey(objectTypeId)) {
                ObjectType objectType = objectTypes.get(objectTypeId);
                rule.setRelatedEntityType("OBJECT_TYPE");
                rule.setRelatedEntityId(objectType.getId());
                rule.setRelatedEntityName(objectType.getName());
                continue;
            }

            String linkTypeId = extractAfter(url, "/api/link-instances/");
            if (linkTypeId != null && linkTypes.containsKey(linkTypeId)) {
                LinkType linkType = linkTypes.get(linkTypeId);
                rule.setRelatedEntityType("LINK_TYPE");
                rule.setRelatedEntityId(linkType.getId());
                rule.setRelatedEntityName(linkType.getName());
            }
        }
    }

    private String extractAfter(String url, String prefix) {
        int index = url.indexOf(prefix);
        if (index < 0) return null;
        String tail = url.substring(index + prefix.length());
        int slash = tail.indexOf("/");
        if (slash >= 0) {
            tail = tail.substring(0, slash);
        }
        return tail.isBlank() ? null : tail;
    }
}
