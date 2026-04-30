package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.FunctionType;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface FunctionTypeMapper extends BaseMapper<FunctionType> {
    
    @Select("SELECT * FROM function_types WHERE status = 'ACTIVE' AND project_id = #{projectId} ORDER BY created_at DESC")
    List<FunctionType> selectAllActive(@Param("projectId") String projectId);
    
    @Select("SELECT * FROM function_types WHERE category = #{category} AND status = 'ACTIVE' AND project_id = #{projectId} ORDER BY created_at DESC")
    List<FunctionType> selectByCategory(@Param("projectId") String projectId, @Param("category") String category);
    
    @Select("SELECT * FROM function_types WHERE code = #{code} AND status = 'ACTIVE' AND project_id = #{projectId} LIMIT 1")
    FunctionType selectByCode(@Param("projectId") String projectId, @Param("code") String code);
}
