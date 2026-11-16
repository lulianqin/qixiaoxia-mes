package com.ruoyi.system.domain.mes.sal;

/**
 * 销售模块常量
 *
 * @author qixiaoxia
 * @date 2026-08-05
 */
public class SalConstants
{
    /** 订单来源：直接新增（系统内手工建单） */
    public static final int SOURCE_DIRECT = 1;
    /** 订单来源：CRM系统（外部推单） */
    public static final int SOURCE_CRM = 2;
    /** 订单来源：ERP系统（采购单下发） */
    public static final int SOURCE_ERP = 3;

    /** 来源系统编码：手工建单 */
    public static final String SYSTEM_MANUAL = "MANUAL";
    /** 来源系统编码：CRM */
    public static final String SYSTEM_CRM = "CRM";
    /** 来源系统编码：ERP */
    public static final String SYSTEM_ERP = "ERP";
}
