# 第 8 章　六種事件：觸發源全解

第 7 章的 workflow 只監聽了留言；GitHub 的 webhook 還有五扇門可以開。本章把六種事件一次講透——各自的觸發時機、必要輸入與權限要求。讀完你會拿到一張「什麼場景配什麼事件」的決策表。

## 8.1 事件總表

| 事件 | 觸發時機 | 指令來源 | prompt 必填？ |
|------|----------|----------|---------------|
| issue_comment | issue 或 PR 有新留言 | 留言中的 /oc | 否 |
| pull_request_review_comment | PR 代碼行留言 | 行內 /oc | 否 |
| issues | issue 新開或編輯 | 無（自動） | **是** |
| pull_request | PR 開啟/同步/重開 | 無（自動） | 否（預設審查） |
| schedule | cron 排程 | cron 定義 | **是** |
| workflow_dispatch | Actions 分頁手動點 | UI 輸入 | **是** |

記憶法：**有人打字的（兩種 comment）不用 prompt**——指令就在留言裡；**沒人打字的四種自動事件**，prompt 就是它的任務書〔文件〕。

## 8.2 兩種 comment：對話式觸發

`issue_comment` 覆蓋 issue 與 PR 的討論串留言，是最常用的入口。代理讀整條討論串上下文後回覆、開分支或提交 PR。適合「隨叫隨到」的互動模式。

`pull_request_review_comment` 是它的精準版：在 PR 的 Files 分頁對特定代碼行留言時觸發，payload 自帶檔案路徑、行號與周邊 diff〔文件〕。審查時指著某段說「這裡要加錯誤處理」，不需要自己描述位置。

## 8.3 三種無人值守：prompt 是任務書

`issues`（新 issue 觸發）、`schedule`（cron 觸發）、`workflow_dispatch`（手動觸發）都沒有留言可解析，因此 **prompt 必填**〔文件〕。schedule 與 dispatch 的輸出沒有 issue 可回，會進 Action 日誌與 PR。

排程範例骨架〔文件〕：

```yaml
on:
  schedule:
    - cron: "0 9 * * 1"   # 每週一 09:00 UTC
jobs:
  opencode:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: write
      pull-requests: write
      issues: write
    steps:
      - uses: actions/checkout@v6
        with: { persist-credentials: false }
      - uses: anomalyco/opencode/github@latest
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        with:
          model: anthropic/claude-sonnet-4-20250514
          prompt: |
            巡檵代碼庫中的 TODO 與 FIXME，
            彙整成清單；值得處理的開 issue 追蹤。
```

注意權限變多了：排程沒有使用者上下文做權限把關，要讓代理開分支提 PR 就得明確給 `contents: write` 與 `pull-requests: write`〔文件〕。放權之前想清楚 prompt 寫得多克制——它是這台自動化唯一的韁繩。

## 8.4 pull_request：自動審查員

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
```

PR 事件的特典：不給 prompt 時，代理預設執行**代碼審查**〔文件〕。搭配只讀權限（contents/pull-requests/issues 都 read），就是一台零風險的審查機器：

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: read
  issues: read
```

每個 PR 開啟或更新時自動出審查意見，人類審查者上班前已有初稿。團隊反饋最常見的調整是把「找問題」收斂成專案自己的審查清單——用 `prompt:` 覆蓋即可（第 7 章）。

## 8.5 決策表：什麼場景配什麼事件

| 你想要 | 配的事件 |
|--------|----------|
| 隨叫隨到的幫手 | issue_comment |
| 行級精準審查對話 | pull_request_review_comment |
| 新 issue 自動回應/分流 | issues＋prompt |
| 每個 PR 自動初審 | pull_request（免 prompt 或自訂） |
| 週期性巡檢（TODO、依賴、測試覆蓋） | schedule＋prompt |
| 一鍵跑重活（大重構、批量文檔） | workflow_dispatch＋prompt |

## 本章摘要 {.unnumbered .unlisted}

- 六事件分兩類：留言驅動（指令在留言裡）與自動驅動（prompt 是任務書）
- issues/schedule/dispatch 必填 prompt；排程輸出進日誌與 PR
- 排程與 dispatch 要明確放行 write 權限，prompt 成為唯一韁繩
- pull_request 事件免 prompt 即預設審查，配唯讀權限零風險上線
- 場景配事件照決策表，別為一個需求開滿全部事件

## 下章預告 {.unnumbered .unlisted}

零件齊了，下一章組裝：四套可直接抄的作戰配方——修 issue 自動開 PR、行內審查回應、週巡檢報告、以及用帳齡過濾防 spam 的議題分流。

## 延伸資源 {.unnumbered .unlisted}

- GitHub 整合文檔：<https://opencode.ai/docs/github/>
