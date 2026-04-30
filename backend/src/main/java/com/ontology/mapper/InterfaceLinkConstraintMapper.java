package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.InterfaceLinkConstraint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InterfaceLinkConstraintMapper extends BaseMapper<InterfaceLinkConstraint> {

    @Select("SELECT * FROM interface_link_constraints WHERE interface_id = #{interfaceId} AND project_id = #{projectId} ORDER BY created_at, name")
    List<InterfaceLinkConstraint> selectByInterfaceId(@Param("interfaceId") String interfaceId, @Param("projectId") String projectId);
}
