# 第 9 章　對話管線鉤子

第 8 章的攔截發生在工具層；這一章沿著管線往上遊走——訊息進場、參數定形、系統提示成稿、上下文壓縮。這四個位置決定了「模型到底看到什麼」，是外掛系統裡槓桿最長的一段。

## 9.1 chat.message：新訊息進場

每收到一條使用者訊息就觸發一次〔實測自 d.ts〕：

```ts
"chat.message": async (input, output) => {
  // input: { sessionID, agent?, model?, messageID?, variant? }
  // output: { message: UserMessage, parts: Part[] }
}
```

典型用途是**入場登記**：把每則提示的時間戳與會話 ID 寫進外部系統做審計；或在特定專案自動補充上下文 parts（例如偵測到訊息提到「部署」就附上部署檢查清單檔案）。注意它管的是「新訊息」事件本身，想改的是 `output.parts`。

## 9.2 chat.params：取樣參數的手術檯

送給 LLM 的推理參數在這裡定形：

```ts
"chat.params": async (input, output) => {
  if (input.agent === "review") {
    output.temperature = 0
    output.topP = 0.9
  }
  output.options = { ...output.options, myProviderFlag: true }
}
```

`output` 可改欄位：`temperature`、`topP`、`topK`、`maxOutputTokens`，以及直通供應商的 `options` 袋〔實測自 d.ts〕。第 6 章你在 frontmatter 靜態調參；這裡是動態版——按會話、按模型、按當下情境即時調整。例如夜間批次時段統一壓低 maxOutputTokens 控制成本。

`chat.headers` 則處理 HTTP 層：需要固定注入 `X-Trace-Id`、租戶標頭或企業代理認證的外掛在這裡加，每次請求都帶上。

## 9.3 shell.env：全域環境變數注入口

```ts
"shell.env": async (input, output) => {
  output.env.MY_API_KEY = process.env.MY_API_KEY ?? ""
  output.env.PROJECT_ROOT = input.cwd
}
```

這個鉤子影響**所有** shell 執行——不只模型的 bash 工具，也包括你自己的終端命令〔文件〕。官方範例就是拿它注入 API 金鑰與專案根路徑。安全提醒：注入的金鑰會出現在任何列出環境變數的命令輸出裡，敏感場景請配合第 8 章的輸出掃描打碼一起用。

## 9.4 experimental 六鉤子：能力越級的後門

d.ts 裡以 `experimental.` 開頭的六個鉤子是進階玩家的大招〔實測自 d.ts〕：

| 鉤子 | 能做什麼 |
|------|----------|
| `experimental.chat.messages.transform` | 送 LLM 前改寫整個訊息陣列 |
| `experimental.chat.system.transform` | 最終改寫系統提示字串陣列 |
| `experimental.provider.small_model` | 換掉「小任務」用的模型（標題、摘要等） |
| `experimental.session.compacting` | 客製或全面取代壓縮提示 |
| `experimental.compaction.autocontinue` | 決定壓縮後要不要自動續跑 |
| `experimental.text.complete` | 文字部分完成時攔截 |

名字裡的 experimental 不是客套：小版本間可能改名或移除（第 3.6 節的版本策略在此兌現）。但回報也實在——看兩個最有感的用法。

**用法一：團隊憲法注入。** 讓所有會話的系統提示都帶上組織規範：

```ts
"experimental.chat.system.transform": async (input, output) => {
  output.system.push("公司規範：所有程式碼需符合內部樣式指南 docs/style.md。")
}
```

比 AGENTS.md 更強制——它作用於每一次請求，不依賴模型自覺去讀檔。

**用法二：接管壓縮。** 第三冊講過長會話的自動摘要（session 表的 time_compacting 欄位）；外掛可以完全改寫那段摘要指令：

```ts
"experimental.session.compacting": async (input, output) => {
  output.prompt = `你是多代理群體會話的記錄官。
總結：1) 目前任務與狀態 2) 各檔案的修改者 3) 彼此的阻塞關係 4) 下一步。`
}
```

設了 `output.prompt` 就整份取代預設提示（`output.context` 屆時被忽略）；只 push `context` 則是附加資訊的溫和做法〔文件〕。配套的 `experimental.compaction.autocontinue` 可以關掉「壓縮完自動繼續」的合成回合，讓長任務在壓縮後停下來等人確認——無人值守與有人監督兩種模式的開關就在這裡。

## 9.5 組合技：一個治理外掛

把本章鉤子合起來，可以做出一支「治理外掛」：`chat.headers` 加租戶標頭、`chat.params` 對非白名單代理鎖溫度、`shell.env` 注入憑證、`system.transform` 附合規聲明。四個鉤子各十行，疊出一層完整的企業政策皮——這正是外掛相對於零散腳本的价值所在。

## 本章摘要 {.unnumbered .unlisted}

- `chat.message` 登記入場；`chat.params`／`chat.headers` 改 LLM 請求的參數與標頭
- `shell.env` 注入範圍涵蓋模型工具與使用者終端的全部 shell 執行
- experimental 六鉤子能改訊息陣列、系統提示、小模型與壓縮行為——強大但不保證穩定
- 壓縮客製分溫和（context.push）與激進（prompt 取代）兩檔
- 多鉤子合體即可做出組織級治理外掛

## 下章預告 {.unnumbered .unlisted}

管線之外還有一整片海洋：事件流。下一章把 OpenCode 的全部事件類型攤開，教你寫一支安靜的旁觀者外掛——通知、觸發器、儀表板資料源都從這裡來。

## 延伸資源 {.unnumbered .unlisted}

- 壓縮鉤子官方說明：<https://opencode.ai/docs/plugins/>
