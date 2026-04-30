UPDATE link_types
SET name = '电芯由电解液组成',
    updated_at = NOW()
WHERE id = 'lt_battery_cell_battery_electrolyte_1775655447785';

UPDATE link_types
SET name = '电解液由碳酸锂组成',
    updated_at = NOW()
WHERE id = 'lt_battery_electrolyte_lithium_carbonate_1775655437902';

UPDATE link_types
SET name = '电芯由正极材料组成',
    updated_at = NOW()
WHERE id = 'lt_battery_cell_cathode_material_1775472265881';

UPDATE link_types
SET name = '电池装载于整车',
    updated_at = NOW()
WHERE id = 'lt_power_battery_new_energy_vehicle_1775374603746';
