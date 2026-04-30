package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("interface_properties")
public class InterfaceProperty {

    @TableId(type = IdType.INPUT)
    private String id;

    private String interfaceId;

    private String name;

    private String type;

    private String description;

    private Integer required;

    private Integer sortOrder;

    private String projectId;

    @TableField(exist = false)
    private Boolean inherited;

    @TableField(exist = false)
    private String sourceInterfaceId;

    @TableField(exist = false)
    private String sourceInterfaceName;
}
