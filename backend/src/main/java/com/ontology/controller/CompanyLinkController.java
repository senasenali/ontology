package com.ontology.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/company-links")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CompanyLinkController {

    private final JdbcTemplate jdbcTemplate;

    @PostMapping
    public Map<String, Object> createCompanyLink(@RequestBody Map<String, Object> request) {
        String sourceInstanceId = stringValue(request.get("sourceInstanceId"));
        String targetInstanceId = stringValue(request.get("targetInstanceId"));
        String linkTypeId = stringValue(request.get("linkTypeId"));
        String evidence = stringValue(request.get("evidence"));

        if (sourceInstanceId == null || targetInstanceId == null || linkTypeId == null) {
            return Map.of(
                    "success", false,
                    "error", "sourceInstanceId, targetInstanceId and linkTypeId are required"
            );
        }

        Integer sourceCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM company_entity WHERE company_id = ?",
                Integer.class,
                sourceInstanceId
        );
        Integer targetCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM company_entity WHERE company_id = ?",
                Integer.class,
                targetInstanceId
        );
        Integer linkTypeCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM link_types WHERE id = ?",
                Integer.class,
                linkTypeId
        );

        if (sourceCount == null || sourceCount == 0) {
            return Map.of("success", false, "error", "Source company instance not found");
        }
        if (targetCount == null || targetCount == 0) {
            return Map.of("success", false, "error", "Target company instance not found");
        }
        if (linkTypeCount == null || linkTypeCount == 0) {
            return Map.of("success", false, "error", "Link type not found");
        }

        Integer existing = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM link_instance_data WHERE link_type_id = ? AND source_instance_id = ? AND target_instance_id = ?",
                Integer.class,
                linkTypeId,
                sourceInstanceId,
                targetInstanceId
        );

        if (existing != null && existing > 0) {
            return Map.of(
                    "success", true,
                    "message", "Link already exists",
                    "data", Map.of(
                            "sourceInstanceId", sourceInstanceId,
                            "targetInstanceId", targetInstanceId,
                            "linkTypeId", linkTypeId,
                            "evidence", evidence == null ? "" : evidence
                    )
            );
        }

        jdbcTemplate.update(
                "INSERT INTO link_instance_data (link_type_id, source_instance_id, target_instance_id, created_at) VALUES (?, ?, ?, ?)",
                linkTypeId,
                sourceInstanceId,
                targetInstanceId,
                LocalDateTime.now()
        );

        return Map.of(
                "success", true,
                "message", "Company strategic cooperation link created",
                "data", Map.of(
                        "sourceInstanceId", sourceInstanceId,
                        "targetInstanceId", targetInstanceId,
                        "linkTypeId", linkTypeId,
                        "evidence", evidence == null ? "" : evidence
                )
        );
    }

    @DeleteMapping
    public Map<String, Object> deleteCompanyLink(@RequestBody Map<String, Object> request) {
        String sourceInstanceId = stringValue(request.get("sourceInstanceId"));
        String targetInstanceId = stringValue(request.get("targetInstanceId"));
        String linkTypeId = stringValue(request.get("linkTypeId"));

        if (sourceInstanceId == null || targetInstanceId == null || linkTypeId == null) {
            return Map.of(
                    "success", false,
                    "error", "sourceInstanceId, targetInstanceId and linkTypeId are required"
            );
        }

        Integer deleted = jdbcTemplate.update(
                """
                DELETE FROM link_instance_data
                WHERE link_type_id = ?
                  AND (
                    (source_instance_id = ? AND target_instance_id = ?)
                    OR (source_instance_id = ? AND target_instance_id = ?)
                  )
                """,
                linkTypeId,
                sourceInstanceId,
                targetInstanceId,
                targetInstanceId,
                sourceInstanceId
        );

        return Map.of(
                "success", true,
                "message", deleted != null && deleted > 0 ? "Company link deleted" : "Company link not found",
                "data", Map.of(
                        "sourceInstanceId", sourceInstanceId,
                        "targetInstanceId", targetInstanceId,
                        "linkTypeId", linkTypeId,
                        "deleted", deleted == null ? 0 : deleted
                )
        );
    }

    private String stringValue(Object value) {
        if (value == null) return null;
        String text = String.valueOf(value).trim();
        return text.isEmpty() ? null : text;
    }
}
