package com.ontology.service;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OntologyRuleSyncRunner implements ApplicationRunner {

    private final RuleTemplateService ruleTemplateService;

    @Override
    public void run(ApplicationArguments args) {
        ruleTemplateService.syncAllRules();
    }
}
