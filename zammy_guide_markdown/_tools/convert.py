# -*- coding: utf-8 -*-
"""
Convert SingleFile-saved Zammy Smith Creator Guide HTML pages
from C:/Users/user/Downloads/ko into a clean Markdown tree at
C:/Users/user/Desktop/zammy_guide_markdown.

Usage:
    py convert.py [--sample] [--limit N]

Stdlib only.
"""
import os
import re
import sys
import base64
import hashlib
from html.parser import HTMLParser

INPUT_ROOT = r"C:\Users\user\Downloads\ko"
OUTPUT_ROOT = r"C:\Users\user\Desktop\zammy_guide_markdown"
IMAGES_DIR = os.path.join(OUTPUT_ROOT, "images")
SITE_PREFIX = "https://developers-zammysmith.onstove.com/ko/"


# --------- DOM tree ---------
class Node:
    __slots__ = ("tag", "attrs", "text", "children", "parent")

    def __init__(self, tag=None, attrs=None, parent=None):
        self.tag = tag
        self.attrs = dict(attrs or [])
        self.text = None
        self.children = []
        self.parent = parent


class TreeBuilder(HTMLParser):
    VOID = {
        "img", "br", "hr", "meta", "link", "input", "col", "area",
        "base", "embed", "param", "source", "track", "wbr",
    }

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = Node("__root__")
        self.cur = self.root

    def handle_starttag(self, tag, attrs):
        n = Node(tag, attrs, self.cur)
        self.cur.children.append(n)
        if tag not in self.VOID:
            self.cur = n

    def handle_startendtag(self, tag, attrs):
        n = Node(tag, attrs, self.cur)
        self.cur.children.append(n)

    def handle_endtag(self, tag):
        n = self.cur
        while n is not self.root and n.tag != tag:
            n = n.parent
        if n.parent is not None:
            self.cur = n.parent

    def handle_data(self, data):
        n = Node(None, parent=self.cur)
        n.text = data
        self.cur.children.append(n)


def parse_html(s):
    tb = TreeBuilder()
    tb.feed(s)
    return tb.root


def text_of(node):
    if node.text is not None:
        return node.text
    return "".join(text_of(c) for c in node.children)


def find_all(node, tag):
    out = []
    if node.tag == tag:
        out.append(node)
    for c in node.children:
        out.extend(find_all(c, tag))
    return out


def find_first(node, tag):
    if node.tag == tag:
        return node
    for c in node.children:
        r = find_first(c, tag)
        if r:
            return r
    return None


def has_class(node, name):
    cls = node.attrs.get("class", "")
    return name in cls.split()


# --------- Markdown renderer ---------
class MdRenderer:
    def __init__(self, page_slug, images_dir, url_to_relmd, current_md_path):
        self.page_slug = page_slug
        self.images_dir = images_dir
        self.url_to_relmd = url_to_relmd
        self.current_md_path = current_md_path
        self.img_counter = 0

    def render(self, node):
        return self.render_block(node).strip("\n") + "\n"

    def render_block(self, node):
        out = []
        for c in node.children:
            if c.tag is None:
                t = c.text or ""
                if t.strip():
                    out.append(t.strip() + "\n\n")
                continue
            tag = c.tag
            if tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
                lvl = int(tag[1])
                inline = self.render_inline(c).strip()
                out.append("#" * lvl + " " + inline + "\n\n")
            elif tag == "p":
                inline = self.render_inline(c).strip()
                if inline:
                    out.append(inline + "\n\n")
            elif tag == "blockquote":
                inner = self.render_block(c).strip("\n")
                lines = inner.split("\n")
                out.append("\n".join(("> " + l) if l else ">" for l in lines) + "\n\n")
            elif tag == "ul":
                out.append(self.render_list(c, "ul") + "\n\n")
            elif tag == "ol":
                out.append(self.render_list(c, "ol") + "\n\n")
            elif tag == "pre":
                out.append(self.render_pre(c))
            elif tag == "table":
                out.append(self.render_table(c) + "\n")
            elif tag == "hr":
                out.append("---\n\n")
            elif tag == "br":
                out.append("\n")
            elif tag == "img":
                im = self.render_img(c)
                if im:
                    out.append(im + "\n\n")
            elif tag == "figure":
                img = find_first(c, "img")
                if img:
                    im = self.render_img(img)
                    if im:
                        out.append(im + "\n\n")
                cap = find_first(c, "figcaption")
                if cap:
                    inline = self.render_inline(cap).strip()
                    if inline:
                        out.append("*" + inline + "*\n\n")
            elif tag in ("div", "section", "article", "main"):
                if has_class(c, "table-wrapper"):
                    tbl = find_first(c, "table")
                    if tbl:
                        out.append(self.render_table(tbl) + "\n")
                    continue
                out.append(self.render_block(c))
            elif tag == "details":
                summary = find_first(c, "summary")
                summary_text = self.render_inline(summary).strip() if summary else ""
                out.append("<details><summary>" + summary_text + "</summary>\n\n")
                kids = [k for k in c.children if k is not summary]
                fake = Node("__fake__")
                fake.children = kids
                out.append(self.render_block(fake))
                out.append("</details>\n\n")
            elif tag == "button":
                continue
            else:
                inline = self.render_inline(c).strip()
                if inline:
                    out.append(inline + "\n\n")
        return "".join(out)

    def render_inline(self, node):
        out = []
        for c in node.children:
            if c.tag is None:
                t = c.text or ""
                if t:
                    out.append(t)
                continue
            tag = c.tag
            if tag in ("strong", "b"):
                out.append("**" + self.render_inline(c) + "**")
            elif tag in ("em", "i"):
                out.append("*" + self.render_inline(c) + "*")
            elif tag == "code":
                out.append("`" + text_of(c) + "`")
            elif tag == "a":
                href = self.normalize_link(c.attrs.get("href", ""))
                inner = self.render_inline(c)
                if href:
                    out.append("[" + inner + "](" + href + ")")
                else:
                    out.append(inner)
            elif tag == "br":
                out.append("  \n")
            elif tag == "img":
                im = self.render_img(c)
                if im:
                    out.append(im)
            elif tag in ("del", "s"):
                out.append("~~" + self.render_inline(c) + "~~")
            elif tag == "button":
                continue
            elif tag in ("span", "u", "mark", "sub", "sup", "font", "small",
                        "div", "p", "section"):
                out.append(self.render_inline(c))
            else:
                out.append(self.render_inline(c))
        return "".join(out)

    def render_list(self, node, kind, depth=0):
        lines = []
        idx = 0
        indent = "  " * depth
        for li in node.children:
            if li.tag != "li":
                continue
            idx += 1
            marker = "- " if kind == "ul" else f"{idx}. "
            inline_kids = []
            block_kids = []
            for k in li.children:
                if k.tag in ("ul", "ol", "p", "pre", "blockquote", "table", "div"):
                    block_kids.append(k)
                else:
                    inline_kids.append(k)
            fake = Node("__fake__")
            fake.children = inline_kids
            inline_text = self.render_inline(fake).strip()
            lines.append(indent + marker + inline_text)
            for bk in block_kids:
                if bk.tag == "ul":
                    lines.append(self.render_list(bk, "ul", depth + 1))
                elif bk.tag == "ol":
                    lines.append(self.render_list(bk, "ol", depth + 1))
                elif bk.tag == "p":
                    p_text = self.render_inline(bk).strip()
                    if p_text:
                        lines.append(indent + "  " + p_text)
                elif bk.tag == "pre":
                    pre_md = self.render_pre(bk).rstrip("\n")
                    pre_lines = pre_md.split("\n")
                    lines.append("\n".join((indent + "  " + l) if l else "" for l in pre_lines))
                elif bk.tag == "div":
                    sub = self.render_block(bk).strip("\n")
                    if sub:
                        sub_lines = sub.split("\n")
                        lines.append("\n".join((indent + "  " + l) if l else "" for l in sub_lines))
        return "\n".join(lines)

    def render_pre(self, node):
        # collect raw text of all descendants (preserves whitespace/newlines)
        text = text_of(node)
        text = text.strip("\n")
        # collapse trailing whitespace per line but preserve blank lines
        cleaned_lines = [l.rstrip() for l in text.split("\n")]
        # drop trailing empty lines
        while cleaned_lines and cleaned_lines[-1] == "":
            cleaned_lines.pop()
        return "```lua\n" + "\n".join(cleaned_lines) + "\n```\n\n"

    def render_table(self, node):
        thead = find_first(node, "thead")
        rows = []
        seen_tr = set()
        if thead:
            for tr in find_all(thead, "tr"):
                cells = [self.cell_md(c) for c in tr.children if c.tag in ("th", "td")]
                rows.append(("th", cells))
                seen_tr.add(id(tr))
        for tr in find_all(node, "tr"):
            if id(tr) in seen_tr:
                continue
            cells = [self.cell_md(c) for c in tr.children if c.tag in ("th", "td")]
            only_th = all(c.tag == "th" for c in tr.children if c.tag in ("th", "td"))
            rows.append(("th" if only_th else "td", cells))
        if not rows:
            return ""
        cols = max(len(r[1]) for r in rows)
        if rows[0][0] != "th":
            rows.insert(0, ("th", [""] * cols))
        out = []
        head = rows[0][1] + [""] * (cols - len(rows[0][1]))
        out.append("| " + " | ".join(head) + " |")
        out.append("| " + " | ".join(["---"] * cols) + " |")
        for kind, cells in rows[1:]:
            cells = cells + [""] * (cols - len(cells))
            out.append("| " + " | ".join(cells) + " |")
        return "\n".join(out) + "\n"

    def cell_md(self, td):
        s = self.render_inline(td)
        s = s.replace("\r", " ").replace("\n", " ")
        s = re.sub(r"\s+", " ", s).strip()
        s = s.replace("|", "\\|")
        return s

    def render_img(self, c):
        src = c.attrs.get("src", "")
        alt = (c.attrs.get("alt", "") or "").strip()
        if src.startswith("data:image/"):
            self.img_counter += 1
            name = self.save_data_image(src, alt, self.img_counter)
            if not name:
                return ""
            rel = self.relpath_to_image(name)
            alt_clean = alt.replace("]", "").replace("[", "")
            return "![" + alt_clean + "](" + rel + ")"
        if src:
            return "![" + alt + "](" + src + ")"
        return ""

    def save_data_image(self, src, alt, idx):
        m = re.match(r"data:image/([\w\+\-]+);base64,(.+)", src, re.S)
        if not m:
            return None
        ext = m.group(1).lower()
        if ext == "svg+xml":
            ext = "svg"
        if ext == "jpeg":
            ext = "jpg"
        b64 = re.sub(r"\s+", "", m.group(2))
        try:
            raw = base64.b64decode(b64)
        except Exception:
            return None
        h = hashlib.sha1(raw).hexdigest()[:10]
        # base name from alt's filename if it looks like one
        base = None
        if alt:
            am = re.search(r"([\w\-]+)\.(png|jpg|jpeg|gif|webp|svg)", alt, re.I)
            if am:
                base = am.group(1)
        if not base:
            base = self.page_slug + "_" + str(idx)
        base = re.sub(r"[^\w\-]", "_", base)[:60]
        name = base + "_" + h + "." + ext
        path = os.path.join(self.images_dir, name)
        if not os.path.exists(path):
            os.makedirs(self.images_dir, exist_ok=True)
            with open(path, "wb") as f:
                f.write(raw)
        return name

    def relpath_to_image(self, name):
        cur_dir = os.path.dirname(self.current_md_path)
        return os.path.relpath(
            os.path.join(self.images_dir, name), cur_dir
        ).replace("\\", "/")

    def normalize_link(self, href):
        if not href:
            return href
        if href.startswith(SITE_PREFIX):
            tail = href[len(SITE_PREFIX):]
            anchor = ""
            if "#" in tail:
                tail, frag = tail.split("#", 1)
                anchor = "#" + frag
            tail = tail.split("?", 1)[0]
            md_path = self.url_to_relmd.get(tail)
            if md_path:
                cur_dir = os.path.dirname(self.current_md_path)
                rel = os.path.relpath(
                    os.path.join(OUTPUT_ROOT, md_path), cur_dir
                ).replace("\\", "/")
                return rel + anchor
            return href
        return href


# --------- Pipeline ---------
def discover_files():
    files = []
    for dirpath, _, filenames in os.walk(INPUT_ROOT):
        for fn in filenames:
            if fn.lower().endswith(".html"):
                full = os.path.join(dirpath, fn)
                rel = os.path.relpath(full, INPUT_ROOT).replace("\\", "/")
                md_rel = rel[:-5] + ".md"
                files.append((full, rel, md_rel))
    files.sort(key=lambda t: t[1])
    return files


def build_url_map(files):
    url_to_md = {}
    for _, rel, md_rel in files:
        url_to_md[rel[:-5]] = md_rel
    return url_to_md


def parse_singlefile_header(html_text):
    head = html_text[:2000]
    url = saved = None
    m = re.search(r"url:\s*(\S+)", head)
    if m:
        url = m.group(1).strip()
    m = re.search(r"saved date:\s*([^\r\n]+)", head)
    if m:
        saved = m.group(1).strip().rstrip("-").strip()
    return url, saved


def extract_article(html_text):
    m = re.search(r"<article\b[^>]*>(.*?)</article>", html_text, re.S)
    return m.group(1) if m else None


def split_meta_from_body(article_html):
    last_updated = None
    m = re.search(r'<p\s+itemprop=lastUpdatedAt[^>]*>([^<]+)</p>', article_html)
    if m:
        last_updated = re.sub(r"^마지막 업데이트:\s*", "", m.group(1)).strip()
        article_html = article_html[:m.start()] + article_html[m.end():]
    article_html = re.sub(
        r'<p>\s*<font\s+color=#808080>[^<]*AI[^<]*</font>\s*</p>',
        "", article_html
    )
    return article_html, last_updated


def slug_from_path(rel):
    base = os.path.basename(rel)[:-5]
    base = re.sub(r"[^\w\-]", "_", base)
    return base[:50] or "page"


def yaml_quote(s):
    if s is None:
        return '""'
    if any(c in s for c in ':#[]{}\n"\''):
        return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ") + '"'
    return s


def convert_one(full_path, rel, md_rel, url_to_relmd):
    with open(full_path, "r", encoding="utf-8") as f:
        text = f.read()
    url, saved = parse_singlefile_header(text)
    article_html = extract_article(text)
    if not article_html:
        return None, "no article"
    body_html, last_updated = split_meta_from_body(article_html)
    root = parse_html(body_html)
    h1 = find_first(root, "h1")
    title = text_of(h1).strip() if h1 else os.path.basename(md_rel)[:-3]
    page_slug = slug_from_path(rel)
    out_md_path = os.path.join(OUTPUT_ROOT, md_rel.replace("/", os.sep))
    rendr = MdRenderer(page_slug, IMAGES_DIR, url_to_relmd, out_md_path)
    body_md = rendr.render(root)
    front = ["---"]
    front.append("title: " + yaml_quote(title))
    if url:
        front.append("source_url: " + url)
    front.append("source_path: " + rel)
    if last_updated:
        front.append("last_updated: " + yaml_quote(last_updated))
    front.append("---")
    output = "\n".join(front) + "\n\n" + body_md
    os.makedirs(os.path.dirname(out_md_path), exist_ok=True)
    with open(out_md_path, "w", encoding="utf-8") as f:
        f.write(output)
    return out_md_path, title


def main():
    files = discover_files()
    print("Found", len(files), "html files")
    url_map = build_url_map(files)
    sample_only = "--sample" in sys.argv
    limit = None
    for i, a in enumerate(sys.argv):
        if a == "--limit" and i + 1 < len(sys.argv):
            limit = int(sys.argv[i + 1])
    if sample_only:
        wanted = {
            "Introduction.html",
            "Important-Notes-for-Use.html",
            "creator-hub/dashboard.html",
            "LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_KnockBack.html",
            "LuaScript/VObjects/ItemVo/Properties/Item_amount.html",
            "LuaScript/Components/MeshCollider.html",
        }
        files = [t for t in files if t[1] in wanted]
        print("Sample mode:", len(files), "files")
    if limit:
        files = files[:limit]
    failed = []
    ok = 0
    for full, rel, md_rel in files:
        try:
            res = convert_one(full, rel, md_rel, url_map)
            if not res[0]:
                failed.append((rel, res[1] if len(res) > 1 else "unknown"))
            else:
                ok += 1
        except Exception as e:
            import traceback
            failed.append((rel, str(e)))
            traceback.print_exc()
    print("OK:", ok, "Failed:", len(failed))
    for f, err in failed[:20]:
        print("  ", f, "->", err)


if __name__ == "__main__":
    main()
