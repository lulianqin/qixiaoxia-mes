package com.ruoyi.system.service.mes.wm;

import java.util.List;

import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessAttr;

/**
 * 外协工序-扩展属性模板 Service
 *
 * @author qixiaoxia
 */
public interface IWmOutsourceProcessAttrService
{
    /** 查询工序绑定的属性（含属性定义） */
    List<WmOutsourceProcessAttr> selectByProcessId(Long processId);

    /** 保存工序绑定（全量替换） */
    int saveProcessAttrs(Long processId, List<WmOutsourceProcessAttr> attrs);
}
