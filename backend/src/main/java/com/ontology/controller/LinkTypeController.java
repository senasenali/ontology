package com.ontology.controller;

import com.ontology.entity.LinkType;
import com.ontology.mapper.LinkTypeMapper;
import com.ontology.service.OntologyService;
import com.ontology.service.RuleTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/link-types")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LinkTypeController {

    private final LinkTypeMapper linkTypeMapper;
    private final OntologyService ontologyService;
    private final RuleTemplateService ruleTemplateService;

    @PostMapping
    @Transactional
    public Map<String, Object> create(@RequestBody LinkType linkType, @RequestParam(required = false) String projectId) {
        linkType.setProjectId(com.ontology.project.ProjectScope.normalize(projectId));
        linkType.setStatus("pending"); // 新建链接类型默认待审核
        linkTypeMapper.insert(linkType);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(linkType.getProjectId()));
        return result;
    }

    @PutMapping("/{id}")
    @Transactional
    public Map<String, Object> update(@PathVariable String id, @RequestBody LinkType linkType, @RequestParam(required = false) String projectId) {
        linkType.setId(id);
        linkType.setProjectId(com.ontology.project.ProjectScope.normalize(projectId));
        linkTypeMapper.updateById(linkType);
        LinkType updated = linkTypeMapper.selectById(id);
        if (updated != null && "active".equalsIgnoreCase(updated.getStatus())) {
            ruleTemplateService.ensureLinkTypeRules(updated);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(linkType.getProjectId()));
        return result;
    }

    @DeleteMapping("/{id}")
    @Transactional
    public Map<String, Object> delete(@PathVariable String id, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        ruleTemplateService.deleteLinkTypeRuleArtifacts(id);
        linkTypeMapper.deleteById(id);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }
}
