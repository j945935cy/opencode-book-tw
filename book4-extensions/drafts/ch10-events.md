# 第 10 章　事件驅動：寫一支安靜的旁觀者

前兩章的鉤子都站在生產線上動手改貨；`event` 鉤子不同——它站在廠房天花板，只看不碰，卻看得見一切。會話建立、檔案被編輯、權限被詢問、LSP 吐出診斷……每個動作都以事件的型式廣播。通知器、觸發器、儀表板資料源，全都是 `event` 鉤子的變形。

## 10.1 一個訂閱口，全部事件

```ts
export const Watcher = async ({ client }) => ({
  event: async ({ event }) => {
    if (event.type === "session.idle") {
      await client.app.log({
        body: { service: "watcher", level: "info", message: "session idle" },
      })
    }
  },
})
```

`event` 鉤子在每個事件到達時被呼叫，`event.type` 是判別欄位，附帶屬性在 `event.properties`。第三冊第 16 章你已經從 SSE 的角度看過這條流（`GET /event` 的首事件就是 `server.connected`）；外掛的 `event` 鉤子等於**進程內直連同一條流**，不用走 HTTP。

## 10.2 事件類型全表

官方文檔列出的類型按域分組〔文件〕：

| 域 | 事件 |
|----|------|
| 伺服器 | server.connected |
| 會話 | session.created、session.updated、session.deleted、session.idle、session.status、session.error、session.diff、session.compacted |
| 訊息 | message.updated、message.removed、message.part.updated、message.part.removed |
| 權限 | permission.asked、permission.replied |
| 工具 | tool.execute.before、tool.execute.after |
| 檔案 | file.edited、file.watcher.updated |
| LSP | lsp.client.diagnostics、lsp.updated |
| 待辦 | todo.updated |
| Shell | shell.env |
| 指令 | command.executed |
| TUI | tui.prompt.append、tui.command.execute、tui.toast.show |
| 安裝 | installation.updated |

驗證方法用第 3 章的探針外掛最直接：掛上 event 把每個 type 寫進日誌，正常操作一輪，對照表就活了。注意工具層同時有「鉤子」與「事件」兩條路——`tool.execute.before/after` 既是可改寫的鉤子也是唯讀事件；要改就用鉤子，只想記錄就訂事件，別在事件裡嘗試改東西。

## 10.3 經典應用一：完成通知

官方範例——會話閒置時彈系統通知〔文件〕：

```ts
export const Notifier = async ({ $ }) => ({
  event: async ({ event }) => {
    if (event.type === "session.idle") {
      await $`osascript -e 'display notification "任務完成！" with title "opencode"'`
    }
  },
})
```

`$` 是 Bun shell（資源包裡那把鑰匙）。跨平台替換命令即可：Windows 用 PowerShell 的 toast、Linux 用 notify-send。長任務跑著你去切視窗做事，完成那一刻桌面跳出通知——這是外掛入門者最有感的第一個勝利。

## 10.4 經典應用二：品質閘門觸發器

把 `file.edited` 或 `lsp.client.diagnostics` 當觸發源：

- 每次編輯 Rust 檔後自動排一次 `cargo clippy`，結果寫回日誌
- LSP 診斷一出現 error 級別項目，立刻用 `client.tui.showToast()` 在介面上彈提示（SDK 的 TUI 方法在第 18 章成套登場）
- `permission.asked` 事件配上 Slack webhook——代理在等你批准？手機先知道

設計提醒：事件處理函式應該**快進快出**。重活兒丟給背景執行（fire-and-forget），別阻塞事件泵；失敗也要靜默吞掉並記日誌，別讓旁觀者炸掉生產線。

## 10.5 生命週期與 dispose

外掛函式本身是非同步初始化——可以在這裡開檔案、連資料庫、起計時器。對應地，把清理工作放進 `dispose`：

```ts
export const Tidy = async () => {
  const timer = setInterval(() => heartbeat(), 60_000)
  return {
    dispose: async () => clearInterval(timer),
    event: async ({ event }) => { /* ... */ },
  }
}
```

`dispose` 在關閉時被呼叫〔實測自 d.ts〕。開了什麼就要收什麼：計時器、子程序、檔案把手。忘了收，長時間掛著的 OpenCode 進程會慢慢積累殭屍資源。

## 10.6 旁觀者的邊界

最後畫一條線：事件是**事實的報導**，不是介入的請柬。想改行為，回到第 8、9 章的鉤子；想在事情發生後做點別的事，才是 event 的主場。把這條線畫清楚，你的外掛架構就不會長成義大利麵——每一支外掛都能回答「我是改貨的還是看貨的」。

## 本章摘要 {.unnumbered .unlisted}

- `event` 鉤子＝進程內的事件流訂閱口，覆蓋十一域二十餘種類型
- 工具層「鉤子可改、事件唯讀」，用途分流
- 完成通知與品質閘門是兩大經典應用，`$` 讓外部命令一步到位
- 處理函式快進快出，重活背景化；dispose 收乾淨計時器與程序
- 先分清「改貨」還是「看貨」，再選鉤子還是事件

## 下章預告 {.unnumbered .unlisted}

旁觀完了，下一章回到生產線的核心工位：自訂工具——用 zod 定參數、用 attachments 回附件、必要時整個取代內建 bash，甚至讓 Python 幫模型打工。

## 延伸資源 {.unnumbered .unlisted}

- 外掛事件清單：<https://opencode.ai/docs/plugins/>
