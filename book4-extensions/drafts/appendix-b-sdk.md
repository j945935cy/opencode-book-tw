# 附錄 B　SDK 方法速查

@opencode-ai/sdk 1.18.21 的方法面，與 HTTP 端點對照。端點細節見第三冊附錄 A；本表補「SDK 怎麼叫」。整理自官方 sdk 文檔〔文件〕。

| 域 | 方法 | 對應端點 |
|----|------|----------|
| global | health() | GET /global/health |
| app | log({ body }) | POST /log |
| app | agents() | GET /agent |
| project | list() / current() | GET /project 等 |
| path | get() | GET /path |
| config | get() / providers() | GET/PATCH /config、GET /config/providers |
| session | create({ body }) | POST /session |
| session | list() / get({ path }) | GET /session、GET /session/:id |
| session | children({ path }) | 子會話列表 |
| session | update() / delete() | PATCH/DELETE /session/:id |
| session | init({ path, body }) | 生成 AGENTS.md |
| session | abort({ path }) | 中止執行中回合 |
| session | prompt({ path, body }) | POST /session/:id/message（noReply 選項） |
| session | command({ path, body }) | 送指令到會話 |
| session | shell({ path, body }) | 跑 shell 命令 |
| session | messages() / message() | 訊息與 parts 列表 |
| session | revert({ path, body }) / unrevert() | 回退／還原 |
| session | share() / unshare() | 分享連結開關 |
| session | summarize({ path, body }) | 手動壓縮摘要 |
| find | text({ query }) | GET /find?pattern= |
| find | files({ query }) | GET /find/file?query=（type/directory/limit） |
| find | symbols({ query }) | 符號搜尋 |
| file | read({ query }) / status() | 檔案讀取與 git 狀態 |
| tui | appendPrompt / submitPrompt / clearPrompt | POST /tui/* 系列 |
| tui | openHelp / openSessions / openThemes / openModels | 同上 |
| tui | executeCommand / showToast | 同上 |
| auth | set({ path, body }) | 寫入認證 |
| event | subscribe() | GET /event（SSE 迭代器） |

## 用法提醒

- 預設 responseStyle="fields"：結果取 `.data`、錯誤查 `.error`
- structured output：prompt body 加 `format: { type: "json_schema", schema, retryCount }`，結果在 `info.structured_output`；失敗為 `StructuredOutputError`〔文件〕

## 延伸資源 {.unnumbered .unlisted}

- SDK 文檔：<https://opencode.ai/docs/sdk/>
