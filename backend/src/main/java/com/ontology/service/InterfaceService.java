package com.ontology.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ontology.entity.InterfaceExtends;
import com.ontology.entity.InterfaceLinkConstraint;
import com.ontology.entity.InterfaceProperty;
import com.ontology.entity.InterfacePropertyMapping;
import com.ontology.entity.ObjectType;
import com.ontology.entity.ObjectTypeInterfaceMapping;
import com.ontology.entity.OntologyInterface;
import com.ontology.entity.Property;
import com.ontology.mapper.InterfaceExtendsMapper;
import com.ontology.mapper.InterfaceLinkConstraintMapper;
import com.ontology.mapper.InterfaceMapper;
import com.ontology.mapper.InterfacePropertyMapper;
import com.ontology.mapper.InterfacePropertyMappingMapper;
import com.ontology.mapper.ObjectTypeInterfaceMappingMapper;
import com.ontology.mapper.ObjectTypeMapper;
import com.ontology.mapper.PropertyMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class InterfaceService {

    private final InterfaceMapper interfaceMapper;
    private final InterfacePropertyMapper interfacePropertyMapper;
    private final InterfaceExtendsMapper interfaceExtendsMapper;
    private final InterfaceLinkConstraintMapper interfaceLinkConstraintMapper;
    private final InterfacePropertyMappingMapper interfacePropertyMappingMapper;
    private final ObjectTypeMapper objectTypeMapper;
    private final PropertyMapper propertyMapper;
    private final ObjectTypeInterfaceMappingMapper objectTypeInterfaceMappingMapper;

    public List<OntologyInterface> listOntologyInterfaces() {
        List<OntologyInterface> interfaces = interfaceMapper.selectAllOrdered();
        return enrichInterfaces(interfaces, false);
    }

    public List<OntologyInterface> listOntologyInterfacesByIndustry(Set<String> industryIds) {
        if (industryIds == null || industryIds.isEmpty()) {
            return List.of();
        }
        List<OntologyInterface> interfaces = interfaceMapper.selectList(
                new LambdaQueryWrapper<OntologyInterface>()
                        .in(OntologyInterface::getIndustryId, industryIds)
                        .orderByAsc(OntologyInterface::getName)
        );
        return enrichInterfaces(interfaces, false);
    }

    public OntologyInterface getInterfaceDetail(String id) {
        OntologyInterface ontologyInterface = requireInterface(id);
        hydrateInterface(ontologyInterface, true);
        ontologyInterface.setProperties(buildEffectiveProperties(id));
        ontologyInterface.setLinkTypeConstraints(buildEffectiveLinkTypeConstraints(id));
        return ontologyInterface;
    }

    @Transactional
    public OntologyInterface createInterface(OntologyInterface request) {
        validateInterfaceForCreate(request);
        if (isBlank(request.getStatus())) {
            request.setStatus("pending");
        }
        interfaceMapper.insert(request);
        return getInterfaceDetail(request.getId());
    }

    @Transactional
    public OntologyInterface updateInterface(String id, OntologyInterface request) {
        OntologyInterface existing = requireInterface(id);
        existing.setName(firstNonBlank(request.getName(), existing.getName()));
        existing.setDescription(request.getDescription() != null ? request.getDescription() : existing.getDescription());
        existing.setIndustryId(request.getIndustryId() != null ? request.getIndustryId() : existing.getIndustryId());
        existing.setStatus(firstNonBlank(request.getStatus(), existing.getStatus()));
        validateInterfaceForUpdate(existing);
        interfaceMapper.updateById(existing);
        return getInterfaceDetail(id);
    }

    @Transactional
    public void deleteInterface(String id) {
        requireInterface(id);
        List<InterfaceExtends> childRelations = interfaceExtendsMapper.selectByParentInterfaceId(id);
        if (!childRelations.isEmpty()) {
            throw new IllegalArgumentException("请先解除子 Interface 的继承关系");
        }
        Long mappingCount = objectTypeInterfaceMappingMapper.countByInterfaceId(id);
        if (mappingCount != null && mappingCount > 0) {
            throw new IllegalArgumentException("请先移除 Object Type 的实现关系");
        }
        InterfaceExtends parentRelation = interfaceExtendsMapper.selectByChildInterfaceId(id);
        if (parentRelation != null) {
            interfaceExtendsMapper.deleteById(parentRelation.getId());
        }
        interfaceMapper.deleteById(id);
    }

    @Transactional
    public InterfaceProperty addProperty(String interfaceId, InterfaceProperty property) {
        requireInterface(interfaceId);
        validateProperty(property);
        property.setInterfaceId(interfaceId);
        interfacePropertyMapper.insert(property);
        return property;
    }

    @Transactional
    public InterfaceProperty updateProperty(String interfaceId, String propertyId, InterfaceProperty request) {
        requireInterface(interfaceId);
        InterfaceProperty existing = requireProperty(propertyId);
        if (!Objects.equals(existing.getInterfaceId(), interfaceId)) {
            throw new IllegalArgumentException("属性不属于该 Interface");
        }
        existing.setName(firstNonBlank(request.getName(), existing.getName()));
        existing.setType(firstNonBlank(request.getType(), existing.getType()));
        existing.setDescription(request.getDescription() != null ? request.getDescription() : existing.getDescription());
        existing.setRequired(request.getRequired() != null ? request.getRequired() : existing.getRequired());
        existing.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : existing.getSortOrder());
        validateProperty(existing);
        interfacePropertyMapper.updateById(existing);
        return existing;
    }

    @Transactional
    public void deleteProperty(String interfaceId, String propertyId) {
        requireInterface(interfaceId);
        InterfaceProperty existing = requireProperty(propertyId);
        if (!Objects.equals(existing.getInterfaceId(), interfaceId)) {
            throw new IllegalArgumentException("属性不属于该 Interface");
        }
        interfacePropertyMapper.deleteById(propertyId);
    }

    @Transactional
    public OntologyInterface setExtends(String childInterfaceId, String parentInterfaceId) {
        OntologyInterface child = requireInterface(childInterfaceId);
        OntologyInterface parent = requireInterface(parentInterfaceId);
        if (Objects.equals(child.getId(), parent.getId())) {
            throw new IllegalArgumentException("Interface 不能继承自己");
        }
        ensureNoCycle(childInterfaceId, parentInterfaceId);
        InterfaceExtends relation = interfaceExtendsMapper.selectByChildInterfaceId(childInterfaceId);
        if (relation == null) {
            relation = new InterfaceExtends();
            relation.setId(buildStableId("ie", childInterfaceId, parentInterfaceId));
            relation.setChildInterfaceId(childInterfaceId);
            relation.setParentInterfaceId(parentInterfaceId);
            interfaceExtendsMapper.insert(relation);
        } else {
            relation.setParentInterfaceId(parentInterfaceId);
            interfaceExtendsMapper.updateById(relation);
        }
        return getInterfaceDetail(child.getId());
    }

    @Transactional
    public OntologyInterface removeExtends(String childInterfaceId) {
        requireInterface(childInterfaceId);
        InterfaceExtends relation = interfaceExtendsMapper.selectByChildInterfaceId(childInterfaceId);
        if (relation != null) {
            interfaceExtendsMapper.deleteById(relation.getId());
        }
        return getInterfaceDetail(childInterfaceId);
    }

    @Transactional
    public InterfaceLinkConstraint addLinkTypeConstraint(String interfaceId, InterfaceLinkConstraint constraint) {
        requireInterface(interfaceId);
        constraint.setInterfaceId(interfaceId);
        if (isBlank(constraint.getStatus())) {
            constraint.setStatus("pending");
        }
        validateLinkTypeConstraint(constraint);
        interfaceLinkConstraintMapper.insert(constraint);
        return enrichLinkTypeConstraint(constraint);
    }

    @Transactional
    public InterfaceLinkConstraint updateLinkTypeConstraint(String interfaceId, String constraintId, InterfaceLinkConstraint request) {
        requireInterface(interfaceId);
        InterfaceLinkConstraint existing = requireLinkTypeConstraint(constraintId);
        if (!Objects.equals(existing.getInterfaceId(), interfaceId)) {
            throw new IllegalArgumentException("Link Type Constraint 不属于该 Interface");
        }
        existing.setName(firstNonBlank(request.getName(), existing.getName()));
        existing.setTargetType(firstNonBlank(request.getTargetType(), existing.getTargetType()));
        existing.setTargetInterfaceId(request.getTargetInterfaceId());
        existing.setTargetObjectTypeId(request.getTargetObjectTypeId());
        existing.setCardinality(firstNonBlank(request.getCardinality(), existing.getCardinality()));
        existing.setRequired(request.getRequired() != null ? request.getRequired() : existing.getRequired());
        existing.setStatus(firstNonBlank(request.getStatus(), existing.getStatus()));
        validateLinkTypeConstraint(existing);
        interfaceLinkConstraintMapper.updateById(existing);
        return enrichLinkTypeConstraint(existing);
    }

    @Transactional
    public void deleteLinkTypeConstraint(String interfaceId, String constraintId) {
        requireInterface(interfaceId);
        InterfaceLinkConstraint existing = requireLinkTypeConstraint(constraintId);
        if (!Objects.equals(existing.getInterfaceId(), interfaceId)) {
            throw new IllegalArgumentException("Link Type Constraint 不属于该 Interface");
        }
        interfaceLinkConstraintMapper.deleteById(constraintId);
    }

    public List<ObjectTypeInterfaceMapping> listObjectTypeInterfaceMappings(String objectTypeId) {
        requireObjectType(objectTypeId);
        List<ObjectTypeInterfaceMapping> mappings = objectTypeInterfaceMappingMapper.selectByObjectTypeId(objectTypeId);
        return enrichObjectTypeInterfaceMappings(mappings);
    }

    @Transactional
    public ObjectTypeInterfaceMapping saveObjectTypeInterfaceMapping(String objectTypeId, ObjectTypeInterfaceMapping request) {
        ObjectType objectType = requireObjectType(objectTypeId);
        if (request == null || isBlank(request.getInterfaceId())) {
            throw new IllegalArgumentException("请选择要实现的 Interface");
        }

        OntologyInterface ontologyInterface = requireInterface(request.getInterfaceId());
        ObjectTypeInterfaceMapping existing = null;
        if (!isBlank(request.getId())) {
            existing = requireObjectTypeInterfaceMapping(request.getId());
            if (!Objects.equals(existing.getObjectTypeId(), objectTypeId)) {
                throw new IllegalArgumentException("实现关系不属于该 Object Type");
            }
        } else {
            for (ObjectTypeInterfaceMapping mapping : objectTypeInterfaceMappingMapper.selectByObjectTypeId(objectTypeId)) {
                if (Objects.equals(mapping.getInterfaceId(), request.getInterfaceId())) {
                    throw new IllegalArgumentException("该 Object Type 已实现此 Interface");
                }
            }
        }

        List<InterfaceProperty> effectiveProperties = buildEffectiveProperties(ontologyInterface.getId());
        validatePropertyMappings(objectType, effectiveProperties, request.getPropertyMappings());

        ObjectTypeInterfaceMapping mapping = existing != null ? existing : new ObjectTypeInterfaceMapping();
        if (existing == null) {
            mapping.setId(isBlank(request.getId()) ? buildStableId("otim", objectTypeId, ontologyInterface.getId()) : request.getId());
            mapping.setObjectTypeId(objectTypeId);
            mapping.setInterfaceId(ontologyInterface.getId());
            mapping.setStatus(isBlank(request.getStatus()) ? "pending" : request.getStatus());
            objectTypeInterfaceMappingMapper.insert(mapping);
        } else {
            mapping.setStatus(firstNonBlank(request.getStatus(), mapping.getStatus()));
            objectTypeInterfaceMappingMapper.updateById(mapping);
        }

        replacePropertyMappings(mapping.getId(), request.getPropertyMappings());
        return enrichObjectTypeInterfaceMapping(requireObjectTypeInterfaceMapping(mapping.getId()));
    }

    @Transactional
    public void deleteObjectTypeInterfaceMapping(String objectTypeId, String mappingId) {
        requireObjectType(objectTypeId);
        ObjectTypeInterfaceMapping mapping = requireObjectTypeInterfaceMapping(mappingId);
        if (!Objects.equals(mapping.getObjectTypeId(), objectTypeId)) {
            throw new IllegalArgumentException("实现关系不属于该 Object Type");
        }
        objectTypeInterfaceMappingMapper.deleteById(mappingId);
    }

    @Transactional
    public void approveObjectTypeInterfaceMapping(String id) {
        ObjectTypeInterfaceMapping mapping = requireObjectTypeInterfaceMapping(id);
        mapping.setStatus("active");
        objectTypeInterfaceMappingMapper.updateById(mapping);
    }

    @Transactional
    public void rejectObjectTypeInterfaceMapping(String id) {
        requireObjectTypeInterfaceMapping(id);
        objectTypeInterfaceMappingMapper.deleteById(id);
    }

    @Transactional
    public void approveInterface(String id) {
        OntologyInterface ontologyInterface = requireInterface(id);
        ontologyInterface.setStatus("active");
        interfaceMapper.updateById(ontologyInterface);
    }

    @Transactional
    public void rejectInterface(String id) {
        deleteInterface(id);
    }

    public List<OntologyInterface> listPendingInterfaces() {
        return enrichInterfaces(
                interfaceMapper.selectList(new LambdaQueryWrapper<OntologyInterface>()
                        .eq(OntologyInterface::getStatus, "pending")
                        .orderByDesc(OntologyInterface::getCreatedAt)),
                false
        );
    }

    public List<ObjectTypeInterfaceMapping> listPendingObjectTypeInterfaceMappings() {
        return enrichObjectTypeInterfaceMappings(objectTypeInterfaceMappingMapper.selectPendingOrdered());
    }

    private List<OntologyInterface> enrichInterfaces(List<OntologyInterface> interfaces, boolean includeChildren) {
        for (OntologyInterface ontologyInterface : interfaces) {
            hydrateInterface(ontologyInterface, includeChildren);
        }
        return interfaces;
    }

    private void hydrateInterface(OntologyInterface ontologyInterface, boolean includeChildren) {
        InterfaceExtends parentRelation = interfaceExtendsMapper.selectByChildInterfaceId(ontologyInterface.getId());
        if (parentRelation != null) {
            ontologyInterface.setParentInterfaceId(parentRelation.getParentInterfaceId());
            OntologyInterface parent = interfaceMapper.selectById(parentRelation.getParentInterfaceId());
            ontologyInterface.setParentInterfaceName(parent != null ? parent.getName() : null);
        }
        ontologyInterface.setProperties(interfacePropertyMapper.selectByInterfaceId(ontologyInterface.getId()));
        ontologyInterface.setLinkTypeConstraints(enrichLinkTypeConstraints(interfaceLinkConstraintMapper.selectByInterfaceId(ontologyInterface.getId())));
        ontologyInterface.setImplementedObjectTypes(
                enrichObjectTypeInterfaceMappings(objectTypeInterfaceMappingMapper.selectByInterfaceId(ontologyInterface.getId()))
        );
        if (includeChildren) {
            List<OntologyInterface> children = new ArrayList<>();
            for (InterfaceExtends childRelation : interfaceExtendsMapper.selectByParentInterfaceId(ontologyInterface.getId())) {
                OntologyInterface child = interfaceMapper.selectById(childRelation.getChildInterfaceId());
                if (child != null) {
                    child.setParentInterfaceId(ontologyInterface.getId());
                    child.setParentInterfaceName(ontologyInterface.getName());
                    children.add(child);
                }
            }
            ontologyInterface.setChildInterfaces(children);
        }
    }

    private List<InterfaceProperty> buildEffectiveProperties(String interfaceId) {
        LinkedHashMap<String, InterfaceProperty> properties = new LinkedHashMap<>();
        for (String ancestorId : collectLineage(interfaceId)) {
            OntologyInterface source = interfaceMapper.selectById(ancestorId);
            for (InterfaceProperty property : interfacePropertyMapper.selectByInterfaceId(ancestorId)) {
                InterfaceProperty copy = copyProperty(property);
                copy.setInherited(!Objects.equals(ancestorId, interfaceId));
                copy.setSourceInterfaceId(ancestorId);
                copy.setSourceInterfaceName(source != null ? source.getName() : ancestorId);
                properties.put(copy.getId(), copy);
            }
        }
        return new ArrayList<>(properties.values());
    }

    private List<InterfaceLinkConstraint> buildEffectiveLinkTypeConstraints(String interfaceId) {
        LinkedHashMap<String, InterfaceLinkConstraint> constraints = new LinkedHashMap<>();
        for (String ancestorId : collectLineage(interfaceId)) {
            OntologyInterface source = interfaceMapper.selectById(ancestorId);
            for (InterfaceLinkConstraint constraint : interfaceLinkConstraintMapper.selectByInterfaceId(ancestorId)) {
                InterfaceLinkConstraint copy = copyLinkTypeConstraint(constraint);
                copy.setInherited(!Objects.equals(ancestorId, interfaceId));
                copy.setSourceInterfaceId(ancestorId);
                copy.setSourceInterfaceName(source != null ? source.getName() : ancestorId);
                constraints.put(copy.getId(), enrichLinkTypeConstraint(copy));
            }
        }
        return new ArrayList<>(constraints.values());
    }

    private List<InterfaceLinkConstraint> enrichLinkTypeConstraints(List<InterfaceLinkConstraint> constraints) {
        List<InterfaceLinkConstraint> result = new ArrayList<>();
        for (InterfaceLinkConstraint constraint : constraints) {
            result.add(enrichLinkTypeConstraint(constraint));
        }
        return result;
    }

    private InterfaceLinkConstraint enrichLinkTypeConstraint(InterfaceLinkConstraint constraint) {
        if ("interface".equals(constraint.getTargetType()) && !isBlank(constraint.getTargetInterfaceId())) {
            OntologyInterface target = interfaceMapper.selectById(constraint.getTargetInterfaceId());
            constraint.setTargetName(target != null ? target.getName() : constraint.getTargetInterfaceId());
        } else if ("object_type".equals(constraint.getTargetType()) && !isBlank(constraint.getTargetObjectTypeId())) {
            ObjectType target = objectTypeMapper.selectById(constraint.getTargetObjectTypeId());
            constraint.setTargetName(target != null ? target.getName() : constraint.getTargetObjectTypeId());
        }
        return constraint;
    }

    private List<ObjectTypeInterfaceMapping> enrichObjectTypeInterfaceMappings(List<ObjectTypeInterfaceMapping> mappings) {
        List<ObjectTypeInterfaceMapping> result = new ArrayList<>();
        for (ObjectTypeInterfaceMapping mapping : mappings) {
            result.add(enrichObjectTypeInterfaceMapping(mapping));
        }
        return result;
    }

    private ObjectTypeInterfaceMapping enrichObjectTypeInterfaceMapping(ObjectTypeInterfaceMapping mapping) {
        OntologyInterface ontologyInterface = requireInterface(mapping.getInterfaceId());
        ObjectType objectType = requireObjectType(mapping.getObjectTypeId());
        mapping.setInterfaceName(ontologyInterface.getName());
        mapping.setInterfaceDescription(ontologyInterface.getDescription());
        mapping.setObjectTypeName(objectType.getName());
        List<InterfaceProperty> effectiveProperties = buildEffectiveProperties(mapping.getInterfaceId());
        mapping.setInterfaceProperties(effectiveProperties);
        List<InterfacePropertyMapping> propertyMappings = interfacePropertyMappingMapper.selectByObjectTypeInterfaceMappingId(mapping.getId());
        Map<String, InterfaceProperty> interfacePropertyIndex = new HashMap<>();
        for (InterfaceProperty property : effectiveProperties) {
            interfacePropertyIndex.put(property.getId(), property);
        }
        Map<String, Property> objectPropertyIndex = new HashMap<>();
        for (Property property : propertyMapper.selectByObjectTypeId(mapping.getObjectTypeId())) {
            objectPropertyIndex.put(property.getId(), property);
        }
        for (InterfacePropertyMapping propertyMapping : propertyMappings) {
            InterfaceProperty interfaceProperty = interfacePropertyIndex.get(propertyMapping.getInterfacePropertyId());
            if (interfaceProperty != null) {
                propertyMapping.setInterfacePropertyName(interfaceProperty.getName());
                propertyMapping.setInterfacePropertyRequired(interfaceProperty.getRequired());
            }
            Property objectProperty = objectPropertyIndex.get(propertyMapping.getPropertyId());
            if (objectProperty != null) {
                propertyMapping.setPropertyName(objectProperty.getName());
            }
        }
        mapping.setPropertyMappings(propertyMappings);
        mapping.setMappingComplete(hasAllRequiredMappings(effectiveProperties, propertyMappings));
        return mapping;
    }

    private void validateInterfaceForCreate(OntologyInterface request) {
        if (request == null || isBlank(request.getId())) {
            throw new IllegalArgumentException("Interface ID 不能为空");
        }
        if (isBlank(request.getName())) {
            throw new IllegalArgumentException("Interface 名称不能为空");
        }
        if (interfaceMapper.selectById(request.getId()) != null) {
            throw new IllegalArgumentException("Interface ID 已存在");
        }
    }

    private void validateInterfaceForUpdate(OntologyInterface request) {
        if (request == null || isBlank(request.getId())) {
            throw new IllegalArgumentException("Interface ID 不能为空");
        }
        if (isBlank(request.getName())) {
            throw new IllegalArgumentException("Interface 名称不能为空");
        }
    }

    private void validateProperty(InterfaceProperty property) {
        if (property == null || isBlank(property.getId())) {
            throw new IllegalArgumentException("属性 ID 不能为空");
        }
        if (isBlank(property.getName())) {
            throw new IllegalArgumentException("属性名称不能为空");
        }
        if (isBlank(property.getType())) {
            throw new IllegalArgumentException("属性类型不能为空");
        }
    }

    private void validatePropertyMappings(
            ObjectType objectType,
            List<InterfaceProperty> effectiveProperties,
            List<InterfacePropertyMapping> propertyMappings
    ) {
        Map<String, InterfaceProperty> interfacePropertyIndex = new LinkedHashMap<>();
        for (InterfaceProperty property : effectiveProperties) {
            interfacePropertyIndex.put(property.getId(), property);
        }

        Map<String, Property> objectPropertyIndex = new LinkedHashMap<>();
        for (Property property : propertyMapper.selectByObjectTypeId(objectType.getId())) {
            objectPropertyIndex.put(property.getId(), property);
        }

        Set<String> mappedInterfacePropertyIds = new LinkedHashSet<>();
        if (propertyMappings != null) {
            for (InterfacePropertyMapping propertyMapping : propertyMappings) {
                if (isBlank(propertyMapping.getInterfacePropertyId()) || isBlank(propertyMapping.getPropertyId())) {
                    throw new IllegalArgumentException("属性映射不能为空");
                }
                InterfaceProperty interfaceProperty = interfacePropertyIndex.get(propertyMapping.getInterfacePropertyId());
                if (interfaceProperty == null) {
                    throw new IllegalArgumentException("存在无效的 Interface 属性映射");
                }
                if (!objectPropertyIndex.containsKey(propertyMapping.getPropertyId())) {
                    throw new IllegalArgumentException("属性映射必须指向当前 Object Type 的本地属性");
                }
                if (!mappedInterfacePropertyIds.add(propertyMapping.getInterfacePropertyId())) {
                    throw new IllegalArgumentException("同一个 Interface 属性只能映射一次");
                }
            }
        }

        List<String> missingRequired = new ArrayList<>();
        for (InterfaceProperty property : effectiveProperties) {
            if (property.getRequired() != null && property.getRequired() > 0
                    && !mappedInterfacePropertyIds.contains(property.getId())) {
                missingRequired.add(property.getName());
            }
        }
        if (!missingRequired.isEmpty()) {
            throw new IllegalArgumentException("以下必填属性未完成映射: " + String.join("、", missingRequired));
        }
    }

    private void validateLinkTypeConstraint(InterfaceLinkConstraint constraint) {
        if (constraint == null || isBlank(constraint.getId())) {
            throw new IllegalArgumentException("Link Type Constraint ID 不能为空");
        }
        if (isBlank(constraint.getName())) {
            throw new IllegalArgumentException("Link Type Constraint 名称不能为空");
        }
        if (!"interface".equals(constraint.getTargetType()) && !"object_type".equals(constraint.getTargetType())) {
            throw new IllegalArgumentException("target_type 只能是 interface 或 object_type");
        }
        if (!"1:1".equals(constraint.getCardinality()) && !"1:N".equals(constraint.getCardinality())) {
            throw new IllegalArgumentException("当前仅支持 1:1 或 1:N");
        }
        boolean hasTargetInterface = !isBlank(constraint.getTargetInterfaceId());
        boolean hasTargetObjectType = !isBlank(constraint.getTargetObjectTypeId());
        if (hasTargetInterface == hasTargetObjectType) {
            throw new IllegalArgumentException("目标 Interface 与目标 Object Type 只能选择一个");
        }
        if ("interface".equals(constraint.getTargetType())) {
            if (!hasTargetInterface || interfaceMapper.selectById(constraint.getTargetInterfaceId()) == null) {
                throw new IllegalArgumentException("目标 Interface 不存在");
            }
            constraint.setTargetObjectTypeId(null);
        } else {
            if (!hasTargetObjectType || objectTypeMapper.selectById(constraint.getTargetObjectTypeId()) == null) {
                throw new IllegalArgumentException("目标 Object Type 不存在");
            }
            constraint.setTargetInterfaceId(null);
        }
    }

    private void ensureNoCycle(String childInterfaceId, String parentInterfaceId) {
        String cursor = parentInterfaceId;
        while (!isBlank(cursor)) {
            if (Objects.equals(cursor, childInterfaceId)) {
                throw new IllegalArgumentException("无法建立继承关系：存在循环依赖");
            }
            InterfaceExtends relation = interfaceExtendsMapper.selectByChildInterfaceId(cursor);
            cursor = relation != null ? relation.getParentInterfaceId() : null;
        }
    }

    private List<String> collectLineage(String interfaceId) {
        LinkedHashSet<String> lineage = new LinkedHashSet<>();
        collectAncestors(interfaceId, lineage);
        lineage.add(interfaceId);
        return new ArrayList<>(lineage);
    }

    private void collectAncestors(String interfaceId, Set<String> lineage) {
        InterfaceExtends relation = interfaceExtendsMapper.selectByChildInterfaceId(interfaceId);
        if (relation == null || isBlank(relation.getParentInterfaceId())) {
            return;
        }
        collectAncestors(relation.getParentInterfaceId(), lineage);
        lineage.add(relation.getParentInterfaceId());
    }

    private OntologyInterface requireInterface(String id) {
        OntologyInterface ontologyInterface = interfaceMapper.selectById(id);
        if (ontologyInterface == null) {
            throw new IllegalArgumentException("Interface 不存在: " + id);
        }
        return ontologyInterface;
    }

    private ObjectType requireObjectType(String id) {
        ObjectType objectType = objectTypeMapper.selectById(id);
        if (objectType == null) {
            throw new IllegalArgumentException("Object Type 不存在: " + id);
        }
        return objectType;
    }

    private InterfaceProperty requireProperty(String id) {
        InterfaceProperty property = interfacePropertyMapper.selectById(id);
        if (property == null) {
            throw new IllegalArgumentException("Interface 属性不存在: " + id);
        }
        return property;
    }

    private InterfaceLinkConstraint requireLinkTypeConstraint(String id) {
        InterfaceLinkConstraint constraint = interfaceLinkConstraintMapper.selectById(id);
        if (constraint == null) {
            throw new IllegalArgumentException("Link Type Constraint 不存在: " + id);
        }
        return constraint;
    }

    private ObjectTypeInterfaceMapping requireObjectTypeInterfaceMapping(String id) {
        ObjectTypeInterfaceMapping mapping = objectTypeInterfaceMappingMapper.selectById(id);
        if (mapping == null) {
            throw new IllegalArgumentException("Object Type Interface 实现关系不存在: " + id);
        }
        return mapping;
    }

    private void replacePropertyMappings(String mappingId, List<InterfacePropertyMapping> propertyMappings) {
        List<InterfacePropertyMapping> existingMappings = interfacePropertyMappingMapper.selectByObjectTypeInterfaceMappingId(mappingId);
        for (InterfacePropertyMapping existingMapping : existingMappings) {
            interfacePropertyMappingMapper.deleteById(existingMapping.getId());
        }
        if (propertyMappings == null) {
            return;
        }
        for (InterfacePropertyMapping propertyMapping : propertyMappings) {
            InterfacePropertyMapping copy = new InterfacePropertyMapping();
            copy.setId(isBlank(propertyMapping.getId())
                    ? buildStableId("ipm", mappingId, propertyMapping.getInterfacePropertyId())
                    : propertyMapping.getId());
            copy.setObjectTypeInterfaceMappingId(mappingId);
            copy.setInterfacePropertyId(propertyMapping.getInterfacePropertyId());
            copy.setPropertyId(propertyMapping.getPropertyId());
            interfacePropertyMappingMapper.insert(copy);
        }
    }

    private boolean hasAllRequiredMappings(List<InterfaceProperty> effectiveProperties, List<InterfacePropertyMapping> propertyMappings) {
        Set<String> mappedInterfacePropertyIds = new LinkedHashSet<>();
        for (InterfacePropertyMapping propertyMapping : propertyMappings) {
            mappedInterfacePropertyIds.add(propertyMapping.getInterfacePropertyId());
        }
        for (InterfaceProperty property : effectiveProperties) {
            if (property.getRequired() != null && property.getRequired() > 0
                    && !mappedInterfacePropertyIds.contains(property.getId())) {
                return false;
            }
        }
        return true;
    }

    private InterfaceProperty copyProperty(InterfaceProperty source) {
        InterfaceProperty target = new InterfaceProperty();
        target.setId(source.getId());
        target.setInterfaceId(source.getInterfaceId());
        target.setName(source.getName());
        target.setType(source.getType());
        target.setDescription(source.getDescription());
        target.setRequired(source.getRequired());
        target.setSortOrder(source.getSortOrder());
        return target;
    }

    private InterfaceLinkConstraint copyLinkTypeConstraint(InterfaceLinkConstraint source) {
        InterfaceLinkConstraint target = new InterfaceLinkConstraint();
        target.setId(source.getId());
        target.setInterfaceId(source.getInterfaceId());
        target.setName(source.getName());
        target.setTargetType(source.getTargetType());
        target.setTargetInterfaceId(source.getTargetInterfaceId());
        target.setTargetObjectTypeId(source.getTargetObjectTypeId());
        target.setCardinality(source.getCardinality());
        target.setRequired(source.getRequired());
        target.setStatus(source.getStatus());
        target.setCreatedAt(source.getCreatedAt());
        target.setUpdatedAt(source.getUpdatedAt());
        return target;
    }

    private String buildStableId(String prefix, String... parts) {
        return prefix + "_" + String.join("_", parts);
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (!isBlank(value)) {
                return value;
            }
        }
        return null;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
