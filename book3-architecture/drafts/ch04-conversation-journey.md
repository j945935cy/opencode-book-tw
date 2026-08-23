# 第 4 章　一次對話的完整旅程

這一章追蹤一條訊息的一生：從你在終端機按下 Enter，到回應逐字串流完成。全程以資料庫裡留下的真實痕跡為證。

## 4.1 起點：session_input 佇列

你的輸入不是直接變成 API 呼叫。查詢 `session_input` 表可以看到它先落在一個有明確語意的佇列結構裡：

```sql
SELECT id, session_id, delivery, admitted_seq, promoted_seq
FROM session_input ORDER BY time_created DESC LIMIT 5;
```

三個欄位透露了設計意圖：`delivery` 記錄送達方式；`admitted_seq` 是「准入序號」——系統承認這筆輸入的時間點；`promoted_seq` 則是它被提升為正式訊息的時間點。

為什麼要佇列？因為**代理正在跑的時候你也會想打字**。你中途補充的那句話不會打斷執行中的回合，而是排進佇列，在正確的時機被吸收。搶話不掉話，就是這張表的價值。

## 4.2 兩層模型：message 與 part

訊息本體拆成兩張表：

- `message`：一次發言的殼——誰說的、哪個會話、何時、模型與成本中繼資料（存在 data JSON 欄）。
- `part`：發言的內容切片——一段文字、一個工具呼叫、一次工具結果、一張圖，各是一個 part。

用 `session_message` 表把兩者掛到會話時間軸上（type 欄區分使用者/代理事件，seq 保序）。

這個兩層設計解決了串流時代的核心難題：**回應不是一口氣到貨的**。文字塊、工具呼叫、工具結果依序抵達，每個都是獨立的 part，各自有建立與更新時間戳。前端因此能精確渲染「正在呼叫工具」的動畫——因為那真的是一個尚未完成的 part。

## 4.3 迴圈骨架

把 DB 痕跡與官方 API 行為拼起來，一個回合的骨架是：

```text
1. 輸入入佇列            （session_input）
2. 提升為 message        （user part）
3. 呼叫供應商，串流回應
4. 回應切片落成 parts    （文字／工具呼叫）
5. 工具呼叫 → 權限閘門
6. 通過 → 執行 → 結果寫回新 part（或溢寫 tool-output）
7. 有工具呼叫 → 回到 3   （代理迴圈繼續）
8. 純文字回應 → 回合結束
9. 全程廣播事件          （event 表 + SSE，第 16 章）
```

第 7 步是「代理」二字的由來：模型自己決定要不要再來一圈。第二冊講的使用者視角「工具迴圈」，在資料層就是 parts 的鏈式生長。

## 4.4 重放足跡：親手驗證

開一個新會話隨便聊一輪，然後唯讀查詢：

```bash
sqlite3 "file:$HOME/.local/share/opencode/opencode.db?mode=ro"
```

```sql
-- 這個會話產生了哪些 part？
SELECT p.id, substr(p.data, 1, 60)
FROM part p JOIN message m ON p.message_id = m.id
WHERE m.session_id = 'ses_剛才那個'
ORDER BY p.time_created;
```

你會看到文字 part、工具呼叫 part、工具結果 part 交錯出現，時間戳嚴格遞增。架構書讀到能自己重放資料，才算真的懂了。

## 本章摘要 {.unnumbered .unlisted}

- 輸入先進 session_input 佇列，admitted/promoted 兩個序號管理時機。
- message 是殼、part 是切片；串流時代的渲染全靠兩層分離。
- 迴圈骨架九步：佇列→提升→串流→切片→閘門→執行→遞迴→收束→廣播。
- 唯讀查詢即可重放任何一輪對話。

## 下章預告 {.unnumbered .unlisted}

單次旅程看完了，下一章拉高到全域：19 張表如何組成一個自洽的領域模型。

## 延伸資源 {.unnumbered .unlisted}

- SQLite 唯讀 URI：<https://www.sqlite.org/uri.html>
- 第二冊附錄 C（工具列表）複習
