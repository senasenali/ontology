package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.AgentAnalysis;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface AgentAnalysisMapper extends BaseMapper<AgentAnalysis> {
    
    @Select("SELECT * FROM agent_analyses WHERE agent_id = #{agentId} AND project_id = #{projectId} ORDER BY created_at DESC LIMIT 20")
    List<AgentAnalysis> selectByAgentId(@Param("agentId") String agentId, @Param("projectId") String projectId);

    @Delete("DELETE FROM agent_analyses WHERE agent_id = #{agentId} AND project_id = #{projectId}")
    void deleteByAgentId(@Param("agentId") String agentId, @Param("projectId") String projectId);
}
