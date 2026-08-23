# 附錄 B　CLI 命令總表

opencode-ai 1.18.21 全部子命令〔實測 --help〕。標記★者為本冊新登場。

| 命令 | 用途 | 本冊章節 |
|------|------|----------|
| opencode [project] | 啟動 TUI（預設） | — |
| serve | 無頭伺服器 | 5 |
| ★attach \<url\> | 接管執行中的引擎 | 5 |
| ★web | 起伺服器並開 Web 介面 | 6 |
| run [message..] | 非互動跑一次提示 | — |
| ★github install / run | GitHub 代理安裝與執行 | 7 |
| ★pr \<number\> | 檢出 PR 分支並啟動會話 | 11 |
| session list / delete | 會話名冊與刪除 | 3 |
| ★export [sessionID] / import | 會話 JSON 匯出匯入 | 3 |
| ★stats | token 用量與成本報表 | 3 |
| models [provider] | 列出可用模型 | 13 |
| providers（alias auth） | 供應商與憑證管理 | — |
| agent | 代理管理（含 create） | — |
| mcp | MCP 伺服器管理 | — |
| acp | 啟動 ACP 伺服器 | — |
| plugin \<module\> | 安裝外掛並更新設定 | — |
| ★db [query] | sqlite3 shell 或單條查詢 | 18 |
| debug | 除錯工具集 | — |
| completion | 產生 shell 補全腳本 | 2 |
| upgrade [target] | 升級或指定版本 | 2 |
| uninstall | 解除安裝 | 2 |

## 全域旗標

| 旗標 | 作用 |
|------|------|
| --print-logs / --log-level DEBUG..ERROR | 日誌直印／等級（第三冊 ch19） |
| --pure | 不載入外部外掛——除錯第一步 | 
| -m, --model provider/model | 覆蓋模型 |
| --port / --hostname | 監聽位址（預設隨機埠、127.0.0.1） |
| --mdns / --mdns-domain | 區網發現（開啟時 hostname 預設轉 0.0.0.0） |
| --cors | 追加允許的跨域來源 |

## 延伸資源 {.unnumbered .unlisted}

- CLI 文檔：<https://opencode.ai/docs/cli/>
