# -*- coding: utf-8 -*-
"""
MES 数据清理与初始化 SQL 生成器
读取三个仓库 Excel，生成 V206~V209 迁移脚本。

用法: python gen_reset_sql.py
"""
import os
import re
import json
from collections import OrderedDict
import openpyxl

BASE = os.path.dirname(os.path.abspath(__file__))
XLS_DIR = os.path.join(BASE, "..", "..", ".tmp_mes_clean")
OUT_DIR = os.path.join(BASE, "sql")
os.makedirs(OUT_DIR, exist_ok=True)

F1 = os.path.join(XLS_DIR, "仓库11月23日成品库存汇总.xlsx")
F2 = os.path.join(XLS_DIR, "仓库11月23日份原料库存表.xlsx")
F3 = os.path.join(XLS_DIR, "柔印类材料+工艺命名(1).xlsx")

PWD_BCRYPT = "$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO"  # 12345678


def esc(v):
    if v is None:
        return "NULL"
    s = str(v).replace("\\", "\\\\").replace("'", "''")
    return "'" + s + "'"


def clean_name(s):
    """去掉换行/制表/首尾空格，压缩多空格"""
    if s is None:
        return ""
    s = str(s).replace("\r", " ").replace("\n", " ").replace("\t", " ")
    s = re.sub(r"\s+", " ", s).strip()
    return s


# ---------------------------------------------------------------- 纸种映射
# 顺序很重要：长名优先，避免 白牛皮 吃掉 食品级白牛皮
PAPER_KINDS = [
    ("食品级白牛皮", "SPBNP", "食品级白牛皮"),
    ("食品级黄牛皮", "SPHNP", "食品级黄牛皮"),
    ("白挂面箱板纸", "BGMZ", "白挂面纸"),
    ("TC箱板纸", "TCXBZ", "TC箱板纸"),
    ("灰底白板纸", "HDHBZ", "灰底白板纸"),
    ("彩色双胶纸", "CSSJZ", "彩色双胶纸"),
    ("赤松黄牛", "CSHN", "赤松黄牛"),
    ("瑞典赤牛", "RDCN", "瑞典赤牛"),
    ("箱板纸", "XBZ", "箱板纸"),
    ("白牛皮", "BNP", "白牛皮"),
    ("乌卡", "WK", "乌卡"),
    ("精牛", "JN", "精牛"),
    ("特种纸", "TZZ", "特种纸"),
    ("梦迪", "MD", "梦迪"),
]
BRANDS = ["金东", "云轩", "君茹", "晨鸣", "仙鹤"]

# 柔印表的 11 种纸（用于全量笛卡尔积）
ROUYIN_PAPERS = [
    ("白牛皮", "BNP"), ("乌卡", "WK"), ("食品级白牛皮", "SPBNP"),
    ("食品级黄牛皮", "SPHNP"), ("精牛", "JN"), ("箱板纸", "XBZ"),
    ("TC箱板纸", "TCXBZ"), ("白挂面纸", "BGMZ"), ("彩色双胶纸", "CSSJZ"),
    ("特种纸", "TZZ"), ("灰底白板纸", "HDHBZ"),
]

AUX_ROPES = [
    ("白牛皮色圆纸绳", "BNPY", "圆纸绳"),
    ("黄牛皮色圆纸绳", "HNPY", "圆纸绳"),
    ("黑色圆纸绳", "HSY", "圆纸绳"),
    ("彩色圆纸绳", "CSY", "圆纸绳"),
    ("黄牛皮色扁纸绳", "HNPB", "扁纸绳"),
    ("白牛皮色扁纸绳", "BNPB", "扁纸绳"),
    ("黑色扁纸绳", "HSB", "扁纸绳"),
    ("彩色扁纸绳", "CSB", "扁纸绳"),
]


def parse_paper_name(name):
    """解析 '117克金东白牛皮' -> (weight=117, kind=白牛皮, code=BNP, brand=金东)"""
    s = clean_name(name)
    # TC 前缀写法：TC120克箱板纸 -> 120克TC箱板纸
    tc = False
    if s.upper().startswith("TC"):
        tc = True
        s = s[2:].strip()
    m = re.match(r"^(\d+)\s*克?\s*(.+)$", s)
    if not m:
        return None
    weight = int(m.group(1))
    rest = m.group(2).strip()
    if tc:
        rest = "TC" + rest
    brand = ""
    for b in BRANDS:
        if rest.startswith(b):
            brand = b
            rest = rest[len(b):]
            break
    for kw, code, canon in PAPER_KINDS:
        if kw == rest:
            return weight, canon, code, brand
    if rest == "GP":
        return weight, "精牛", "JN", brand
    for kw, code, canon in PAPER_KINDS:
        if kw in rest:
            return weight, canon, code, brand
    return weight, rest, None, brand


# ---------------------------------------------------------------- 读原料
def load_raw_material():
    """返回 [(kind_name, full_name, width, qty_kg, qty_roll)]"""
    wb = openpyxl.load_workbook(F2, data_only=True)
    ws = wb["原料库存表"]
    cur_kind = cur_name = None
    out = []
    for r in ws.iter_rows(min_row=3, max_row=ws.max_row, max_col=9, values_only=True):
        kind, name, width, cat, src, use, detail, roll, kg = r
        if kind and str(kind).strip():
            cur_kind = clean_name(kind)
        if name and str(name).strip():
            cur_name = clean_name(name)
        if width is None or not str(width).strip():
            continue
        if not cur_name:
            continue
        w = re.sub(r"(?i)\s*mm$", "", clean_name(width)).strip()
        out.append((cur_kind, cur_name, w, kg, roll))
    return out


def load_raw_edge():
    """纸边库存: [(kind_name, width, qty_kg)]"""
    wb = openpyxl.load_workbook(F2, data_only=True)
    ws = wb["纸边库存"]
    cur = None
    out = []
    for r in ws.iter_rows(min_row=2, max_row=ws.max_row, max_col=3, values_only=True):
        if r[0] and str(r[0]).strip():
            cur = clean_name(r[0])
        if r[1] is None or not str(r[1]).strip():
            continue
        w = re.sub(r"(?i)\s*mm$", "", clean_name(r[1])).strip()
        out.append((cur, w, r[2]))
    return out


# ---------------------------------------------------------------- 读成品
def load_finished():
    wb = openpyxl.load_workbook(F1, data_only=True)
    spot, wai, order = [], [], []

    ws = wb["现货"]
    for r in ws.iter_rows(min_row=2, max_row=ws.max_row, max_col=6, values_only=True):
        name = clean_name(r[0])
        if not name:
            continue
        spot.append({"name": name, "spec": clean_name(r[1]), "qty": r[4],
                     "packing": r[3], "boxes": r[5], "po": "", "order_no": ""})

    ws = wb["外采"]
    for r in ws.iter_rows(min_row=3, max_row=ws.max_row, max_col=15, values_only=True):
        name = clean_name(r[0])
        if not name:
            continue
        wai.append({"name": name, "spec": "", "qty": r[12], "vendor": clean_name(r[6]),
                    "packing": None, "boxes": None, "po": "", "order_no": ""})

    ws = wb["订单"]
    for r in ws.iter_rows(min_row=2, max_row=ws.max_row, max_col=8, values_only=True):
        name = clean_name(r[1])
        if not name:
            continue
        order.append({"name": name, "spec": "", "qty": r[6], "remark": clean_name(r[4]),
                      "po": clean_name(r[2]), "order_no": clean_name(r[3]),
                      "packing": r[5], "boxes": r[7]})
    return spot, wai, order


# ---------------------------------------------------------------- 读柔印
def load_rouyin():
    wb = openpyxl.load_workbook(F3, data_only=True)
    ws = wb["Sheet1"]
    weights_raw = str(ws.cell(row=2, column=2).value or "")
    weights = [int(x) for x in re.findall(r"\d+", weights_raw)]
    return weights


# ================================================================ 生成
def main():
    weights = load_rouyin()
    raw = load_raw_material()
    edge = load_raw_edge()
    spot, wai, order = load_finished()

    log = []

    # ---------- 1. 纸张 SPU 集合 ----------
    # key = (canon_kind, weight) -> {code, name}
    spu = OrderedDict()
    for kind, code in ROUYIN_PAPERS:
        for w in weights:
            key = (kind, w)
            spu[key] = {"code": code, "name": f"{w}克{kind}"}

    # 库存里出现但柔印表没有的克重/纸种，补进 SPU
    for kind_name, full, width, kg, roll in raw + [(a, b, c, d, e) for a, b, c, d, e in []]:
        p = parse_paper_name(full)
        if not p:
            continue
        w, canon, code, brand = p
        if code is None:
            log.append(f"[警告] 无法识别纸种: {full}")
            continue
        key = (canon, w)
        if key not in spu:
            spu[key] = {"code": code, "name": f"{w}克{canon}"}

    # 纸边里的材料也补
    for kind_name, width, kg in edge:
        p = parse_paper_name(kind_name)
        if not p:
            log.append(f"[警告] 纸边无法识别纸种: {kind_name}")
            continue
        w, canon, code, brand = p
        if code is None:
            continue
        key = (canon, w)
        if key not in spu:
            spu[key] = {"code": code, "name": f"{w}克{canon}"}

    log.append(f"纸张 SPU: {len(spu)}")

    # ---------- 2. 纸张 SKU（原料卷料） ----------
    sku = OrderedDict()  # item_code -> dict
    sku_by_spu = {}
    for kind_name, full, width, kg, roll in raw:
        p = parse_paper_name(full)
        if not p:
            continue
        w, canon, code, brand = p
        if code is None:
            continue
        spu_key = (canon, w)
        scode = spu[spu_key]["code"]
        item_code = f"RAW-PAPER-{scode}-{w}-{width}"
        if item_code in sku:
            continue
        attrs = {"PAPER_TYPE": canon, "PAPER_WEIGHT": w, "PAPER_WIDTH": int(width) if width.isdigit() else width}
        if brand:
            attrs["PAPER_SOURCE"] = brand
        sku[item_code] = {
            "name": f"{full} {width}MM",
            "spec": f"{width}mm*{w}g",
            "spu": spu_key,
            "spu_code": f"RAW-PAPER-{scode}-{w}",
            "type_code": f"RAW-PAPER-{scode}",
            "attrs": attrs,
            "qty": kg,
            "unit": "KG",
            "wh": "RAW",
            "remark": f"库存 {roll}卷 / {kg}kg" if roll is not None else "",
        }
    log.append(f"原料卷料 SKU: {len(sku)}")

    # ---------- 3. 纸边 SKU ----------
    edge_sku = OrderedDict()
    for kind_name, width, kg in edge:
        p = parse_paper_name(kind_name)
        if not p:
            continue
        w, canon, code, brand = p
        if code is None:
            continue
        spu_key = (canon, w)
        if spu_key not in spu:
            continue
        scode = spu[spu_key]["code"]
        item_code = f"RAW-EDGE-{scode}-{w}-{width}"
        if item_code in sku or item_code in edge_sku:
            continue
        attrs = {"PAPER_TYPE": canon, "PAPER_WEIGHT": w, "PAPER_WIDTH": int(width) if width.isdigit() else width}
        if brand:
            attrs["PAPER_SOURCE"] = brand
        edge_sku[item_code] = {
            "name": f"{kind_name} 纸边 {width}MM",
            "spec": f"{width}mm*{w}g 纸边",
            "spu": spu_key,
            "spu_code": f"RAW-PAPER-{scode}-{w}",
            "type_code": f"RAW-PAPER-{scode}",
            "attrs": attrs,
            "qty": kg,
            "unit": "KG",
            "wh": "RAW",
            "remark": "分切余料",
        }
    log.append(f"纸边 SKU: {len(edge_sku)}")

    # ---------- 4. 辅料纸绳 ----------
    rope_items = OrderedDict()
    for name, code, sub in AUX_ROPES:
        item_code = f"AUX-ROPE-{code}"
        rope_items[item_code] = {
            "name": name, "spec": "标准", "sub": sub,
            "attrs": {}, "qty": 0, "unit": "PAIR", "wh": None, "remark": "",
        }
    log.append(f"辅料纸绳: {len(rope_items)}")

    # ---------- 5. 成品 ----------
    fin = OrderedDict()
    seen = set()
    # 现货优先
    for i, r in enumerate(spot, 1):
        if r["name"] in seen:
            continue
        seen.add(r["name"])
        code = f"FIN-SPOT-{i:04d}"
        fin[code] = {"name": r["name"], "spec": r["spec"], "qty": r["qty"], "src": "现货", "batch": "",
                     "packing": r.get("packing"), "boxes": r.get("boxes"),
                     "po": r.get("po", ""), "order_no": r.get("order_no", "")}
    n = 0
    for r in wai:
        if r["name"] in seen:
            continue  # 与现货同名，视为同一物料
        seen.add(r["name"])
        n += 1
        code = f"FIN-WAI-{n:04d}"
        fin[code] = {"name": r["name"], "spec": "", "qty": r["qty"], "src": "外采", "batch": r.get("vendor", ""),
                     "packing": r.get("packing"), "boxes": r.get("boxes"),
                     "po": r.get("po", ""), "order_no": r.get("order_no", "")}
    m = 0
    for r in order:
        if r["name"] in seen:
            continue
        seen.add(r["name"])
        m += 1
        code = f"FIN-ORD-{m:04d}"
        # 只有标注"库存货/库存"的才计入期初库存
        is_stock = r["remark"] in ("库存货", "库存")
        fin[code] = {"name": r["name"], "spec": "", "qty": r["qty"] if is_stock else 0,
                     "src": "订单", "batch": r["po"],
                     "packing": r.get("packing"), "boxes": r.get("boxes"),
                     "po": r.get("po", ""), "order_no": r.get("order_no", "")}
    log.append(f"成品物料: {len(fin)} (现货去重后{len(spot)} / 外采新增{n} / 订单新增{m})")
    stock_fin = [k for k, v in fin.items() if v["qty"] not in (None, 0, "")]
    log.append(f"成品有库存数量: {len(stock_fin)}")

    # ---------- 6. 供应商补充 ----------
    vendors = OrderedDict()
    for r in wai:
        v = r.get("vendor", "")
        if v and v not in vendors:
            vendors[v] = True
    log.append(f"外采涉及供应商: {list(vendors.keys())}")

    # ============================================================ 写 SQL
    write_v206(log)
    write_v207(log)
    write_v208(spu, sku, edge_sku, rope_items, fin, log)
    write_v209(sku, edge_sku, rope_items, fin, vendors, log)
    write_v210(fin, log)

    print("\n".join(log))


# ---------------------------------------------------------------- V206 DDL
def write_v206(log):
    tables = [
        ("qxx_md_item", "物料"),
        ("qxx_pro_route", "工艺路线"),
        ("qxx_pro_process", "工序"),
        ("qxx_pro_workorder", "生产工单"),
        ("qxx_sal_order", "销售订单"),
        ("qxx_sal_quote", "报价单"),
        ("qxx_pur_order", "采购订单"),
        ("qxx_wm_material_stock", "库存"),
    ]
    lines = [
        "-- ============================================================",
        "-- V206 为业务主数据/单据表增加逻辑删除标记",
        "-- 0=存在  2=删除（与 sys_dept/sys_user/sys_role 保持一致）",
        "-- 幂等：列/索引已存在则跳过",
        "-- ============================================================",
        "",
        "DROP PROCEDURE IF EXISTS qxx_add_del_flag;",
        "DELIMITER $$",
        "CREATE PROCEDURE qxx_add_del_flag(IN tbl VARCHAR(64), IN cn VARCHAR(64))",
        "BEGIN",
        "  IF NOT EXISTS (SELECT 1 FROM information_schema.columns",
        "                  WHERE table_schema = DATABASE() AND table_name = tbl AND column_name = 'del_flag') THEN",
        "    SET @s = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `del_flag` char(1) NOT NULL DEFAULT ''0'' COMMENT ''', cn, '删除标志（0代表存在 2代表删除）''');",
        "    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;",
        "  END IF;",
        "  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics",
        "                  WHERE table_schema = DATABASE() AND table_name = tbl AND index_name = 'idx_del_flag') THEN",
        "    SET @s = CONCAT('ALTER TABLE `', tbl, '` ADD KEY `idx_del_flag` (`factory_id`,`del_flag`)');",
        "    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;",
        "  END IF;",
        "END$$",
        "DELIMITER ;",
        "",
    ]
    for t, cn in tables:
        lines.append(f"CALL qxx_add_del_flag('{t}','{cn}');")
    lines += ["", "DROP PROCEDURE IF EXISTS qxx_add_del_flag;", ""]
    with open(os.path.join(OUT_DIR, "V206__add_del_flag.sql"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    log.append("V206 已生成")


# ---------------------------------------------------------------- V207 组织
ORGS = [
    # (key, name, parent_key, order, leader)
    ("ROOT", "全印家供应链", None, 0, "陈总"),
    ("PQ", "生产质检部", "ROOT", 1, "陈广奇"),
    ("PROD", "生产部门", "PQ", 1, "陈广奇"),
    ("QC", "质检部门", "PQ", 2, ""),
    ("WH", "仓库", "PQ", 3, "叶崇忠"),
    ("FIN", "财务部门", "ROOT", 2, ""),
    ("HR", "人事行政", "ROOT", 3, ""),
    ("BAG", "制袋车间", "ROOT", 4, ""),
    ("PACK", "包装车间", "ROOT", 5, ""),
]

POSTS = [
    ("FGZB", "完稿制版", 20), ("GYZG", "工艺主管", 21), ("WFZG", "外发主管", 22),
    ("WXGDQC", "外协跟单QC", 23), ("GJQC", "跟单QC", 24), ("YSJZ", "印刷机长", 25),
    ("NPJPJ", "牛皮袋品检", 26), ("BZLPJ", "包装类品检", 27), ("CKWLY", "仓库物料员", 28),
    ("CCSJ", "叉车司机", 29), ("PHY", "配货员", 30), ("CG", "仓管", 31),
    ("SJWY", "数据文员", 32), ("RSXZ", "人事行政", 33),
]

# 账号, 姓名, 部门, 岗位, 角色
USERS = [
    ("fangfeifeng", "方飞锋", "PROD", "FGZB", "EMP"),
    ("juyang", "鞠阳", "PROD", "GYZG", "PROD_MGR"),
    ("chumaoli", "褚茂利", "PROD", "WFZG", "OUT_MGR"),
    ("huangxiaoben", "黄孝奔", "PROD", "WXGDQC", "QC_FOLLOW"),
    ("chenguangqi", "陈广奇", "PROD", "GJQC", "FOLLOW_MGR"),
    ("zouyu", "邹瑜", "PROD", "YSJZ", "EMP"),
    ("ouyangbin", "欧阳斌", "PROD", "YSJZ", "EMP"),
    ("liwei", "李伟", "QC", "NPJPJ", "EMP"),
    ("cailing", "蔡玲", "QC", "BZLPJ", "EMP"),
    ("yechongzhong", "叶崇忠", "WH", "CKWLY", "WH_MGR"),
    ("jiangliuzhi", "江刘治", "WH", "CCSJ", "EMP"),
    ("huxiaoguo", "胡小国", "WH", "PHY", "EMP"),
    ("zhongwanming", "钟万明", "WH", "CG", "EMP"),
    ("liuyi", "刘忆", "WH", "CG", "EMP"),
    ("chenhuilin", "陈慧琳", "FIN", "SJWY", "PUR_CLERK"),
    ("luzizi", "卢姿姿", "HR", "RSXZ", "ADMIN_VIEW"),
]

ROLES = [
    ("PROD_MGR", "生产主管", "prod_mgr", 30, "1", "报价+采购+开单+工艺路线+仓库库存"),
    ("FOLLOW_MGR", "跟单主管", "follow_mgr", 31, "1", "开单+工艺路线+全盘跟单查看"),
    ("OUT_MGR", "外发主管", "out_mgr", 32, "1", "开单+工艺路线+跟单查看"),
    ("QC_FOLLOW", "跟单QC", "qc_follow", 33, "3", "跟单+报工"),
    ("ADMIN_VIEW", "综合查看", "admin_view", 34, "1", "全盘只读查看"),
    ("WH_MGR", "仓库管理", "wh_mgr", 35, "3", "仓库模块"),
    ("PUR_CLERK", "采购文员", "pur_clerk", 36, "3", "采购+库存查询"),
    ("EMP", "生产员工", "emp", 37, "3", "报工"),
]

# 角色 -> 授权菜单根（M目录 + 具体C菜单）
ROLE_MENUS = {
    "PROD_MGR": [2900, 2970, 2006, 2002, 23360, 23190, 2003, 2300, 2305, 2301],
    "FOLLOW_MGR": [2900, 2003],
    "OUT_MGR": [2900, 2003, 2300, 2305, 2301],
    "QC_FOLLOW": [2003, 2303, 2302, 2300],
    "ADMIN_VIEW": [2001, 2002, 2003, 2006, 2900, 28900, 2005],
    "WH_MGR": [2002, 2001, 2101],
    "PUR_CLERK": [2006, 2002, 23360, 23190],
    "EMP": [2003, 2303, 2300],
}


def write_v207(log):
    L = []
    a = L.append
    a("-- ============================================================")
    a("-- V207 组织架构 / 岗位 / 用户 / 角色 重建")
    a("-- 幂等：重复执行不会产生重复数据")
    a("-- ============================================================")
    a("")
    a("SET @now = NOW();")
    a("SET @op = 'admin';")
    a("")
    a("-- ---------- 1. 部门 ----------")
    a("-- 先全量软删，再按名称+父级复活（已存在）或新建（不存在），保证可重复执行")
    a("UPDATE sys_dept SET del_flag='2', update_by=@op, update_time=@now")
    a(" WHERE factory_id=1 AND del_flag='0';")
    a("")
    a("-- 根部门：按名称复活（多条同名取最小 dept_id），不存在则创建")
    a("UPDATE sys_dept SET del_flag='0', parent_id=0, ancestors='0', order_num=0,")
    a("       leader='陈总', status='0', update_by=@op, update_time=@now")
    a(" WHERE factory_id=1 AND dept_name='全印家供应链' ORDER BY dept_id LIMIT 1;")
    a("INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)")
    a("SELECT 1,0,'0','全印家供应链',0,'陈总','0','0',@op,@now FROM DUAL")
    a(" WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='全印家供应链' AND del_flag='0');")
    a("SET @d_root = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='全印家供应链' AND del_flag='0' ORDER BY dept_id LIMIT 1);")
    a("")
    for key, name, parent, order, leader in ORGS[1:]:
        pvar = "@d_root" if parent == "ROOT" else "@d_" + parent.lower()
        # ancestors 直接按层级算，避免依赖 UPDATE 执行顺序
        anc = "CONCAT('0,', @d_root)" if parent == "ROOT" else "CONCAT('0,', @d_root, ',', @d_pq)"
        a(f"-- {name}")
        # 1) 已存在（上次执行建的）则复活
        a("UPDATE sys_dept SET del_flag='0', parent_id=" + pvar + f", ancestors={anc}, order_num={order}, leader='{leader}', status='0',"
          " update_by=@op, update_time=@now")
        a(f" WHERE factory_id=1 AND dept_name='{name}' AND parent_id={pvar} ORDER BY dept_id LIMIT 1;")
        # 2) 仍不存在才创建
        a("INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)")
        a(f"SELECT 1,{pvar},{anc},'{name}',{order},'{leader}','0','0',@op,@now FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='{name}' AND parent_id={pvar} AND del_flag='0');")
        a(f"SET @d_{key.lower()} = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='{name}' AND parent_id={pvar} AND del_flag='0' ORDER BY dept_id LIMIT 1);")
        a("")

    a("-- ---------- 2. 岗位 ----------")
    for code, name, sort in POSTS:
        a("INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)")
        a(f"SELECT '{code}','{name}',{sort},'0',@op,@now,'' FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='{code}');")
    a("")

    a("-- ---------- 3. 用户 ----------")
    a("-- 密码统一 12345678（BCrypt）")
    for uname, nick, dept, post, role in USERS:
        a(f"-- {nick}")
        a("INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)")
        a(f"SELECT 1,@d_{dept.lower()},'{uname}','{nick}','00','{PWD_BCRYPT}','0','0',@op,@now,'{post}' FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='{uname}' AND factory_id=1);")
        a(f"UPDATE sys_user SET dept_id=@d_{dept.lower()}, nick_name='{nick}', status='0', del_flag='0', update_by=@op, update_time=@now")
        a(f" WHERE user_name='{uname}' AND factory_id=1;")
        a(f"SET @u_{uname} = (SELECT user_id FROM sys_user WHERE user_name='{uname}' AND factory_id=1 LIMIT 1);")
        a("DELETE FROM sys_user_post WHERE user_id=@u_" + uname + " AND factory_id=1;")
        a(f"INSERT INTO sys_user_post (user_id,post_id,factory_id)")
        a(f"SELECT @u_{uname}, post_id, 1 FROM sys_post WHERE post_code='{post}';")
        a("")
    a("-- 陈广奇设为生产质检部/生产部门负责人")
    a("UPDATE sys_dept SET leader='陈广奇' WHERE factory_id=1 AND dept_name IN ('生产质检部','生产部门') AND del_flag='0';")
    a("UPDATE sys_dept SET leader='叶崇忠' WHERE factory_id=1 AND dept_name='仓库' AND del_flag='0';")
    a("")
    a("-- 残留用户的部门指向已删部门时置空（admin/ry/luheng 等历史账号）")
    a("UPDATE sys_user SET dept_id=NULL")
    a(" WHERE factory_id=1 AND dept_id IS NOT NULL")
    a("   AND dept_id NOT IN (SELECT dept_id FROM (SELECT dept_id FROM sys_dept WHERE del_flag='0') x);")
    a("")

    a("-- ---------- 4. 角色 ----------")
    for key, name, rkey, sort, scope, remark in ROLES:
        a(f"-- {name}")
        a("INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)")
        a(f"SELECT 1,'{name}','{rkey}',{sort},'{scope}',1,1,'0','0',@op,@now,'{remark}' FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='{rkey}' AND factory_id=1);")
        a(f"SET @r_{key.lower()} = (SELECT role_id FROM sys_role WHERE role_key='{rkey}' AND factory_id=1 AND del_flag='0' LIMIT 1);")
        # 菜单授权：给定根 + 其子菜单 + 按钮
        roots = ROLE_MENUS[key]
        ids = ",".join(str(x) for x in roots)
        a(f"DELETE FROM sys_role_menu WHERE role_id=@r_{key.lower()} AND factory_id=1;")
        a("INSERT INTO sys_role_menu (role_id,menu_id,factory_id)")
        a("SELECT DISTINCT @r_" + key.lower() + ", m.menu_id, 1 FROM sys_menu m")
        a(f" WHERE m.menu_id IN ({ids})")
        a(f"    OR m.parent_id IN ({ids})")
        a(f"    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN ({ids})) x);")
        a("")
    a("-- ---------- 5. 用户角色绑定 ----------")
    for uname, nick, dept, post, role in USERS:
        a(f"DELETE FROM sys_user_role WHERE user_id=@u_{uname} AND factory_id=1;")
        a(f"INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_{uname}, @r_{role.lower()}, 1);")
    a("")
    with open(os.path.join(OUT_DIR, "V207__org_restructure.sql"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    log.append("V207 已生成")


# ---------------------------------------------------------------- V208 主数据
def write_v208(spu, sku, edge_sku, rope_items, fin, log):
    L = []
    a = L.append
    a("-- ============================================================")
    a("-- V208 主数据重建：物料分类 / 物料 / 工艺路线 / 工序")
    a("-- 幂等")
    a("-- ============================================================")
    a("")
    a("SET @now = NOW();")
    a("SET @op = 'admin';")
    a("SET @u_kg   = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='KG'   AND factory_id=1 LIMIT 1);")
    a("SET @u_pcs  = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='PCS'  AND factory_id=1 LIMIT 1);")
    a("SET @u_pair = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='PAIR' AND factory_id=1 LIMIT 1);")
    a("")
    a("-- ---------- 1. 纸张三级分类 ----------")
    a("SET @t_paper = (SELECT item_type_id FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER' AND factory_id=1 LIMIT 1);")
    a("SET @t_rope  = (SELECT item_type_id FROM qxx_md_item_type WHERE item_type_code='RAW-ROPE'  AND factory_id=1 LIMIT 1);")
    a("")
    kinds = OrderedDict()
    for kind, code, canon in PAPER_KINDS:
        kinds[code] = canon
    order = 10
    for code, canon in kinds.items():
        a(f"INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)")
        a(f"SELECT 1,'RAW-PAPER-{code}','{canon}',@t_paper,'RAW',{order},'1',@op,@now FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-{code}' AND factory_id=1);")
        order += 10
    a("")
    a("-- 绳子二级分类（圆纸绳 / 扁纸绳）")
    for code, name, o in [("YZ", "圆纸绳", 10), ("BZ", "扁纸绳", 20)]:
        a("INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)")
        a(f"SELECT 1,'RAW-ROPE-{code}','{name}',@t_rope,'RAW',{o},'1',@op,@now FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-ROPE-{code}' AND factory_id=1);")
    a("")

    a("-- ---------- 2. 建保留清单，清理清单外的原有物料 ----------")
    all_codes = [f"RAW-PAPER-{v['code']}-{w}" for (canon, w), v in spu.items()]
    all_codes += list(sku.keys()) + list(edge_sku.keys()) + list(rope_items.keys()) + list(fin.keys())
    _raw_codes = list(all_codes)
    all_codes = list(dict.fromkeys(all_codes))
    if len(_raw_codes) != len(all_codes):
        from collections import Counter as _C
        _dup = [c for c, n in _C(_raw_codes).items() if n > 1]
        log.append(f"[去重] 物料编码重复 {len(_raw_codes)-len(all_codes)} 个: {_dup[:5]}")
    a("DROP TEMPORARY TABLE IF EXISTS tmp_keep_item;")
    a("CREATE TEMPORARY TABLE tmp_keep_item (item_code VARCHAR(64) COLLATE utf8mb4_unicode_ci NOT NULL PRIMARY KEY);")
    a("INSERT INTO tmp_keep_item (item_code) VALUES")
    for i, c in enumerate(all_codes):
        sep = "," if i < len(all_codes) - 1 else ";"
        a(f"('{c}'){sep}")
    a("")
    a("-- 不在清单内的物料逻辑删除（含历史测试物料）")
    a("UPDATE qxx_md_item i LEFT JOIN tmp_keep_item k ON i.item_code=k.item_code")
    a("   SET i.del_flag='2', i.enable_flag='0', i.update_by=@op, i.update_time=@now")
    a(" WHERE i.factory_id=1 AND i.del_flag='0' AND k.item_code IS NULL;")
    a("")

    a("-- ---------- 3. 纸张 SPU ----------")
    a("-- 柔印 11 种纸 x 18 种克重 全量 + 库存中出现的其他克重")
    for (canon, w), v in spu.items():
        code = f"RAW-PAPER-{v['code']}-{w}"
        name = v["name"]
        attrs = json.dumps({"PAPER_TYPE": canon, "PAPER_WEIGHT": w}, ensure_ascii=False)
        a("INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)")
        a(f"SELECT 1,'{code}','{name}','{w}g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1',{esc(attrs)},@op,@now")
        a(f"  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-{v['code']}' AND t.factory_id=1")
        a(f"   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='{code}' AND i.factory_id=1);")
    a("")

    a("-- ---------- 4. 纸张 SKU（按门幅） ----------")
    for code, v in sku.items():
        attrs = json.dumps(v["attrs"], ensure_ascii=False)
        a("INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)")
        a(f"SELECT 1,'{code}','{v['name']}','{v['spec']}',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,")
        a(f"       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='{v['spu_code']}' AND factory_id=1) i2),")
        a(f"       '1','1',{esc(attrs)},{esc(v['remark'])},@op,@now")
        a(f"  FROM qxx_md_item_type t WHERE t.item_type_code='{v['type_code']}' AND t.factory_id=1")
        a(f"   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='{code}' AND i.factory_id=1);")
    a("")

    a("-- ---------- 5. 纸边 SKU ----------")
    for code, v in edge_sku.items():
        attrs = json.dumps(v["attrs"], ensure_ascii=False)
        a("INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)")
        a(f"SELECT 1,'{code}','{v['name']}','{v['spec']}',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,")
        a(f"       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='{v['spu_code']}' AND factory_id=1) i2),")
        a(f"       '1','1',{esc(attrs)},{esc(v['remark'])},@op,@now")
        a(f"  FROM qxx_md_item_type t WHERE t.item_type_code='{v['type_code']}' AND t.factory_id=1")
        a(f"   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='{code}' AND i.factory_id=1);")
    a("")

    a("-- ---------- 6. 辅料纸绳 ----------")
    for code, v in rope_items.items():
        sub_code = "RAW-ROPE-YZ" if v["sub"] == "圆纸绳" else "RAW-ROPE-BZ"
        a("INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)")
        a(f"SELECT 1,'{code}','{v['name']}','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{{}}',@op,@now")
        a(f"  FROM qxx_md_item_type t WHERE t.item_type_code='{sub_code}' AND t.factory_id=1")
        a(f"   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='{code}' AND i.factory_id=1);")
    a("")

    a("-- ---------- 7. 成品物料（扁平，parent_id=0） ----------")
    for code, v in fin.items():
        a("INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)")
        a(f"SELECT 1,'{code}','{v['name']}',{esc(v['spec'])},@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{{}}',{esc(v['src'])},@op,@now")
        a("  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1")
        a(f"   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='{code}' AND i.factory_id=1);")
    a("")

    a("-- ---------- 8. 原有工艺路线 / 工序 逻辑删除（保留本次新建的） ----------")
    a("UPDATE qxx_pro_route SET del_flag='2', enable_flag='0', update_by=@op, update_time=@now")
    a(" WHERE factory_id=1 AND del_flag='0' AND route_code<>'ROUTE-KRAFT-BAG';")
    a("UPDATE qxx_pro_process SET del_flag='2', enable_flag='0', update_by=@op, update_time=@now")
    a(" WHERE factory_id=1 AND del_flag='0' AND process_code NOT LIKE 'PRC-BAG-%';")
    a("-- 路线-工序关联表无启用标志，随路线 del_flag 一起失效")
    a("")
    a("-- ---------- 9. 卷筒牛皮纸袋生产工艺路线 + 8 道工序 ----------")
    procs = [
        ("YL", "原纸", 10), ("FL", "辅料", 20), ("YS", "印刷", 30), ("ZD", "制袋", 40),
        ("TS", "贴绳", 50), ("BZ", "包装", 60), ("CPRK", "产品入库", 70), ("XSCK", "销售出库", 80),
    ]
    for code, name, o in procs:
        a("INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)")
        a(f"SELECT 1,'PRC-BAG-{code}','{name}','','1',@op,@now FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-{code}' AND factory_id=1);")
    a("")
    a("INSERT INTO qxx_pro_route (factory_id,route_code,route_name,route_desc,enable_flag,create_by,create_time)")
    a("SELECT 1,'ROUTE-KRAFT-BAG','卷筒牛皮纸袋生产工艺路线','原纸-辅料-印刷-制袋-贴绳-包装-产品入库-销售出库','1',@op,@now FROM DUAL")
    a(" WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_route WHERE route_code='ROUTE-KRAFT-BAG' AND factory_id=1);")
    a("SET @rt_bag = (SELECT route_id FROM qxx_pro_route WHERE route_code='ROUTE-KRAFT-BAG' AND factory_id=1 LIMIT 1);")
    a("")
    prev = None
    for code, name, o in procs:
        nxt = None
        a("INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)")
        a(f"SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,{o},NULL,NULL,NULL,'SS','N','N','0','#00AEF3'")
        a(f"  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-{code}' AND p.factory_id=1")
        a(f"   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-{code}' AND rp.factory_id=1);")
    a("")
    a("-- 回填 next_process")
    a("UPDATE qxx_pro_route_process a JOIN qxx_pro_route_process b")
    a("  ON a.route_id=b.route_id AND a.factory_id=b.factory_id AND b.order_num=(")
    a("     SELECT MIN(c.order_num) FROM (SELECT route_id,factory_id,order_num FROM qxx_pro_route_process) c")
    a("      WHERE c.route_id=a.route_id AND c.factory_id=a.factory_id AND c.order_num>a.order_num)")
    a("   SET a.next_process_id=b.process_id, a.next_process_code=b.process_code, a.next_process_name=b.process_name")
    a(" WHERE a.route_id=@rt_bag AND a.factory_id=1;")
    a("")
    a("-- ---------- 10. 清单内物料兜底复活（重复执行安全） ----------")
    a("UPDATE qxx_md_item i JOIN tmp_keep_item k ON i.item_code=k.item_code")
    a("   SET i.del_flag='0', i.enable_flag='1', i.update_by=@op, i.update_time=@now")
    a(" WHERE i.factory_id=1 AND (i.del_flag<>'0' OR i.enable_flag<>'1');")
    a("")
    a("-- 兜底复活工艺路线/工序")
    a("UPDATE qxx_pro_route SET del_flag='0', enable_flag='1' WHERE factory_id=1 AND route_code='ROUTE-KRAFT-BAG' AND del_flag<>'0';")
    a("UPDATE qxx_pro_process SET del_flag='0', enable_flag='1' WHERE factory_id=1 AND process_code LIKE 'PRC-BAG-%' AND del_flag<>'0';")
    a("")
    a("DROP TEMPORARY TABLE IF EXISTS tmp_keep_item;")
    a("")
    with open(os.path.join(OUT_DIR, "V208__master_data.sql"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    log.append("V208 已生成")


# ---------------------------------------------------------------- V209 业务数据
def write_v209(sku, edge_sku, rope_items, fin, vendors, log):
    L = []
    a = L.append
    a("-- ============================================================")
    a("-- V209 业务数据清理 + 期初库存导入 + 供应商补充")
    a("-- ============================================================")
    a("")
    a("SET @now = NOW();")
    a("SET @op = 'admin';")
    a("")
    a("-- ---------- 1. 单据逻辑删除 ----------")
    for t, cn in [
        ("qxx_pro_workorder", "工单"),
        ("qxx_sal_order", "销售订单"),
        ("qxx_sal_quote", "报价单"),
        ("qxx_pur_order", "采购订单"),
    ]:
        a(f"-- {cn}")
        a(f"UPDATE {t} SET del_flag='2', update_by=@op, update_time=@now WHERE factory_id=1 AND del_flag='0';")
    a("")
    a("-- 库存：先建保留清单（本次要导入期初的物料），清单外的存量库存全部逻辑删除")
    stock_codes = []
    for src in (sku, edge_sku, fin):
        for code, v in src.items():
            if v["qty"] not in (None, "", 0):
                stock_codes.append(code)
    a("DROP TEMPORARY TABLE IF EXISTS tmp_keep_stock;")
    a("CREATE TEMPORARY TABLE tmp_keep_stock (item_code VARCHAR(64) COLLATE utf8mb4_unicode_ci NOT NULL PRIMARY KEY);")
    a("INSERT INTO tmp_keep_stock (item_code) VALUES")
    for i, c in enumerate(stock_codes):
        sep = "," if i < len(stock_codes) - 1 else ";"
        a(f"('{c}'){sep}")
    a("")
    a("UPDATE qxx_wm_material_stock s LEFT JOIN tmp_keep_stock k ON s.item_code=k.item_code")
    a("   SET s.del_flag='2', s.enable_flag='0', s.update_by=@op, s.update_time=@now")
    a(" WHERE s.factory_id=1 AND s.del_flag='0' AND k.item_code IS NULL;")
    a("")
    a("-- 库存事务流水（保留历史，不删；如需要可注释掉下面一句）")
    a("-- UPDATE qxx_wm_transaction SET remark=CONCAT(IFNULL(remark,''),' [历史]') WHERE factory_id=1;")
    a("")
    a("-- 客户逻辑删除（供应商保留）")
    a("UPDATE qxx_md_client SET enable_flag='0', update_by=@op, update_time=@now WHERE factory_id=1 AND enable_flag='1';")
    a("")
    a("-- ---------- 2. 供应商补充（外采表涉及但系统中没有的） ----------")
    for i, v in enumerate(vendors.keys(), 1):
        code = f"VEN-AUTO-{i:03d}"
        a("INSERT INTO qxx_md_vendor (factory_id,vendor_code,vendor_name,vendor_type,enable_flag,create_by,create_time)")
        a(f"SELECT 1,'{code}','{v}','MATERIAL','1',@op,@now FROM DUAL")
        a(f" WHERE NOT EXISTS (SELECT 1 FROM qxx_md_vendor WHERE vendor_name='{v}' AND factory_id=1);")
    a("")
    a("-- ---------- 3. 期初库存 ----------")
    a("SET @wh_raw  = (SELECT warehouse_id FROM qxx_wm_warehouse WHERE factory_id=1 AND warehouse_type='RAW'      AND enable_flag='1' ORDER BY warehouse_id LIMIT 1);")
    a("SET @wh_aux  = (SELECT warehouse_id FROM qxx_wm_warehouse WHERE factory_id=1 AND warehouse_type='AUX'      AND enable_flag='1' ORDER BY warehouse_id LIMIT 1);")
    a("SET @wh_fin  = (SELECT warehouse_id FROM qxx_wm_warehouse WHERE factory_id=1 AND warehouse_type='FINISHED' AND enable_flag='1' ORDER BY warehouse_id LIMIT 1);")
    a("SET @u_kg    = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='KG'   AND factory_id=1 LIMIT 1);")
    a("SET @u_pcs   = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='PCS'  AND factory_id=1 LIMIT 1);")
    a("SET @u_pair  = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='PAIR' AND factory_id=1 LIMIT 1);")
    a("")
    a("DROP TEMPORARY TABLE IF EXISTS tmp_init_stock;")
    a("CREATE TEMPORARY TABLE tmp_init_stock (")
    a("  item_code VARCHAR(64) COLLATE utf8mb4_unicode_ci NOT NULL,")
    a("  qty DECIMAL(14,4) NOT NULL,")
    a("  wh_id BIGINT NOT NULL,")
    a("  remark VARCHAR(255)")
    a(");")
    a("")
    rows = []
    for code, v in sku.items():
        if v["qty"] in (None, "", 0):
            continue
        rows.append((code, v["qty"], "@wh_raw", v["remark"]))
    for code, v in edge_sku.items():
        if v["qty"] in (None, "", 0):
            continue
        rows.append((code, v["qty"], "@wh_raw", v["remark"]))
    for code, v in fin.items():
        if v["qty"] in (None, "", 0):
            continue
        rows.append((code, v["qty"], "@wh_fin", f"期初-{v['src']}"))
    a("INSERT INTO tmp_init_stock (item_code,qty,wh_id,remark) VALUES")
    for i, (code, qty, wh, rm) in enumerate(rows):
        sep = "," if i < len(rows) - 1 else ";"
        a(f"('{code}',{qty},{wh},{esc(rm)}){sep}")
    a("")
    a("INSERT INTO qxx_wm_material_stock")
    a(" (factory_id,item_id,item_code,item_name,specification,unit_of_measure,unit_name,")
    a("  quantity_onhand,quantity_onhand2,quantity_available,quantity_available2,quantity_locked,")
    a("  batch_id,batch_code,warehouse_id,warehouse_code,warehouse_name,")
    a("  vendor_id,workorder_id,quality_status,status,enable_flag,remark,create_by,create_time)")
    a("SELECT 1,i.item_id,i.item_code,i.item_name,i.specification,")
    a("       CASE WHEN i.unit_of_measure='PCS' THEN 'PCS' WHEN i.unit_of_measure='PAIR' THEN 'PAIR' ELSE 'KG' END,")
    a("       i.unit_name, st.qty,0,st.qty,0,0,")
    a("       0,'',w.warehouse_id,w.warehouse_code,w.warehouse_name,")
    a("       0,0,'NORMAL','NORMAL','1',st.remark,@op,@now")
    a("  FROM tmp_init_stock st")
    a("  JOIN qxx_md_item i ON i.item_code=st.item_code AND i.factory_id=1")
    a("  JOIN qxx_wm_warehouse w ON w.warehouse_id=st.wh_id AND w.factory_id=1")
    a(" WHERE NOT EXISTS (SELECT 1 FROM qxx_wm_material_stock s")
    a("        WHERE s.item_id=i.item_id AND s.warehouse_id=w.warehouse_id AND s.batch_id=0 AND s.factory_id=1 AND s.del_flag='0');")
    a("")
    a("-- 清单内库存兜底复活（重复执行安全）")
    a("UPDATE qxx_wm_material_stock s JOIN tmp_keep_stock k ON s.item_code=k.item_code")
    a("   SET s.del_flag='0', s.enable_flag='1'")
    a(" WHERE s.factory_id=1 AND (s.del_flag<>'0' OR s.enable_flag<>'1');")
    a("")
    a("DROP TEMPORARY TABLE IF EXISTS tmp_keep_stock;")
    a("DROP TEMPORARY TABLE IF EXISTS tmp_init_stock;")
    a("")
    with open(os.path.join(OUT_DIR, "V209__business_reset.sql"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    log.append("V209 已生成")


# ---------------------------------------------------------------- V210 修正
def write_v210(fin, log):
    """修正 V209 的两处缺陷：单位存成 unit_id、缺装箱规格/辅助数量/PO号"""
    L = []
    a = L.append
    a("-- ============================================================")
    a("-- V210 修正期初数据的计量单位与辅助单位")
    a("-- 修正 V209 两处缺陷：")
    a("--   1) unit_of_measure 误写为 unit_id（200/201/204），应为单位编码（PCS/KG/PAIR）")
    a("--   2) 未导入装箱数量（conversion_rate）、剩余箱数（quantity_onhand2）、PO号、系统订单号")
    a("-- 幂等")
    a("-- ============================================================")
    a("")
    a("SET @now = NOW();")
    a("SET @op = 'admin';")
    a("")
    a("-- ---------- 1. 库存表新增 PO 号 / 系统订单号 ----------")
    a("DROP PROCEDURE IF EXISTS qxx_add_stock_doc_cols;")
    a("DELIMITER $$")
    a("CREATE PROCEDURE qxx_add_stock_doc_cols()")
    a("BEGIN")
    a("  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE()")
    a("                  AND table_name = 'qxx_wm_material_stock' AND column_name = 'po_no') THEN")
    a("    ALTER TABLE `qxx_wm_material_stock` ADD COLUMN `po_no` varchar(64) DEFAULT NULL COMMENT '客户PO号' AFTER `lot_number`;")
    a("  END IF;")
    a("  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE()")
    a("                  AND table_name = 'qxx_wm_material_stock' AND column_name = 'source_order_code') THEN")
    a("    ALTER TABLE `qxx_wm_material_stock` ADD COLUMN `source_order_code` varchar(64) DEFAULT NULL COMMENT '来源系统订单号' AFTER `po_no`;")
    a("  END IF;")
    a("END$$")
    a("DELIMITER ;")
    a("CALL qxx_add_stock_doc_cols();")
    a("DROP PROCEDURE IF EXISTS qxx_add_stock_doc_cols;")
    a("")
    a("-- ---------- 2. 单位字段从 unit_id 改为单位编码 ----------")
    a("UPDATE qxx_md_item SET unit_of_measure='PCS'  WHERE factory_id=1 AND unit_of_measure='200';")
    a("UPDATE qxx_md_item SET unit_of_measure='KG'   WHERE factory_id=1 AND unit_of_measure='201';")
    a("UPDATE qxx_md_item SET unit_of_measure='PAIR' WHERE factory_id=1 AND unit_of_measure='204';")
    a("")
    a("-- 库存行按物料回填主单位（V209 里成品被误写成 KG）")
    a("UPDATE qxx_wm_material_stock s")
    a("  JOIN qxx_md_item i ON s.item_id = i.item_id AND i.factory_id = 1")
    a("   SET s.unit_of_measure = i.unit_of_measure, s.unit_name = i.unit_name")
    a(" WHERE s.factory_id = 1 AND s.del_flag = '0';")
    a("")
    a("-- ---------- 3. 成品装箱规格 / 箱数 / PO号 / 订单号 ----------")
    rows = []
    for code, v in fin.items():
        packing = v.get("packing")
        boxes = v.get("boxes")
        po = v.get("po") or ""
        ono = v.get("order_no") or ""
        if packing in (None, "", 0) and boxes in (None, "") and not po and not ono:
            continue
        rows.append((code, packing, boxes, po, ono))
    a("DROP TEMPORARY TABLE IF EXISTS tmp_fin_spec;")
    a("CREATE TEMPORARY TABLE tmp_fin_spec (")
    a("  item_code VARCHAR(64) COLLATE utf8mb4_unicode_ci NOT NULL PRIMARY KEY,")
    a("  packing DECIMAL(14,4) DEFAULT NULL,")
    a("  boxes DECIMAL(14,4) DEFAULT NULL,")
    a("  po_no VARCHAR(64) DEFAULT NULL,")
    a("  order_no VARCHAR(64) DEFAULT NULL")
    a(");")
    a("INSERT INTO tmp_fin_spec (item_code,packing,boxes,po_no,order_no) VALUES")
    for i, (code, packing, boxes, po, ono) in enumerate(rows):
        sep = "," if i < len(rows) - 1 else ";"
        a(f"('{code}',{num_or_null(packing)},{num_or_null(boxes)},{esc(po or None)},{esc(ono or None)}){sep}")
    a("")
    a("-- 物料：辅助单位=箱，换算率=每箱数量，装箱规格文本")
    a("UPDATE qxx_md_item i JOIN tmp_fin_spec t ON i.item_code = t.item_code")
    a("   SET i.unit2='BOX', i.unit2_name='箱', i.conversion_rate=t.packing,")
    a("       i.package_spec=CONCAT(CAST(t.packing AS UNSIGNED), '个/箱')")
    a(" WHERE i.factory_id=1 AND t.packing IS NOT NULL AND t.packing > 0;")
    a("")
    a("-- 库存：辅助单位/换算率/辅助数量（箱数）/PO号/订单号")
    a("UPDATE qxx_wm_material_stock s JOIN tmp_fin_spec t ON s.item_code = t.item_code")
    a("   SET s.unit2='BOX', s.unit2_name='箱',")
    a("       s.conversion_rate=IFNULL(NULLIF(t.packing,0),1),")
    a("       s.quantity_onhand2=IFNULL(t.boxes,0),")
    a("       s.quantity_available2=IFNULL(t.boxes,0),")
    a("       s.po_no=NULLIF(t.po_no,''),")
    a("       s.source_order_code=NULLIF(t.order_no,'')")
    a(" WHERE s.factory_id=1 AND s.del_flag='0';")
    a("")
    a("DROP TEMPORARY TABLE IF EXISTS tmp_fin_spec;")
    a("")
    with open(os.path.join(OUT_DIR, "V210__fix_stock_units.sql"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    log.append(f"V210 已生成（装箱规格 {len(rows)} 条）")


def num_or_null(v):
    if v is None or v == "":
        return "NULL"
    try:
        return str(float(v))
    except (TypeError, ValueError):
        return "NULL"


if __name__ == "__main__":
    main()
