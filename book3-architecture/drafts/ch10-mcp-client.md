# 第 10 章　MCP 客戶端實作

第二冊講了怎麼裝 MCP；這一章拆開客戶端本身：兩種形態、動態註冊、命名空間與故障隔離。

## 10.1 兩種形態

| 形態 | 設定寫法 | 運行方式 |
|------|----------|----------|
| local | `command` 陣列（如 npx 啟動） | 本機子進程，stdio 通訊 |
| remote | `url` 指向端點 | 遠端伺服器，HTTP 通訊 |

local 的本質是「OpenCode 拉起子程序並透過標準輸入輸出對話」；remote 是純網路客戶端。對上層完全透明——工具就是工具。

## 10.2 動態註冊：POST /mcp

架構亮點：MCP 不必寫死在設定檔。API 提供執行期新增：

```bash
curl -X POST http://127.0.0.1:4096/mcp \
  -H 'Content-Type: application/json' \
  -d '{"name":"my-server","config":{"type":"remote","url":"https://example.com/mcp/","enabled":true}}'
```

`GET /mcp` 回報全部狀態。組合起來可以寫出自適應腳本：偵測到專案有 Dockerfile 就當場掛上對應伺服器——環境自適應的工具供應。

## 10.3 命名空間

外部工具湧入後的名字衝突以 `mcp_<伺服器>_<工具>` 解決：

1. 不同伺服器的同名工具和平共處
2. 權限規則可精確到單一工具（`"github_*": "allow"`）
3. TUI 工具清單一眼辨識來源

## 10.4 故障隔離

npx 失失敗、遠端斷線、子進程崩潰都是常態。設計回應是**單點失效不傳染**：

- 一個伺服器掛掉，其餘照常
- 狀態在 `/mcp` 與 TUI `/status` 可見
- 除錯有專門子命令（`opencode mcp debug`，第二冊第 22 章）

## 本章摘要 {.unnumbered .unlisted}

- local＝stdio 子進程、remote＝HTTP 端點。
- POST /mcp 讓工具供應可以程式化、自適應。
- 命名空間解決碰撞並讓權限可細粒度。
- 故障隔離保證生態擴充不犧牲核心穩定。

## 下章預告 {.unnumbered .unlisted}

下一章看另一種擴充：插件系統與它的資料目錄。

## 延伸資源 {.unnumbered .unlisted}

- MCP servers 文件：<https://opencode.ai/docs/mcp-servers/>
- 第二冊第 10 章（MCP 使用者視角）
