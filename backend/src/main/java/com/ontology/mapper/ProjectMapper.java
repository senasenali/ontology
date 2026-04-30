package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.Project;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ProjectMapper extends BaseMapper<Project> {

    @Select("SELECT * FROM projects ORDER BY is_public DESC, name ASC")
    List<Project> selectAllOrdered();
}
