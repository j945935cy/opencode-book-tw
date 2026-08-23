#!/usr/bin/env node
/**
 * render-mermaid.js — 把 Markdown 內的 ```mermaid 區塊預渲染成 SVG
 * 用法：node render-mermaid.js <input.md> <output.md> <assetsDir>
 * 行為：
 *   1. 抽出每個 mermaid 區塊，以內容雜湊為檔名查快取（assetsDir）
 *   2. 快取未命中則呼叫 mermaid.ink API 渲染成 SVG
 *   3. 將區塊替換為圖片引用，寫出 output.md
 */
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const [input, output, assetsDir] = process.argv.slice(2);
if (!input || !output || !assetsDir) {
  console.error("用法：node render-mermaid.js <in.md> <out.md> <assetsDir>");
  process.exit(1);
}
fs.mkdirSync(assetsDir, { recursive: true });

const src = fs.readFileSync(input, "utf8");
let figIndex = 0;
let failCount = 0;

function b64url(s) {
  return Buffer.from(s).toString("base64").replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function renderSvg(code) {
  const state = { code, mermaid: { theme: "neutral" } };
  const url = `https://mermaid.ink/img/${b64url(JSON.stringify(state))}?type=png&width=1400`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return Buffer.from(await res.arrayBuffer());
}

(async () => {
  const re = /```mermaid\n([\s\S]*?)\n```/g;
  const jobs = [];
  let m;
  while ((m = re.exec(src)) !== null) {
    jobs.push({ full: m[0], code: m[1] });
  }

  let out = src;
  for (const job of jobs) {
    figIndex += 1;
    const hash = crypto.createHash("sha1").update(job.code).digest("hex").slice(0, 8);
    const name = `mermaid-${String(figIndex).padStart(2, "0")}-${hash}.png`;
    const file = path.join(assetsDir, name);

    if (!fs.existsSync(file)) {
      try {
        const svg = await renderSvg(job.code);
        fs.writeFileSync(file, svg);
        console.log(`rendered: ${name}`);
      } catch (e) {
        failCount += 1;
        console.error(`FAILED (${name}): ${e.message} —— 保留原始程式碼區塊`);
        continue;
      }
    } else {
      console.log(`cached:   ${name}`);
    }
    out = out.replace(job.full, `![](${path.relative(process.cwd(), file)})`);
  }

  fs.writeFileSync(output, out);
  console.log(`done: ${figIndex} 個圖表，失敗 ${failCount}`);
  process.exit(failCount > 0 ? 2 : 0);
})();
