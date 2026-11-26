package com.ruoyi.system.service.mes.pro;

import com.ruoyi.system.domain.mes.pro.ProRoute;
import com.ruoyi.system.domain.mes.pro.ProRouteCopyRequest;

/**
 * 工艺路线整链复制服务
 *
 * @author qixiaoxia
 * @date 2026-11-26
 */
public interface IProRouteCopyService
{
    /**
     * 复制路线主表、工序组成、关联产品、工序BOM及工序参数，返回新路线。
     */
    ProRoute copyProRoute(ProRouteCopyRequest request);
}
