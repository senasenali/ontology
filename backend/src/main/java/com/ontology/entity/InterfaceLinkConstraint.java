package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("interface_link_constraints")
public class InterfaceLinkConstraint {

    @TableId(type = IdType.INPUT)
    private String id;

    private String interfaceId;

    private String name;

    private String targetType;

    private String targetInterfaceId;

    private String targetObjectTypeId;

    private String cardinality;

    private Integer required;

    private String status;

    private String projectId;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private Boolean inherited;

    @TableField(exist = false)
    private String sourceInterfaceId;

    @TableField(exist = false)
    private String sourceInterfaceName;

    @TableField(exist = false)
    private String targetName;
}
