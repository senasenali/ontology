package com.ontology.controller;

import com.ontology.entity.Agent;
import com.ontology.entity.AgentEvent;
import com.ontology.entity.AgentAnalysis;
import com.ontology.mapper.AgentMapper;
import com.ontology.mapper.AgentEventMapper;
import com.ontology.mapper.AgentAnalysisMapper;
import com.ontology.project.ProjectScope;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/research-agents")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ResearchAgentController {

    private static final String LITHIUM_DEMO_AGENT_ID = "demo_agent_lithium";
    
    private final AgentMapper agentMapper;
    private final AgentEventMapper agentEventMapper;
    private final AgentAnalysisMapper agentAnalysisMapper;

    private Agent requireAgent(String id, String projectId) {
        Agent agent = agentMapper.selectById(id);
        if (agent == null || !projectId.equals(agent.getProjectId())) {
            throw new RuntimeException("Agent not found");
        }
        return agent;
    }
    
    @GetMapping
    public Map<String, Object> list(@RequestParam(required = false) String projectId) {
        List<Agent> agents = agentMapper.selectAllOrdered(ProjectScope.normalize(projectId));
        return Map.of("agents", agents);
    }
    
    @GetMapping("/{id}")
    public Map<String, Object> getById(@PathVariable String id, @RequestParam(required = false) String projectId) {
        Agent agent = requireAgent(id, ProjectScope.normalize(projectId));
        return Map.of("agent", agent);
    }
    
    @PostMapping
    public Map<String, Object> create(@RequestBody Map<String, Object> data, @RequestParam(required = false) String projectId) {
        String name = (String) data.get("name");
        String targetCompany = (String) data.get("targetCompany");
        String targetIndustry = (String) data.get("targetIndustry");
        String scopedProjectId = ProjectScope.normalize(projectId);
        
        if (name == null || targetCompany == null || targetIndustry == null) {
            throw new RuntimeException("name, targetCompany, targetIndustry are required");
        }
        
        Agent agent = new Agent();
        agent.setId("agent_" + UUID.randomUUID().toString().substring(0, 8));
        agent.setName(name);
        agent.setDescription((String) data.getOrDefault("description", ""));
        agent.setTargetCompany(targetCompany);
        agent.setTargetIndustry(targetIndustry);
        agent.setAnalysisFocus((String) data.getOrDefault("analysisFocus", ""));
        agent.setScheduleMinutes((Integer) data.getOrDefault("scheduleMinutes", 0));
        agent.setIsActive(0);
        agent.setProjectId(scopedProjectId);
        agent.setCreatedAt(LocalDateTime.now());
        agent.setUpdatedAt(LocalDateTime.now());
        
        agentMapper.insert(agent);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("agent", agent);
        return result;
    }
    
    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable String id, @RequestBody Map<String, Object> data, @RequestParam(required = false) String projectId) {
        Agent agent = requireAgent(id, ProjectScope.normalize(projectId));
        
        if (data.containsKey("is_active")) {
            Object isActive = data.get("is_active");
            if (isActive instanceof Boolean) {
                agent.setIsActive((Boolean) isActive ? 1 : 0);
            } else if (isActive instanceof Number) {
                agent.setIsActive(((Number) isActive).intValue());
            }
        }
        
        if (data.containsKey("schedule_minutes")) {
            agent.setScheduleMinutes((Integer) data.get("schedule_minutes"));
        }
        
        agent.setUpdatedAt(LocalDateTime.now());
        agentMapper.updateById(agent);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("agent", agent);
        return result;
    }
    
    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable String id, @RequestParam(required = false) String projectId) {
        requireAgent(id, ProjectScope.normalize(projectId));
        agentMapper.deleteById(id);
        return Map.of("success", true);
    }
    
    @GetMapping("/{id}/events")
    public Map<String, Object> getEvents(@PathVariable String id, @RequestParam(required = false) String projectId) {
        String scopedProjectId = ProjectScope.normalize(projectId);
        requireAgent(id, scopedProjectId);
        List<AgentEvent> events = agentEventMapper.selectByAgentId(id, scopedProjectId);
        // Parse JSON fields
        for (AgentEvent event : events) {
            if (event.getRelatedEntities() == null) {
                event.setRelatedEntities("[]");
            }
        }
        return Map.of("events", events);
    }
    
    @PostMapping("/{id}/events")
    public Map<String, Object> createEvent(@PathVariable String id, @RequestBody Map<String, Object> data, @RequestParam(required = false) String projectId) {
        String scopedProjectId = ProjectScope.normalize(projectId);
        requireAgent(id, scopedProjectId);
        AgentEvent event = new AgentEvent();
        event.setId((String) data.get("id"));
        event.setAgentId(id);
        event.setTitle((String) data.get("title"));
        event.setSummary((String) data.get("summary"));
        event.setSource((String) data.get("source"));
        event.setSourceUrl((String) data.get("source_url"));
        event.setEventDate((String) data.get("event_date"));
        event.setImpactLevel((String) data.get("impact_level"));
        event.setRelatedEntities((String) data.get("related_entities"));
        event.setProjectId(scopedProjectId);
        event.setCreatedAt(LocalDateTime.now());
        
        agentEventMapper.insert(event);
        return Map.of("success", true, "event", event);
    }
    
    @GetMapping("/{id}/analyses")
    public Map<String, Object> getAnalyses(@PathVariable String id, @RequestParam(required = false) String projectId) {
        String scopedProjectId = ProjectScope.normalize(projectId);
        requireAgent(id, scopedProjectId);
        List<AgentAnalysis> analyses = agentAnalysisMapper.selectByAgentId(id, scopedProjectId);
        return Map.of("analyses", analyses);
    }
    
    @PostMapping("/{id}/analyses")
    public Map<String, Object> createAnalysis(@PathVariable String id, @RequestBody Map<String, Object> data, @RequestParam(required = false) String projectId) {
        String scopedProjectId = ProjectScope.normalize(projectId);
        requireAgent(id, scopedProjectId);
        if (LITHIUM_DEMO_AGENT_ID.equals(id)) {
            agentAnalysisMapper.deleteByAgentId(id, scopedProjectId);
        }

        AgentAnalysis analysis = new AgentAnalysis();
        analysis.setId((String) data.get("id"));
        analysis.setAgentId(id);
        analysis.setEventId((String) data.get("event_id"));
        analysis.setTitle((String) data.get("title"));
        analysis.setContent((String) data.get("content"));
        analysis.setKeyFindings((String) data.get("key_findings"));
        analysis.setImpactChain((String) data.get("impact_chain"));
        analysis.setRecommendation((String) data.get("recommendation"));
        analysis.setProjectId(scopedProjectId);
        analysis.setCreatedAt(LocalDateTime.now());
        
        agentAnalysisMapper.insert(analysis);
        return Map.of("success", true, "analysis", analysis);
    }

    @DeleteMapping("/{id}/analyses/{analysisId}")
    public Map<String, Object> deleteAnalysis(@PathVariable String id, @PathVariable String analysisId, @RequestParam(required = false) String projectId) {
        String scopedProjectId = ProjectScope.normalize(projectId);
        requireAgent(id, scopedProjectId);
        AgentAnalysis analysis = agentAnalysisMapper.selectById(analysisId);
        if (analysis == null || !id.equals(analysis.getAgentId()) || !scopedProjectId.equals(analysis.getProjectId())) {
            throw new RuntimeException("Analysis not found");
        }

        agentAnalysisMapper.deleteById(analysisId);
        return Map.of("success", true);
    }
}
