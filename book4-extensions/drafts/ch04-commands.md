# 第 4 章　自訂指令：把長提示變成一個斜線

如果你每個 PR 都打同一段審查提示、每次發版都貼同一份檢查清單——你已經在手工模擬這一章要教的東西了。自訂指令把「重複輸入的提示」沉澱成 `.opencode/commands/` 裡的一個 Markdown 檔，從此 `/test` 四個鍵搞定。它是八個擴充點裡成本最低、回報最快的一個。

## 4.1 第一支指令

在專案根建 `.opencode/commands/test.md`〔文件〕：

```markdown
---
description: 跑完整測試並分析失敗
agent: build
---
跑整套測試，列出失敗案例。
針對失敗的測試提出修法，但先不要動程式碼。
```

存檔後在 TUI 輸入 `/test` 就能用。規則極簡：

- **檔名就是指令名**（`test.md` → `/test`）
- frontmatter 是設定，內文是送給模型的範本
- 放專案 `.opencode/commands/` 只在該專案生效；放全域 `~/.config/opencode/commands/` 到處生效

不愛開檔案的人也可以直接寫在 `opencode.json` 的 `command` 欄位，效果等價〔文件〕；本書偏愛 Markdown 版——diff 好讀、可以進版控、非工程師也改得動。

## 4.2 三種插值：參數、命令輸出、檔案內容

範本不是死字串，有三種活水可以注入。

**位置參數**：`$ARGUMENTS` 收整串參數，`$1` `$2` `$3` 收切好的第幾段：

```markdown
---
description: 建新元件
---
建一個名為 $ARGUMENTS 的 React 元件，含 TypeScript 型別與基本結構。
```

`/component Button` 執行時 `$ARGUMENTS` 換成 `Button`。

**Shell 注入**：反引號前加驚嘆號 `!`\`command\``，執行當下先把命令輸出灌進提示：

```markdown
---
description: 審查近期變更
---
最近十筆提交：
!`git log --oneline -10`
審查這些變更，指出風險與可改之處。
```

命令在專案根目錄執行〔文件〕。這招讓指令變成「活的」——同一支 `/review-changes` 每次抓到的都是當下狀態。

**檔案引用**：`@` 開頭的路徑會把整份檔案內容帶進提示：

```markdown
---
description: 審查元件
---
審查 @src/components/Button.tsx 的效能問題。
```

三種插值可以混用。一個實用的組合：`!`git diff HEAD~1`` 抓差異、`@docs/style-guide.md` 附規範、`$ARGUMENTS` 收指定檔案——一支 `/check` 就是一套個人審查 SOP。

## 4.3 frontmatter 全欄位

| 欄位 | 必填 | 作用 |
|------|------|------|
| `template` | JSON 寫法必填 | 提示範本（Markdown 寫法用內文取代） |
| `description` | 選填 | TUI 指令列表裡的說明文字 |
| `agent` | 選填 | 指定由哪個代理執行（如 `build`、`plan`） |
| `model` | 選填 | 覆蓋模型，如 `anthropic/claude-3-5-sonnet-20241022` |
| `subtask` | 選填 | `true` 強制以子代理方式執行 |

`subtask` 值得特別解釋。設為 `true` 後，指令會開一個子代理會話去跑，結果回到主對話——主對話的上下文不被污染〔文件〕。適合「跑一次大掃描但不想塞爆當前脈絡」的場景；即使指定的代理本身是主代理型態，`subtask: true` 也會強制走子代理。

## 4.4 覆蓋內建指令

自訂指令與內建指令同名時，你的版本勝出〔文件〕。這是正式的客製管道而非旁門左道：嫌預設 `/init` 的行為不合團隊規範，就在專案層放一份自己的 `init.md`，內文寫清楚你要的分析重點與 AGENTS.md 格式。覆蓋只影響該層級（專案覆蓋不影響全域），刪掉檔案即還原。

## 4.5 團隊協作的甜點

因為指令就是倉庫裡的檔案，它天然支援版本控與 code review。把 `.opencode/commands/` 提交進倉庫，全隊共用同一套 `/deploy-check`、`/security-scan`、`/write-changelog`；有人改進了提示，PR 審查一眼看清改了哪句話。這是把「AI 使用經驗」資產化的最輕量做法——第二冊教的是怎麼用代理，這裡你開始為團隊**設計**代理的工作流程。

## 本章摘要 {.unnumbered .unlisted}

- 檔名即指令名；專案 `.opencode/commands/` 或全域 `~/.config/opencode/commands/`
- 範本三種插值：`$ARGUMENTS`／`$1..$n` 參數、`!`\`cmd\`` 命令輸出注入、`@path` 檔案引用
- frontmatter 可綁 agent、覆蓋 model、用 `subtask: true` 隔離到子代理
- 同名覆蓋內建指令是正式用法
- 指令進版控＝團隊共享的 AI 工作流資產

## 下章預告 {.unnumbered .unlisted}

指令是你「主動」觸發的提示；Skills 反過來——是代理「自己判斷要不要翻」的知識庫。下一章拆解 SKILL.md 的規格與發現機制，並把一段真實的多步驟工作流做成技能。

## 延伸資源 {.unnumbered .unlisted}

- 自訂指令文檔：<https://opencode.ai/docs/commands/>
