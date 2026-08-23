#!/usr/bin/env bash
# build-book1.sh — 第一冊組建管線：md → (mermaid→SVG) → PDF(typst) + EPUB
# 用法：bash tools/build-book1.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRAFTS="$ROOT/book1-intro/drafts"
BUILD="$ROOT/build/book1"
ASSETS="$BUILD/assets"
CSS="$ROOT/docs/assets/book.css"

mkdir -p "$BUILD" "$ASSETS"

echo "== 1/4 合併章節 =="
MANUSCRIPT="$BUILD/manuscript.md"
cat > "$MANUSCRIPT" <<'META'
---
title: "OpenCode 入門指南"
subtitle: "30 分鐘學會 AI 輔助程式設計"
author: "Happy eBook Authors"
lang: zh-TW
---
META
for f in \
  "$DRAFTS/ch01-understanding-opencode.md" \
  "$DRAFTS/ch02-installation.md" \
  "$DRAFTS/ch03-first-use.md" \
  "$DRAFTS/ch04-basic-interaction.md" \
  "$DRAFTS/ch05-modes.md" \
  "$DRAFTS/ch06-commands.md" \
  "$DRAFTS/ch07-understanding-code.md" \
  "$DRAFTS/ch08-exercises.md" \
  "$DRAFTS/appendix-a-faq.md" \
  "$DRAFTS/appendix-b-free-models.md" \
  "$DRAFTS/appendix-c-keybinds.md"; do
  printf '\n\n' >> "$MANUSCRIPT"
  cat "$f" >> "$MANUSCRIPT"
done
echo "manuscript: $(wc -l < "$MANUSCRIPT") 行"

echo "== 2/4 渲染 mermaid =="
node "$ROOT/tools/render-mermaid.js" "$MANUSCRIPT" "$BUILD/manuscript-rendered.md" "$ASSETS"

echo "== 3/4 產出 PDF（typst）=="
pandoc "$BUILD/manuscript-rendered.md" \
  -o "$BUILD/OpenCode入門指南-draft.pdf" \
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
  -o "$BUILD/OpenCode入門指南-draft.epub" \
  -f markdown-citations \
  --split-level=1 \
  --css="$CSS" \
  --toc --toc-depth=2 \
  --metadata lang=zh-TW

echo "== 完成 =="
ls -lh "$BUILD"/*.pdf "$BUILD"/*.epub
