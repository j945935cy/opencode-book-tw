# 附錄 C　擴充點路徑總表

八個擴充點的全域／專案位置、快取與載入順序。〔實測〕標記者在本書撰寫環境驗證過。

## 設定與擴充目錄

| 擴充點 | 專案層 | 全域層 |
|--------|--------|--------|
| 核心設定 | `<專案>/opencode.json(c)` | `~/.config/opencode/opencode.json(c)` |
| 介面設定 | — | `~/.config/opencode/tui.json` |
| 外掛（本地） | `.opencode/plugins/*.js|ts` | `~/.config/opencode/plugins/` |
| 自訂工具 | `.opencode/tools/*.ts` | `~/.config/opencode/tools/` |
| 自訂指令 | `.opencode/commands/*.md` | `~/.config/opencode/commands/` |
| Skills | `.opencode/skills/<名>/SKILL.md` | `~/.config/opencode/skills/<名>/` |
| 相容 Skills | `.claude/skills/`、`.agents/skills/` | `~/.claude/skills/`、`~/.agents/skills/` |
| 自訂代理 | `.opencode/agents/*.md` | `~/.config/opencode/agents/` |
| 主題 | `<專案根>/.opencode/themes/*.json` | `~/.config/opencode/themes/*.json` |
| MCP／外掛清單 | opencode.json 的 mcp/plugin 欄位 | 同左 |

## 快取與資料

| 內容 | 路徑 | 備註 |
|------|------|------|
| npm 外掛安裝 | `~/.cache/opencode/packages/<名>@<版>/` | Bun 啟動時自動安裝〔實測；文檔寫 node_modules/〕 |
| 隨附工具 | `~/.cache/opencode/bin/` | 如 rg〔實測〕 |
| 隨附技能 | `~/.cache/opencode/skills/` | security-research 等〔實測〕 |
| 本地外掛依賴 | 設定目錄的 package.json → bun install | 〔文件＋實測〕 |
| 外掛持久資料 | `~/.local/share/opencode/storage/<外掛>/` | 慣例〔實測樣本 oh-my-openagent〕 |
| 引擎資料庫 | `~/.local/share/opencode/opencode.db` | 第三冊主題 |

## 載入順序

1. 全域設定宣告的外掛
2. 專案設定宣告的外掛
3. 全域 plugins 目錄檔案
4. 專案 plugins 目錄檔案

同名同版 npm 套件只載一次；本地檔與 npm 套件各自載入〔文件〕。同類鉤子依此序執行，後到者對 output 的修改勝出。

## 主題覆蓋序

內建 → `~/.config/opencode/themes/` → 專案根 `.opencode/themes/` → 當前目錄 `.opencode/themes/`，同名高層勝〔文件〕。

## 延伸資源 {.unnumbered .unlisted}

- 各擴充點文檔入口：<https://opencode.ai/docs/>
