package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.InterfaceProperty;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InterfacePropertyMapper extends BaseMapper<InterfaceProperty> {

    @Select("SELECT * FROM interface_properties WHERE interface_id = #{interfaceId} AND project_id = #{projectId} ORDER BY sort_order, name")
    List<InterfaceProperty> selectByInterfaceId(@Param("interfaceId") String interfaceId, @Param("projectId") String projectId);
}
