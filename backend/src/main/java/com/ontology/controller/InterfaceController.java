package com.ontology.controller;

import com.ontology.entity.InterfaceLinkConstraint;
import com.ontology.entity.InterfaceProperty;
import com.ontology.entity.OntologyInterface;
import com.ontology.service.InterfaceService;
import com.ontology.service.OntologyService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/interfaces")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class InterfaceController {

    private final InterfaceService interfaceService;
    private final OntologyService ontologyService;

    @GetMapping
    public Map<String, Object> list(@RequestParam(required = false) String projectId) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("interfaces", interfaceService.listOntologyInterfaces(projectId));
        return result;
    }

    @GetMapping("/{id}")
    public Map<String, Object> detail(@PathVariable String id, @RequestParam(required = false) String projectId) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("interface", interfaceService.getInterfaceDetail(id, projectId));
        return result;
    }

    @PostMapping
    @Transactional
    public Map<String, Object> create(@RequestBody OntologyInterface ontologyInterface, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.createInterface(ontologyInterface, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PutMapping("/{id}")
    @Transactional
    public Map<String, Object> update(@PathVariable String id, @RequestBody OntologyInterface ontologyInterface, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.updateInterface(id, ontologyInterface, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @DeleteMapping("/{id}")
    @Transactional
    public Map<String, Object> delete(@PathVariable String id, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.deleteInterface(id, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/{interfaceId}/properties")
    @Transactional
    public Map<String, Object> addProperty(@PathVariable String interfaceId, @RequestBody InterfaceProperty property, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.addProperty(interfaceId, property, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PutMapping("/{interfaceId}/properties/{propertyId}")
    @Transactional
    public Map<String, Object> updateProperty(
            @PathVariable String interfaceId,
            @PathVariable String propertyId,
            @RequestBody InterfaceProperty property,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.updateProperty(interfaceId, propertyId, property, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @DeleteMapping("/{interfaceId}/properties/{propertyId}")
    @Transactional
    public Map<String, Object> deleteProperty(@PathVariable String interfaceId, @PathVariable String propertyId, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.deleteProperty(interfaceId, propertyId, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/{interfaceId}/extends")
    @Transactional
    public Map<String, Object> setExtends(@PathVariable String interfaceId, @RequestBody Map<String, String> body, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.setExtends(interfaceId, body.get("parentInterfaceId"), projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @DeleteMapping("/{interfaceId}/extends")
    @Transactional
    public Map<String, Object> removeExtends(@PathVariable String interfaceId, @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.removeExtends(interfaceId, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/{interfaceId}/link-type-constraints")
    @Transactional
    public Map<String, Object> addLinkTypeConstraint(
            @PathVariable String interfaceId,
            @RequestBody InterfaceLinkConstraint constraint,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.addLinkTypeConstraint(interfaceId, constraint, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PutMapping("/{interfaceId}/link-type-constraints/{constraintId}")
    @Transactional
    public Map<String, Object> updateLinkTypeConstraint(
            @PathVariable String interfaceId,
            @PathVariable String constraintId,
            @RequestBody InterfaceLinkConstraint constraint,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.updateLinkTypeConstraint(interfaceId, constraintId, constraint, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @DeleteMapping("/{interfaceId}/link-type-constraints/{constraintId}")
    @Transactional
    public Map<String, Object> deleteLinkTypeConstraint(
            @PathVariable String interfaceId,
            @PathVariable String constraintId,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        interfaceService.deleteLinkTypeConstraint(interfaceId, constraintId, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }
}
