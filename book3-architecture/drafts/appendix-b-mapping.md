# 附錄 B　三向對照總表

> 檔案系統 × 資料表 × API 端點的對照關係——找任何一種狀態的三個入口。

## 對話領域

| 概念 | 資料表 | API |
|------|--------|-----|
| 會話 | session | /session 系列 |
| 發言 | message | /session/:id/message |
| 內容切片 | part | 同上（回傳 info+parts） |
| 輸入佇列 | session_input | POST message/prompt_async |
| 待辦 | todo | GET /session/:id/todo |
| 分享 | session_share | POST/DELETE share |
| 壓縮 | session_context_epoch | POST summarize |

## 身分與權限

| 概念 | 檔案 | 資料表 | API |
|------|------|--------|-----|
| 供應商憑證 | auth.json | account、credential | PUT /auth/:id、OAuth 端點 |
| 權限決定 | — | permission | POST permissions/:pid |
| 規則（設定層） | opencode.json | — | GET/PATCH /config |

## 空間與版本

| 概念 | 資料表 | API |
|------|--------|-----|
| 專案 | project、project_directory | /project |
| 工作區 | workspace | （經 project 間接） |
| 變更統計 | session.summary_* | GET /session/:id/diff |
| 回退 | session.revert | revert／unrevert |

## 子系統

| 概念 | 目錄 | 資料表 | API |
|------|------|--------|-----|
| 快照 | snapshot/〈hash〉/ | — | revert 間接使用 |
| 工具輸出 | tool-output/tool_* | part（指標） | message 詳情 |
| MCP | — | — | GET/POST /mcp |
| LSP | — | — | GET /lsp |
| 插件資料 | storage/〈名稱〉/ | — | — |
| 日誌 | log/opencode.log | event（廣播面） | POST /log、GET /event |
