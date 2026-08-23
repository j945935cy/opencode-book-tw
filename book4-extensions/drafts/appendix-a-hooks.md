# 附錄 A　Hooks 快查表

十七支鉤子的簽名、觸發時機與可改輸出欄位。整理自 @opencode-ai/plugin 1.18.5 的 index.d.ts〔實測〕。

| 鉤子 | 觸發時機 | input | 可改 output 欄位 |
|------|----------|-------|------------------|
| config | 設定合併完成後 | —（Config 本體） | 設定物件 |
| auth | 供應商認證流程 | 認證情境 | 認證結果 |
| provider | 供應商註冊/調整 | 供應商資訊 | provider 選項 |
| tool | 外掛載入時註冊 | — | ToolDefinition 表 |
| chat.message | 新使用者訊息進場 | sessionID, agent?, model?, messageID?, variant? | message, parts |
| chat.params | 組裝 LLM 請求參數 | sessionID, agent, model, provider, message | temperature, topP, topK, maxOutputTokens, options |
| chat.headers | 送出 LLM HTTP 請求前 | 同上 | headers |
| permission.ask | 權限詢問發生 | Permission 物件 | status: ask/deny/allow |
| command.execute.before | 斜線指令執行前 | command, sessionID, arguments | parts |
| tool.execute.before | 工具執行前 | tool, sessionID, callID | args（throw＝封鎖） |
| tool.execute.after | 工具執行後 | tool, sessionID, callID, args | title, output, metadata |
| tool.definition | 組裝送模型的工具描述 | toolID | description, parameters |
| shell.env | 任一 shell 執行前 | cwd, sessionID?, callID? | env |
| event | 任一事件廣播 | event（type＋properties） | 唯讀旁觀，勿改 |
| dispose | 關閉清理 | — | — |
| experimental.chat.messages.transform | 送 LLM 前 | — | messages 陣列 |
| experimental.chat.system.transform | 送 LLM 前 | sessionID?, model | system 字串陣列 |

另有三個不在 Hooks 介面內的特殊註冊點：experimental.provider.small_model（換小模型）、experimental.session.compacting（壓縮 context.push 或 output.prompt 全面取代）、experimental.compaction.autocontinue（壓縮後自動續跑開關）、experimental.text.complete（文字部分完成攔截）〔實測自 d.ts〕。

## 延伸資源 {.unnumbered .unlisted}

- 型別原始碼：node_modules/@opencode-ai/plugin/dist/index.d.ts
