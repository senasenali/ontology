package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("projects")
public class Project {

    @TableId(type = IdType.INPUT)
    private String id;

    private String name;

    private String description;

    private Integer isPublic;

    private String status;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
