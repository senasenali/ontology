package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("interfaces")
public class OntologyInterface {

    @TableId(type = IdType.INPUT)
    private String id;

    private String name;

    private String description;

    private String industryId;

    private String projectId;

    private String status;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String parentInterfaceId;

    @TableField(exist = false)
    private String parentInterfaceName;

    @TableField(exist = false)
    private List<OntologyInterface> childInterfaces;

    @TableField(exist = false)
    private List<InterfaceProperty> properties;

    @TableField(exist = false)
    private List<InterfaceLinkConstraint> linkTypeConstraints;

    @TableField(exist = false)
    private List<ObjectTypeInterfaceMapping> implementedObjectTypes;
}
