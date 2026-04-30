package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("object_type_interfaces_mapping")
public class ObjectTypeInterfaceMapping {

    @TableId(type = IdType.INPUT)
    private String id;

    private String objectTypeId;

    private String interfaceId;

    private String status;

    private String projectId;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String objectTypeName;

    @TableField(exist = false)
    private String interfaceName;

    @TableField(exist = false)
    private String interfaceDescription;

    @TableField(exist = false)
    private List<InterfaceProperty> interfaceProperties;

    @TableField(exist = false)
    private List<InterfacePropertyMapping> propertyMappings;

    @TableField(exist = false)
    private Boolean mappingComplete;
}
