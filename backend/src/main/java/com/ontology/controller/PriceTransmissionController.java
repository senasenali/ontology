package com.ontology.controller;

import com.ontology.service.PriceTransmissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/analysis")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PriceTransmissionController {
    
    private final PriceTransmissionService priceTransmissionService;
    
    @PostMapping("/price-transmission")
    public Map<String, Object> calculatePriceTransmission(@RequestBody Map<String, Object> request) {
        String sourceObjectTypeId = firstNonBlank(
                (String) request.get("sourceObjectTypeId"),
                (String) request.get("objectTypeId"),
                "lithium_carbonate"
        );
        String sourceInstanceId = firstNonBlank(
                (String) request.get("sourceInstanceId"),
                (String) request.get("instanceId")
        );
        String direction = firstNonBlank((String) request.get("direction"), "downstream");
        
        // 处理 depth 参数，支持字符串和数字类型
        Integer depth = 3;
        Object depthObj = request.get("depth");
        if (depthObj != null) {
            if (depthObj instanceof Number) {
                depth = ((Number) depthObj).intValue();
            } else if (depthObj instanceof String) {
                try {
                    depth = Integer.parseInt((String) depthObj);
                } catch (NumberFormatException e) {
                    return Map.of("success", false, "error", "depth must be a valid number");
                }
            }
        }
        
        Double previousPrice = parseDouble(request.get("previousPrice"), "previousPrice must be a valid number");
        if (previousPrice instanceof Double && Double.isNaN(previousPrice)) {
            return Map.of("success", false, "error", "previousPrice must be a valid number");
        }

        Double priceChangePercent = parseDouble(request.get("priceChangePercent"), "priceChangePercent must be a valid number");
        if (priceChangePercent instanceof Double && Double.isNaN(priceChangePercent)) {
            return Map.of("success", false, "error", "priceChangePercent must be a valid number");
        }

        Double latestPrice = parseDouble(request.get("latestPrice"), "latestPrice must be a valid number");
        if (latestPrice instanceof Double && Double.isNaN(latestPrice)) {
            return Map.of("success", false, "error", "latestPrice must be a valid number");
        }
        
        if (sourceInstanceId == null || sourceInstanceId.isEmpty()) {
            return Map.of("success", false, "error", "sourceInstanceId is required");
        }
        if (priceChangePercent == null && (latestPrice == null || latestPrice <= 0)) {
            return Map.of("success", false, "error", "priceChangePercent is required");
        }
        if (latestPrice != null && latestPrice <= 0) {
            return Map.of("success", false, "error", "latestPrice must be positive");
        }
        if (depth < 1 || depth > 5) {
            return Map.of("success", false, "error", "depth must be between 1 and 5");
        }
        
        return priceTransmissionService.calculatePriceTransmission(sourceObjectTypeId, sourceInstanceId, priceChangePercent, latestPrice, previousPrice, depth, direction);
    }

    @PostMapping("/price-transmission/object-type")
    public Map<String, Object> calculateObjectTypePriceTransmission(@RequestBody Map<String, Object> request) {
        String objectTypeId = firstNonBlank(
                (String) request.get("sourceObjectTypeId"),
                (String) request.get("objectTypeId")
        );
        String direction = firstNonBlank((String) request.get("direction"), "downstream");

        Integer depth = 4;
        Object depthObj = request.get("depth");
        if (depthObj != null) {
            if (depthObj instanceof Number) {
                depth = ((Number) depthObj).intValue();
            } else if (depthObj instanceof String) {
                try {
                    depth = Integer.parseInt((String) depthObj);
                } catch (NumberFormatException e) {
                    return Map.of("success", false, "error", "depth must be a valid number");
                }
            }
        }

        Double priceChangePercent = parseDouble(request.get("priceChangePercent"), "priceChangePercent must be a valid number");
        if (priceChangePercent instanceof Double && Double.isNaN(priceChangePercent)) {
            return Map.of("success", false, "error", "priceChangePercent must be a valid number");
        }

        Double previousPrice = parseDouble(request.get("previousPrice"), "previousPrice must be a valid number");
        if (previousPrice instanceof Double && Double.isNaN(previousPrice)) {
            return Map.of("success", false, "error", "previousPrice must be a valid number");
        }

        Double latestPrice = parseDouble(request.get("latestPrice"), "latestPrice must be a valid number");
        if (latestPrice instanceof Double && Double.isNaN(latestPrice)) {
            return Map.of("success", false, "error", "latestPrice must be a valid number");
        }

        if (objectTypeId == null || objectTypeId.isEmpty()) {
            return Map.of("success", false, "error", "objectTypeId is required");
        }
        if (priceChangePercent == null) {
            return Map.of("success", false, "error", "priceChangePercent is required");
        }
        if (depth < 1 || depth > 5) {
            return Map.of("success", false, "error", "depth must be between 1 and 5");
        }

        return priceTransmissionService.calculateObjectTypePriceTransmission(objectTypeId, priceChangePercent, depth, direction, previousPrice, latestPrice);
    }

    private Double parseDouble(Object value, String _unusedErrorMessage) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        if (value instanceof String) {
            String stringValue = ((String) value).trim();
            if (stringValue.isEmpty()) {
                return null;
            }
            try {
                return Double.parseDouble(stringValue);
            } catch (NumberFormatException e) {
                return Double.NaN;
            }
        }
        return Double.NaN;
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }
}
