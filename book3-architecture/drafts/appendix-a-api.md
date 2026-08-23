# 附錄 A　REST API 速查表

> 基準版本 v1.18.21；完整規格以 `GET /doc`（OpenAPI 3.1）為準。以下路徑省略 `http://127.0.0.1:4096` 前綴。

## 全域與健康

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET | /global/health | 健康＋版本 |
| GET | /global/event | 全域事件流（SSE） |

## 專案與環境

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET | /project | 專案清單 |
| GET | /project/current | 當前專案 |
| GET | /path | 工作目錄資訊 |
| GET | /vcs | VCS 資訊 |
| POST | /instance/dispose | 釋放實例 |
| GET/PATCH | /config | 讀取／修改設定 |
| GET | /config/providers | 供應商設定視圖 |

## 供應商

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET | /provider | 清單＋預設＋已連線 |
| GET | /provider/auth | 認證方法 |
| POST | /provider/{id}/oauth/authorize | OAuth 授權 |
| POST | /provider/{id}/oauth/callback | OAuth 回跳 |
| PUT | /auth/:id | 設定憑證 |

## 會話

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET/POST | /session | 列表／建立 |
| GET | /session/status | 各會話狀態 |
| GET/PATCH/DELETE | /session/:id | 詳情／改名／刪除 |
| GET | /session/:id/children | 子會話 |
| GET | /session/:id/todo | 待辦清單 |
| POST | /session/:id/init | 產生 AGENTS.md |
| POST | /session/:id/fork | 分岔 |
| POST | /session/:id/abort | 中止 |
| POST/DELETE | /session/:id/share | 開／關分享 |
| GET | /session/:id/diff | 變更差異 |
| POST | /session/:id/summarize | 摘要壓縮 |
| POST | /session/:id/revert、unrevert | 回退／取消回退 |
| POST | /session/:id/permissions/:pid | 回應權限請求 |

## 訊息與指令

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET/POST | /session/:id/message | 列表／同步發送 |
| POST | /session/:id/prompt_async | 非同步發送 |
| GET | /session/:id/message/:mid | 單則詳情 |
| POST | /session/:id/command | 執行斜線指令 |
| POST | /session/:id/shell | 執行 shell |
| GET | /command | 指令清單 |

## 檔案與搜尋

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET | /find?pattern= | 內容搜尋 |
| GET | /find/file?query= | 檔名模糊搜尋 |
| GET | /find/symbol?query= | 符號搜尋 |
| GET | /file?path= | 目錄列表 |
| GET | /file/content?path= | 讀檔 |
| GET | /file/status | Git 狀態視圖 |

## 子系統狀態

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET | /lsp、/formatter | LSP／格式化器狀態 |
| GET/POST | /mcp | MCP 狀態／動態新增 |
| GET | /agent | 代理清單 |
| GET | /experimental/tool* | 實驗性工具內省 |

## 事件、日誌與 TUI

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET | /event | 事件流（SSE） |
| POST | /log | 寫入日誌 |
| POST | /tui/* | 九個介面控制端點（第 17 章） |
| GET/POST | /tui/control/* | 雙向控制通道 |

## 延伸資源 {.unnumbered .unlisted}

- OpenAPI 規格：<http://127.0.0.1:4096/doc>
- SDK 文件：<https://opencode.ai/docs/sdk/>
