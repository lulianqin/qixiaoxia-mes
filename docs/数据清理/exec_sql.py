# -*- coding: utf-8 -*-
"""
SQL 脚本执行器（支持 DELIMITER 语法）
用法:
  python exec_sql.py local              # 本地 127.0.0.1:3307
  python exec_sql.py local V207         # 只跑某个文件（前缀匹配）
  python exec_sql.py local --dry        # 只切分不执行
"""
import os
import re
import sys
import pymysql

BASE = os.path.dirname(os.path.abspath(__file__))
SQL_DIR = os.path.join(BASE, "sql")

CONNS = {
    "local": dict(host="127.0.0.1", port=3307, user="root", password="root"),
}


def split_sql(text):
    """按 DELIMITER 规则切分语句"""
    stmts = []
    delimiter = ";"
    buf = []
    for raw_line in text.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("--") or stripped.startswith("#"):
            continue
        m = re.match(r"(?i)^DELIMITER\s+(\S+)$", stripped)
        if m:
            if buf:
                s = "\n".join(buf).strip()
                if s:
                    stmts.append(s)
                buf = []
            delimiter = m.group(1)
            continue
        buf.append(line)
        if stripped.endswith(delimiter):
            joined = "\n".join(buf).strip()
            joined = joined[: -len(delimiter)].strip()
            if joined:
                stmts.append(joined)
            buf = []
    if buf:
        s = "\n".join(buf).strip()
        if s:
            stmts.append(s)
    return stmts


def main():
    env = sys.argv[1] if len(sys.argv) > 1 else "local"
    only = sys.argv[2] if len(sys.argv) > 2 else None
    dry = "--dry" in sys.argv

    files = sorted(f for f in os.listdir(SQL_DIR) if f.endswith(".sql"))
    if only:
        files = [f for f in files if only in f]

    conn = pymysql.connect(database="mes", charset="utf8mb4", autocommit=True, **CONNS[env])
    cur = conn.cursor()

    for fn in files:
        path = os.path.join(SQL_DIR, fn)
        with open(path, encoding="utf-8") as fh:
            text = fh.read()
        stmts = split_sql(text)
        print(f"\n===== {fn}  ({len(stmts)} 条语句) =====")
        if dry:
            for i, s in enumerate(stmts[:5], 1):
                print(f"--[{i}] {s[:120]}...")
            continue
        for i, s in enumerate(stmts, 1):
            try:
                cur.execute(s)
                affected = cur.rowcount
                head = re.sub(r"\s+", " ", s)[:78]
                if cur.description:
                    rows = cur.fetchall()
                    print(f"  [{i:>3}] OK rows={len(rows):<4} {head}")
                elif affected and affected > 0:
                    print(f"  [{i:>3}] OK aff={affected:<5} {head}")
            except Exception as e:
                print(f"  [{i:>3}] FAIL {head}\n        -> {e}")
                conn.close()
                sys.exit(1)
    conn.close()
    print("\n完成")


if __name__ == "__main__":
    main()
