# 第 17 章　驅動 TUI：控制端點

前兩章的 API 都在「繞過」介面直接對話核心；這一章反其道而行——官方提供一組端點專門**遙控 TUI 本身**。IDE 外掛的魔法，拆開就這麼樸素。

## 17.1 /tui/* 家族

官方文件列出的控制端點：

| 端點 | 作用 |
|------|------|
| POST /tui/append-prompt | 把文字塞進輸入框 |
| POST /tui/submit-prompt | 按下送出 |
| POST /tui/clear-prompt | 清空輸入框 |
| POST /tui/open-sessions | 開會話選擇器 |
| POST /tui/open-models | 開模型選擇器 |
| POST /tui/open-themes | 開主題選擇器 |
| POST /tui/open-help | 開說明對話框 |
| POST /tui/execute-command | 執行指定命令 |
| POST /tui/show-toast | 彈出提示通知 |

組合示範——從腳本替使用者備好一句提示：

```bash
curl -X POST .../tui/append-prompt -d '{"text":"幫我 review 剛才的 diff"}'
curl -X POST .../tui/submit-prompt
```

正在看螢幕的人會看到輸入框自動填入並送出。

## 17.2 IDE 外掛的接線真相

官方文件明載：這組端點的存在目的之一就是 IDE 整合。外掛的架構因此異常清晰：

```text
編輯器外掛（VS Code 等）
   ↓ HTTP：append-prompt + submit-prompt
OpenCode 伺服器
   ↓ 事件流回推狀態
外掛面板即時渲染
```

沒有深層鉤子、沒有私有協定——外掛就是另一個 API 客戶端，跟你第 15 章寫的 curl 腳本平起平坐。這也解釋了為什麼第三方環境能快速做出高品質整合：接線圖是公開的。

## 17.3 control 通道：雙向的例外

清單裡有兩個特殊成員：

- `GET /tui/control/next`：等待下一個控制請求
- `POST /tui/control/response`：回應該請求

這是一條**反向通道**：不是你遙控 TUI，而是 TUI（或代理）發出需要互動的請求、外部程式作答。典型場景是權限確認的自訂介面——把「按 y/n」升級成任何你想要的 UI，同時保持核心邏輯不變。

至此通訊拼圖完整：

```text
REST        → 你呼叫核心      （指令）
SSE         → 核心廣播給你    （通知）
control     → 雙向請求/應答   （互動）
```

## 本章摘要 {.unnumbered .unlisted}

- 九個 /tui/* 端點可完全遙控介面。
- IDE 外掛＝公開 API 的普通客戶端，無私有魔法。
- control/next＋response 構成雙向互動通道。
- REST/SSE/control 三通道各司其職。

## 下章預告 {.unnumbered .unlisted}

通訊篇最後一站：跳出 HTTP，看編輯器生態的另一條路——ACP 協定。

## 延伸資源 {.unnumbered .unlisted}

- Server 文件（TUI 節）：<https://opencode.ai/docs/server/>
- IDE 整合文件：<https://opencode.ai/docs/ide/>
