package com.ontology.controller;

import com.ontology.entity.LithiumPriceMonitor;
import com.ontology.mapper.LithiumPriceMonitorMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/lithium-price-monitor")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LithiumPriceMonitorController {

    private final LithiumPriceMonitorMapper lithiumPriceMonitorMapper;

    @GetMapping("/recent")
    public Map<String, Object> recent(
        @RequestParam(defaultValue = "LC-BT-001-2024") String instanceId,
        @RequestParam(defaultValue = "2") Integer limit
    ) {
        List<LithiumPriceMonitor> records = lithiumPriceMonitorMapper.selectRecentByInstanceId(instanceId, Math.max(1, limit));
        return Map.of("success", true, "records", records);
    }

    @GetMapping("/compare")
    public Map<String, Object> compare(
        @RequestParam(defaultValue = "LC-BT-001-2024") String instanceId,
        @RequestParam(defaultValue = "5") Double thresholdPercent
    ) {
        List<LithiumPriceMonitor> records = lithiumPriceMonitorMapper.selectRecentByInstanceId(instanceId, 2);
        if (records.size() < 2) {
            return Map.of(
                "success", false,
                "message", "价格记录不足，至少需要两条监控数据",
                "records", records
            );
        }

        LithiumPriceMonitor latest = records.get(0);
        LithiumPriceMonitor previous = records.get(1);
        if (latest.getPrice() == null || previous.getPrice() == null || previous.getPrice().compareTo(BigDecimal.ZERO) == 0) {
            return Map.of("success", false, "message", "价格数据无效");
        }

        BigDecimal delta = latest.getPrice().subtract(previous.getPrice());
        BigDecimal percent = delta
            .divide(previous.getPrice(), 6, RoundingMode.HALF_UP)
            .multiply(BigDecimal.valueOf(100));
        BigDecimal absPercent = percent.abs();

        Map<String, Object> data = new HashMap<>();
        data.put("instanceId", instanceId);
        data.put("latest", latest);
        data.put("previous", previous);
        data.put("priceChangeAmount", delta.setScale(2, RoundingMode.HALF_UP));
        data.put("priceChangePercent", percent.setScale(2, RoundingMode.HALF_UP));
        data.put("thresholdPercent", BigDecimal.valueOf(thresholdPercent).setScale(2, RoundingMode.HALF_UP));
        data.put("thresholdExceeded", absPercent.compareTo(BigDecimal.valueOf(thresholdPercent)) >= 0);

        return Map.of("success", true, "data", data);
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody Map<String, Object> payload) {
        String instanceId = (String) payload.getOrDefault("instanceId", "LC-BT-001-2024");
        Object priceValue = payload.get("price");
        if (priceValue == null) {
            throw new RuntimeException("price is required");
        }

        LithiumPriceMonitor record = new LithiumPriceMonitor();
        record.setInstanceId(instanceId);
        record.setPrice(new BigDecimal(String.valueOf(priceValue)));
        record.setSource((String) payload.getOrDefault("source", "manual"));
        record.setCreatedAt(LocalDateTime.now());

        Object priceDate = payload.get("priceDate");
        if (priceDate instanceof String && !((String) priceDate).isBlank()) {
            record.setPriceDate(LocalDateTime.parse((String) priceDate));
        } else {
            record.setPriceDate(record.getCreatedAt());
        }

        lithiumPriceMonitorMapper.insert(record);
        return Map.of("success", true, "record", record);
    }
}
