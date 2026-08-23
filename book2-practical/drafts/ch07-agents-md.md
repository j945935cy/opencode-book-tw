# 第 7 章：專案初始化

同一個 AI、同一個模型，在不同專案裡的表現可以天差地遠——差別不在運氣，在於專案有沒有把「這裡的規矩」講清楚。這一章的主題只有兩個：寫好 AGENTS.md，以及把整個 `.opencode/` 目錄經營成團隊共用的資產。這是全書投資報酬率最高的一章。

## 7.1 AGENTS.md 最佳實踐

AGENTS.md 是放在儲存庫根目錄（或子目錄）的說明文件，OpenCode 啟動時自動讀取，作為代理的長期記憶。它不是給人看的 README，而是**給 AI 的工作簡報**。

**該放什麼**

| 區塊 | 內容 | 範例 |
|------|------|------|
| 專案概要 | 三句話講完這是什麼、用什麼技術棧 | 「本專案是訂單管理 API，Go 1.22＋Postgres」 |
| 常用指令 | 建置、測試、lint 的正確命令 | `make test`、`uv run pytest -q` |
| 目錄導覽 | 核心程式碼在哪、新代碼該放哪 | 「業務邏輯放 internal/service/，勿放 handler」 |
| 慣例與紅線 | 命名規則、禁止事項 | 「不得直接改 migrations/ 已合併檔案」 |
| 驗收標準 | 完成的定義 | 「所有變更須通過 CI 全綠」 |

**不該放什麼**

- 複製貼上整份架構文件——AI 要的是濃縮過的規則，不是百科全書。
- 會過期的內容（進度、待辦）——那是 issue tracker 的職責。
- 含糊的願景口號——「保持程式碼整潔」沒有可操作性，「匯出函式需附 docstring 且通過 ruff」才有。

**範例骨架**

```markdown
# AGENTS.md

## 專案概要
電商後端 API。Go 1.22、PostgreSQL 16、Redis。
部署目標為公司 K8s 叢集，本地開發以 docker compose 為主。

## 常用指令
- 測試：make test（等價 go test ./... -race）
- 本地啟動：make dev
- 資料庫遷移：make migrate-up / make migrate-down

## 目錄導覽
- cmd/server/：程式進入點，只做組裝
- internal/service/：業務邏輯層，新功能主要落在這裡
- internal/handler/：HTTP 層，不做業務判斷
- migrations/：僅新增檔案，已合併的遷移不可修改

## 慣例與紅線
- 所有公開函式需有 docstring，起頭為函式名
- 金額計算一律使用 decimal 套件，禁用 float
- 修改前先跑 make test 確認基準為綠

## 驗收標準
CI 全綠；新增功能必須附表驅動測試。
```

**版控策略**

AGENTS.md 放儲存庫根目錄一起進 git——它是程式碼的一部分，跟著 code review 走。改動它的 PR 和改功能的 PR 一樣需要審查，因為「教壞 AI」的後果等同「教壞新人」，而且規模更大。

維護節奏：每次發現 AI 重複犯同類錯誤，就回頭補一條對應規則。AGENTS.md 是活的文件，累積三個月後你會得到一份團隊智慧結晶。

## 7.2 團隊共用的專案設定

AGENTS.md 只解決「知識」，`.opencode/` 目錄解決「行為」。這個目錄下的東西全部可以進版控：

```text
.opencode/
├── opencode.json      專案層設定（權限、模型偏好）
├── skill/             專案技能（第 5 章）
├── agent/             自訂代理（第四冊深入）
└── command/           自訂指令（第 12 章）
```

**專案層設定的典型用法**

把團隊的安全底線寫死在專案層，成員不必各自設定：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "allow",
    "bash": {
      "git push*": "ask",
      "rm -rf *": "deny",
      "*": "ask"
    }
  }
}
```

**多層設定的合併關係**

全域設定（`~/.config/opencode/opencode.json`）與專案層設定會合併生效，衝突時專案層優先——所以「個人習慣放全域，團隊規範放專案」是不會互相踩到的分工。完整的七層合併優先序在第 12 章展開。

**新人第一天體驗**

clone 專案、裝好 OpenCode、打開終端機——AGENTS.md 與 `.opencode/` 隨儲存庫到位，AI 立刻知道這個專案的指令、慣例、紅線。這就是「團隊共用的專案設定」的最終形態：知識隨著儲存庫走，而不是跟著某位資深工程師的腦袋走。

## 本章摘要 {.unnumbered .unlisted}

- AGENTS.md 是給 AI 的工作簡報：概要、常用指令、目錄導覽、慣例覽、慣例紅線、驗收標準五區塊；避免塞百科全書、過期資訊與空泛口號。
- 它隨儲存庫版控、跟著 code review 走；AI 重複犯錯時回頭補規則，讓它持續進化。
- `.opencode/` 目錄承載專案層設定、技能、代理、指令，全部進版控；全域放個人偏好、專案層放團隊規範，衝突時專案層勝出。

## 下章預告 {.unnumbered .unlisted}

工具與環境都有了，決定產出上限的是互動品質。第八章精修基本互動：像帶新人一樣下指令的方法論，以及圖片等非文字素材的正確餵法。

## 延伸資源 {.unnumbered .unlisted}

- AGENTS.md 規範：<https://opencode.ai/docs/rules/>
- 官方文件〈Config〉：<https://opencode.ai/docs/config/>
