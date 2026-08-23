# 附錄 D　名詞表

| 名詞 | 釋義 | 詳見 |
|------|------|------|
| 擴充點 | OpenCode 可被客製的八個介面：指令、Skills、代理、主題、MCP、自訂工具、外掛、SDK | ch1 |
| 鉤子（Hook） | 外掛在特定時機被呼叫的 `(input, output)` 函式，改 output 即改行為 | ch7 |
| 事件 | 廣播式的事實報導，唯讀；與鉤子分流的旁觀管道 | ch10 |
| responseStyle | SDK 回應封裝方式：fields（預設，取 .data）或 data | ch16 |
| noReply | prompt 的注入模式：只加內容不觸發 AI 回覆 | ch17 |
| 結構化輸出 | 以 json_schema 約束模型輸出，經 StructuredOutput 工具回傳並重試校正 | ch17 |
| subtask | 指令選項：強制以子代理會話執行，隔離上下文 | ch4 |
| SKILL.md | 技能定義檔；frontmatter 描述觸發條件，代理按需載入全文 | ch5 |
| permission.task | 控制代理可派遣哪些子代理的萬用字元規則面 | ch6 |
| 最後符合者勝 | permission 物件多規則匹配時的裁決規則 | ch6 |
| slots | TUI 外掛的版位插槽系統：宣告插入位置而非覆蓋版面 | ch14 |
| 注意力系統 | 依終端機焦點狀態決定通知與音效的機制，六種語意音效 | ch15 |
| WorkspaceAdapter | 實驗性工作區適配器介面，可註冊 local/remote 引擎來源 | ch19 |
| ACP | Agent Client Protocol：編輯器與代理間的開放協定 | ch19 |
| policies | 組織層強制約束，優先級高於一切擴充與設定 | ch19 |
| Bun shell | 外掛資源包 `$` 的底層：標籤模板執行外部命令 | ch7 |
| logfmt | 「鍵=值」一行式日誌格式；client.app.log 寫入後以此呈現 | ch3 |
| truecolor | 24 位元終端色彩支援，主題完整顯色的前提 | ch13 |
| defs | 主題 JSON 的自訂色票區，供全檔引用 | ch13 |
| 語意化版本 | major.minor.patch 紀律：鉤子行為改變＝major | ch12 |

## 延伸資源 {.unnumbered .unlisted}

- 官方文檔總入口：<https://opencode.ai/docs/>
