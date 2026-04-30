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
    public Map<String, Object> create(@RequestBody ObjectType objectType) {
        objectType.setStatus("pending"); // 新建对象类型默认待审核
        objectTypeMapper.insert(objectType);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PutMapping("/{id}")
    @Transactional
    public Map<String, Object> update(@PathVariable String id, @RequestBody ObjectType objectType) {
        objectType.setId(id);
        objectTypeMapper.updateById(objectType);
        ObjectType updated = objectTypeMapper.selectById(id);
        if (updated != null && "active".equalsIgnoreCase(updated.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(updated);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @DeleteMapping("/{id}")
    @Transactional
    public Map<String, Object> delete(@PathVariable String id) {
        ruleTemplateService.deleteObjectTypeRuleArtifacts(id);
        objectTypeMapper.deleteById(id);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PostMapping("/{objectTypeId}/properties")
    @Transactional
    public Map<String, Object> addProperty(@PathVariable String objectTypeId, @RequestBody Property property) {
        property.setObjectTypeId(objectTypeId);
        propertyMapper.insert(property);
        ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
        if (objectType != null && "active".equalsIgnoreCase(objectType.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(objectType);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @DeleteMapping("/{objectTypeId}/properties/{propId}")
    @Transactional
    public Map<String, Object> deleteProperty(@PathVariable String objectTypeId, @PathVariable String propId) {
        propertyMapper.deleteById(propId);
        ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
        if (objectType != null && "active".equalsIgnoreCase(objectType.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(objectType);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PutMapping("/{objectTypeId}/properties/{propId}")
    @Transactional
    public Map<String, Object> updateProperty(@PathVariable String objectTypeId, @PathVariable String propId, @RequestBody Property property) {
        property.setId(propId);
        property.setObjectTypeId(objectTypeId);
        propertyMapper.updateById(property);
        ObjectType objectType = objectTypeMapper.selectById(objectTypeId);
        if (objectType != null && "active".equalsIgnoreCase(objectType.getStatus())) {
            ruleTemplateService.ensureObjectTypeRules(objectType);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @GetMapping("/{objectTypeId}/interfaces")
    public Map<String, Object> listImplementedInterfaces(@PathVariable String objectTypeId) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("interfaces", interfaceService.listObjectTypeInterfaceMappings(objectTypeId));
        return result;
    }

    @PostMapping("/{objectTypeId}/interfaces")
    @Transactional
    public Map<String, Object> createImplementedInterface(
            @PathVariable String objectTypeId,
            @RequestBody ObjectTypeInterfaceMapping mapping) {
        interfaceService.saveObjectTypeInterfaceMapping(objectTypeId, mapping);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PutMapping("/{objectTypeId}/interfaces/{mappingId}")
    @Transactional
    public Map<String, Object> updateImplementedInterface(
            @PathVariable String objectTypeId,
            @PathVariable String mappingId,
            @RequestBody ObjectTypeInterfaceMapping mapping) {
        mapping.setId(mappingId);
        interfaceService.saveObjectTypeInterfaceMapping(objectTypeId, mapping);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @DeleteMapping("/{objectTypeId}/interfaces/{mappingId}")
    @Transactional
    public Map<String, Object> deleteImplementedInterface(
            @PathVariable String objectTypeId,
            @PathVariable String mappingId) {
        interfaceService.deleteObjectTypeInterfaceMapping(objectTypeId, mappingId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }
}
