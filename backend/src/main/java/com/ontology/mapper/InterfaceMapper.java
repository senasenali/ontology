package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.OntologyInterface;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InterfaceMapper extends BaseMapper<OntologyInterface> {

    @Select("SELECT * FROM interfaces WHERE project_id = #{projectId} ORDER BY name")
    List<OntologyInterface> selectAllOrdered(@org.apache.ibatis.annotations.Param("projectId") String projectId);
}
