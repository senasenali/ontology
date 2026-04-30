package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.AIConversation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface AIConversationMapper extends BaseMapper<AIConversation> {
    
    @Select("SELECT id, title, created_at, updated_at, project_id FROM ai_conversations WHERE project_id = #{projectId} ORDER BY updated_at DESC")
    List<AIConversation> selectListOrdered(@Param("projectId") String projectId);
}
