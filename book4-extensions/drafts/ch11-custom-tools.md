# 第 11 章　自訂工具實戰

外掛鉤子改變「工具怎麼跑」；自訂工具創造「模型能做什麼新事」。它是八個擴充點裡與 MCP 最常被混淆的一個，先用一句話畫清界線：**自訂工具是函式，MCP 是程序**。邏輯短、需要型別安全、跟著專案走——寫函式；能力本身是獨立服務、要跨客戶端共用——包 MCP。

## 11.1 檔名即工具名

放 `.opencode/tools/`（專案）或 `~/.config/opencode/tools/`（全域），用 `tool()` 助手定義〔文件〕：

```ts
// .opencode/tools/database.ts
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "查詢專案資料庫",
  args: {
    query: tool.schema.string().describe("要執行的 SQL"),
  },
  async execute(args) {
    return `已執行：${args.query}`
  },
})
```

`database.ts` 這個檔名就是工具名，模型會看到一個 `database` 工具。三條命名規則：

- 預設導出一個工具，名字＝檔名
- **具名導出多個工具**時，名字＝`<檔名>_<導出名>`——`math.ts` 匯出 `add` 與 `multiply`，就得到 `math_add`、`math_multiply`
- 與內建工具同名時，你的版本**取代**內建——`tools/bash.ts` 就會換掉官方 bash（想只禁用不取代，用第 6 章的 permission，別搶名字）

## 11.2 參數：zod 的兩種寫法

`tool.schema` 就是 zod。簡單參數用它鏈式描述：

```ts
args: {
  query: tool.schema.string().describe("SQL 查詢"),
  limit: tool.schema.number().optional(),
}
```

複雜結構直接 import zod 寫完整 schema，甚至可以拋開 `tool()` 助手、導出普通物件（description/args/execute 三鍵）〔文件〕。`.describe()` 不是裝飾——它會進入模型看到的參數說明，是提示工程的一部分，每個欄位都值得一句人話描述。

## 11.3 execute 的上下文與回傳

第二個參數 `context` 帶著執行現場〔實測自 d.ts〕：

| 欄位 | 用途 |
|------|------|
| `sessionID`／`messageID`／`agent` | 歸屬哪個會話、哪則訊息、哪個代理 |
| `directory`／`worktree` | 相對路徑一律相對這兩者解析 |
| `abort` | AbortSignal，長任務記得監聽 |
| `metadata({ title, metadata })` | 執行中回報進度標題與中繼資料 |
| `ask({ permission, patterns, always, metadata })` | 執行中途主動發起權限詢問 |

回傳值可以是純字串，或帶結構的物件：

```ts
return {
  title: "查詢結果",
  output: rows.map(r => r.name).join("\n"),
  metadata: { rowCount: rows.length },
  attachments: [{ type: "file", mime: "text/csv", url: csvPath }],
}
```

`attachments` 是容易被忽略的殺手級欄位：讓工具把產出物（CSV、圖片、PDF）以附件形式掛回對話，模型後續可以直接引用〔實測自 d.ts 的 ToolAttachment〕。

## 11.4 取代內建 bash：閹割術

同名覆蓋的正經用法——給模型一個受限 shell：

```ts
// .opencode/tools/bash.ts
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "受限 bash：僅允許唯讀命令",
  args: { command: tool.schema.string() },
  async execute(args, ctx) {
    const allow = /^(ls|cat|grep|git (status|log|diff)|rg)\b/
    if (!allow.test(args.command.trim())) {
      return "已阻擋：此環境僅允許唯讀命令"
    }
    const proc = Bun.$`${args.command}`.quiet()
    return String(await proc)
  },
})
```

比 permission 更硬——permission 是事前閘門，這是連工具本體都換掉。適合示範環境、教學沙盒、或臨時給外部協作者用的收縮版 OpenCode。

## 11.5 任意語言混搭

工具定義必須是 TS/JS，但執行體可以是任何東西——定義檔只是殼，殼裡用 Bun shell 召喚真正的實作〔文件〕：

```python
# .opencode/tools/add.py
import sys
print(int(sys.argv[1]) + int(sys.argv[2]))
```

```ts
// .opencode/tools/python-add.ts
import { tool } from "@opencode-ai/plugin"
import path from "path"

export default tool({
  description: "用 Python 兩數相加",
  args: {
    a: tool.schema.number(),
    b: tool.schema.number(),
  },
  async execute(args, ctx) {
    const script = path.join(ctx.worktree, ".opencode/tools/add.py")
    const out = await Bun.$`python3 ${script} ${args.a} ${args.b}`.text()
    return out.trim()
  },
})
```

團隊既有的 Python 分析腳本、Rust 小工具、公司 CLI，全部可以這樣「借殼」變成模型的工具。錯誤處理建議：非零結束碼時回傳人話說明而非丟例外，模型才有機會自我修正重試。

## 本章摘要

- `.opencode/tools/<檔名>.ts`；多重導出名為 `<檔名>_<導出名>`；同名可取代內建
- args 用 `tool.schema`（即 zod），describe 是提示工程
- context 有 session/worktree 定位、abort、進度 metadata 與中途 ask()
- 回傳支援 title/output/metadata 與 file attachments
- Bun.$ 讓任何語言的既有程式都能借殼成工具

## 下章預告 {.unnumbered .unlisted}

工具寫好了，孤芳自賞可惜。下一章談外掛的「成品化」：發布到 npm、版本策略、以及解剖一支真實生態外掛的安裝足跡。

## 延伸資源 {.unnumbered .unlisted}

- 自訂工具文檔：<https://opencode.ai/docs/custom-tools/>
