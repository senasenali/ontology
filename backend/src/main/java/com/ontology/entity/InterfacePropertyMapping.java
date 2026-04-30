package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("interface_property_mapping")
public class InterfacePropertyMapping {

    @TableId(type = IdType.INPUT)
    private String id;

    private String objectTypeInterfaceMappingId;

    private String interfacePropertyId;

    private String propertyId;

    private String projectId;

    @TableField(exist = false)
    private String interfacePropertyName;

    @TableField(exist = false)
    private Integer interfacePropertyRequired;

    @TableField(exist = false)
    private String propertyName;
}
