import React, { useEffect, useMemo, useState } from 'react';
import { api } from '@/src/api/client';
import {
  InterfaceLinkTypeConstraint,
  InterfaceProperty,
  OntologyData,
  OntologyInterface,
} from '@/src/store/ontologyStore';
import { Badge } from '@/src/components/ui/badge';
import { Button } from '@/src/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/src/components/ui/dialog';
import { Input } from '@/src/components/ui/input';
import { Label } from '@/src/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/src/components/ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/src/components/ui/table';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/src/components/ui/tabs';
import { toast } from 'sonner';
import {
  ArrowLeft,
  AlertCircle,
  Boxes,
  FileText,
  GitBranch,
  Link2,
  Loader2,
  Pencil,
  Plus,
  Search,
  Settings2,
  Trash2,
} from 'lucide-react';

function renderStatus(status?: string) {
  return status === 'pending' ? (
    <Badge variant="outline" className="border-amber-200 text-amber-600 bg-amber-50">待审核</Badge>
  ) : (
    <Badge variant="outline" className="border-emerald-200 text-emerald-600 bg-emerald-50">已生效</Badge>
  );
}

function renderRequired(required?: number) {
  return required === 1 ? (
    <Badge variant="outline" className="border-rose-200 text-rose-600 bg-rose-50">必填</Badge>
  ) : (
    <Badge variant="outline" className="border-slate-200 text-slate-500 bg-slate-50">选填</Badge>
  );
}

function renderConstraintRequired(required?: number) {
  return required === 1 ? (
    <Badge variant="outline" className="border-rose-200 text-rose-600 bg-rose-50">是</Badge>
  ) : (
    <Badge variant="outline" className="border-slate-200 text-slate-500 bg-slate-50">非必须</Badge>
  );
}

function ConstraintRow({ constraint }: { constraint: InterfaceLinkTypeConstraint }) {
  return (
    <TableRow key={constraint.id}>
      <TableCell className="font-medium text-slate-900">
        <div className="flex items-center gap-2">
          <span>{constraint.name}</span>
          {constraint.inherited && (
            <Badge variant="secondary" className="text-[10px]">
              继承自 {constraint.sourceInterfaceName || constraint.sourceInterfaceId}
            </Badge>
          )}
        </div>
      </TableCell>
      <TableCell>
        <Badge variant="secondary" className="font-mono text-[10px] uppercase">
          {constraint.targetType}
        </Badge>
      </TableCell>
      <TableCell className="text-slate-700">{constraint.targetName || '-'}</TableCell>
      <TableCell>
        <Badge variant="outline" className="font-mono text-[10px]">{constraint.cardinality}</Badge>
      </TableCell>
      <TableCell>{renderConstraintRequired(constraint.required)}</TableCell>
    </TableRow>
  );
}

function PropertyRow({ property }: { property: InterfaceProperty }) {
  return (
    <TableRow key={property.id}>
      <TableCell className="font-mono text-xs text-slate-600">{property.id}</TableCell>
      <TableCell className="font-medium text-slate-900">
        <div className="flex items-center gap-2">
          <span>{property.name}</span>
          {property.inherited && (
            <Badge variant="secondary" className="text-[10px]">
              继承自 {property.sourceInterfaceName || property.sourceInterfaceId}
            </Badge>
          )}
        </div>
      </TableCell>
      <TableCell>
        <Badge variant="secondary" className="font-mono text-[10px] uppercase">{property.type}</Badge>
      </TableCell>
      <TableCell>{renderRequired(property.required)}</TableCell>
      <TableCell className="text-slate-500 text-sm">{property.description || '-'}</TableCell>
    </TableRow>
  );
}

export function Interfaces({ data, onUpdate }: { data: OntologyData; onUpdate: (data: OntologyData) => void }) {
  const [search, setSearch] = useState('');
  const [selectedInterfaceId, setSelectedInterfaceId] = useState<string | null>(null);
  const [selectedInterface, setSelectedInterface] = useState<OntologyInterface | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [creating, setCreating] = useState(false);
  const [newInterfaceId, setNewInterfaceId] = useState('');
  const [newInterfaceName, setNewInterfaceName] = useState('');
  const [newInterfaceDescription, setNewInterfaceDescription] = useState('');

  const [editingName, setEditingName] = useState('');
  const [editingDescription, setEditingDescription] = useState('');
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [propertyDialogOpen, setPropertyDialogOpen] = useState(false);
  const [editingProperty, setEditingProperty] = useState<InterfaceProperty | null>(null);
  const [propertyId, setPropertyId] = useState('');
  const [propertyName, setPropertyName] = useState('');
  const [propertyType, setPropertyType] = useState('string');
  const [propertyDescription, setPropertyDescription] = useState('');
  const [propertyRequired, setPropertyRequired] = useState('0');
  const [savingProperty, setSavingProperty] = useState(false);
  const [constraintDialogOpen, setConstraintDialogOpen] = useState(false);
  const [editingConstraint, setEditingConstraint] = useState<InterfaceLinkTypeConstraint | null>(null);
  const [constraintId, setConstraintId] = useState('');
  const [constraintName, setConstraintName] = useState('');
  const [constraintTargetType, setConstraintTargetType] = useState<'interface' | 'object_type'>('interface');
  const [constraintTargetId, setConstraintTargetId] = useState('');
  const [constraintCardinality, setConstraintCardinality] = useState<'1:1' | '1:N'>('1:1');
  const [constraintRequired, setConstraintRequired] = useState('0');
  const [savingConstraint, setSavingConstraint] = useState(false);
  const interfaces = data.interfaces || [];

  const filteredInterfaces = useMemo(() => {
    return interfaces.filter(item =>
      item.name.toLowerCase().includes(search.toLowerCase()) ||
      item.id.toLowerCase().includes(search.toLowerCase())
    );
  }, [interfaces, search]);

  useEffect(() => {
    if (!selectedInterfaceId) {
      setSelectedInterface(null);
      return;
    }

    let active = true;
    setLoadingDetail(true);
    api.getInterfaceDetail(selectedInterfaceId)
      .then(res => {
        if (!active) return;
        const detail = res.interface;
        setSelectedInterface(detail);
        setEditingName(detail.name || '');
        setEditingDescription(detail.description || '');
      })
      .catch((err: any) => {
        if (!active) return;
        toast.error(err.message || '加载 Interface 详情失败');
      })
      .finally(() => {
        if (active) setLoadingDetail(false);
      });

    return () => {
      active = false;
    };
  }, [selectedInterfaceId]);

  const handleCreate = async () => {
    if (!newInterfaceId || !newInterfaceName) {
      toast.error('请填写 Interface ID 和名称');
      return;
    }

    setCreating(true);
    try {
      const result = await api.createInterface({
        id: newInterfaceId,
        name: newInterfaceName,
        description: newInterfaceDescription,
      });
      onUpdate(result.data);
      setCreateDialogOpen(false);
      setNewInterfaceId('');
      setNewInterfaceName('');
      setNewInterfaceDescription('');
      setSelectedInterfaceId(newInterfaceId);
      toast.success(`Interface "${newInterfaceName}" 创建成功`);
    } catch (err: any) {
      toast.error(err.message);
    } finally {
      setCreating(false);
    }
  };

  const handleSave = async () => {
    if (!selectedInterface) return;
    setSaving(true);
    try {
      const result = await api.updateInterface(selectedInterface.id, {
        name: editingName,
        description: editingDescription,
      });
      onUpdate(result.data);
      const detail = await api.getInterfaceDetail(selectedInterface.id);
      setSelectedInterface(detail.interface);
      setEditingName(detail.interface.name || '');
      setEditingDescription(detail.interface.description || '');
      toast.success('Interface 信息已保存');
    } catch (err: any) {
      toast.error(err.message);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!selectedInterface) return;
    setDeleting(true);
    try {
      const result = await api.deleteInterface(selectedInterface.id);
      onUpdate(result.data);
      setSelectedInterfaceId(null);
      setSelectedInterface(null);
      toast.success(`Interface "${selectedInterface.name}" 已删除`);
    } catch (err: any) {
      toast.error(err.message);
    } finally {
      setDeleting(false);
    }
  };

  const openCreatePropertyDialog = () => {
    setEditingProperty(null);
    setPropertyId('');
    setPropertyName('');
    setPropertyType('string');
    setPropertyDescription('');
    setPropertyRequired('0');
    setPropertyDialogOpen(true);
  };

  const openEditPropertyDialog = (property: InterfaceProperty) => {
    setEditingProperty(property);
    setPropertyId(property.id);
    setPropertyName(property.name);
    setPropertyType(property.type);
    setPropertyDescription(property.description || '');
    setPropertyRequired(String(property.required || 0));
    setPropertyDialogOpen(true);
  };

  const handleSaveProperty = async () => {
    if (!selectedInterface || !propertyId || !propertyName) {
      toast.error('请填写属性 ID 和名称');
      return;
    }
    setSavingProperty(true);
    try {
      const payload = {
        id: propertyId,
        name: propertyName,
        type: propertyType,
        description: propertyDescription,
        required: Number(propertyRequired),
      };
      const result = editingProperty
        ? await api.updateInterfaceProperty(selectedInterface.id, editingProperty.id, payload)
        : await api.addInterfaceProperty(selectedInterface.id, payload);
      onUpdate(result.data);
      const detail = await api.getInterfaceDetail(selectedInterface.id);
      setSelectedInterface(detail.interface);
      setPropertyDialogOpen(false);
      toast.success(editingProperty ? 'Interface 属性已更新' : 'Interface 属性已添加');
    } catch (err: any) {
      toast.error(err.message);
    } finally {
      setSavingProperty(false);
    }
  };

  const handleDeleteProperty = async (property: InterfaceProperty) => {
    if (!selectedInterface) return;
    if (!confirm(`确定要删除属性 ${property.name} 吗？`)) return;
    try {
      const result = await api.deleteInterfaceProperty(selectedInterface.id, property.id);
      onUpdate(result.data);
      const detail = await api.getInterfaceDetail(selectedInterface.id);
      setSelectedInterface(detail.interface);
      toast.success('Interface 属性已删除');
    } catch (err: any) {
      toast.error(err.message);
    }
  };

  const openCreateConstraintDialog = () => {
    setEditingConstraint(null);
    setConstraintId('');
    setConstraintName('');
    setConstraintTargetType('interface');
    setConstraintTargetId('');
    setConstraintCardinality('1:1');
    setConstraintRequired('0');
    setConstraintDialogOpen(true);
  };

  const openEditConstraintDialog = (constraint: InterfaceLinkTypeConstraint) => {
    setEditingConstraint(constraint);
    setConstraintId(constraint.id);
    setConstraintName(constraint.name);
    setConstraintTargetType(constraint.targetType);
    setConstraintTargetId(constraint.targetType === 'interface'
      ? (constraint.targetInterfaceId || '')
      : (constraint.targetObjectTypeId || ''));
    setConstraintCardinality(constraint.cardinality);
    setConstraintRequired(String(constraint.required || 0));
    setConstraintDialogOpen(true);
  };

  const handleSaveConstraint = async () => {
    if (!selectedInterface || !constraintId || !constraintName || !constraintTargetId) {
      toast.error('请填写完整的 Link Type Constraint 信息');
      return;
    }
    setSavingConstraint(true);
    try {
      const payload = {
        id: constraintId,
        name: constraintName,
        targetType: constraintTargetType,
        targetInterfaceId: constraintTargetType === 'interface' ? constraintTargetId : null,
        targetObjectTypeId: constraintTargetType === 'object_type' ? constraintTargetId : null,
        cardinality: constraintCardinality,
        required: Number(constraintRequired),
      };
      const result = editingConstraint
        ? await api.updateInterfaceLinkTypeConstraint(selectedInterface.id, editingConstraint.id, payload)
        : await api.addInterfaceLinkTypeConstraint(selectedInterface.id, payload);
      onUpdate(result.data);
      const detail = await api.getInterfaceDetail(selectedInterface.id);
      setSelectedInterface(detail.interface);
      setConstraintDialogOpen(false);
      toast.success(editingConstraint ? 'Link Type Constraint 已更新' : 'Link Type Constraint 已添加');
    } catch (err: any) {
      toast.error(err.message);
    } finally {
      setSavingConstraint(false);
    }
  };

  const handleDeleteConstraint = async (constraint: InterfaceLinkTypeConstraint) => {
    if (!selectedInterface) return;
    if (!confirm(`确定要删除约束 ${constraint.name} 吗？`)) return;
    try {
      const result = await api.deleteInterfaceLinkTypeConstraint(selectedInterface.id, constraint.id);
      onUpdate(result.data);
      const detail = await api.getInterfaceDetail(selectedInterface.id);
      setSelectedInterface(detail.interface);
      toast.success('Link Type Constraint 已删除');
    } catch (err: any) {
      toast.error(err.message);
    }
  };

  if (selectedInterfaceId) {
    return (
      <div className="space-y-6 max-w-6xl mx-auto">
        <div className="flex items-center gap-4">
          <Button variant="ghost" onClick={() => setSelectedInterfaceId(null)} className="text-slate-500">
            <ArrowLeft className="w-4 h-4 mr-1" />
            返回 Interface 列表
          </Button>
        </div>

        {loadingDetail || !selectedInterface ? (
          <div className="flex items-center justify-center h-64 gap-3 text-slate-500">
            <Loader2 className="w-5 h-5 animate-spin" />
            <span>加载 Interface 详情...</span>
          </div>
        ) : (
          <>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-lg bg-sky-100 text-sky-600 flex items-center justify-center border border-sky-200 border-dashed">
                  <Boxes className="w-6 h-6" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold tracking-tight text-slate-900">{selectedInterface.name}</h1>
                  <p className="text-slate-500 text-sm font-mono">{selectedInterface.id}</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                {renderStatus(selectedInterface.status)}
                <Button
                  variant="outline"
                  className="text-red-500 border-red-200 hover:bg-red-50"
                  onClick={handleDelete}
                  disabled={deleting}
                >
                  {deleting ? <Loader2 className="w-4 h-4 animate-spin mr-1" /> : <Trash2 className="w-4 h-4 mr-1" />}
                  删除
                </Button>
                <Button onClick={handleSave} disabled={saving}>
                  {saving ? <Loader2 className="w-4 h-4 animate-spin mr-1" /> : null}
                  保存更改
                </Button>
              </div>
            </div>

            <Tabs defaultValue="overview" className="w-full">
              <TabsList className="mb-4">
                <TabsTrigger value="overview" className="gap-2"><GitBranch className="w-4 h-4" /> 概览</TabsTrigger>
                <TabsTrigger value="properties" className="gap-2"><FileText className="w-4 h-4" /> 属性</TabsTrigger>
                <TabsTrigger value="constraints" className="gap-2"><Link2 className="w-4 h-4" /> Link Type Constraints</TabsTrigger>
                <TabsTrigger value="settings" className="gap-2"><Settings2 className="w-4 h-4" /> 设置</TabsTrigger>
              </TabsList>

              <TabsContent value="overview">
                <div className="grid gap-6 lg:grid-cols-2">
                  <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-6 space-y-4">
                    <h3 className="font-semibold text-slate-900">基本信息</h3>
                    <div className="space-y-3 text-sm">
                      <div>
                        <div className="text-slate-400 mb-1">名称</div>
                        <div className="text-slate-900 font-medium">{selectedInterface.name}</div>
                      </div>
                      <div>
                        <div className="text-slate-400 mb-1">Interface ID</div>
                        <div className="font-mono text-slate-700">{selectedInterface.id}</div>
                      </div>
                      <div>
                        <div className="text-slate-400 mb-1">描述</div>
                        <div className="text-slate-700">{selectedInterface.description || '暂无描述'}</div>
                      </div>
                      <div>
                        <div className="text-slate-400 mb-1">所属行业</div>
                        <div className="text-slate-700">{selectedInterface.industryId || '未设置'}</div>
                      </div>
                    </div>
                  </div>

                  <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-6 space-y-5">
                    <div>
                      <h3 className="font-semibold text-slate-900 mb-3">继承关系</h3>
                      <div className="space-y-3 text-sm">
                        <div>
                          <div className="text-slate-400 mb-1">父 Interface</div>
                          <div className="text-slate-700">
                            {selectedInterface.parentInterfaceName ? (
                              <span>
                                {selectedInterface.parentInterfaceName}
                                <span className="ml-2 font-mono text-xs text-slate-400">{selectedInterface.parentInterfaceId}</span>
                              </span>
                            ) : '无'}
                          </div>
                        </div>
                        <div>
                          <div className="text-slate-400 mb-1">子 Interface</div>
                          {selectedInterface.childInterfaces && selectedInterface.childInterfaces.length > 0 ? (
                            <div className="flex flex-wrap gap-2">
                              {selectedInterface.childInterfaces.map(child => (
                                <Badge key={child.id} variant="outline" className="bg-slate-50 text-slate-700">
                                  {child.name}
                                </Badge>
                              ))}
                            </div>
                          ) : (
                            <div className="text-slate-700">暂无子 Interface</div>
                          )}
                        </div>
                      </div>
                    </div>

                    <div className="grid grid-cols-3 gap-3">
                      <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                        <div className="text-xs text-slate-400">属性数</div>
                        <div className="text-xl font-semibold text-slate-900 mt-1">{selectedInterface.properties.length}</div>
                      </div>
                      <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                        <div className="text-xs text-slate-400">约束数</div>
                        <div className="text-xl font-semibold text-slate-900 mt-1">{selectedInterface.linkTypeConstraints.length}</div>
                      </div>
                      <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                        <div className="text-xs text-slate-400">实现 OT</div>
                        <div className="text-xl font-semibold text-slate-900 mt-1">{selectedInterface.implementedObjectTypes?.length || 0}</div>
                      </div>
                    </div>

                    <div>
                      <div className="text-slate-400 mb-2 text-sm">已实现的 Object Type</div>
                      {selectedInterface.implementedObjectTypes && selectedInterface.implementedObjectTypes.length > 0 ? (
                        <div className="space-y-2">
                          {selectedInterface.implementedObjectTypes.map((implementation) => (
                            <div key={implementation.id} className="flex items-center justify-between rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-sm">
                              <div>
                                <div className="font-medium text-slate-900">{implementation.objectTypeName || implementation.objectTypeId}</div>
                                <div className="text-xs text-slate-500">{implementation.objectTypeId}</div>
                              </div>
                              {implementation.mappingComplete ? (
                                <Badge variant="outline" className="border-emerald-200 text-emerald-700 bg-emerald-50">映射完整</Badge>
                              ) : (
                                <Badge variant="outline" className="border-amber-200 text-amber-700 bg-amber-50">
                                  <AlertCircle className="w-3 h-3 mr-1" />
                                  缺少必填映射
                                </Badge>
                              )}
                            </div>
                          ))}
                        </div>
                      ) : (
                        <div className="text-slate-700 text-sm">暂无实现该 Interface 的 Object Type</div>
                      )}
                    </div>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="properties">
                <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                  <div className="p-4 border-b border-slate-200 bg-slate-50/50 flex items-center justify-between">
                    <h3 className="font-semibold text-slate-900">属性 ({selectedInterface.properties.length})</h3>
                    <Dialog open={propertyDialogOpen} onOpenChange={setPropertyDialogOpen}>
                      <Button size="sm" variant="outline" className="h-8 gap-1" onClick={openCreatePropertyDialog}>
                        <Plus className="w-3 h-3" />
                        添加属性
                      </Button>
                      <DialogContent>
                        <DialogHeader>
                          <DialogTitle>{editingProperty ? '编辑 Interface 属性' : '添加 Interface 属性'}</DialogTitle>
                          <DialogDescription>配置 Interface 的属性定义和必填约束。</DialogDescription>
                        </DialogHeader>
                        <div className="space-y-4 py-4">
                          <div className="space-y-2">
                            <Label>属性名称 *</Label>
                            <Input value={propertyName} onChange={e => setPropertyName(e.target.value)} />
                          </div>
                          <div className="space-y-2">
                            <Label>属性 ID *</Label>
                            <Input value={propertyId} onChange={e => setPropertyId(e.target.value)} disabled={!!editingProperty} className="font-mono text-sm" />
                          </div>
                          <div className="space-y-2">
                            <Label>类型</Label>
                            <Select value={propertyType} onValueChange={setPropertyType}>
                              <SelectTrigger><SelectValue /></SelectTrigger>
                              <SelectContent>
                                {['string', 'integer', 'double', 'boolean', 'date', 'timestamp', 'geohash'].map((type) => (
                                  <SelectItem key={type} value={type}>{type}</SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </div>
                          <div className="space-y-2">
                            <Label>必填</Label>
                            <Select value={propertyRequired} onValueChange={setPropertyRequired}>
                              <SelectTrigger><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="0">选填</SelectItem>
                                <SelectItem value="1">必填</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                          <div className="space-y-2">
                            <Label>描述</Label>
                            <Input value={propertyDescription} onChange={e => setPropertyDescription(e.target.value)} />
                          </div>
                        </div>
                        <DialogFooter>
                          <Button variant="outline" onClick={() => setPropertyDialogOpen(false)}>取消</Button>
                          <Button onClick={handleSaveProperty} disabled={savingProperty}>
                            {savingProperty ? <Loader2 className="w-4 h-4 animate-spin mr-1" /> : null}
                            保存
                          </Button>
                        </DialogFooter>
                      </DialogContent>
                    </Dialog>
                  </div>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="w-[220px]">属性 ID</TableHead>
                        <TableHead>名称</TableHead>
                        <TableHead>类型</TableHead>
                        <TableHead>必填</TableHead>
                        <TableHead>描述</TableHead>
                        <TableHead className="text-right">操作</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {selectedInterface.properties.map(property => (
                        <TableRow key={property.id}>
                          <TableCell className="font-mono text-xs text-slate-600">{property.id}</TableCell>
                          <TableCell className="font-medium text-slate-900">
                            <div className="flex items-center gap-2">
                              <span>{property.name}</span>
                              {property.inherited && (
                                <Badge variant="secondary" className="text-[10px]">
                                  继承自 {property.sourceInterfaceName || property.sourceInterfaceId}
                                </Badge>
                              )}
                            </div>
                          </TableCell>
                          <TableCell>
                            <Badge variant="secondary" className="font-mono text-[10px] uppercase">{property.type}</Badge>
                          </TableCell>
                          <TableCell>{renderRequired(property.required)}</TableCell>
                          <TableCell className="text-slate-500 text-sm">{property.description || '-'}</TableCell>
                          <TableCell className="text-right">
                            {!property.inherited && (
                              <div className="flex items-center justify-end gap-1">
                                <Button variant="ghost" size="icon" className="h-8 w-8" onClick={() => openEditPropertyDialog(property)}>
                                  <Pencil className="w-3.5 h-3.5" />
                                </Button>
                                <Button variant="ghost" size="icon" className="h-8 w-8 text-red-500 hover:bg-red-50" onClick={() => handleDeleteProperty(property)}>
                                  <Trash2 className="w-3.5 h-3.5" />
                                </Button>
                              </div>
                            )}
                          </TableCell>
                        </TableRow>
                      ))}
                      {selectedInterface.properties.length === 0 && (
                        <TableRow>
                          <TableCell colSpan={6} className="h-16 text-center text-slate-400 text-sm">
                            暂无属性
                          </TableCell>
                        </TableRow>
                      )}
                    </TableBody>
                  </Table>
                </div>
              </TabsContent>

              <TabsContent value="constraints">
                <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                  <div className="p-4 border-b border-slate-200 bg-slate-50/50 flex items-center justify-between">
                    <h3 className="font-semibold text-slate-900">
                      Link Type Constraints ({selectedInterface.linkTypeConstraints.length})
                    </h3>
                    <Dialog open={constraintDialogOpen} onOpenChange={setConstraintDialogOpen}>
                      <Button size="sm" variant="outline" className="h-8 gap-1" onClick={openCreateConstraintDialog}>
                        <Plus className="w-3 h-3" />
                        添加约束
                      </Button>
                      <DialogContent>
                        <DialogHeader>
                          <DialogTitle>{editingConstraint ? '编辑 Link Type Constraint' : '添加 Link Type Constraint'}</DialogTitle>
                          <DialogDescription>配置 Interface 的抽象关系约束。</DialogDescription>
                        </DialogHeader>
                        <div className="space-y-4 py-4">
                          <div className="space-y-2">
                            <Label>名称 *</Label>
                            <Input value={constraintName} onChange={e => setConstraintName(e.target.value)} />
                          </div>
                          <div className="space-y-2">
                            <Label>Constraint ID *</Label>
                            <Input value={constraintId} onChange={e => setConstraintId(e.target.value)} disabled={!!editingConstraint} className="font-mono text-sm" />
                          </div>
                          <div className="space-y-2">
                            <Label>目标类型</Label>
                            <Select value={constraintTargetType} onValueChange={(value: 'interface' | 'object_type') => setConstraintTargetType(value)}>
                              <SelectTrigger><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="interface">Interface</SelectItem>
                                <SelectItem value="object_type">Object Type</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                          <div className="space-y-2">
                            <Label>目标 *</Label>
                            <Select value={constraintTargetId} onValueChange={setConstraintTargetId}>
                              <SelectTrigger><SelectValue placeholder="选择目标..." /></SelectTrigger>
                              <SelectContent>
                                {(constraintTargetType === 'interface' ? data.interfaces : data.objectTypes).map((item: any) => (
                                  <SelectItem key={item.id} value={item.id}>
                                    {item.name} ({item.id})
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </div>
                          <div className="space-y-2">
                            <Label>基数</Label>
                            <Select value={constraintCardinality} onValueChange={(value: '1:1' | '1:N') => setConstraintCardinality(value)}>
                              <SelectTrigger><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="1:1">1:1</SelectItem>
                                <SelectItem value="1:N">1:N</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                          <div className="space-y-2">
                            <Label>是否必需约束</Label>
                            <Select value={constraintRequired} onValueChange={setConstraintRequired}>
                              <SelectTrigger><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="0">非必须</SelectItem>
                                <SelectItem value="1">是</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                        </div>
                        <DialogFooter>
                          <Button variant="outline" onClick={() => setConstraintDialogOpen(false)}>取消</Button>
                          <Button onClick={handleSaveConstraint} disabled={savingConstraint}>
                            {savingConstraint ? <Loader2 className="w-4 h-4 animate-spin mr-1" /> : null}
                            保存
                          </Button>
                        </DialogFooter>
                      </DialogContent>
                    </Dialog>
                  </div>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>名称</TableHead>
                        <TableHead>目标类型</TableHead>
                        <TableHead>目标</TableHead>
                        <TableHead>基数</TableHead>
                        <TableHead>是否必需约束</TableHead>
                        <TableHead className="text-right">操作</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {selectedInterface.linkTypeConstraints.map(constraint => (
                        <TableRow key={constraint.id}>
                          <TableCell className="font-medium text-slate-900">
                            <div className="flex items-center gap-2">
                              <span>{constraint.name}</span>
                              {constraint.inherited && (
                                <Badge variant="secondary" className="text-[10px]">
                                  继承自 {constraint.sourceInterfaceName || constraint.sourceInterfaceId}
                                </Badge>
                              )}
                            </div>
                          </TableCell>
                          <TableCell>
                            <Badge variant="secondary" className="font-mono text-[10px] uppercase">
                              {constraint.targetType}
                            </Badge>
                          </TableCell>
                          <TableCell className="text-slate-700">{constraint.targetName || '-'}</TableCell>
                          <TableCell>
                            <Badge variant="outline" className="font-mono text-[10px]">{constraint.cardinality}</Badge>
                          </TableCell>
                          <TableCell>{renderConstraintRequired(constraint.required)}</TableCell>
                          <TableCell className="text-right">
                            {!constraint.inherited && (
                              <div className="flex items-center justify-end gap-1">
                                <Button variant="ghost" size="icon" className="h-8 w-8" onClick={() => openEditConstraintDialog(constraint)}>
                                  <Pencil className="w-3.5 h-3.5" />
                                </Button>
                                <Button variant="ghost" size="icon" className="h-8 w-8 text-red-500 hover:bg-red-50" onClick={() => handleDeleteConstraint(constraint)}>
                                  <Trash2 className="w-3.5 h-3.5" />
                                </Button>
                              </div>
                            )}
                          </TableCell>
                        </TableRow>
                      ))}
                      {selectedInterface.linkTypeConstraints.length === 0 && (
                        <TableRow>
                          <TableCell colSpan={6} className="h-16 text-center text-slate-400 text-sm">
                            暂无 Link Type Constraints
                          </TableCell>
                        </TableRow>
                      )}
                    </TableBody>
                  </Table>
                </div>
              </TabsContent>

              <TabsContent value="settings">
                <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-6 space-y-6">
                  <div className="space-y-4 max-w-xl">
                    <div className="space-y-2">
                      <Label>名称</Label>
                      <Input value={editingName} onChange={e => setEditingName(e.target.value)} />
                    </div>
                    <div className="space-y-2">
                      <Label>描述</Label>
                      <Input value={editingDescription} onChange={e => setEditingDescription(e.target.value)} />
                    </div>
                    <div className="space-y-2">
                      <Label>Industry ID</Label>
                      <Input value={selectedInterface.industryId || ''} disabled className="font-mono text-sm text-slate-500" />
                    </div>
                  </div>
                </div>
              </TabsContent>
            </Tabs>
          </>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Interface</h1>
          <p className="text-slate-500 text-sm mt-1">定义 Object Type 共享的抽象契约。</p>
        </div>
        <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
          <DialogTrigger asChild>
            <Button className="gap-2"><Plus className="w-4 h-4" /> 新建 Interface</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>创建 Interface</DialogTitle>
              <DialogDescription>定义新的抽象本体类型。</DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label>名称 *</Label>
                <Input value={newInterfaceName} onChange={e => setNewInterfaceName(e.target.value)} placeholder="例如：电池、电芯、储能单元" />
              </div>
              <div className="space-y-2">
                <Label>Interface ID *</Label>
                <Input value={newInterfaceId} onChange={e => setNewInterfaceId(e.target.value)} placeholder="例如：if_battery" className="font-mono text-sm" />
              </div>
              <div className="space-y-2">
                <Label>描述</Label>
                <Input value={newInterfaceDescription} onChange={e => setNewInterfaceDescription(e.target.value)} placeholder="这个抽象类型代表什么？" />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setCreateDialogOpen(false)}>取消</Button>
              <Button onClick={handleCreate} disabled={creating}>
                {creating ? <Loader2 className="w-4 h-4 animate-spin mr-1" /> : null}
                创建
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      <div className="flex items-center gap-4 bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <Input placeholder="搜索 Interface..." className="pl-9" value={search} onChange={e => setSearch(e.target.value)} />
        </div>
      </div>

      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/50">
              <TableHead>名称</TableHead>
              <TableHead>Interface ID</TableHead>
              <TableHead>父 Interface</TableHead>
              <TableHead>属性</TableHead>
              <TableHead>Link Type Constraints</TableHead>
              <TableHead>状态</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredInterfaces.map(item => (
              <TableRow key={item.id} className="cursor-pointer hover:bg-slate-50" onClick={() => setSelectedInterfaceId(item.id)}>
                <TableCell className="font-medium text-slate-900">
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 rounded bg-sky-50 text-sky-600 flex items-center justify-center border border-sky-200 border-dashed">
                      <Boxes className="w-3 h-3" />
                    </div>
                    {item.name}
                  </div>
                </TableCell>
                <TableCell className="font-mono text-xs text-slate-500">{item.id}</TableCell>
                <TableCell className="text-slate-600">{item.parentInterfaceName || '-'}</TableCell>
                <TableCell><Badge variant="secondary">{item.properties.length}</Badge></TableCell>
                <TableCell><Badge variant="secondary">{item.linkTypeConstraints.length}</Badge></TableCell>
                <TableCell>{renderStatus(item.status)}</TableCell>
              </TableRow>
            ))}
            {filteredInterfaces.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} className="h-24 text-center text-slate-500">未找到 Interface。</TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
