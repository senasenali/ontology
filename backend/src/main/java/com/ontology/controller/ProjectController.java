package com.ontology.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.ontology.entity.Project;
import com.ontology.mapper.*;
import com.ontology.project.ProjectScope;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/projects")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProjectController {

    private final ProjectMapper projectMapper;
    private final ObjectTypeMapper objectTypeMapper;
    private final LinkTypeMapper linkTypeMapper;
    private final InterfaceMapper interfaceMapper;
    private final ActionTypeMapper actionTypeMapper;
    private final OntologyRuleMapper ontologyRuleMapper;
    private final FunctionTypeMapper functionTypeMapper;

    @GetMapping
    public Map<String, Object> list() {
        List<Project> projects = projectMapper.selectAllOrdered();
        return Map.of("success", true, "projects", projects);
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody Map<String, String> body) {
        String name = body.get("name");
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("项目名称不能为空");
        }

        Project project = new Project();
        project.setId("project_" + System.currentTimeMillis());
        project.setName(name.trim());
        project.setDescription(body.get("description"));
        project.setIsPublic(0);
        project.setStatus("ACTIVE");
        project.setCreatedAt(LocalDateTime.now());
        project.setUpdatedAt(LocalDateTime.now());
        projectMapper.insert(project);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("project", project);
        result.put("projects", projectMapper.selectAllOrdered());
        return result;
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable String id) {
        if (ProjectScope.PUBLIC_PROJECT_ID.equals(id)) {
            throw new IllegalArgumentException("公共项目不可删除");
        }
        Project project = projectMapper.selectById(id);
        if (project == null) {
            throw new IllegalArgumentException("项目不存在");
        }
        if (hasMetadata(id)) {
            throw new IllegalArgumentException("请先清空项目中的元数据后再删除");
        }
        projectMapper.deleteById(id);
        return Map.of("success", true, "projects", projectMapper.selectAllOrdered());
    }

    private boolean hasMetadata(String projectId) {
        return objectTypeMapper.selectCount(new QueryWrapper<com.ontology.entity.ObjectType>().eq("project_id", projectId)) > 0
                || linkTypeMapper.selectCount(new QueryWrapper<com.ontology.entity.LinkType>().eq("project_id", projectId)) > 0
                || interfaceMapper.selectCount(new QueryWrapper<com.ontology.entity.OntologyInterface>().eq("project_id", projectId)) > 0
                || actionTypeMapper.selectCount(new QueryWrapper<com.ontology.entity.ActionType>().eq("project_id", projectId)) > 0
                || ontologyRuleMapper.selectCount(new QueryWrapper<com.ontology.entity.OntologyRule>().eq("project_id", projectId)) > 0
                || functionTypeMapper.selectCount(new QueryWrapper<com.ontology.entity.FunctionType>().eq("project_id", projectId)) > 0;
    }
}
