package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.ActionRuleParam;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;

import java.util.List;

@Mapper
public interface ActionRuleParamMapper extends BaseMapper<ActionRuleParam> {
    
    @Select("SELECT * FROM action_rule_params WHERE action_rule_id = #{actionRuleId} ORDER BY sort_order")
    List<ActionRuleParam> selectByActionRuleId(@Param("actionRuleId") String actionRuleId);
    
    @Delete("DELETE FROM action_rule_params WHERE action_rule_id IN (SELECT id FROM action_rules WHERE action_type_id = #{actionTypeId})")
    void deleteByActionTypeId(@Param("actionTypeId") String actionTypeId);

    @Delete("DELETE FROM action_rule_params WHERE param_value IS NULL OR TRIM(param_value) = ''")
    int deleteBlankValues();

    @Delete("""
            DELETE arp FROM action_rule_params arp
            JOIN action_rules ar ON ar.id = arp.action_rule_id
            LEFT JOIN ontology_rule_params orp
              ON orp.rule_id = ar.ontology_rule_id
             AND orp.param_direction = 'INPUT'
             AND orp.param_name = arp.param_name
            WHERE ar.rule_type = 'ONTOLOGY'
              AND orp.id IS NULL
            """)
    int deleteInvalidOntologyBindings();
}
