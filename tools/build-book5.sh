#!/usr/bin/env bash
# build-book5.sh — 第五冊組建管線：md → (mermaid→PNG) → PDF(typst) + EPUB
# 用法：bash tools/build-book1.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRAFTS="$ROOT/book5-team/drafts"
BUILD="$ROOT/build/book5"
ASSETS="$BUILD/assets"
CSS="$ROOT/docs/assets/book.css"

mkdir -p "$BUILD" "$ASSETS"

echo "== 1/4 合併章節 =="
MANUSCRIPT="$BUILD/manuscript.md"
cat > "$MANUSCRIPT" <<'META'
---
title: "OpenCode 團隊作戰"
subtitle: "從個人效率到組織級 AI 工程化"
author: "Happy eBook Authors"
lang: zh-TW
---
META
for f in \
  "$DRAFTS"/ch*.md \
  "$DRAFTS"/appendix-*.md; do
  printf '\n\n' >> "$MANUSCRIPT"
  cat "$f" >> "$MANUSCRIPT"
done
echo "manuscript: $(wc -l < "$MANUSCRIPT") 行"

echo "== 2/4 渲染 mermaid =="
node "$ROOT/tools/render-mermaid.js" "$MANUSCRIPT" "$BUILD/manuscript-rendered.md" "$ASSETS"

echo "== 3/4 產出 PDF（typst）=="
pandoc "$BUILD/manuscript-rendered.md" \
  -o "$BUILD/OpenCode團隊作戰-draft.pdf" \
  --pdf-engine=typst \
  -f markdown-citations \
  -V mainfont="AR PL UMing TW" \
  -V sansfont="WenQuanYi Micro Hei" \
  -V monofont="DejaVu Sans Mono" \
  -V fontsize=11pt \
  -V papersize=a4 \
  -V margin-left=22mm -V margin-right=22mm \
  -V margin-top=24mm -V margin-bottom=24mm \
  --toc --toc-depth=2

echo "== 4/4 產出 EPUB =="
pandoc "$BUILD/manuscript-rendered.md" \
  -o "$BUILD/OpenCode團隊作戰-draft.epub" \
  -f markdown-citations \
  --split-level=1 \
  --css="$CSS" \
  --toc --toc-depth=2 \
  --metadata lang=zh-TW

echo "== 完成 =="
ls -lh "$BUILD"/*.pdf "$BUILD"/*.epub
