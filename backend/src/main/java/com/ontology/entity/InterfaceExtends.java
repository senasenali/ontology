package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("interface_extends")
public class InterfaceExtends {

    @TableId(type = IdType.INPUT)
    private String id;

    private String parentInterfaceId;

    private String childInterfaceId;

    private String projectId;
}
