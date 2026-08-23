# 第 10 章：MCP 伺服器

OpenCode 的內建工具已經能讀寫檔案、跑指令、抓網頁，但你的工作世界遠不止於此：資料庫裡的資料、Figma 上的設計稿、Linear 上的工單、瀏覽器裡的實際畫面。MCP（Model Context Protocol）是一把萬用介面卡，讓任何服務都能變成代理的新工具。這章講概念、設定、權限與選型。

## 10.1 Model Context Protocol 概念

MCP 是 Anthropic 於 2024 年底開放的標準協定，目標是解決一個 M×N 問題：M 種 AI 工具要接 N 種外部服務，過去得寫 M×N 次整合；有了統一協定，變成 M＋N——工具方實作一次 MCP 客戶端，服務方實作一次 MCP 伺服器，彼此即相容。

三個核心名詞：

- **MCP 主機（Host）**：OpenCode 本身。它連到各個伺服器，把對方提供的功能彙整進代理的工具清單。
- **MCP 伺服器**：包著某個服務的小程式。例如 GitHub 官方 MCP 伺服器把「開 issue、發 PR 評論」包成標準工具。
- **工具／資源**：伺服器對外暴露的能力。工具是要 AI 主動呼叫的動作，資源是可讀取的資料。

裝好一個 MCP 伺服器後，它的工具就混入代理的工具箱，AI 依任務自行取用——你不需要改任何提示詞。

## 10.2 傳輸方式與設定

MCP 支援兩種傳輸方式，設定語法直接寫在 `opencode.json`：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/srv/data"],
      "enabled": true
    },
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "enabled": true
    }
  }
}
```

| 方式 | 型態 | 運作 | 適合 |
|------|------|------|------|
| local（stdio） | 本機子行程 | OpenCode 直接啟動伺服器行程，經標準輸入輸出通訊 | 本地服務：檔案系統、SQLite、本機腳本 |
| remote（HTTP/SSE） | 遠端端點 | 透過 HTTP 連到雲端 MCP 端點 | SaaS 服務：GitHub、Notion、Linear |

CLI 也提供互動式管理，不必手編 JSON：

```bash
opencode mcp add my-server
opencode mcp list
```

需要 OAuth 登入的伺服器（如官方 GitHub）走 `opencode mcp auth <名稱>` 完成授權；狀態異常時 `opencode mcp debug <名稱>` 是第一診斷工具。

**驗證安裝成功**

重啟會話後在 TUI 輸入 `/status`，或直接觀察代理的工具清單是否多了新條目。最直接的測試就是派一個小任務：「用剛裝的工具列出我的未關閉 issue」。

## 10.3 MCP 工具的權限控制

外部工具等於擴大的副作用半徑，權限必須跟著管。`permission` 區塊以 `mcp` 前綴指名道姓：

```json
{
  "permission": {
    "mcp": {
      "github_*": "allow",
      "database_*": "ask",
      "*_delete*": "deny"
    }
  }
}
```

規則語意與第 3 章相同：GitHub 的查詢類操作全面放行；資料庫類每次確認；名字含 delete 的一律拒絕。萬用字元配對的是「伺服器名稱_工具名稱」。

兩條紅線經驗：

1. **寫入型 MCP 一律從 ask 起步。** 讓它跑幾天 ask，確認行為模式後再考慮升級 allow——順序顛倒的代價通常是誤刪資料。
2. **金鑰最小化。** MCP 伺服器的憑證給到「該伺服器需要的最小範圍」即可，不要拿管理員 token 餵唯讀場景。

## 10.4 常用 MCP 伺服器推薦

按實用度排序的起步清單：

| 伺服器 | 提供什麼 | 典型用途 |
|--------|----------|----------|
| filesystem（官方） | 指定目錄的檔案操作 | 讓代理安全地存取專案外的資料夾 |
| GitHub（官方） | issues、PR、repo 操作 | 工單驅動開發、PR 自審（第 18 章） |
| PostgreSQL / SQLite | 受控的 SQL 查詢 | 對著真實 schema 寫程式、驗證查詢 |
| Playwright / Puppeteer | 瀏覽器自動化 | UI 除錯、截圖比對、E2E 腳本草稿 |
| Notion / Linear | 文件與工單讀寫 | 把需求文件直接餵進開發流程 |

選型原則：先問「這個服務在我的工作流中，AI 需要多頻繁觸及？」——每多一個 MCP 伺服器，代理的工具選擇空間就大一圈，太雜反而稀釋決策品質。三到五個高頻伺服器是甜蜜點。

## 本章摘要 {.unnumbered .unlisted}

- MCP 把 M×N 整合問題化簡為 M＋N；OpenCode 作為主機，將 MCP 伺服器的工具併入代理工具箱。
- 兩種傳輸：local（stdio 子行程）與 remote（HTTP/SSE）；`opencode mcp add/list/auth/debug` 全程可用 CLI 管理。
- 權限以 `mcp` 前綴加萬用字元管控；寫入型從 ask 起步、憑證最小化是兩條鐵律。
- 從高頻需求挑 3 至 5 個伺服器起手，貪多稀釋品質。

## 下章預告 {.unnumbered .unlisted}

工具齊備之後，真正的高手差別在「怎麼同時駕馭多條工作線」。第十一章會話管理：並行會話的工作流設計，以及把對話變成可分享網頁的協作玩法。

## 延伸資源 {.unnumbered .unlisted}

- 官方文件首頁：<https://opencode.ai/docs/>
- MCP 伺服器目錄：<https://github.com/modelcontextprotocol/servers>
