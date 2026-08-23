# 第二冊《OpenCode 實戰寶典》技術審稿報告

- 審稿日期：2026-08-23
- 基準版本：OpenCode 1.18.21（npm 實測 `npm view opencode-ai version` 回傳同版）
- 審稿範圍：book2-practical/drafts/ 全部 26 檔（22 章＋附錄 A–D）

## 一、CLI 指令實測（全數通過）

| 驗證項 | 結果 |
|--------|------|
| `agent list`／`agent create` | OK |
| `providers`（auth 別名） | OK |
| `stats`／`export`／`import`／`pr`／`acp`／`debug` | OK |
| `upgrade`／`uninstall`／`serve`／`attach` | OK |
| `mcp add/list/auth/logout/debug` | OK（help 層級） |
| `session list` | OK，實際輸出 ses_ 格式與書中一致 |
| `run --help` 旗標 | `--command/--fork/--share/--agent/--format/--title/--attach/--dir/--port` 全部存在 |
| 頂層 `-c, --continue`／`--session`／`--fork` | 存在，ch11 寫法正確 |

## 二、設定範例對照真實環境

以本機 `~/.config/opencode/opencode.jsonc` 為對照基準：

- `mcp` 區塊結構（type/command/enabled）與書中 ch10 範例一致
- `$schema` 指向 `https://opencode.ai/config.json` 與書中各範例一致（schema 端點本身不回 HTTP 200 屬正常，保留）
- `tui.json` keybinds 結構與附錄 A 一致

## 三、URL 審查

全書共引 33 條 URL：

- **19 條 200 通過**：官方站、/docs/ 及 agents/commands/config/github/ide/lsp/rules/skills/tools 子頁、GitHub 三頁、MCP servers 目錄、LSP 規格、ACP、git-bisect、Ollama 兩頁、install script
- **5 條修正**（原為 404 深連結）：

| 章 | 原連結 | 修正後 |
|----|--------|--------|
| ch06 | /docs/installation/ | /install |
| ch08 | /docs/tips/ | /docs/ |
| ch10 | /docs/mcp/ | /docs/ |
| ch15 | /docs/modes/ | /docs/agents/ |
| ch19、ch21 | /docs/security/ | ch19→/docs/config/；ch21→security/advisories |

- **9 條示意性佔位保留**：localhost、workstation.local、example.com、內網位址等教學用例（githubcopilot MCP 端點實測 401＝需授權，屬預期行為）

## 四、其他檢查

- emoji 掃描：零檢出
- 模板合規：22 章均含摘要／預告／延伸資源，65 處 `.unnumbered .unlisted`
- 術語：台灣用語一致（代理、會話、儲存庫、程式碼等）
- 版本敏感陳述均已標註「撰寫時凍結於 1.18.21」或「以官方文件為準」

## 五、結論

技術審稿通過。全書指令可執行、連結可用、設定範例與真實環境形態相符。後續排版組建時沿用第一冊管線即可。
