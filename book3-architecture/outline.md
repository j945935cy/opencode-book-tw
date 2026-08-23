# 《OpenCode 架構解密》大綱（第三冊）

**副標題**：從代理迴圈到生產級 AI 系統的可觀察設計
**定位**：內部設計深度解析 | **難度**：進階 | **目標頁數**：380 頁
**狀態**：撰寫中（本版大綱 2026-08-23 依實測重訂，取代早期規劃稿）
> 叢書第三冊。讀者：讀完前兩冊、想理解引擎室的工程師。
> 方法論承諾：不猜內部——只寫能驗證的事（DB schema、HTTP API、目錄結構、日誌、官方文件）。
> 版本凍結：v1.18.21。

## 事實基礎（2026-08-23 探測）

- 安裝形態：`~/.local/lib/node_modules/opencode-ai/`，package.json 零 runtime deps（單體打包）、bin 符號連結、postinstall.mjs
- 資料目錄 `~/.local/share/opencode/`：opencode.db（SQLite WAL 模式，實測 398MB）、auth.json、log/opencode.log（logfmt＋run ID）、repos/、snapshot/<hash>/（內容定址）、storage/（插件資料）、tool-output/tool_*（工具輸出溢寫）
- DB 19 表全 schema 已取得：account、account_state、control_account、credential、data_migration、event、event_sequence、message、migration、part、permission、project、project_directory、session、session_context_epoch、session_input、session_message、session_share、todo、workspace
- 官方 Server 文件：完整 REST/SSE API 清單、OpenAPI 3.1 於 /doc、SDK 由 spec 生成；TUI 本身是伺服器客戶端；serve 旗標 port/hostname/mdns/mdns-domain/cors；OPENCODE_SERVER_PASSWORD/USERNAME
- 文件站已驗證路徑：server/plugins/acp/web/providers/keybinds/sdk/network/policies/custom-tools/formatters/troubleshooting 等

---

## 第一篇 全景篇

### 第 1 章　為什麼要打開引擎室
- 1.1 從「會用」到「懂它」：除錯、客製、整合三種回報
- 1.2 黑盒焦慮與可觀察架構——本書方法論：每個論述都可重現
- 1.3 全書地圖與閱讀路線（應用型讀者／整合型讀者）

### 第 2 章　一個核心、多種面孔
- 2.1 client/server 分離：TUI 只是客戶端之一（官方明載）
- 2.2 客戶端家族：TUI／Web／IDE 外掛／SDK／curl
- 2.3 這個設計換來什麼：多客戶端共用、可程式化、遠端化、規格化
- 2.4 TUI 內嵌伺服器 vs opencode serve 獨立伺服器

### 第 3 章　資料地圖
- 3.1 ~/.config 與 ~/.local/share 的分離原則
- 3.2 逐一走訪資料目錄：db／auth.json／log／repos／snapshot／storage／tool-output
- 3.3 WAL 與 SHM：398MB 實例的檔案生態
- 3.4 磁碟佔比實測與容量預算思維

## 第二篇 核心引擎篇

### 第 4 章　一次對話的完整旅程
- 4.1 Enter 之後：session_input 的佇列語意（delivery/admitted_seq/promoted_seq）
- 4.2 message → part 兩層模型：串流、工具呼叫、多模態如何共居
- 4.3 迴圈骨架：意圖 → 權限閘門 → 執行 → 回填 → 事件廣播
- 4.4 以真實 DB 查詢重放一輪對話的足跡

### 第 5 章　資料模型深探
- 5.1 19 表分組導覽：身分／空間／對話／事件／周邊
- 5.2 fork 樹（session.parent_id）與 context_epoch：分岔與壓縮的痕跡
- 5.3 token 五欄位與 cost：計費真相在本地
- 5.4 event/event_sequence：事件溯源式排序保障

### 第 6 章　工具執行迴圈內幕
- 6.1 工具呼叫的誕生：模型輸出如何變成結構化 part
- 6.2 權限閘門攔截點：ask/allow/deny 在迴圈中的位置
- 6.3 大型輸出的去路：tool-output 溢寫機制實測
- 6.4 失敗、重試與中止（abort）的資料痕跡

### 第 7 章　權限與憑證體系
- 7.1 雙層結構：設定層 permission 規則 vs DB permission 表
- 7.2 ask 的等待迴路：/session/:id/permissions/:permissionID
- 7.3 auth.json、credential 表與供應商 OAuth 端點
- 7.4 伺服器暴露面防護：基本授權與 CORS

## 第三篇 周邊系統篇

### 第 8 章　設定解析引擎
- 8.1 七層優先序的合併語意（第二冊 ch12 底層視角）
- 8.2 JSONC、$schema 與設定除錯
- 8.3 用 GET/PATCH /config 觀察生效結果

### 第 9 章　LSP 整合層
- 9.1 啟動、索引與就緒：GET /lsp 觀察法
- 9.2 診斷流進代理工作迴圈的路徑
- 9.3 formatter 子系統與 /formatter API

### 第 10 章　MCP 客戶端實作
- 10.1 local/remote 兩態與動態註冊（POST /mcp）
- 10.2 工具命名空間落地：mcp_<伺服器>_<工具>
- 10.3 故障隔離設計：單點掛掉不等於全掛

### 第 11 章　插件系統
- 11.1 storage/ 實測：插件資料目錄長什麼樣
- 11.2 插件鉤子點與事件匯流排
- 11.3 安全邊界：插件即完全信任程式碼

### 第 12 章　快照與復原機制
- 12.1 snapshot/<hash>：內容定址儲存實測
- 12.2 revert/unrevert API 與 session.revert 欄位
- 12.3 undo 保險的架構代價與清理策略

### 第 13 章　供應商抽象層
- 13.1 一個介面、多個後端：75+ 供應商如何被統一
- 13.2 模型 ID 解析（provider/model 二元組）與 GET /config/providers
- 13.3 免費／付費模型的接入差異；本地端點（Ollama/vLLM）

## 第四篇 通訊篇

### 第 14 章　HTTP Server 全景
- 14.1 serve 旗標全表與 OpenAPI 3.1（/doc）
- 14.2 SDK 由 spec 生成：規格即真相
- 14.3 遠端場景：mdns、CORS、密碼保護

### 第 15 章　會話操作 API 實戰
- 15.1 CRUD ＋ children/fork/share/diff/summarize/init 全走訪
- 15.2 用 curl 走完一個會話生命週期（建立→提示→回應→分享→刪除）
- 15.3 同步 message vs prompt_async 的取捨

### 第 16 章　事件流：SSE 即時架構
- 16.1 /event 與 /global/event；server.connected 之後的事件巴士
- 16.2 動手寫一個會話監看器
- 16.3 UI 即時性的來源：事件驅動黏合

### 第 17 章　驅動 TUI：控制端點
- 17.1 /tui/* 家族巡禮（append-prompt/submit-prompt/show-toast…）
- 17.2 IDE 外掛的接線方式（官方明載用途）
- 17.3 control request/response 對話通道

### 第 18 章　ACP 與協定層次
- 18.1 ACP 定位：編輯器與代理之間的通用語言
- 18.2 三種協定的分工：ACP vs HTTP API vs MCP
- 18.3 選型決策樹：我要自動化該用哪條路

## 第五篇 維運與洞察篇

### 第 19 章　日誌系統解剖
- 19.1 logfmt 逐欄解讀；run= 追蹤一次執行全程
- 19.2 --print-logs --log-level DEBUG 重現法
- 19.3 POST /log：把外部事件寫進同一條時間軸

### 第 20 章　效能、容量與演進觀察
- 20.1 大 DB 的教訓：WAL 成長、清理與備份
- 20.2 健康檢查與指標清單（/global/health、stats）
- 20.3 用 OpenAPI diff 追蹤版本演進；個人儀表板實作

## 附錄
- A：REST API 速查表（全端點分組一頁表）
- B：資料目錄 × 資料表 × API 三向對照總表
- C：環境變數與命令列旗標清單（已驗證者標實值）
- D：名詞表（instance/part/SSE/WAL/content-addressing…）
