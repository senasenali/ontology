package com.ontology.project;

public final class ProjectScope {

    public static final String PUBLIC_PROJECT_ID = "project_public";

    private ProjectScope() {
    }

    public static String normalize(String projectId) {
        if (projectId == null || projectId.isBlank()) {
            return PUBLIC_PROJECT_ID;
        }
        return projectId.trim();
    }
}
