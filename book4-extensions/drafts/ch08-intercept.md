# 第 8 章　攔截與改寫：三件實用品

鉤子不是拿來看的，是拿來擋路的。本章做三件馬上能用的東西：保護 `.env` 不被讀、給 bash 命令消毒、把工具輸出加工成人話。做完這章，你會擁有一套可以直接搬進團隊倉庫的防護外掛。

## 8.1 .env 保護：執行前的紅線

`tool.execute.before` 在每個工具呼叫前觸發，`input` 給你工具名，`output.args` 是即將送入的參數——**改它就等於改了要執行的東西**；直接 throw 則整個呼叫中止〔文件〕：

```ts
import type { Plugin } from "@opencode-ai/plugin"

export const EnvGuard: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool !== "read" && input.tool !== "bash") return
    const text = JSON.stringify(output.args)
    if (/\.env\b/.test(text)) {
      throw new Error("禁止讀取 .env（EnvGuard 外掛）")
    }
  },
})
```

代理想讀 `.env` 或跑 `cat .env` 都會吃到這個錯個錯誤，錯誤訊息會進對話成為模型的上下文——它下次就知道繞不過去。把正則換成你的機密清單（金鑰檔、客戶資料目錄），就是一套零成本的資料外洩防線。

## 8.2 命令消毒：改寫參數

同一個鉤子，換一種玩法——不擋，而是**改**。官方文檔的範例用 shescape 對 bash 命令做跳脫處理〔文件〕：

```ts
import { escape } from "shescape"

export const Sanitizer: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool === "bash") {
      output.args.command = escape(output.args.command)
    }
  },
})
```

更貼近日常的變體是「策略改寫」：強制所有 `npm test` 走 `npm test -- --run`（CI 模式）、把 `rm -rf /` 之類的高危模式自動降級成回收站搬移、或替 `curl` 統一加上公司代理參數。記住第 7 章的心智模型——`output.args` 就是生產線上的貨，你儘管動手。

`command.execute.before` 是它的兄弟鉤子：在斜線指令執行前往會話注入 parts。典型用法是讓 `/deploy` 自動附上當前 git SHA 與分支名，省去模型自己查〔文件〕。

## 8.3 輸出後處理：執行後的加工

`tool.execute.after` 在工具跑完後觸發，`output` 帶著 `title`、`output`（回傳字串）與 `metadata`，照樣可以改：

```ts
export const OutputPolisher: Plugin = async () => ({
  "tool.execute.after": async (input, output) => {
    if (input.tool === "bash" && output.output.includes("deprecated")) {
      output.output += "\n\n[EnvGuard] 注意：輸出含 deprecated 警告，建議安排升級。"
    }
    if (input.tool === "bash") {
      output.metadata = { ...output.metadata, guarded: true }
    }
  },
})
```

用途想像空間很大：截斷超長輸出保護上下文、掃描輸出中的金鑰樣式並打碼、把測試失敗摘要追加成清單。注意 `input` 一樣帶 `sessionID`／`callID`／`args`，需要時可做逐呼叫追蹤。

`tool.definition` 則在更上游——改的是「送給模型看」的工具描述與參數 schema，不改執行。想讓某個 MCP 工具在描述裡多一句「優先用於 X 情境」，用它。

## 8.4 permission.ask：自動應答員

第三冊看過權限閘門的資料面；外掛側可以直接**代答**：

```ts
import type { Plugin } from "@opencode-ai/plugin"

export const AutoApprover: Plugin = async ({ worktree }) => ({
  "permission.ask": async (input, output) => {
    // 只自動放行工作樹內的讀類權限
    if (input.type === "read" && (input.patterns ?? []).every(p => p.startsWith(worktree))) {
      output.status = "allow"
    }
    // status 可設 "allow" | "deny" | "ask"（維持原狀交給人類）
  },
})
```

這是把第 6 章的靜態權限規則升級成**程式化政策**的入口：按時間放行（上班時間免確認）、按目錄放行、接公司審批 API 後再回答。力氣越大，責任越大——自動 allow 的邏輯請務必寫測試並進版控。

## 8.5 三件合體的目錄長相

```
.opencode/
├── plugins/
│   ├── env-guard.ts      # 8.1 + 8.3 合併一支
│   ├── sanitizer.ts      # 8.2
│   └── auto-approver.ts  # 8.4
└── package.json          # shescape 依賴
```

依載入序規則（第 7 章 7.5），專案層的這幾支會排在全域外掛之後執行——防護邏輯最後說了算，正是我們要的位置。

## 本章摘要 {.unnumbered .unlisted}

- `tool.execute.before`：throw 即封鎖（.env 保護），改 `output.args` 即改寫（命令消毒）
- `tool.execute.after` 加工輸出與 metadata；`tool.definition` 改的是模型看到的描述
- `command.execute.before` 能在斜線指令前往會話注入內容
- `permission.ask` 把權限政策程式化：output.status 三態代答
- 防護類外掛放專案 plugins 目錄，吃最後執行的位置優勢

## 下章預告 {.unnumbered .unlisted}

攔截是站在生產線旁邊動手；下一章直接走進管線內部——從訊息進場到 LLM 參數、系統提示的最終形狀，以及六個實驗性鉤子裡藏著的大招：接管上下文壓縮。

## 延伸資源 {.unnumbered .unlisted}

- 外掛範例（.env 保護、env 注入等官方原始碼）：<https://opencode.ai/docs/plugins/>
