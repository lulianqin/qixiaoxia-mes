package com.ruoyi.system.service.mes.md.impl;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.Normalizer;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.md.MdItemType;
import com.ruoyi.system.mapper.mes.md.MdItemMapper;
import com.ruoyi.system.mapper.mes.md.MdItemTypeMapper;
import com.ruoyi.system.service.mes.md.IMdItemService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 物料产品Service业务层处理（factory_id 由 FactoryIdInterceptor 自动注入）
 *
 * <p>扩展属性（纸张/纸袋/礼品盒等）已从原三张行业子表迁移为分类驱动的动态属性，
 * 存于 {@code qxx_md_item.ext_attrs}（JSON 扁平 {attrCode:value}），随主表 insert/update 一并持久化，
 * 不再需要子表联动的增删改。SPU 变体继承父物料的 ext_attrs。
 *
 * @author qixiaoxia
 * @date 2026-06-10
 */
@Service
public class MdItemServiceImpl implements IMdItemService
{
    private static final Logger log = LoggerFactory.getLogger(MdItemServiceImpl.class);

    @Autowired
    private MdItemMapper mdItemMapper;
    @Autowired
    private MdItemTypeMapper itemTypeMapper;

    @Override
    public List<MdItem> selectMdItemAllEnabled()
    {
        MdItem cond = new MdItem();
        cond.setEnableFlag("1");
        return mdItemMapper.selectMdItemList(cond);
    }

    @Override
    public List<MdItem> selectMdItemList(MdItem mdItem)
    {
        expandItemTypeFilter(mdItem);
        return mdItemMapper.selectMdItemList(mdItem);
    }

    /**
     * 将 itemTypeId 展开为「自身+所有子分类」的 itemTypeIds。
     * <p>该方法内部会查询一次数据库，**必须在 Controller 的 startPage() 之前调用**，
     * 否则 PageHelper 的分页参数会被这次查询消费掉，导致随后的列表查询不分页。
     * <p>幂等：展开后 itemTypeId 被置空，重复调用不会再次查库。
     */
    @Override
    public void expandItemTypeFilter(MdItem mdItem)
    {
        if (mdItem == null || Boolean.TRUE.equals(mdItem.getUncategorized())
                || mdItem.getItemTypeId() == null || mdItem.getItemTypeId() == 0)
        {
            return;
        }
        // 点击父分类时，展开为「自身+所有子分类」ID 列表，使子分类下的物料也能被查出
        List<Long> descendantIds = itemTypeMapper.selectDescendantIds(mdItem.getItemTypeId());
        // CTE 返回空说明该分类ID不存在，塞入-1使 IN(-1) 不命中任何记录（主键永不为负）
        mdItem.setItemTypeIds(descendantIds.isEmpty()
            ? Collections.singletonList(-1L) : descendantIds);
        mdItem.setItemTypeId(null);
    }

    @Override
    public MdItem selectMdItemById(Long itemId)
    {
        // ext_attrs 作为主表 JSON 列，由 MdItemMapper 的 resultMap + JsonMapTypeHandler 自动带出，无需手动 JOIN
        return mdItemMapper.selectMdItemById(itemId);
    }

    @Override
    public boolean checkItemCodeUnique(MdItem mdItem)
    {
        MdItem item = mdItemMapper.checkItemCodeUnique(mdItem);
        Long itemId = mdItem.getItemId() == null ? -1L : mdItem.getItemId();
        if (StringUtils.isNotNull(item) && item.getItemId().longValue() != itemId.longValue())
        {
            return UserConstants.NOT_UNIQUE;
        }
        return UserConstants.UNIQUE;
    }

    @Override
    @Transactional
    public int insertMdItem(MdItem mdItem)
    {
        mdItem.setCreateTime(DateUtils.getNowDate());

        // 兜底：根据 itemTypeCode 查询 itemTypeId（前端可能只传了 code，没传 id）
        resolveItemTypeId(mdItem);

        // SPU/变体继承逻辑：如果是变体（parentId>0），从父产品继承 itemType 信息 + 扩展属性
        // 注意：SPU 自身（parentId=0）即标准，不在此自动创建冗余"标准变体"
        if (mdItem.getParentId() != null && mdItem.getParentId() > 0)
        {
            MdItem parent = mdItemMapper.selectMdItemById(mdItem.getParentId());
            if (parent != null)
            {
                // 继承父产品的类型信息
                if (StringUtils.isEmpty(mdItem.getItemTypeCode()))
                    mdItem.setItemTypeCode(parent.getItemTypeCode());
                if (mdItem.getItemTypeId() == null || mdItem.getItemTypeId() == 0)
                    mdItem.setItemTypeId(parent.getItemTypeId());
                if (StringUtils.isEmpty(mdItem.getItemTypeName()))
                    mdItem.setItemTypeName(parent.getItemTypeName());
                // 继承单位
                if (StringUtils.isEmpty(mdItem.getUnitOfMeasure()))
                    mdItem.setUnitOfMeasure(parent.getUnitOfMeasure());
                if (StringUtils.isEmpty(mdItem.getUnitName()))
                    mdItem.setUnitName(parent.getUnitName());
                // 继承扩展属性（ext_attrs 已随 selectMdItemById 自动带出）
                if (mdItem.getExtAttrs() == null)
                    mdItem.setExtAttrs(parent.getExtAttrs());
            }
        }

        return mdItemMapper.insertMdItem(mdItem);
    }

    @Override
    @Transactional
    public MdItem findOrCreateSpecVariant(MdItem spec)
    {
        if (spec == null || spec.getParentId() == null || spec.getParentId() <= 0)
            throw new ServiceException("请选择产品大类(SPU)");
        MdItem parent = mdItemMapper.selectMdItemById(spec.getParentId());
        if (parent == null) throw new ServiceException("产品大类不存在");

        // 统一规则匹配兄弟变体；印刷/包装作为变体额外判据（双方都有值时比较）
        MdItem query = new MdItem();
        query.setParentId(spec.getParentId());
        for (MdItem candidate : mdItemMapper.selectMdItemList(query))
        {
            if (isSameItem(candidate, spec)
                && normalize(candidate.getProductSize()).equals(normalize(spec.getProductSize()))
                && valuesCompatible(candidate.getPrintingReq(), spec.getPrintingReq())
                && valuesCompatible(candidate.getPackageSpec(), spec.getPackageSpec()))
            {
                return candidate;
            }
        }
        fillVariantDefaults(spec, parent);
        spec.setSpecFingerprint(buildSpecFingerprint(spec));
        insertMdItem(spec);
        return spec;
    }

    @Override
    @Transactional
    public MdItem findOrCreateForStock(MdItem spec)
    {
        if (spec == null || StringUtils.isEmpty(spec.getItemName()))
            throw new ServiceException("物料名称不能为空");
        if (spec.getItemTypeId() == null || spec.getItemTypeId() <= 0)
            throw new ServiceException("请选择物料分类");
        MdItemType type = itemTypeMapper.selectMdItemTypeById(spec.getItemTypeId());
        if (type == null) throw new ServiceException("物料分类不存在");

        spec.setItemName(spec.getItemName().trim());
        spec.setItemTypeCode(type.getItemTypeCode());
        spec.setItemTypeName(type.getItemTypeName());

        // 手工新增：扩展属性严格比对（属性值或属性项变化即视为新物料）
        MdItem existed = matchItem(spec, true);
        if (existed != null) return existed;

        if (StringUtils.isEmpty(spec.getUnitOfMeasure())) spec.setUnitOfMeasure("PCS");
        if (StringUtils.isEmpty(spec.getUnitName())) spec.setUnitName("个");
        spec.setItemCode(generateStockItemCode(type));
        spec.setEnableFlag("1");
        spec.setCreateBy(SecurityUtils.getUsername());
        spec.setRemark("库存新增自动建档");
        insertMdItem(spec);
        return spec;
    }

    @Override
    public boolean isSameItem(MdItem a, MdItem b) { return isSameItem(a, b, false); }

    @Override
    public boolean isSameItem(MdItem a, MdItem b, boolean strictAttrs)
    {
        if (a == null || b == null) return false;
        if (a.getItemId() != null && a.getItemId().equals(b.getItemId())) return true;
        // 分类/父产品：双方都有值时才要求一致，避免外部单据没带分类导致匹配失败
        if (hasType(a) && hasType(b) && !a.getItemTypeId().equals(b.getItemTypeId())) return false;
        if (hasParent(a) && hasParent(b) && !a.getParentId().equals(b.getParentId())) return false;
        // 名称/规格：双方都有值时才比较，空值视为"未提供该维度"
        if (StringUtils.isNotEmpty(a.getItemName()) && StringUtils.isNotEmpty(b.getItemName())
            && !normalize(a.getItemName()).equals(normalize(b.getItemName()))) return false;
        // 规格型号、产品尺寸：必须完全一致（规范化后精确比较，空值与空值视为一致）
        if (!normalize(a.getSpecification()).equals(normalize(b.getSpecification()))) return false;
        if (!normalize(a.getProductSize()).equals(normalize(b.getProductSize()))) return false;
        // 扩展属性：严格模式要求属性项/值完全一致；宽松模式只比较双方都有的 key
        return strictAttrs
            ? attrsKey(a.getExtAttrs()).equals(attrsKey(b.getExtAttrs()))
            : attrsCompatible(a.getExtAttrs(), b.getExtAttrs());
    }

    @Override
    public MdItem matchItem(MdItem spec) { return matchItem(spec, false); }

    @Override
    public MdItem matchItem(MdItem spec, boolean strictAttrs)
    {
        if (spec == null) return null;
        // 1. 编码精确匹配
        String code = StringUtils.isNotEmpty(spec.getItemCode()) ? spec.getItemCode().trim() : null;
        if (code != null)
        {
            MdItem codeQuery = new MdItem();
            codeQuery.setItemCode(code);
            for (MdItem candidate : mdItemMapper.selectMdItemList(codeQuery))
            {
                if (code.equals(candidate.getItemCode())) return candidate;
            }
        }
        // 2. 名称/规格候选，再按统一规则逐一判定
        MdItem query = new MdItem();
        if (StringUtils.isNotEmpty(spec.getItemName())) query.setItemName(spec.getItemName().trim());
        else if (StringUtils.isNotEmpty(spec.getSpecification())) query.setSpecification(spec.getSpecification().trim());
        else return null;
        for (MdItem candidate : mdItemMapper.selectMdItemList(query))
        {
            if (isSameItem(candidate, spec, strictAttrs)) return candidate;
        }
        return null;
    }

    /** 文本规范化：去空白、全角转半角、小写、数字间的 x/× 统一为 * */
    private String normalize(String value)
    {
        if (value == null) return "";
        String text = Normalizer.normalize(value.trim(), Normalizer.Form.NFKC)
            .toLowerCase(Locale.ROOT)
            .replaceAll("(?<=\\d)\\s*[x×✕✖]\\s*(?=\\d)", "*");
        return text.replaceAll("\\s+", "");
    }

    private boolean hasType(MdItem item) { return item.getItemTypeId() != null && item.getItemTypeId() > 0; }

    private boolean hasParent(MdItem item) { return item.getParentId() != null && item.getParentId() > 0; }

    /** 扩展属性兼容：只比较双方都有的 key，值不同则不匹配，缺一方不视为冲突 */
    private boolean attrsCompatible(Map<String, Object> a, Map<String, Object> b)
    {
        if (a == null || b == null) return true;
        for (Map.Entry<String, Object> e : a.entrySet())
        {
            if (!b.containsKey(e.getKey())) continue;
            String va = attrValue(e.getValue());
            String vb = attrValue(b.get(e.getKey()));
            if (!va.isEmpty() && !vb.isEmpty() && !va.equals(vb)) return false;
        }
        return true;
    }

    /** 扩展属性规范化：按 key 排序、忽略空值，数组按逗号连接，用于严格比对 */
    private String attrsKey(Map<String, Object> attrs)
    {
        if (attrs == null || attrs.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, Object> e : new TreeMap<>(attrs).entrySet())
        {
            String text = attrValue(e.getValue());
            if (text.isEmpty()) continue;
            sb.append(e.getKey()).append('=').append(text).append(';');
        }
        return sb.toString();
    }

    private String attrValue(Object v)
    {
        if (v == null) return "";
        String text = v instanceof Collection<?> c
            ? c.stream().map(String::valueOf).collect(Collectors.joining(","))
            : String.valueOf(v);
        return text.trim();
    }

    /** 可选字段比较：任一方为空视为未提供，不构成差异 */
    private boolean valuesCompatible(String a, String b)
    {
        String na = nullToEmpty(a).trim();
        String nb = nullToEmpty(b).trim();
        return na.isEmpty() || nb.isEmpty() || na.equals(nb);
    }

    private String generateStockItemCode(MdItemType type)
    {
        String prefix = StringUtils.isEmpty(type.getItemTypeCode()) ? "ITEM"
            : type.getItemTypeCode().toUpperCase().replaceAll("[^A-Z0-9-]", "");
        if (prefix.length() > 20) prefix = prefix.substring(0, 20);
        return prefix + "-" + DateUtils.dateTimeNow("yyyyMMddHHmmssSSS");
    }

    /** 规格指纹：SPU + 尺寸/印刷/包装/规格 + 扩展属性（按 key 排序）的 SHA-256 */
    private String buildSpecFingerprint(MdItem spec)
    {
        StringBuilder sb = new StringBuilder();
        sb.append(spec.getParentId()).append('|')
          .append(nullToEmpty(spec.getProductSize())).append('|')
          .append(nullToEmpty(spec.getPrintingReq())).append('|')
          .append(nullToEmpty(spec.getPackageSpec())).append('|')
          .append(nullToEmpty(spec.getSpecification()));
        if (spec.getExtAttrs() != null) {
            for (Map.Entry<String, Object> e : new TreeMap<>(spec.getExtAttrs()).entrySet()) {
                sb.append('|').append(e.getKey()).append('=').append(e.getValue());
            }
        }
        return sha256(sb.toString());
    }

    private void fillVariantDefaults(MdItem spec, MdItem parent)
    {
        if (StringUtils.isEmpty(spec.getItemCode())) {
            String base = StringUtils.isNotEmpty(parent.getItemCode()) ? parent.getItemCode() : "ITEM";
            if (base.length() > 48) base = base.substring(0, 48);
            spec.setItemCode(base + "-V" + Long.toString(System.currentTimeMillis(), 36).toUpperCase());
        }
        if (StringUtils.isEmpty(spec.getItemName())) {
            String name = parent.getItemName() + (StringUtils.isNotEmpty(spec.getSpecification())
                    ? " " + spec.getSpecification() : "");
            spec.setItemName(name.length() > 255 ? name.substring(0, 255) : name);
        }
        if (StringUtils.isEmpty(spec.getUnitOfMeasure())) spec.setUnitOfMeasure(parent.getUnitOfMeasure());
        if (StringUtils.isEmpty(spec.getUnitName())) spec.setUnitName(parent.getUnitName());
        if (spec.getEnableFlag() == null) spec.setEnableFlag("1");
        if (spec.getBatchFlag() == null) spec.setBatchFlag(parent.getBatchFlag());
    }

    private String nullToEmpty(String v) { return v == null ? "" : v.trim(); }

    private String sha256(String text)
    {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(text.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(64);
            for (byte b : digest) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            throw new ServiceException("规格指纹计算失败：" + e.getMessage());
        }
    }

    /** 根据 itemTypeCode 查表补全 itemTypeId（前端可能只传了 code 没传 id） */
    private void resolveItemTypeId(MdItem item)
    {
        if ((item.getItemTypeId() == null || item.getItemTypeId() == 0)
            && StringUtils.isNotEmpty(item.getItemTypeCode()))
        {
            com.ruoyi.system.domain.mes.md.MdItemType query = new com.ruoyi.system.domain.mes.md.MdItemType();
            query.setItemTypeCode(item.getItemTypeCode());
            com.ruoyi.system.domain.mes.md.MdItemType type = itemTypeMapper.checkItemTypeCodeUnique(query);
            if (type != null)
            {
                item.setItemTypeId(type.getItemTypeId());
                if (StringUtils.isEmpty(item.getItemTypeName()))
                    item.setItemTypeName(type.getItemTypeName());
            }
        }
    }

    @Override
    @Transactional
    public int updateMdItem(MdItem mdItem)
    {
        resolveItemTypeId(mdItem);
        mdItem.setUpdateTime(DateUtils.getNowDate());
        return mdItemMapper.updateMdItem(mdItem);
    }

    @Override
    @Transactional
    public int deleteMdItemById(Long itemId)
    {
        // ext_attrs 在主表，主表删即全删，无需级联清理子表
        return mdItemMapper.deleteMdItemById(itemId);
    }

    @Override
    @Transactional
    public int deleteMdItemByIds(Long[] itemIds)
    {
        return mdItemMapper.deleteMdItemByIds(itemIds);
    }

    @Override
    public String importItem(List<MdItem> itemList, boolean updateSupport, String operName)
    {
        if (itemList == null || itemList.isEmpty()) return "导入数据为空！";

        int success = 0, fail = 0;
        StringBuilder failMsg = new StringBuilder();

        for (MdItem item : itemList)
        {
            try
            {
                if (!checkItemCodeUnique(item))
                {
                    if (updateSupport)
                    {
                        MdItem exist = mdItemMapper.checkItemCodeUnique(item);
                        if (exist == null)
                        {
                            fail++;
                            failMsg.append("<br/>").append(item.getItemCode()).append("：编码已存在但查询失败");
                            continue;
                        }
                        item.setItemId(exist.getItemId());
                        updateMdItem(item);
                        success++;
                    }
                    else
                    {
                        fail++;
                        failMsg.append("<br/>").append(item.getItemCode()).append("：编码已存在");
                    }
                }
                else
                {
                    item.setCreateBy(operName);
                    insertMdItem(item);
                    success++;
                }
            }
            catch (Exception e)
            {
                fail++;
                failMsg.append("<br/>").append(item.getItemCode()).append("：").append(e.getMessage());
                log.error("导入物料失败: {}", item.getItemCode(), e);
            }
        }
        return "成功导入" + success + "条，失败" + fail + "条" + (fail > 0 ? failMsg.toString() : "");
    }
}
