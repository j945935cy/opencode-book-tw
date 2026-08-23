# 第 7 章　第一支外掛

外掛是八個擴充點裡唯一能「攔截並改寫 OpenCode 行為」的。它是一個 JavaScript/TypeScript 模組，匯出一個或多個函式；每個函式在啟動時被呼叫一次，收到資源包，回傳一包鉤子。本章先跑通最小閉環，再把資源包與鉤子地圖攤開。

## 7.1 最小外掛

建 `.opencode/plugins/hello.js`〔文件〕：

```js
export const Hello = async ({ project, client, $, directory, worktree }) => {
  await client.app.log({
    body: { service: "hello", level: "info", message: "plugin loaded" },
  })
  return {}
}
```

重啟 OpenCode（或這個專案的會話），日誌裡就會多一行 `service=hello message="plugin loaded"`。規則：

- 檔案放專案 `.opencode/plugins/` 或全域 `~/.config/opencode/plugins/`，自動載入
- **匯出的每個具名函式都是一支獨立外掛**——一個檔案可以裝好幾支
- 函式收到同一個資源包，回傳各自的鉤子物件
- TypeScript 也行：副檔名 `.ts` 直接放，型別從 `@opencode-ai/plugin` 匯入（第 3 章的環境準備在此兌現）

```ts
import type { Plugin } from "@opencode-ai/plugin"
export const Typed: Plugin = async (input) => {
  return { /* 型別安全的鉤子 */ }
}
```

## 7.2 資源包：PluginInput 解剖

每支外掛函式的參數就是一張工坊鑰匙圈〔實測自 d.ts〕：

| 鑰匙 | 用途 |
|------|------|
| `project` | 目前專案資訊 |
| `directory` | 目前工作目錄 |
| `worktree` | git 工作樹根——路徑計算一律相對它 |
| `client` | 完整的 SDK 客戶端（第三冊那套 API 全在） |
| `$` | Bun 的 shell API，用標籤模板跑外部命令：``await $`git status` `` |
| `serverUrl` | 內嵌伺服器的位址 |
| `experimental_workspace` | 實驗性工作區註冊點（第 19 章） |

`client` 與 `$` 的組合意味著：外掛內部既能呼叫官方 API（查會話、寫日誌、控 TUI），也能直接跑任何 shell 命令——通知、部署腳本、呼叫公司內部 CLI 都不成問題。

## 7.3 十七個鉤子的全景

回傳的物件裡可以掛這些鉤子〔實測自 index.d.ts〕，按介入位置分四層：

**資源與設定層**

- `config`：讀取後修改合併完成的設定
- `auth`：供應商認證流程掛點
- `provider`：供應商註冊與調整
- `dispose`：會話結束清理

**對話管線層**

- `chat.message`：新訊息進場
- `chat.params`：改送給 LLM 的取樣參數（temperature、maxOutputTokens…）
- `chat.headers`：加 HTTP 標頭（企業代理常需要）
- `experimental.chat.messages.transform`／`system.transform`：訊息陣列與系統提示的最終改寫

**工具與命令層**

- `tool`：註冊自訂工具（第 11 章主角）
- `tool.definition`：改寫送給模型的工具描述與參數
- `tool.execute.before`／`after`：執行前`：執行前攔截、執行後加工
- `command.execute.before`：斜線指令執行前注入 parts
- `permission.ask`：權限詢問的自動應答
- `shell.env`：往所有 shell 執行注入環境變數

**事件與實驗層**

- `event`：訂閱全部事件流（第 10 章）
- `experimental.*` 六鉤子：壓縮客製、autocontinue 開關、小模型選擇、文字補全（第 9 章）

不用全記住——附錄 A 有每個鉤子的簽名、觸發時機與可改輸出欄位的快查表。本章先建立體感。

## 7.4 鉤子的統一形狀

幾乎所有業務鉤子都長這樣：

```ts
"hook.name": async (input, output) => { /* 改 output */ }
```

`input` 是唯讀情境（誰、在哪、哪個會話），`output` 是可變結果袋——你直接改它的欄位，OpenCode 拿改過的繼續跑。沒有回傳值約定，改 `output` 就是你的回傳。這是整個外掛系統最重要的心智模型：**你不是在監聽，你是在生產線上動手**。

## 7.5 載入與順序

啟動時所有來源的外掛一起載入：全域設定的 npm 清單 → 專案設定的 npm 清單 → 全域 plugins 目錄 → 專案 plugins 目錄〔文件〕。同名同版的 npm 套件只載一次；本地檔與 npm 套件即使同名也各自載入。所有同類鉤子**依序執行**——兩支外掛都想改同一個 `output` 時，載入序靠後的贏。把最關鍵的改寫放在專案層目錄，就是利用這條規則讓它排在最後。

## 本章摘要 {.unnumbered .unlisted}

- 外掛＝匯出具名非同步函式的模組，一檔多掛；`.opencode/plugins/` 自動載入
- 資源包七把鑰匙：project/directory/worktree/client/$/serverUrl/experimental_workspace
- 十七鉤子分四層：資源設定、對話管線、工具命令、事件實驗
- 心智模型：`(input, output)` 生產線改貨，不是事件監聽
- 同類鉤子依載入序執行，後到者勝

## 下章預告 {.unnumbered .unlisted}

下一章挑出生產線上最有感的三個工位：工具執行前後與權限詢問，做出 .env 保護、命令消毒、輸出後處理三件實用品——外掛的威力第一次真實落在你的日常裡。

## 延伸資源 {.unnumbered .unlisted}

- 外掛文檔：<https://opencode.ai/docs/plugins/>
