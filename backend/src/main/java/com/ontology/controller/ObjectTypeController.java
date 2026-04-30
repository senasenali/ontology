package com.ontology.controller;

import com.ontology.entity.ObjectType;
import com.ontology.entity.ObjectTypeInterfaceMapping;
import com.ontology.entity.Property;
import com.ontology.service.InterfaceService;
import com.ontology.mapper.ObjectTypeMapper;
import com.ontology.mapper.PropertyMapper;
import com.ontology.service.OntologyService;
import com.ontology.service.RuleTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/object-types")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ObjectTypeController {

    private final ObjectTypeMapper objectTypeMapper;
    private final PropertyMapper propertyMapper;
    private final OntologyService ontologyService;
    private final RuleTemplateService ruleTemplateService;
    private final InterfaceService interfaceService;

    @PostMapping
    @Transactional
    public Map<String, Object> create(@RequestBody ObjectType objectType, @RequestParam(required = false) String projectId) {
        objectType.setProjectId(com.ontology.project.ProjectScope.normalize(projectId));
        objectType.setStatus("pending"); // 新建对象类型默认待审核
        objectTypeMapper.insert(objectType);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(objectType.getProjectId()));
        return result;
    }

    @PutMapping("/{id}")
    @Transactional
    public Map<String, Object> update(@PathVariable String id, @RequestBody ObjectType objectType, @RequestParam(required = false) String projectId) {
        objectType.setId(id);
        objectType.setProjectId(com.ontology.project.ProjectScope.normalize(projectId));
        objectTypeMapper.updateById(objectType);
        ObjectType updated = objectTypeMapper.selectById(id);
        if (updated != null && "active".equalsIgnoreCase(updated.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(updated);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(objectType.getProjectId()));
        return result;
    }

    @DeleteMapping("/{id}")
    @Transactional
    public Map<String, Object> delete(@PathVariable String id, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        ruleTemplateService.deleteObjectTypeRuleArtifacts(id);
        objectTypeMapper.deleteById(id);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/{objectTypeId}/properties")
    @Transactional
    public Map<String, Object> addProperty(@PathVariable String objectTypeId, @RequestBody Property property, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        property.setObjectTypeId(objectTypeId);
        property.setProjectId(projectId);
        propertyMapper.insert(property);
        ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
        if (objectType != null && "active".equalsIgnoreCase(objectType.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(objectType);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @DeleteMapping("/{objectTypeId}/properties/{propId}")
    @Transactional
    public Map<String, Object> deleteProperty(@PathVariable String objectTypeId, @PathVariable String propId, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        propertyMapper.deleteById(propId);
        ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
        if (objectType != null && "active".equalsIgnoreCase(objectType.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(objectType);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PutMapping("/{objectTypeId}/properties/{propId}")
    @Transactional
    public Map<String, Object> updateProperty(@PathVariable String objectTypeId, @PathVariable String propId, @RequestBody Property property, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        property.setId(propId);
        property.setObjectTypeId(objectTypeId);
        property.setProjectId(projectId);
        propertyMapper.updateById(property);
        ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
        if (objectType != null && "active".equalsIgnoreCase(objectType.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(objectType);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @GetMapping("/{objectTypeId}/interfaces")
    public Map<String, Object> listImplementedInterfaces(@PathVariable String objectTypeId, @RequestParam(required = false) String projectId) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("interfaces", interfaceService.listObjectTypeInterfaceMappings(objectTypeId, projectId));
        return result;
    }

    @PostMapping("/{objectTypeId}/interfaces")
    @Transactional
    public Map<String, Object> createImplementedInterface(
            @PathVariable String objectTypeId,
            @RequestBody ObjectTypeInterfaceMapping mapping,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.saveObjectTypeInterfaceMapping(objectTypeId, mapping, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PutMapping("/{objectTypeId}/interfaces/{mappingId}")
    @Transactional
    public Map<String, Object> updateImplementedInterface(
            @PathVariable String objectTypeId,
            @PathVariable String mappingId,
            @RequestBody ObjectTypeInterfaceMapping mapping,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        mapping.setId(mappingId);
        interfaceService.saveObjectTypeInterfaceMapping(objectTypeId, mapping, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @DeleteMapping("/{objectTypeId}/interfaces/{mappingId}")
    @Transactional
    public Map<String, Object> deleteImplementedInterface(
            @PathVariable String objectTypeId,
            @PathVariable String mappingId,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.deleteObjectTypeInterfaceMapping(objectTypeId, mappingId, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }
}
