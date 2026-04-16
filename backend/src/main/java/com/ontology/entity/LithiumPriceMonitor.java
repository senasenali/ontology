package com.ontology.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("lithium_price_monitor")
public class LithiumPriceMonitor {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String instanceId;

    private BigDecimal price;

    private LocalDateTime priceDate;

    private String source;

    private LocalDateTime createdAt;
}
