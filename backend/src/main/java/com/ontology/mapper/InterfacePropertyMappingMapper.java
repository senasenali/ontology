package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.InterfacePropertyMapping;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InterfacePropertyMappingMapper extends BaseMapper<InterfacePropertyMapping> {

    @Select("SELECT * FROM interface_property_mapping WHERE object_type_interface_mapping_id = #{mappingId} ORDER BY interface_property_id")
    List<InterfacePropertyMapping> selectByObjectTypeInterfaceMappingId(@Param("mappingId") String mappingId);

    @Select("SELECT COUNT(*) FROM interface_property_mapping WHERE property_id = #{propertyId}")
    Long countByPropertyId(@Param("propertyId") String propertyId);
}
