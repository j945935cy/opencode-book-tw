# 第 3 章　資料地圖

架構書最怕講成空中樓閣。這一章我們直接登陸檔案系統，把 OpenCode 落在你磁碟上的每一個位元組認識一遍。以下所有路徑與數字，都來自一台真實使用近一個月的機器。

## 3.1 兩個目錄的分離原則

OpenCode 遵守 XDG 慣例，設定與資料分家：

| 目錄 | 身分 | 你會動它嗎 |
|------|------|------------|
| `~/.config/opencode/` | 設定：opencode.json、tui.json、skills/ | 會，這是你的 |
| `~/.local/share/opencode/` | 資料：資料庫、日誌、快照 | 平時不動，但要懂 |

設定的七層優先序在第二冊第 12 章講過；本章聚焦資料側。

## 3.2 資料目錄逐項走訪

實測清單（`ls ~/.local/share/opencode/`）：

```text
auth.json        供應商憑證（API 金鑰、OAuth token）
opencode.db      SQLite 主資料庫
opencode.db-wal  寫前日誌（Write-Ahead Log）
opencode.db-shm  共享記憶體索引
log/opencode.log 執行日誌
repos/           專案相關的 Git 中繼資料
snapshot/<hash>/ 快照儲存（內容定址，第 12 章深探）
storage/         插件資料（如 oh-my-openagent）
tool-output/     工具輸出溢寫檔（tool_* 命名）
```

三個值得停頓的細節：

**auth.json 是金庫。** 所有供應商憑證明文存放於此（權限 600）。備份機器時要意識到它的存在——同步到雲端前先想想。

**tool-output 是洩壓閥。** 工具產生的大量輸出（測試日誌、建置輸出）不塞進資料庫，而是寫成獨立檔案、資料庫裡只留指標。實測此目錄約 9.6MB，而主 DB 已達 398MB——沒有這個分流，DB 會更膨脹。

**snapshot 是時光機。** 以雜湊值為名的巢狀目錄，典型的內容定址儲存。`/undo` 的底層靠它（第 12 章）。

## 3.3 WAL 模式：三個檔案的分工

主資料庫旁邊總跟著 `-wal` 和 `-shm` 兩個影子：

- **WAL**：寫入先落日誌、之後才合併回主主檔——讀寫並發不打架，TUI 一邊寫事件你一邊查詢也不鎖死。
- **SHM**：多連線共享的索引區。

實務含義有二：備份時不能只複製 `.db`（WAL 裡可能有未合併的資料），要嘛整組一起拷、要嘛用 SQLite 的線上備份介面；清理空間時也別手刪 WAL——讓程式自己管理。

## 3.4 容量預算思維

一個月真實使用的磁碟帳單：

```text
opencode.db      ~398 MB   （絕對大宗）
tool-output/     ~9.6 MB
snapshot/        ~0.6 MB
log/             <1 MB
```

DB 是唯一需要認真管理的對象——它會隨會話無限成長。哪些表在吃空間、怎麼安全瘦身，留到第 20 章。

## 本章摘要 {.unnumbered .unlisted}

- 設定在 config、資料在 local/share，XDG 分離。
- auth.json 是明文金庫；tool-output 幫 DB 洩壓；snapshot 是內容定址的時光機。
- WAL 讀寫並發友好，但備份必須整組處理。
- 容量管理的主戰場是 opencode.db。

## 下章預告 {.unnumbered .unlisted}

地圖在手，接下來追蹤一次對話從按下 Enter 到回應串流完畢的完整旅程。

## 延伸資源 {.unnumbered .unlisted}

- SQLite WAL 說明：<https://www.sqlite.org/wal.html>
- 第二冊第 12 章（設定優先序）複習
