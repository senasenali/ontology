package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.Agent;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface AgentMapper extends BaseMapper<Agent> {
    
    @Select("SELECT * FROM agents WHERE project_id = #{projectId} ORDER BY created_at DESC")
    List<Agent> selectAllOrdered(@Param("projectId") String projectId);
}
