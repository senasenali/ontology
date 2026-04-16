package com.ontology.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ontology.entity.LithiumPriceMonitor;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface LithiumPriceMonitorMapper extends BaseMapper<LithiumPriceMonitor> {

    @Select("SELECT * FROM lithium_price_monitor WHERE instance_id = #{instanceId} ORDER BY COALESCE(price_date, created_at) DESC, id DESC LIMIT #{limit}")
    List<LithiumPriceMonitor> selectRecentByInstanceId(@Param("instanceId") String instanceId, @Param("limit") int limit);
}
