package com.ontology.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.ontology.entity.LinkType;
import com.ontology.entity.ObjectType;
import com.ontology.entity.ObjectTypeInterfaceMapping;
import com.ontology.entity.OntologyInterface;
import com.ontology.entity.Property;
import com.ontology.mapper.InterfaceMapper;
import com.ontology.mapper.LinkTypeMapper;
import com.ontology.mapper.ObjectTypeMapper;
import com.ontology.mapper.PropertyMapper;
import com.ontology.service.InterfaceService;
import com.ontology.service.OntologyService;
import com.ontology.service.RuleTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/review")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ReviewController {

    private final ObjectTypeMapper objectTypeMapper;
    private final LinkTypeMapper linkTypeMapper;
    private final PropertyMapper propertyMapper;
    private final InterfaceMapper interfaceMapper;
    private final InterfaceService interfaceService;
    private final OntologyService ontologyService;
    private final RuleTemplateService ruleTemplateService;

    /**
     * 获取待审核列表（分页）
     */
    @GetMapping("/pending")
    public Map<String, Object> getPendingList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        
        Map<String, Object> result = new HashMap<>();
        
        // 查询待审核对象类型
        QueryWrapper<ObjectType> otWrapper = new QueryWrapper<>();
        otWrapper.eq("status", "pending").eq("project_id", projectId).orderByDesc("created_at");
        IPage<ObjectType> otPage = objectTypeMapper.selectPage(new Page<>(page, pageSize), otWrapper);
        
        // 查询待审核链接类型
        QueryWrapper<LinkType> ltWrapper = new QueryWrapper<>();
        ltWrapper.eq("status", "pending").eq("project_id", projectId).orderByDesc("created_at");
        IPage<LinkType> ltPage = linkTypeMapper.selectPage(new Page<>(page, pageSize), ltWrapper);

        QueryWrapper<OntologyInterface> interfaceWrapper = new QueryWrapper<>();
        interfaceWrapper.eq("status", "pending").eq("project_id", projectId).orderByDesc("created_at");
        IPage<OntologyInterface> interfacePage = interfaceMapper.selectPage(new Page<>(page, pageSize), interfaceWrapper);

        List<ObjectTypeInterfaceMapping> objectTypeInterfaceMappings = interfaceService.listPendingObjectTypeInterfaceMappings(projectId);

        // 统计总数
        Long totalObjectTypes = objectTypeMapper.selectCount(
            new QueryWrapper<ObjectType>().eq("status", "pending").eq("project_id", projectId)
        );
        Long totalLinkTypes = linkTypeMapper.selectCount(
            new QueryWrapper<LinkType>().eq("status", "pending").eq("project_id", projectId)
        );
        Long totalInterfaces = interfaceMapper.selectCount(
            new QueryWrapper<OntologyInterface>().eq("status", "pending").eq("project_id", projectId)
        );
        int totalObjectTypeInterfaceMappings = objectTypeInterfaceMappings.size();
        
        result.put("objectTypes", otPage.getRecords());
        result.put("linkTypes", ltPage.getRecords());
        result.put("interfaces", interfacePage.getRecords());
        result.put("objectTypeInterfaceMappings", objectTypeInterfaceMappings);
        result.put("totalObjectTypes", totalObjectTypes);
        result.put("totalLinkTypes", totalLinkTypes);
        result.put("totalInterfaces", totalInterfaces);
        result.put("totalObjectTypeInterfaceMappings", totalObjectTypeInterfaceMappings);
        result.put("total", totalObjectTypes + totalLinkTypes + totalInterfaces + totalObjectTypeInterfaceMappings);
        result.put("page", page);
        result.put("pageSize", pageSize);
        
        return result;
    }

    /**
     * 审核通过对象类型
     */
    @PostMapping("/object-types/{id}/approve")
    public Map<String, Object> approveObjectType(@PathVariable String id, @RequestParam(required = false) String projectId) {
        ObjectType objectType = objectTypeMapper.selectById(id);
        if (objectType == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("error", "Object type not found");
            return result;
        }
        
        objectType.setStatus("active");
        objectTypeMapper.updateById(objectType);
        ruleTemplateService.ensureObjectTypeRules(objectType);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "对象类型审核通过");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    /**
     * 审核不通过并删除对象类型
     */
    @PostMapping("/object-types/{id}/reject")
    public Map<String, Object> rejectObjectType(@PathVariable String id, @RequestParam(required = false) String projectId) {
        ObjectType objectType = objectTypeMapper.selectById(id);
        if (objectType == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("error", "Object type not found");
            return result;
        }
        
        // 删除关联属性
        QueryWrapper<Property> propWrapper = new QueryWrapper<>();
        propWrapper.eq("object_type_id", id);
        propertyMapper.delete(propWrapper);

        // 删除历史上可能已提前生成的动作类型和本体规则
        ruleTemplateService.deleteObjectTypeRuleArtifacts(id);
        
        // 删除对象类型
        objectTypeMapper.deleteById(id);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "对象类型已删除");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    /**
     * 审核通过链接类型
     */
    @PostMapping("/link-types/{id}/approve")
    public Map<String, Object> approveLinkType(@PathVariable String id, @RequestParam(required = false) String projectId) {
        LinkType linkType = linkTypeMapper.selectById(id);
        if (linkType == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("error", "Link type not found");
            return result;
        }
        
        linkType.setStatus("active");
        linkTypeMapper.updateById(linkType);
        ruleTemplateService.ensureLinkTypeRules(linkType);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "链接类型审核通过");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    /**
     * 审核不通过并删除链接类型
     */
    @PostMapping("/link-types/{id}/reject")
    public Map<String, Object> rejectLinkType(@PathVariable String id, @RequestParam(required = false) String projectId) {
        LinkType linkType = linkTypeMapper.selectById(id);
        if (linkType == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("error", "Link type not found");
            return result;
        }
        
        // 删除历史上可能已提前生成的动作类型和本体规则
        ruleTemplateService.deleteLinkTypeRuleArtifacts(id);

        // 删除链接类型
        linkTypeMapper.deleteById(id);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "链接类型已删除");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/interfaces/{id}/approve")
    public Map<String, Object> approveInterface(@PathVariable String id, @RequestParam(required = false) String projectId) {
        interfaceService.approveInterface(id, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "Interface 审核通过");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/interfaces/{id}/reject")
    public Map<String, Object> rejectInterface(@PathVariable String id, @RequestParam(required = false) String projectId) {
        interfaceService.rejectInterface(id, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "Interface 已删除");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/object-type-interface-mappings/{id}/approve")
    public Map<String, Object> approveObjectTypeInterfaceMapping(@PathVariable String id, @RequestParam(required = false) String projectId) {
        interfaceService.approveObjectTypeInterfaceMapping(id, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "实现关系审核通过");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    @PostMapping("/object-type-interface-mappings/{id}/reject")
    public Map<String, Object> rejectObjectTypeInterfaceMapping(@PathVariable String id, @RequestParam(required = false) String projectId) {
        interfaceService.rejectObjectTypeInterfaceMapping(id, projectId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "实现关系已删除");
        result.put("data", ontologyService.buildOntologyData(projectId));
        return result;
    }

    /**
     * 获取待审核数量
     */
    @GetMapping("/count")
    public Map<String, Object> getPendingCount(@RequestParam(required = false) String projectId) {
        projectId = com.ontology.project.ProjectScope.normalize(projectId);
        Long objectTypes = objectTypeMapper.selectCount(
            new QueryWrapper<ObjectType>().eq("status", "pending").eq("project_id", projectId)
        );
        Long linkTypes = linkTypeMapper.selectCount(
            new QueryWrapper<LinkType>().eq("status", "pending").eq("project_id", projectId)
        );
        Long interfaces = interfaceMapper.selectCount(
            new QueryWrapper<OntologyInterface>().eq("status", "pending").eq("project_id", projectId)
        );
        int objectTypeInterfaceMappings = interfaceService.listPendingObjectTypeInterfaceMappings(projectId).size();
        
        Map<String, Object> result = new HashMap<>();
        result.put("total", objectTypes + linkTypes + interfaces + objectTypeInterfaceMappings);
        result.put("objectTypes", objectTypes);
        result.put("linkTypes", linkTypes);
        result.put("interfaces", interfaces);
        result.put("objectTypeInterfaceMappings", objectTypeInterfaceMappings);
        return result;
    }
}
