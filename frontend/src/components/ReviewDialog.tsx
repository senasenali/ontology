import React, { useState, useEffect, useCallback } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/src/components/ui/dialog';
import { Button } from '@/src/components/ui/button';
import { Badge } from '@/src/components/ui/badge';
import { Database, Link as LinkIcon, CheckCircle, Trash2, Loader2, ChevronLeft, ChevronRight, Layers3, GitBranch } from 'lucide-react';
import { toast } from 'sonner';
import { api } from '@/src/api/client';
import { OntologyData } from '@/src/store/ontologyStore';

interface PendingItem {
  id: string;
  name: string;
  description?: string;
  createdAt?: string;
  type: 'objectType' | 'linkType';
}

interface ReviewDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onUpdate: (data: OntologyData) => void;
}

export function ReviewDialog({ open, onOpenChange, onUpdate }: ReviewDialogProps) {
  const [loading, setLoading] = useState(false);
  const [objectTypes, setObjectTypes] = useState<any[]>([]);
  const [linkTypes, setLinkTypes] = useState<any[]>([]);
  const [interfaces, setInterfaces] = useState<any[]>([]);
  const [objectTypeInterfaceMappings, setObjectTypeInterfaceMappings] = useState<any[]>([]);
  const [totalObjectTypes, setTotalObjectTypes] = useState(0);
  const [totalLinkTypes, setTotalLinkTypes] = useState(0);
  const [totalInterfaces, setTotalInterfaces] = useState(0);
  const [totalObjectTypeInterfaceMappings, setTotalObjectTypeInterfaceMappings] = useState(0);
  const [page, setPage] = useState(1);
  const [actionId, setActionId] = useState<string | null>(null);
  const pageSize = 10;

  const loadPendingReviews = useCallback(async () => {
    if (!open) return;
    setLoading(true);
    try {
      const res = await api.getPendingReviews(page, pageSize);
      setObjectTypes(res.objectTypes || []);
      setLinkTypes(res.linkTypes || []);
      setInterfaces(res.interfaces || []);
      setObjectTypeInterfaceMappings(res.objectTypeInterfaceMappings || []);
      setTotalObjectTypes(res.totalObjectTypes || 0);
      setTotalLinkTypes(res.totalLinkTypes || 0);
      setTotalInterfaces(res.totalInterfaces || 0);
      setTotalObjectTypeInterfaceMappings(res.totalObjectTypeInterfaceMappings || 0);
    } catch (err: any) {
      toast.error('加载待审核列表失败');
    } finally {
      setLoading(false);
    }
  }, [open, page]);

  useEffect(() => {
    loadPendingReviews();
  }, [loadPendingReviews]);

  const handleApproveObject = async (id: string) => {
    setActionId(id);
    try {
      const res = await api.approveObjectType(id);
      if (res.success) {
        toast.success('对象类型审核通过');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const handleRejectObject = async (id: string) => {
    if (!confirm('确定要删除该对象类型吗？关联的属性也会被删除。')) return;
    setActionId(id);
    try {
      const res = await api.rejectObjectType(id);
      if (res.success) {
        toast.success('对象类型已删除');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const handleApproveLink = async (id: string) => {
    setActionId(id);
    try {
      const res = await api.approveLinkType(id);
      if (res.success) {
        toast.success('链接类型审核通过');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const handleRejectLink = async (id: string) => {
    if (!confirm('确定要删除该链接类型吗？')) return;
    setActionId(id);
    try {
      const res = await api.rejectLinkType(id);
      if (res.success) {
        toast.success('链接类型已删除');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const handleApproveInterface = async (id: string) => {
    setActionId(id);
    try {
      const res = await api.approveInterface(id);
      if (res.success) {
        toast.success('Interface 审核通过');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const handleRejectInterface = async (id: string) => {
    if (!confirm('确定要删除该 Interface 吗？')) return;
    setActionId(id);
    try {
      const res = await api.rejectInterface(id);
      if (res.success) {
        toast.success('Interface 已删除');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const handleApproveImplementation = async (id: string) => {
    setActionId(id);
    try {
      const res = await api.approveObjectTypeInterfaceMapping(id);
      if (res.success) {
        toast.success('实现关系审核通过');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const handleRejectImplementation = async (id: string) => {
    if (!confirm('确定要删除该实现关系吗？')) return;
    setActionId(id);
    try {
      const res = await api.rejectObjectTypeInterfaceMapping(id);
      if (res.success) {
        toast.success('实现关系已删除');
        onUpdate(res.data);
        loadPendingReviews();
      }
    } catch (err: any) {
      toast.error(err.message || '操作失败');
    } finally {
      setActionId(null);
    }
  };

  const total = totalObjectTypes + totalLinkTypes + totalInterfaces + totalObjectTypeInterfaceMappings;
  const totalPages = Math.ceil(total / pageSize);

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl max-h-[80vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            审核变更列表
            {total > 0 && (
              <Badge variant="secondary" className="ml-2">{total} 项待审核</Badge>
            )}
          </DialogTitle>
        </DialogHeader>

        <div className="flex-1 overflow-y-auto py-4">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
              <span className="ml-2 text-slate-500">加载中...</span>
            </div>
          ) : total === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-slate-500">
              <CheckCircle className="w-12 h-12 text-emerald-400 mb-3" />
              <p>暂无待审核的变更</p>
            </div>
          ) : (
            <div className="space-y-3">
              {/* 对象类型列表 */}
              {objectTypes.map((ot) => (
                <div key={ot.id} className="flex items-center gap-3 p-3 border border-slate-200 rounded-lg bg-white hover:bg-slate-50">
                  <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center">
                    <Database className="w-5 h-5 text-blue-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="font-medium text-slate-900">{ot.name}</span>
                      <Badge variant="outline" className="text-xs">对象类型</Badge>
                    </div>
                    <div className="text-sm text-slate-500 truncate">
                      ID: {ot.id} {ot.description && `· ${ot.description}`}
                    </div>
                    {ot.createdAt && (
                      <div className="text-xs text-slate-400 mt-1">
                        创建于 {new Date(ot.createdAt).toLocaleString()}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <Button
                      size="sm"
                      variant="default"
                      className="h-8 gap-1"
                      onClick={() => handleApproveObject(ot.id)}
                      disabled={actionId === ot.id}
                    >
                      {actionId === ot.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <CheckCircle className="w-3 h-3" />}
                      通过
                    </Button>
                    <Button
                      size="sm"
                      variant="destructive"
                      className="h-8 gap-1"
                      onClick={() => handleRejectObject(ot.id)}
                      disabled={actionId === ot.id}
                    >
                      {actionId === ot.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <Trash2 className="w-3 h-3" />}
                      删除
                    </Button>
                  </div>
                </div>
              ))}

              {/* 链接类型列表 */}
              {linkTypes.map((lt) => (
                <div key={lt.id} className="flex items-center gap-3 p-3 border border-slate-200 rounded-lg bg-white hover:bg-slate-50">
                  <div className="w-10 h-10 rounded-lg bg-emerald-50 flex items-center justify-center">
                    <LinkIcon className="w-5 h-5 text-emerald-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="font-medium text-slate-900">{lt.name}</span>
                      <Badge variant="outline" className="text-xs border-emerald-200 text-emerald-600">链接类型</Badge>
                    </div>
                    <div className="text-sm text-slate-500 truncate">
                      ID: {lt.id} {lt.description && `· ${lt.description}`}
                    </div>
                    {lt.createdAt && (
                      <div className="text-xs text-slate-400 mt-1">
                        创建于 {new Date(lt.createdAt).toLocaleString()}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <Button
                      size="sm"
                      variant="default"
                      className="h-8 gap-1"
                      onClick={() => handleApproveLink(lt.id)}
                      disabled={actionId === lt.id}
                    >
                      {actionId === lt.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <CheckCircle className="w-3 h-3" />}
                      通过
                    </Button>
                    <Button
                      size="sm"
                      variant="destructive"
                      className="h-8 gap-1"
                      onClick={() => handleRejectLink(lt.id)}
                      disabled={actionId === lt.id}
                    >
                      {actionId === lt.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <Trash2 className="w-3 h-3" />}
                      删除
                    </Button>
                  </div>
                </div>
              ))}

              {interfaces.map((item) => (
                <div key={item.id} className="flex items-center gap-3 p-3 border border-slate-200 rounded-lg bg-white hover:bg-slate-50">
                  <div className="w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center">
                    <Layers3 className="w-5 h-5 text-amber-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="font-medium text-slate-900">{item.name}</span>
                      <Badge variant="outline" className="text-xs border-amber-200 text-amber-700">Interface</Badge>
                    </div>
                    <div className="text-sm text-slate-500 truncate">
                      ID: {item.id} {item.description && `· ${item.description}`}
                    </div>
                    {item.createdAt && (
                      <div className="text-xs text-slate-400 mt-1">
                        创建于 {new Date(item.createdAt).toLocaleString()}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <Button
                      size="sm"
                      variant="default"
                      className="h-8 gap-1"
                      onClick={() => handleApproveInterface(item.id)}
                      disabled={actionId === item.id}
                    >
                      {actionId === item.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <CheckCircle className="w-3 h-3" />}
                      通过
                    </Button>
                    <Button
                      size="sm"
                      variant="destructive"
                      className="h-8 gap-1"
                      onClick={() => handleRejectInterface(item.id)}
                      disabled={actionId === item.id}
                    >
                      {actionId === item.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <Trash2 className="w-3 h-3" />}
                      删除
                    </Button>
                  </div>
                </div>
              ))}

              {objectTypeInterfaceMappings.map((item) => (
                <div key={item.id} className="flex items-center gap-3 p-3 border border-slate-200 rounded-lg bg-white hover:bg-slate-50">
                  <div className="w-10 h-10 rounded-lg bg-violet-50 flex items-center justify-center">
                    <GitBranch className="w-5 h-5 text-violet-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="font-medium text-slate-900">{item.objectTypeName || item.objectTypeId}</span>
                      <Badge variant="outline" className="text-xs border-violet-200 text-violet-700">实现关系</Badge>
                    </div>
                    <div className="text-sm text-slate-500 truncate">
                      Interface: {item.interfaceName || item.interfaceId}
                      {item.mappingComplete === false ? ' · 必填映射未完成' : ''}
                    </div>
                    {item.createdAt && (
                      <div className="text-xs text-slate-400 mt-1">
                        创建于 {new Date(item.createdAt).toLocaleString()}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <Button
                      size="sm"
                      variant="default"
                      className="h-8 gap-1"
                      onClick={() => handleApproveImplementation(item.id)}
                      disabled={actionId === item.id}
                    >
                      {actionId === item.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <CheckCircle className="w-3 h-3" />}
                      通过
                    </Button>
                    <Button
                      size="sm"
                      variant="destructive"
                      className="h-8 gap-1"
                      onClick={() => handleRejectImplementation(item.id)}
                      disabled={actionId === item.id}
                    >
                      {actionId === item.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <Trash2 className="w-3 h-3" />}
                      删除
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* 分页 */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between pt-4 border-t">
            <div className="text-sm text-slate-500">
              共 {total} 项，第 {page}/{totalPages} 页
            </div>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page <= 1}
              >
                <ChevronLeft className="w-4 h-4" />
                上一页
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page >= totalPages}
              >
                下一页
                <ChevronRight className="w-4 h-4" />
              </Button>
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
