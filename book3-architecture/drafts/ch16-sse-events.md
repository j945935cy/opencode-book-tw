# 第 16 章　事件流：SSE 即時架構

TUI 裡代理的每個動作「即時」出現——不是輪詢的功勞，是事件推播。這章拆解 SSE 事件流的結構，並動手寫一個最小監看器。

## 16.1 兩個事件端點

| 端點 | 範圍 |
|------|------|
| GET /event | 單一實例的事件流 |
| GET /global/event | 跨實例的全域流 |

連上後第一則事件固定是 `server.connected`，之後是持續推送的匯流排事件。資料庫側的對應物是 event/event_sequence 雙表（第 5 章）——**先落盤、再廣播**，順序由 seq 保證。

這個組合解決了即時系統的經典難題：斷線重連不丟事件。SSE 本身會漏（它只是 HTTP 串流），但客戶端只要記住最後 seq，重連後向 API 補查即可無漏續傳。

## 16.2 最小監看器

十行 Python 感受心跳：

```python
import requests, json

url = "http://127.0.0.1:4096/event"
with requests.get(url, stream=True, timeout=None) as r:
    for line in r.iter_lines():
        if line and line.startswith(b"data:"):
            ev = json.loads(line[5:])
            t = ev.get("type", "?")
            print(t)
```

跑起來後在 TUI 裡隨便做點事：發提示、批准權限、跑工具——每個動作都以事件形式流過你的終端機。常見事件族：訊息更新、part 更新、權限請求、會話狀態變化。

## 16.3 三個實戰模式

**模式一：活動儀表板。** 監看 session 相關事件＋定期查 /session/status，做出團隊級「誰的代理正在忙什麼」看板。

**模式二：自動化應答機。** 監聽 permission 請求事件 → 白名單內自動回填 allow、白名單外推 Slack 通知等人類。第 15 章的按確認死結由此解開。

**模式三：審計流水帳。** 把事件原樣寫入自家日誌系統，得到一份獨立於 OpenCode 的完整行為帳本——合規場景的剛需。

## 16.4 為什麼是 SSE 而非 WebSocket

值得停一格的設計選擇。SSE 的劣勢是單向（伺服器→客戶端），但這正是互動模型：**指令走 REST、通知走 SSE**——兩條通道各司其職。附帶的好處全是工程現實：純 HTTP 基礎設施友好（代理、負載均衡、curl 都能直接玩）、自動重連內建於瀏覽器 EventSource。

雙向需求出現的地方（IDE 控制 TUI），架構用了另一個機制——control request/response，見下章。

## 本章摘要 {.unnumbered .unlisted}

- 先落盤再廣播；seq 讓斷線重連可無漏補齊。
- 十行代碼接上心跳；三個實戰模式：儀表板、應答機、審計帳。
- 指令走 REST、通知走 SSE——單向不是缺陷是分工。
- 雙向互動另闢 control 通道（第 17 章）。

## 下章預告 {.unnumbered .unlisted}

下一章反向操作：不改介面、用 API 遙控 TUI 本身。

## 延伸資源 {.unnumbered .unlisted}

- Server 文件（Events/TUI 節）：<https://opencode.ai/docs/server/>
- 第二冊第 20 章（stats 成本對帳）
