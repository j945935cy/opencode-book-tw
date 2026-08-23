# 第 15 章　rules：讓規範自動進入每個會話

團隊最貴的知識不在代碼裡，在老手的腦子裡：「這專案要用 bun 別用 npm」「infra 拆在 infra/ 別亂放」「跑測試前先起 docker」。AGENTS.md 的任務就是把這些腦內知識寫下來，讓**每一個新會話——無論是誰開的、還是代理自動開的——都自帶這份常識**。

## 15.1 /init：起點而非終點

```
/init
```

掃描倉庫重要檔案、必要時問幾個針對性問題，然後產生或更新 AGENTS.md〔文件〕。它聚焦未來會話最需要的五類資訊：build/lint/test 命令、命令順序與驗證步驟、光看檔名猜不到的架構、專案怪癖、以及既有的 Cursor/Copilot 規則引用。

官方建議把 AGENTS.md **提交進 Git**〔文件〕。已有檔案時 /init 是就地改進而非盲目覆蓋——定期重跑 /init 讓文檔跟著代碼演化，是最低成本的維護方式。

## 15.2 三層位置與優先序

OpenCode 找規則檔的順序〔文件〕：

1. **本地層**：從當前目錄向上走訪（AGENTS.md 優先於 CLAUDE.md）
2. **全域層**：`~/.config/opencode/AGENTS.md`
3. **Claude 相容層**：`~/.claude/CLAUDE.md`（前面皆無時）

同類別先找到者勝。分工原則：專案層寫「這個倉庫怎麼伺候」（提交入庫、全隊共享）；全域層寫「我個人希望 AI 怎麼跟我說話」（不共享）。從 Claude Code 遷移的團隊無痛接軌——CLAUDE.md 直接被認；三個環境變數可分別關掉相容行為（OPENCODE_DISABLE_CLAUDE_CODE 系列）〔文件〕。

## 15.3 instructions：複用既有規用既有規範

團隊往往已有一堆規範文件（CONTRIBUTING、樣式指南），不想複製一份進 AGENTS.md。opencode.json 的 `instructions` 欄位直接收編它們：

```json
{
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md",
    "https://raw.githubusercontent.com/my-org/shared-rules/main/style.md"
  ]
}
```

支援 glob 與遠端 URL（5 秒逾時）〔文件〕；所有指令檔與 AGENTS.md 合併生效。monorepo 用 `packages/*/AGENTS.md` 一行收編全部子包規則——官方明言這比手動引用更好維護。

## 15.4 分層治理模型

把本章與第四冊合起來看，團隊的「AI 行為規範」應該分成四層，各司其職：

| 層 | 載體 | 管什麼 | 生命週期 |
|----|------|--------|----------|
| 政策 | enterprise policies（第 17 章） | 不可違的紅線 | 組織級、集中管控 |
| 權限 | permission 物件（第四冊 ch6） | 能做什麼動作 | 專案級、版控 |
| 規範 | AGENTS.md＋instructions | 該怎麼做事 | 專案級、版控 |
| 偏好 | 全域 AGENTS.md | 個人溝通風格 | 個人、不入庫 |

規範（rules）是軟性的「請照做」，權限是硬性的「不准做」，政策是組織的「連設定都不准改」。三者的邊界清楚，治理才不會互相踩腳。

## 15.5 寫好 AGENTS.md 的四條心法

- **寫事實不寫願望**：「測試指令是 bun test」有效；「請寫高品質代碼」是噪音
- **短而準勝過長而全**：每條指令都在消耗上下文預算，留給真正的任務
- **怪癖優先**：光看代碼猜不到的事才是精華（那個要先 source env.sh 才能跑的腳本）
- **懶載入大文件**：細節指南用 `@docs/xxx.md` 引用並教代理按需讀取〔文件〕，別一股腦塞進上下文

## 本章摘要 {.unnumbered .unlisted}

- /init 掃碼產生或改進 AGENTS.md；提交入庫是官方建議
- 三層搜尋：本地向上走訪→全域→Claude 相容；同類先到者勝
- instructions 收編既有規範：glob＋URL，與 AGENTS.md 合併
- 四層治理：政策＞權限＞規範＞偏好，軟硬分明
- 心法：寫事實、保持短、怪癖優先、大文件懶載入

## 下章預告 {.unnumbered .unlisted}

規矩立完了，下一章盤點武器庫：OpenCode 內建工具全目錄——每支工具做什麼、哪些配置項能調、以及它們如何被你的擴充覆蓋與增強。

## 延伸資源 {.unnumbered .unlisted}

- Rules 文檔：<https://opencode.ai/docs/rules/>
