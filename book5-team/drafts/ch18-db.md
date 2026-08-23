# 第 18 章　db 工具與營運：直查引擎的心臟

第三冊用 Python 唯讀連線解剖過 opencode.db；這一章官方把同樣能力搬進了 CLI——`opencode db` 直接開出 sqlite3 shell 或跑單條查詢。營運視角的老問題（容量、清理、稽核）從此一行命令解決。

## 18.1 兩種用法

```bash
opencode db                          # 互動式 sqlite3 shell
opencode db "SELECT ..."             # 跑單條查詢
```

帶查詢參數時直接執行並印結果〔實測〕：

```sql
opencode db "SELECT count(*) AS sessions FROM session;"
-- sessions
-- 267
```

互動模式就是標準 sqlite3 shell，.tables、.schema、點命令全套可用。等於第三冊附錄的 SQL 技能直接升級成一等公民命令——不再需要繞道 Python。

## 18.2 營運三查

**容量健檢**——那顆 398MB 的資料庫是怎麼長大的：

```bash
opencode db "SELECT name, SUM(pgsize)/1048576 AS mb FROM dbstat
             GROUP BY name ORDER BY mb DESC LIMIT 5;"
```

dbstat 虛擬表（第三冊附錄引用過 SQLite 官方文檔）逐表報大小。通常 event/message/part 三張事件溯源表是大頭——這是正常成長，不是病。

**老會話清點**——找出三個月沒動的會話準備歸檔：

```bash
opencode db "SELECT id, title, time_updated FROM session
             WHERE time_updated < unixepoch() - 90*86400
             ORDER BY time_updated LIMIT 20;"
```

配第 3 章的 export→delete 流程：先匯出再刪除，資產不流失。

**憑證盤點**——auth.json 之外的供應商授權狀態：

```bash
opencode db "SELECT providerID, type, length(apiKey) FROM credential;"
```

只取長度不看內容——稽核「有哪些 key」而不洩漏 key 本身。

## 18.3 寫入的紅線

db shell 是全功能的 sqlite3——理論上 INSERT/UPDATE/DELETE 都打得進去。營運鐵律：**唯讀使用**。理由有三：

1. 引擎可能正在跑（WAL 模式下併發寫有鎖競爭），手滑寫壞 schema 要重建整個歷史
2. 事件溯源表的完整性靠 seq 序號，外部改寫等於破壞重放基礎
3. 官方提供的正規寫入路徑齊全得多：session delete 命令、SDK 的 update/revert、TUI 操作——需要改東西時走正門

真要動手術（例如清除特定外掛的殘留資料），先停引擎、備份整個資料目錄、再開 shell。

## 18.4 定期維運腳本

把本章查詢組合成 cron 友善的一支腳本：

```bash
#!/usr/bin/env bash
# opencode-db-check.sh — 週度健檢
echo "== 容量 TOP5 =="
opencode db "SELECT name, printf('%.1f MB', SUM(pgsize)/1048576.0) FROM dbstat GROUP BY name ORDER BY SUM(pgsize) DESC LIMIT 5;"
echo "== 90 天未活動會話數 =="
opencode db "SELECT count(*) FROM session WHERE time_updated < unixepoch() - 7776000;"
echo "== 憑證數 =="
opencode db "SELECT count(*) FROM credential;"
```

輸出貼週報或丟給第 9 章的排程代理自動判讀——營運數據本身也該被 AI 盯著。

## 本章摘要 {.unnumbered .unlisted}

- `opencode db`＝官方 sqlite3 入口；單條查詢與互動 shell 兩用
- 營運三查：dbstat 容量、老會話清點、憑證盤點（只看長度）
- shell 可寫但鐵律唯讀——寫入走 session delete／SDK／TUI 正門
- 手術前停引擎＋備份目錄
- 週度健檢腳本讓營運可持續、可委派

## 下章預告 {.unnumbered .unlisted}

最後一塊拼圖屬於最容易被忽略的戰場：Windows。下一章把 WSL 環境的團隊標準化一次講完——本系列作者群親身使用的組態。

## 延伸資源 {.unnumbered .unlisted}

- CLI 文檔：<https://opencode.ai/docs/cli/>
