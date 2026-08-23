# 附錄 D　名詞表

| 名詞 | 釋義 | 詳見 |
|------|------|------|
| 事件溯源（Event Sourcing） | 以不可變事件序列作為真相來源的設計；重放事件即可重建狀態 | ch5 |
| 聚合／aggregate_id | 事件所屬的主體（通常是會話）；序號在其內單調遞增 | ch5、ch16 |
| part | 訊息的內容切片：文字塊、工具呼叫、工具結果各為一個 | ch4 |
| session_input 佇列 | 使用者輸入的暫存區，admitted/promoted 序號控制吸收時機 | ch4 |
| 內容定址（Content Addressing） | 以內容雜湊作為儲存地址；天然去重、可自證完整 | ch12 |
| WAL | Write-Ahead Log；寫入先落日誌再合併，讀寫並發友好 | ch3 |
| SSE | Server-Sent Events；HTTP 單向伺服器推播 | ch16 |
| OpenAPI 3.1 | API 機器可讀規格；/doc 端點提供，SDK 由其生成 | ch14 |
| client/server 分離 | 核心邏輯住伺服器，TUI/Web/IDE/SDK 皆為客戶端 | ch2 |
| MCP | Model Context Protocol；以外部進程/端點為代理加工具 | ch10 |
| ACP | Agent Client Protocol；編輯器與代理間的開放協定 | ch18 |
| LSP | Language Server Protocol；語意分析的外部程序標準 | ch9 |
| formatter | 格式化子系統；與 LSP 平行、狀態可查 | ch9 |
| 插件（Plugin） | 載入核心、透過鉤子改變行為的完全信任擴充 | ch11 |
| 快照（Snapshot） | 回合級工作樹保險機制，revert 以標記而非刪除實現 | ch12 |
| provider/model 二元組 | 斜線分隔的供應商＋模型識別字串 | ch13 |
| control 通道 | /tui/control 的雙向請求-應答機制 | ch17 |
| logfmt | 「鍵=值」並列的一行式日誌格式 | ch19 |
| prompt_async | 非同步送提示的端點；配事件流收取結果 | ch15 |
