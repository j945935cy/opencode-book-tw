# 第 18 章　ACP 與協定層次

通訊篇收尾。這一章把全書出現過的協定放上同一張桌子，回答一個整合者必問的問題：**我的場景該用哪條路？**

## 18.1 ACP 是什麼

ACP（Agent Client Protocol，agentclientprotocol.com）是為「編輯器 ↔ 編碼代理」設計的開放協定。OpenCode 以 `opencode acp` 提供支援，讓任何實作 ACP 的編輯器客戶端都能驅動它。

與 /tui 控制端點的差別在通用性：/tui 系列是 OpenCode 專屬 REST；ACP 是跨代理的公共語言——編輯器側只要講 ACP，背後換任何支援的代理都不用改接線。

## 18.2 三條路的分工

| 通道 | 方向 | 對象 | 典型用途 |
|------|------|------|----------|
| HTTP REST | 你 → 核心 | 任何人 | 自動化、儀表板、CI |
| SSE 事件 | 核心 → 你 | 任何人 | 即時監看、應答機 |
| MCP | 核心內的工具擴充 | 工具供應者 | 加工具（第 10 章） |
| ACP | 編輯器 ⇄ 代理 | IDE 生態 | 編輯器整合 |
| skills/插件 | 核心內行為注入 | 擴充開發者 | 改變行為 |

注意 MCP 與 ACP 方向相反：MCP 把外部能力**拉進**代理；ACP 把代理**推進**編輯器。一進一出，剛好互補。

## 18.3 選型決策樹

```text
你要做的是……
├─ 腳本自動化／CI → REST（同步或 prompt_async）
├─ 即時監看／看板 → SSE 事件流
├─ 幫 TUI 使用者代勞 → /tui/* 控制端點
├─ 替權限框做自訂 UI → control 通道
├─ 讓代理多會用工具 → MCP
├─ 做編輯器外掛（跨代理）→ ACP
└─ 只想加知識 → skills；要改行為 → 插件
```

## 18.4 協定的哲學

退一步看全景：OpenCode 的整合面沒有發明私有宇宙——REST、SSE、OpenAPI、MCP、ACP 全是業界現成標準或開放協定。這是第三冊反覆浮現的主題的終章：**好架構不是炫技，是把標準零件組裝得彼此誠實**。

規格公開、狀態可查、一切留痕——你已經具備了審視任何 AI 工具架構的完整取證工具箱。

## 本章摘要 {.unnumbered .unlisted}

- 五通道各司其職：REST 出手、SSE 收聲、control 互動、MCP 引工具、ACP 進編輯器。
- MCP 向內拉、ACP 向外推，方向互補。
- 選型先問方向（誰對誰說話），再問形態。
- 全部採用開放標準——可審計即可信。

## 下章預告 {.unnumbered .unlisted}

最後一篇轉入維運視角：日誌解剖、容量管理與架構演進的追蹤方法。

## 延伸資源 {.unnumbered .unlisted}

- ACP：<https://agentclientprotocol.com/>
- ACP 文件：<https://opencode.ai/docs/acp/>
