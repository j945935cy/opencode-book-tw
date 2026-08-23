# 第 15 章　會話操作 API 實戰

這章做一件純粹的事：不開任何介面，只用 curl 完成從建會話到刪除的完整生命週期。走完你會對「TUI 只是一層皮」有肌肉級的理解。

## 15.1 生命週期八步

以下對 `http://127.0.0.1:4096` 操作（先 `opencode serve --port 4096`）：

```bash
# 1. 建立會話
curl -s -X POST .../session -d '{"title":"API 實戰"}'

# 2. 送提示並等回應（同步）
curl -s -X POST .../session/ses_x/message \
  -d '{"parts":[{"type":"text","text":"用一句話自我介紹"}],
       "agent":"build","model":"anthropic/claude-xxx"}'

# 3. 讀訊息清單
curl -s ".../session/ses_x/message?limit=10"

# 4. 分岔實驗
curl -s -X POST .../session/ses_x/fork -d '{"messageID":"msg_1"}'

# 5. 查程式碼變更
curl -s ".../session/ses_x/diff"

# 6. 分享
curl -s -X POST .../session/ses_x/share

# 7. 中止執行中的回合
curl -s -X POST .../session/ses_x/abort

# 8. 刪除
curl -s -X DELETE .../session/ses_x
```

## 15.2 同步與非同步的分野

送提示有兩條路：

- **POST /session/:id/message**：等回應才返回——腳本要「結果」時用
- **POST /session/:id/prompt_async**：立刻返回 204——排程發射、結果稍後由事件流收（第 16 章）

選擇題的判準只有一個：你的呼叫方要不要在同一行程式裡拿到答案。批次跑任務用非同步＋事件監聽；互動工具用同步。

另有兩個變形端點：`/command` 走斜線指令、`/shell` 直接下 shell——後者是「把代理當受控終端」的官方通道。

## 15.3 查詢面 API 群

唯讀偵察同樣重要：

| 端點 | 用途 |
|------|------|
| GET /project、/project/current | 專案清單／當前專案 |
| GET /path、/vcs | 工作目錄與 VCS 資訊 |
| GET /find?pattern= | 全文搜尋（含行號與偏移） |
| GET /find/file?query= | 檔名模糊搜尋 |
| GET /file/content?path= | 讀檔案內容 |
| GET /session/status | 各會話忙碌狀態 |

組合範例——「找出這個專案所有提到 retry 的位置再問代理」：先 /find 搜出清單，把路徑塞進 message 的 parts 引用，一次完成偵察＋推理。

## 15.4 權限互動：讓腳本能按確認

ask 型請求在無人機自動化裡是死結。架構給了出口：

```bash
POST /session/:id/permissions/:permissionID
{"response": "allow"}
```

先監聽事件流抓 permissionID（第 16 章），再呼叫此端點放行。**自動化不等於全放**——生產腳本仍應只允許白名單類別，其餘轉通知給人類。

## 本章摘要 {.unnumbered .unlisted}

- 八步生命週期證明核心完全可程式化。
- 同步拿結果、非同步配事件流；/shell 是受控終端通道。
- 查詢群 API 支援「先偵察後推理」的複合工作流。
- 權限可程式化回填，但白名單紀律不能丟。

## 下章預告 {.unnumbered .unlisted}

下一章接上伺服器的心跳：SSE 事件流與即時整合。

## 延伸資源 {.unnumbered .unlisted}

- Server 文件（Sessions/Messages/Files 節）：<https://opencode.ai/docs/server/>
- MDN Server-Sent Events：<https://developer.mozilla.org/zh-TW/docs/Web/API/Server-sent_events>
