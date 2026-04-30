package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.ObjectTypeInterfaceMapping;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ObjectTypeInterfaceMappingMapper extends BaseMapper<ObjectTypeInterfaceMapping> {

    @Select("SELECT COUNT(*) FROM object_type_interfaces_mapping WHERE interface_id = #{interfaceId}")
    Long countByInterfaceId(@Param("interfaceId") String interfaceId);

    @Select("SELECT COUNT(*) FROM object_type_interfaces_mapping WHERE object_type_id = #{objectTypeId}")
    Long countByObjectTypeId(@Param("objectTypeId") String objectTypeId);

    @Select("SELECT * FROM object_type_interfaces_mapping WHERE object_type_id = #{objectTypeId} ORDER BY created_at DESC")
    List<ObjectTypeInterfaceMapping> selectByObjectTypeId(@Param("objectTypeId") String objectTypeId);

    @Select("SELECT * FROM object_type_interfaces_mapping WHERE interface_id = #{interfaceId} ORDER BY created_at DESC")
    List<ObjectTypeInterfaceMapping> selectByInterfaceId(@Param("interfaceId") String interfaceId);

    @Select("SELECT * FROM object_type_interfaces_mapping WHERE status = 'pending' ORDER BY created_at DESC")
    List<ObjectTypeInterfaceMapping> selectPendingOrdered();
}
