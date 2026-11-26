package com.ruoyi.system.service.mes.pro.impl;

import java.util.List;
import com.ruoyi.common.core.domain.BaseEntity;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.system.domain.mes.pro.ProRoute;
import com.ruoyi.system.domain.mes.pro.ProRouteCopyRequest;
import com.ruoyi.system.domain.mes.pro.ProRouteProcess;
import com.ruoyi.system.domain.mes.pro.ProRouteProcessParam;
import com.ruoyi.system.domain.mes.pro.ProRouteProduct;
import com.ruoyi.system.domain.mes.pro.ProRouteProductBom;
import com.ruoyi.system.mapper.mes.pro.ProRouteMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProcessMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProcessParamMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProductBomMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProductMapper;
import com.ruoyi.system.service.mes.pro.IProRouteCopyService;
import com.ruoyi.system.service.mes.pro.IProRouteService;

/**
 * 工艺路线整链复制：主表 + 工序组成 + 关联产品 + 工序BOM + 工序参数，单事务落库。
 * 复制件仅基本信息（编码/名称/备注）由调用方指定，其余配置后续通过编辑调整。
 *
 * @author qixiaoxia
 * @date 2026-11-26
 */
@Service
public class ProRouteCopyServiceImpl implements IProRouteCopyService
{
    private static final String NO = "N";
    private static final String COPY_NOTE = "复制自路线#";
    private static final int REMARK_MAX_LEN = 500;

    @Autowired
    private IProRouteService proRouteService;
    @Autowired
    private ProRouteMapper qxxProRouteMapper;
    @Autowired
    private ProRouteProcessMapper qxxProRouteProcessMapper;
    @Autowired
    private ProRouteProductMapper qxxProRouteProductMapper;
    @Autowired
    private ProRouteProductBomMapper qxxProRouteProductBomMapper;
    @Autowired
    private ProRouteProcessParamMapper qxxProRouteProcessParamMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ProRoute copyProRoute(ProRouteCopyRequest request)
    {
        validate(request);
        ProRoute source = qxxProRouteMapper.selectProRouteByRouteId(request.getSourceRouteId());
        if (source == null)
        {
            throw new ServiceException("源工艺路线不存在或已删除");
        }
        ProRoute target = buildTargetRoute(source, request);
        proRouteService.checkRouteCodeUnique(target);
        proRouteService.insertProRoute(target);
        Long sourceRouteId = source.getRouteId();
        Long targetRouteId = target.getRouteId();
        copyProcesses(sourceRouteId, targetRouteId);
        copyProducts(sourceRouteId, targetRouteId);
        copyBoms(sourceRouteId, targetRouteId);
        return target;
    }

    private void validate(ProRouteCopyRequest request)
    {
        if (request == null || request.getSourceRouteId() == null)
        {
            throw new ServiceException("源工艺路线不能为空");
        }
        if (StringUtils.isEmpty(request.getRouteCode()))
        {
            throw new ServiceException("新路线编码不能为空");
        }
        if (StringUtils.isEmpty(request.getRouteName()))
        {
            throw new ServiceException("新路线名称不能为空");
        }
    }

    /** 基本信息取源路线，编码/名称/备注用调用方指定值 */
    private ProRoute buildTargetRoute(ProRoute source, ProRouteCopyRequest request)
    {
        ProRoute target = new ProRoute();
        target.setRouteCode(request.getRouteCode());
        target.setRouteName(request.getRouteName());
        target.setRouteDesc(source.getRouteDesc());
        target.setOwnerId(source.getOwnerId());
        target.setOwnerName(source.getOwnerName());
        target.setEnableFlag(source.getEnableFlag());
        String note = (StringUtils.isEmpty(request.getRemark()) ? "" : request.getRemark() + " ")
            + COPY_NOTE + source.getRouteId();
        target.setRemark(note.length() > REMARK_MAX_LEN ? note.substring(0, REMARK_MAX_LEN) : note);
        return target;
    }

    /** 复制路线工序：所有配置列原样保留，只换 routeId 与主键 */
    private void copyProcesses(Long sourceRouteId, Long targetRouteId)
    {
        List<ProRouteProcess> sources = qxxProRouteProcessMapper.selectProRouteProcessByRouteId(sourceRouteId);
        for (ProRouteProcess src : sources)
        {
            ProRouteProcess dst = new ProRouteProcess();
            dst.setRouteId(targetRouteId);
            dst.setProcessId(src.getProcessId());
            dst.setProcessCode(src.getProcessCode());
            dst.setProcessName(src.getProcessName());
            dst.setOrderNum(src.getOrderNum());
            dst.setNextProcessId(src.getNextProcessId());
            dst.setNextProcessCode(src.getNextProcessCode());
            dst.setNextProcessName(src.getNextProcessName());
            dst.setLinkType(src.getLinkType());
            dst.setDefaultPreTime(src.getDefaultPreTime());
            dst.setDefaultSufTime(src.getDefaultSufTime());
            dst.setColorCode(src.getColorCode());
            dst.setKeyFlag(src.getKeyFlag());
            dst.setIsCheck(src.getIsCheck());
            dst.setIsOutsource(src.getIsOutsource());
            dst.setVendorId(src.getVendorId());
            dst.setVendorCode(src.getVendorCode());
            dst.setVendorName(src.getVendorName());
            dst.setOutsourceFactoryId(src.getOutsourceFactoryId());
            dst.setRemark(src.getRemark());
            fillAudit(dst);
            qxxProRouteProcessMapper.insertProRouteProcess(dst);
        }
    }

    /** 复制关联产品并按新旧 recordId 映射复制其工序参数 */
    private void copyProducts(Long sourceRouteId, Long targetRouteId)
    {
        List<ProRouteProduct> sources = qxxProRouteProductMapper.selectProRouteProductByRouteId(sourceRouteId);
        for (ProRouteProduct src : sources)
        {
            ProRouteProduct dst = new ProRouteProduct();
            dst.setRouteId(targetRouteId);
            dst.setItemId(src.getItemId());
            dst.setItemCode(src.getItemCode());
            dst.setItemName(src.getItemName());
            dst.setSpecification(src.getSpecification());
            dst.setUnitOfMeasure(src.getUnitOfMeasure());
            dst.setUnitName(src.getUnitName());
            dst.setQuantity(src.getQuantity());
            dst.setProductionTime(src.getProductionTime());
            dst.setTimeUnitType(src.getTimeUnitType());
            dst.setApplyOrderType(src.getApplyOrderType());
            dst.setApplyOutsource(src.getApplyOutsource());
            dst.setApplyPackage(src.getApplyPackage());
            // uk_route_product_default 限制同产品只能一条默认路线，复制件不能继承 Y
            dst.setIsDefault(NO);
            dst.setRemark(src.getRemark());
            fillAudit(dst);
            qxxProRouteProductMapper.insertProRouteProduct(dst);
            copyParams(src.getRecordId(), dst.getRecordId());
        }
    }

    /** 参数挂在路线产品上，需按新路线产品ID重建 */
    private void copyParams(Long sourceRecordId, Long targetRecordId)
    {
        List<ProRouteProcessParam> sources = qxxProRouteProcessParamMapper
            .selectProRouteProcessParamByRouteProductId(sourceRecordId);
        for (ProRouteProcessParam src : sources)
        {
            ProRouteProcessParam dst = new ProRouteProcessParam();
            dst.setRouteProductId(targetRecordId);
            dst.setProcessId(src.getProcessId());
            dst.setTemplateId(src.getTemplateId());
            dst.setParamValue(src.getParamValue());
            dst.setRemark(src.getRemark());
            fillAudit(dst);
            qxxProRouteProcessParamMapper.insertProRouteProcessParam(dst);
        }
    }

    /** BOM 按 route_id + product_id(物料) 归属，随路线整体复制一次即可 */
    private void copyBoms(Long sourceRouteId, Long targetRouteId)
    {
        ProRouteProductBom query = new ProRouteProductBom();
        query.setRouteId(sourceRouteId);
        List<ProRouteProductBom> sources = qxxProRouteProductBomMapper.selectProRouteProductBomList(query);
        for (ProRouteProductBom src : sources)
        {
            ProRouteProductBom dst = new ProRouteProductBom();
            dst.setRouteId(targetRouteId);
            dst.setProcessId(src.getProcessId());
            dst.setProductId(src.getProductId());
            dst.setItemId(src.getItemId());
            dst.setItemCode(src.getItemCode());
            dst.setItemName(src.getItemName());
            dst.setSpecification(src.getSpecification());
            dst.setUnitOfMeasure(src.getUnitOfMeasure());
            dst.setUnitName(src.getUnitName());
            dst.setQuantity(src.getQuantity());
            dst.setRemark(src.getRemark());
            fillAudit(dst);
            qxxProRouteProductBomMapper.insertProRouteProductBom(dst);
        }
    }

    private void fillAudit(BaseEntity entity)
    {
        entity.setCreateBy(SecurityUtils.getUsername());
        entity.setCreateTime(DateUtils.getNowDate());
    }
}
