# 第 5 章　資料模型深探

上一章跟著一條訊息走完全程，這一章把鏡頭拉遠：19 張表的全景。我們的優勢是不用猜——schema 就躺在你的磁碟上。

## 5.1 五組功能域

把 19 張表按職責分組，模型立刻清晰：

| 功能域 | 資料表 | 管什麼 |
|--------|--------|--------|
| 身分 | account、account_state、control_account、credential | 供應商帳號、token、憑證 |
| 空間 | project、project_directory、workspace | 專案、工作樹、分支工作區 |
| 對話 | session、message、part、session_message、session_input | 第 4 章的主角們 |
| 事件 | event、event_sequence | 事件溯源骨幹 |
| 周邊 | todo、session_share、permission、session_context_epoch、migration、data_migration | 待辦、分享、權限、壓縮、版本遷移 |

## 5.2 session 表：一張表看懂產品野心

session 是全模型的樞紐，挑關鍵欄位解讀：

- `parent_id`：**fork 樹**。分岔出的會話指向母會話——第二冊教的 `--fork` 平行嘗試法，落盤就是這個欄位。
- `tokens_input/output/reasoning/cache_read/cache_write`：五個 token 欄位＋`cost` 實數。第二冊第 20 章的成本矩陣，資料源頭在這裡。
- `revert`：回退狀態指標，配合 `/undo`（第 12 章）。
- `time_compacting`：上下文壓縮發生的時刻戳——長會話自動摘要不是傳說，是欄位。
- `share_url`、`agent`、`model`：分享連結與「這個會話釘在哪個代理/模型」。
- `summary_additions/deletions/files`：會話層級的程式碼變更統計。

**驗證**：`SELECT id, parent_id, agent, model, cost FROM session ORDER BY time_updated DESC LIMIT 10;`

## 5.3 workspace 與 project：多專案的骨架

`project` 以 worktree 為單位；`project_directory` 記錄專案下被開啟過的目錄與探索策略；`workspace` 更細，帶 `branch` 欄位——同一專案的不同 Git 分支可以是不同工作區。你切分支時代理上下文的乾淨程度，取決於這組表的設計。

## 5.4 事件溯源：event 與 event_sequence

```sql
SELECT type, COUNT(*) FROM event GROUP BY type ORDER BY 2 DESC LIMIT 8;
```

每筆事件掛在 `aggregate_id`（聚合根，多半是會話）之下，配一個 `seq` 序號；`event_sequence` 表保證每個聚合的序號單調遞增。這是教科書級的事件溯源排序保障：**任何客戶端斷線重連後，只要報出最後看到的 seq，就能無漏地補齊事件**。SSE 事件流（第 16 章）的可信賴性建立在這兩張表上。

## 5.5 遷移系統：架構如何自我升級

`migration` 與 `data_migration` 兩張表記錄 schema 版本演進已完成的項目。軟體升版後第一次啟動，你偶爾會感覺慢半拍——那是它在跑遷移並記帳。這也是為什麼本書堅持唯讀查詢：手改 schema 會讓遷移帳本失真。

## 本章摘要 {.unnumbered .unlisted}

- 19 表五域：身分／空間／對話／事件／周邊。
- session 一張表承載 fork 樹、token 成本、壓縮時刻、分享與變更統計。
- 事件溯源雙表保證斷線重連可補齊。
- migration 表讓 schema 自我升級有帳可查。

## 下章預告 {.unnumbered .unlisted}

模型看完了，回到動態面：工具呼叫從誕生到執行、輸出溢寫的完整內幕。

## 延伸資源 {.unnumbered .unlisted}

- 事件溯源概念：<https://martinfowler.com/eaaDev/EventSourcing.html>
- SQLite WAL：<https://www.sqlite.org/wal.html>
