package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.InterfaceExtends;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InterfaceExtendsMapper extends BaseMapper<InterfaceExtends> {

    @Select("SELECT * FROM interface_extends WHERE child_interface_id = #{childInterfaceId} LIMIT 1")
    InterfaceExtends selectByChildInterfaceId(@Param("childInterfaceId") String childInterfaceId);

    @Select("SELECT * FROM interface_extends WHERE parent_interface_id = #{parentInterfaceId} ORDER BY child_interface_id")
    List<InterfaceExtends> selectByParentInterfaceId(@Param("parentInterfaceId") String parentInterfaceId);
}
