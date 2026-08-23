# 第 18 章　儀表板實戰：事件流與介面遙控

腳本會「說」（prompt），儀表板要會「聽」（events）。本章把 SDK 的 `event.subscribe()` 接成一個即時終端儀表板：所有會話的心跳、權限等待、工具活動盡收一屏；順便用 tui 九法反向遙控——你的程式從此也能操作別人螢幕上的 OpenCode。

## 18.1 event.subscribe：SSE 的型別化外衣

```ts
const events = await client.event.subscribe()
for await (const event of events.stream) {
  console.log(event.type, JSON.stringify(event.properties).slice(0, 120))
}
```

`subscribe()` 回傳的 stream 是非同步迭代器〔文件〕——底層就是第三冊第 16 章那條 `GET /event` SSE 流，SDK 幫你處理了連線、斷線與事件解析。第 10 章列過的事件類型全表在這裡全部適用，只是這次你是從外部訂閱，跨進程、跨機器都行。

## 18.2 最小儀表板：三十行看全局

不引框架，先寫一個「滾動狀態板」：

```ts
import { createOpencodeClient } from "@opencode-ai/sdk"

const client = createOpencodeClient({ baseUrl: "http://localhost:4096" })
const lines = new Map<string, string>()

const events = await client.event.subscribe()
for await (const e of events.stream) {
  const p = e.properties as any
  switch (e.type) {
    case "session.idle":
      lines.set(p.info.id, `[完成] ${p.info.title ?? p.info.id}`)
      break
    case "session.error":
      lines.set(p.sessionID ?? "?", `[錯誤] ${p.error?.message ?? ""}`)
      break
    case "permission.asked":
      lines.set(p.sessionID ?? "?", `[待批] ${p.permission?.type ?? ""}`)
      break
    case "tool.execute.before":
      lines.set(p.callID, `[工具] ${p.tool}`)
      break
  }
  render(lines)
}

function render(lines: Map<string, string>) {
  process.stdout.write("\x1b[2J\x1b[H") // 清屏回原點
  for (const [k, v] of lines) console.log(k.slice(0, 12), v)
}
```

跑起來就是一面活牆：誰完成了、誰在等你批准、誰正在呼叫什麼工具。三個升級方向：用 ANSI 色碼上色（error 紅、idle 綠）、把 Map 換成按 sessionID 分組的多行視圖、或接 blessed／Ink 之類的 TUI 框架做面板布局。核心邏輯已經齊了，剩下的都是妝。

## 18.3 tui 九法：反向遙控

儀表板是單向旁觀；`client.tui.*` 九個方法讓你反過來**操縱**使用者面前的 OpenCode 介面〔文件〕：

| 方法 | 效果 |
|------|------|
| `appendPrompt({ body: { text } }) | 往輸入框追加文字 |
| `submitPrompt()` / `clearPrompt()` | 送出／清空當前提示 |
| `openHelp()` / `openSessions()` / `openThemes()` / `openModels()` | 彈出對應選擇器 |
| `executeCommand({ body })` | 執行一個 TUI 指令 |
| `showToast({ body: { message, variant } }) | 彈通知 |

組合技範例——CI 失敗時自動把修復任務塞進開發者的 OpenCode：

```ts
await client.tui.appendPrompt({
  body: { text: "CI 在 main 上掛了，請看剛才的測試報告並修復。" },
})
await client.tui.showToast({
  body: { message: "CI 失敗，修復任務已放入輸入框", variant: "warning" },
})
```

開發者回來看到 toast 一鍵確認，提示已在框裡等著。這是「人的注意力」與「機器的排程」交會的正確姿勢：機器備料、人類扣扳機。

## 18.4 與第三冊控制通道的對照

眼熟的讀者會發現 tui 九法正是第三冊第 17 章 `/tui/control` 雙向請求-應答通道的 SDK 皮。對照記憶：REST 域管資料（session/config），tui 域管介面（框、toast、輸入框），event 流管事實廣播。三者的分工在 SDK 裏被原封不動保留下來——架構書的好處在此：學一次，兩層皮通用。

## 18.5 部署形態

儀表板的三種落點，按投入遞增：

1. **本機常駐**：跟 OpenCode 同機跑，baseUrl 指 localhost，最省事
2. **團隊看板**：`opencode serve --hostname 0.0.0.0 --port 4096` 對內網開放（記得配 OPENCODE_SERVER_PASSWORD，第三冊講過基本授權），儀表板彙總多台引擎
3. **Web 化**：同一套事件流推到瀏覽器（SSE 直通），手機也能看團隊代理群的心跳

## 本章摘要 {.unnumbered .unlisted}

- `event.subscribe()` 回傳非同步迭代器，外部進程可完整旁觀事件流
- 三十行即可做出多會話即時狀態板；升級靠分組與 TUI 框架
- tui 九法反向遙控介面：appendPrompt＋showToast 是人機交接的標準舞步
- REST 管資料、tui 管介面、event 管事實——第三冊的分域在 SDK 完整延續
- 部署從本機常駐到團隊看板，記得加伺服器密碼

## 下章預告 {.unnumbered .unlisted}

穩定的部分都玩過了。下一章走進實驗疆域：遠端工作區適配器、企業政策面、以及站在編輯器那一端打造自己的 ACP 代理。

## 延伸資源 {.unnumbered .unlisted}

- SDK 文檔：<https://opencode.ai/docs/sdk/>
