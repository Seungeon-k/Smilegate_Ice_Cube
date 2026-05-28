# -*- coding: utf-8 -*-
"""
Build INDEX.md from converted markdown files at
C:/Users/user/Desktop/zammy_guide_markdown.

Groups LuaScript subcategories (Components/DataTypes/Resources/Utilities/VObjects)
by class -> Methods/Properties/Events.
"""
import os
import re

ROOT = r"C:\Users\user\Desktop\zammy_guide_markdown"
OUTPUT = os.path.join(ROOT, "INDEX.md")

LUA_SUBCATS = ["Components", "DataTypes", "Resources", "Utilities", "VObjects"]
BUCKETS_ORDER = ["Methods", "Properties", "Events", "(root)"]


def read_title(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            txt = f.read(2048)
    except Exception:
        return None
    m = re.match(r"---\s*\n(.*?)\n---", txt, re.S)
    if not m:
        return None
    fm = m.group(1)
    tm = re.search(r"^title:\s*(.+)$", fm, re.M)
    if not tm:
        return None
    val = tm.group(1).strip()
    if val.startswith('"') and val.endswith('"'):
        val = val[1:-1].replace('\\"', '"').replace("\\\\", "\\")
    return val


def collect():
    items = []
    for dirpath, dirs, filenames in os.walk(ROOT):
        dirs[:] = [d for d in dirs if not d.startswith("_") and d != "images"]
        for fn in filenames:
            if not fn.endswith(".md") or fn == "INDEX.md":
                continue
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, ROOT).replace("\\", "/")
            title = read_title(full) or fn[:-3]
            items.append((rel, title))
    items.sort(key=lambda t: t[0])
    return items


def md_link(title, rel):
    safe = title.replace("[", "\\[").replace("]", "\\]")
    return f"- [{safe}]({rel})"


def main():
    items = collect()
    print("Total md:", len(items))

    root_pages = []
    creator_hub = []
    # lua[subcat] = {
    #   "singletons": [(rel,title)],
    #   "classes": { class_name: { bucket: [(rel,title)] } }
    # }
    lua = {sc: {"singletons": [], "classes": {}} for sc in LUA_SUBCATS}

    for rel, title in items:
        parts = rel.split("/")
        if len(parts) == 1:
            root_pages.append((rel, title))
        elif parts[0] == "creator-hub":
            creator_hub.append((rel, title))
        elif parts[0] == "LuaScript" and len(parts) >= 2:
            sub = parts[1]
            if sub not in lua:
                continue
            if len(parts) == 3:
                lua[sub]["singletons"].append((rel, title))
            elif len(parts) >= 4:
                cls = parts[2]
                bucket = parts[3] if len(parts) > 4 else "(root)"
                lua[sub]["classes"].setdefault(cls, {}).setdefault(bucket, []).append((rel, title))

    # Counts
    def count_subcat(d):
        n = len(d["singletons"])
        for cls, buckets in d["classes"].items():
            for b, lst in buckets.items():
                n += len(lst)
        return n

    counts = {sc: count_subcat(lua[sc]) for sc in LUA_SUBCATS}
    lua_total = sum(counts.values())

    out = []
    out.append("# 재미스미스(Zammy Smith) 크리에이터 가이드 INDEX")
    out.append("")
    out.append(
        f"총 {len(items)}개 페이지. 원본은 https://developers-zammysmith.onstove.com/ko/ 의 SingleFile 저장본을 변환한 결과입니다. 각 페이지 상단 frontmatter에 `source_url` / `last_updated` 메타데이터가 있습니다."
    )
    out.append("")
    out.append("## 카테고리 요약")
    out.append("")
    out.append(f"- **시작하기** ({len(root_pages)})")
    out.append(f"- **Creator Hub** ({len(creator_hub)})")
    out.append(f"- **Lua Script API** ({lua_total})")
    for sc in LUA_SUBCATS:
        out.append(f"  - [{sc}](#luascript--{sc.lower()}) ({counts[sc]})")
    out.append("")

    out.append("## 시작하기")
    out.append("")
    for rel, title in sorted(root_pages):
        out.append(md_link(title, rel))
    out.append("")

    out.append("## Creator Hub")
    out.append("")
    for rel, title in sorted(creator_hub):
        out.append(md_link(title, rel))
    out.append("")

    out.append("## Lua Script API")
    out.append("")

    for sc in LUA_SUBCATS:
        d = lua[sc]
        out.append(f'### LuaScript / {sc} ({counts[sc]}) <a id="luascript--{sc.lower()}"></a>')
        out.append("")
        if d["singletons"]:
            out.append("**단일 페이지**")
            out.append("")
            for rel, title in sorted(d["singletons"]):
                out.append(md_link(title, rel))
            out.append("")
        for cls in sorted(d["classes"].keys()):
            buckets = d["classes"][cls]
            cls_total = sum(len(v) for v in buckets.values())
            out.append(f"#### {cls} ({cls_total})")
            out.append("")
            for bucket in BUCKETS_ORDER:
                if bucket not in buckets:
                    continue
                items_b = sorted(buckets[bucket])
                label = bucket if bucket != "(root)" else "Other"
                out.append(f"_{label}_ ({len(items_b)})")
                out.append("")
                for rel, title in items_b:
                    out.append(md_link(title, rel))
                out.append("")

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("\n".join(out))
    print("Wrote:", OUTPUT)


if __name__ == "__main__":
    main()
