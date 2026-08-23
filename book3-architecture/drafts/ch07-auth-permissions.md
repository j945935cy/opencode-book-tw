# 第 7 章　權限與憑證體系

上一章看到閘門的位置，這章盤點閘門兩側的家當：規則從哪裡來、憑證放在哪裡、伺服器本身怎麼設防。

## 7.1 規則層與記錄層

權限體系有兩個層次，初學者最容易混淆：

**規則層（你寫的）**：opencode.json 裡的 `permission` 區塊。allow/ask/deny 三值，支援萬用字元前綴。它是純設定，隨檔案載入。

**記錄層（系統寫的）**：資料庫 `permission` 表——id、project_id、action、resource。當你在確認框勾選「永遠允許」，被记住的決定就落在这里，之後同類請求不再打擾。

兩層的優先關係：deny 規則永遠贏；「永遠允許」的記錄只在規則未明確反對的範圍內生效。安全審計時兩處都要看。

## 7.2 金庫：auth.json 與 credential

供應商憑證有兩個存放點：

| 位置 | 內容 | 形態 |
|------|------|------|
| `~/.local/share/opencode/auth.json` | 供應商 API 金鑰、OAuth token | 明文 JSON，權限 600 |
| DB `credential` 表 | 整合類憑證（label、value、method） | 結構化欄位 |

OAuth 流程有專門端點支撐：`POST /provider/{id}/oauth/authorize` 發起授權、callback 端點接回跳。token 過期時間在 account 表有 `token_expiry` 欄位追蹤。

實務守則（第二冊第 21 章的安全基線在架構層的落點）：

- 備份/同步排除 auth.json
- 容器化部署時以環境變數注入金鑰而非掛載檔案
- 共用機器上檢查檔案權限確為 600

## 7.3 伺服器自身的防護

核心是 HTTP 伺服器，防護面就有三道：

**基本授權**。設定環境變數即可啟用：

```bash
OPENCODE_SERVER_PASSWORD=your-secret opencode serve --hostname 0.0.0.0
```

使用者名稱預設 `opencode`，可用 `OPENCODE_SERVER_USERNAME` 覆蓋。對 `serve` 與 `web` 同時生效。

**繫結位址**。預設只聽 `127.0.0.1`——本機可用、外網不可達。遠端場景必須顯式指定 `--hostname`，等於強迫你意識到自己正在擴大暴露面。

**CORS 白名單**。瀏覽器客戶端跨源存取需要 `--cors <origin>` 明確放行，可多次傳入。

三道加起來的原則：**預設最小暴露，開放需明示**。

## 7.4 一張圖總結

```text
模型想執行工具
   ↓
規則層比對（json permission 區塊）
   ├─ deny → 拒絕，留痕
   ├─ allow → 放行
   └─ 未命中 → 查記錄層（permission 表）
         ├─ 有「永遠允許」→ 放行
         └─ 無 → ask：事件廣播 → 人類點擊 → API 回填
```

## 本章摘要 {.unnumbered .unlisted}

- 權限分規則層（你的 json）與記錄層（DB 表）；deny 恆勝。
- 憑證金庫是 auth.json＋credential 表；OAuth 有專屬端點。
- 伺服器三道防護：密碼、預設本機綁定、CORS 白名單。
- 預設最小暴露、開放需明示——安全設計的一致哲學。

## 下章預告 {.unnumbered .unlisted}

核心引擎篇到此收束。下一篇轉往周邊：先拆七層設定合併的引擎室實作。

## 延伸資源 {.unnumbered .unlisted}

- Server 文件（Auth 節）：<https://opencode.ai/docs/server/>
- 第二冊第 12 章（七層優先序）、第 21 章（安全基線）
