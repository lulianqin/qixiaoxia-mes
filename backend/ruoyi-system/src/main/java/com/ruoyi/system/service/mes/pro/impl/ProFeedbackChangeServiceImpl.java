package com.ruoyi.system.service.mes.pro.impl;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.pro.ProConstants;
import com.ruoyi.system.domain.mes.pro.ProFeedback;
import com.ruoyi.system.domain.mes.pro.ProFeedbackChange;
import com.ruoyi.system.mapper.mes.pro.ProFeedbackChangeMapper;
import com.ruoyi.system.service.mes.pro.IProFeedbackChangeService;

/**
 * 报工字段变更痕迹Service实现
 *
 * @author qixiaoxia
 */
@Service
public class ProFeedbackChangeServiceImpl implements IProFeedbackChangeService
{
    private static final Logger log = LoggerFactory.getLogger(ProFeedbackChangeServiceImpl.class);

    /** 变更字段 code → 中文名（新增变更字段时在此登记，避免前端硬编码映射） */
    private static final Map<String, String> FIELD_LABELS = Map.of(
        ProConstants.CHANGE_FIELD_QUANTITY_INPUT, "本次上机数量"
    );

    @Autowired
    private ProFeedbackChangeMapper proFeedbackChangeMapper;

    @Override
    public void recordInputChange(Long feedbackId, ProFeedback fb, BigDecimal oldVal, BigDecimal newVal,
                                  String source, String reason)
    {
        if (feedbackId == null || !isDifferent(oldVal, newVal)) {
            return;
        }
        try {
            ProFeedbackChange change = new ProFeedbackChange();
            change.setFeedbackId(feedbackId);
            if (fb != null) {
                change.setTaskId(fb.getTaskId());
                change.setWorkorderId(fb.getWorkorderId());
            }
            change.setFieldName(ProConstants.CHANGE_FIELD_QUANTITY_INPUT);
            change.setOldValue(oldVal != null ? oldVal.toPlainString() : null);
            change.setNewValue(newVal != null ? newVal.toPlainString() : "");
            change.setChangeSource(source != null ? source : ProConstants.CHANGE_SOURCE_MANUAL);
            change.setChangeReason(reason);
            change.setCreateBy(SecurityUtils.getUsername());
            change.setCreateTime(DateUtils.getNowDate());
            proFeedbackChangeMapper.insertProFeedbackChange(change);
        } catch (Exception e) {
            // 留痕失败不阻断报工主流程
            log.error("报工上机数量留痕失败 feedbackId={}, {} -> {}", feedbackId, oldVal, newVal, e);
        }
    }

    @Override
    public List<ProFeedbackChange> selectByFeedback(Long feedbackId)
    {
        return enrichFieldLabel(proFeedbackChangeMapper.selectByFeedback(feedbackId));
    }

    @Override
    public List<ProFeedbackChange> selectByTask(Long taskId)
    {
        return enrichFieldLabel(proFeedbackChangeMapper.selectByTask(taskId));
    }

    /** 查询结果富化字段中文名；未知字段回退原始 code，保证不丢信息 */
    private List<ProFeedbackChange> enrichFieldLabel(List<ProFeedbackChange> list)
    {
        if (list != null)
        {
            for (ProFeedbackChange c : list)
            {
                String label = FIELD_LABELS.get(c.getFieldName());
                c.setFieldLabel(label != null ? label : c.getFieldName());
            }
        }
        return list;
    }

    /** BigDecimal 数值语义不等（1.0 与 1.00 视为相等）；纯 null→null 不算差异 */
    private boolean isDifferent(BigDecimal oldVal, BigDecimal newVal)
    {
        if (oldVal == null && newVal == null) {
            return false;
        }
        if (oldVal == null || newVal == null) {
            return true;
        }
        return oldVal.compareTo(newVal) != 0;
    }
}
