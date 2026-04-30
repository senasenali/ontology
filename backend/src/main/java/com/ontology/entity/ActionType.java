package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("action_types")
public class ActionType {
    
    @TableId(type = IdType.INPUT)
    private String id;
    
    private String displayName;
    
    private String description;
    
    private String status;

    private String projectId;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    @TableField(exist = false)
    private List<ActionRule> rules;
    
    @TableField(exist = false)
    private List<ActionEffect> effects;
}
