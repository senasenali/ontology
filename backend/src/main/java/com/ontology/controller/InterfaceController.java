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
    public Map<String, Object> list() {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("interfaces", interfaceService.listOntologyInterfaces());
        return result;
    }

    @GetMapping("/{id}")
    public Map<String, Object> detail(@PathVariable String id) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("interface", interfaceService.getInterfaceDetail(id));
        return result;
    }

    @PostMapping
    @Transactional
    public Map<String, Object> create(@RequestBody OntologyInterface ontologyInterface) {
        interfaceService.createInterface(ontologyInterface);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PutMapping("/{id}")
    @Transactional
    public Map<String, Object> update(@PathVariable String id, @RequestBody OntologyInterface ontologyInterface) {
        interfaceService.updateInterface(id, ontologyInterface);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @DeleteMapping("/{id}")
    @Transactional
    public Map<String, Object> delete(@PathVariable String id) {
        interfaceService.deleteInterface(id);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PostMapping("/{interfaceId}/properties")
    @Transactional
    public Map<String, Object> addProperty(@PathVariable String interfaceId, @RequestBody InterfaceProperty property) {
        interfaceService.addProperty(interfaceId, property);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PutMapping("/{interfaceId}/properties/{propertyId}")
    @Transactional
    public Map<String, Object> updateProperty(
            @PathVariable String interfaceId,
            @PathVariable String propertyId,
            @RequestBody InterfaceProperty property) {
        interfaceService.updateProperty(interfaceId, propertyId, property);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @DeleteMapping("/{interfaceId}/properties/{propertyId}")
    @Transactional
    public Map<String, Object> deleteProperty(@PathVariable String interfaceId, @PathVariable String propertyId) {
        interfaceService.deleteProperty(interfaceId, propertyId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PostMapping("/{interfaceId}/extends")
    @Transactional
    public Map<String, Object> setExtends(@PathVariable String interfaceId, @RequestBody Map<String, String> body) {
        interfaceService.setExtends(interfaceId, body.get("parentInterfaceId"));
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @DeleteMapping("/{interfaceId}/extends")
    @Transactional
    public Map<String, Object> removeExtends(@PathVariable String interfaceId) {
        interfaceService.removeExtends(interfaceId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PostMapping("/{interfaceId}/link-type-constraints")
    @Transactional
    public Map<String, Object> addLinkTypeConstraint(
            @PathVariable String interfaceId,
            @RequestBody InterfaceLinkConstraint constraint) {
        interfaceService.addLinkTypeConstraint(interfaceId, constraint);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @PutMapping("/{interfaceId}/link-type-constraints/{constraintId}")
    @Transactional
    public Map<String, Object> updateLinkTypeConstraint(
            @PathVariable String interfaceId,
            @PathVariable String constraintId,
            @RequestBody InterfaceLinkConstraint constraint) {
        interfaceService.updateLinkTypeConstraint(interfaceId, constraintId, constraint);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }

    @DeleteMapping("/{interfaceId}/link-type-constraints/{constraintId}")
    @Transactional
    public Map<String, Object> deleteLinkTypeConstraint(
            @PathVariable String interfaceId,
            @PathVariable String constraintId) {
        interfaceService.deleteLinkTypeConstraint(interfaceId, constraintId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", ontologyService.buildOntologyData());
        return result;
    }
}
