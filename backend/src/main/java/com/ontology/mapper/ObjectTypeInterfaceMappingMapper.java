package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.ObjectTypeInterfaceMapping;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ObjectTypeInterfaceMappingMapper extends BaseMapper<ObjectTypeInterfaceMapping> {

    @Select("SELECT COUNT(*) FROM object_type_interfaces_mapping WHERE interface_id = #{interfaceId} AND project_id = #{projectId}")
    Long countByInterfaceId(@Param("interfaceId") String interfaceId, @Param("projectId") String projectId);

    @Select("SELECT COUNT(*) FROM object_type_interfaces_mapping WHERE object_type_id = #{objectTypeId} AND project_id = #{projectId}")
    Long countByObjectTypeId(@Param("objectTypeId") String objectTypeId, @Param("projectId") String projectId);

    @Select("SELECT * FROM object_type_interfaces_mapping WHERE object_type_id = #{objectTypeId} AND project_id = #{projectId} ORDER BY created_at DESC")
    List<ObjectTypeInterfaceMapping> selectByObjectTypeId(@Param("objectTypeId") String objectTypeId, @Param("projectId") String projectId);

    @Select("SELECT * FROM object_type_interfaces_mapping WHERE interface_id = #{interfaceId} AND project_id = #{projectId} ORDER BY created_at DESC")
    List<ObjectTypeInterfaceMapping> selectByInterfaceId(@Param("interfaceId") String interfaceId, @Param("projectId") String projectId);

    @Select("SELECT * FROM object_type_interfaces_mapping WHERE status = 'pending' AND project_id = #{projectId} ORDER BY created_at DESC")
    List<ObjectTypeInterfaceMapping> selectPendingOrdered(@Param("projectId") String projectId);
}
