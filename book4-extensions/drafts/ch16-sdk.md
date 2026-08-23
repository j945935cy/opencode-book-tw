# 第 16 章　SDK 入門：把引擎裝進你的程式

前十四章你都在 OpenCode **裡面**擴充；最後一篇換個方向——站在外面，用官方 SDK 把它當成一顆可程式的引擎驅動。排程跑批次重構、在 CI 裡自動審查、替團隊做儀表板，都從 `@opencode-ai/sdk` 開始。

## 16.1 安裝與兩種建立方式

```bash
npm install @opencode-ai/sdk
```

SDK 提供兩個入口，語意完全不同〔文件〕：

**createOpencode()——起一台新引擎。**

```ts
import { createOpencode } from "@opencode-ai/sdk"

const opencode = await createOpencode({
  hostname: "127.0.0.1",
  port: 4096,
  config: { model: "anthropic/claude-haiku-4-20250514" },
})
console.log(`Server running at ${opencode.server.url}`)
// ...用完收工
opencode.server.close()
```

它會真的拉起一個伺服器進程再回傳客戶端。`config` 參數可以內聯覆蓋設定（仍會疊在你原有的 opencode.json 之上）。適合腳本、CI、一次性任務。

**createOpencodeClient()——連上既有引擎。**

```ts
import { createOpencodeClient } from "@opencode-ai/sdk"

const client = createOpencodeClient({ baseUrl: "http://localhost:4096" })
```

不啟動任何東西，純客戶端。日常已經開著 OpenCode 的開發者、或要接第 3 章那種獨立埠測試場的場景用這個。外掛資源包裡的 `client` 就是它的一個實例（第 7 章）。

## 16.2 responseStyle 陷阱：預設不是 data

建立客戶端的選項裡藏著新手第一大坑〔文件〕：

| 選項 | 預設 | 意義 |
|------|------|------|
| `responseStyle` | `"fields"` | 回傳物件帶 `data`／`error`／`response` 三個欄位 |
| `throwOnError` | `false` | HTTP 錯誤不丟例外 |
| `parseAs` | `"auto"` | 回應解析方式 |

組合起來的意思是：**呼叫失敗不會爆例外**，你得自己檢查 `result.error`；而成功結果藏在 `result.data` 裡。想要「直接拿值、錯了就丟」的直覺風格，明確指定：

```ts
const client = createOpencodeClient({
  baseUrl: "http://localhost:4096",
  responseStyle: "data",
  throwOnError: true,
})
```

本書後續範例都用這組直覺配置。文檔範例則多為預設風格（`result.data.xxx`），閱讀時留意兩種寫法的切換。

## 16.3 型別即文件

SDK 的全部型別由伺服器的 OpenAPI 規格自動生成〔文件〕——第三冊附錄 A 整理過的那份規格，就是這些 TypeScript 型別的源頭。這給你三層保證：

1. 編輯器補全的方法簽名＝當下安裝版本的真實行為
2. 第三冊教過的任何端點，SDK 都有對應方法，命名規律是「域．動作」：`session.list()` 對應 `GET /session`
3. 版本升級後型別有變，編譯期就知道——不用等執行期炸雷

## 16.4 API 地圖速覽

十個域，完整對照表收在本書附錄 B：

| 域 | 代表方法 | 對應第三冊章節 |
|----|----------|----------------|
| global | `health()` | ch14 健康檢查 |
| app | `log()`、`agents()` | ch19 日誌系統 |
| project／path | `list()`、`current()`、`get()` | ch5 專案骨架 |
| config | `get()`、`providers()` | ch8 設定引擎 |
| session | 二十餘法，見 16.5 | ch15 Session API |
| find／file | `text()`、`files()`、`symbols()`、`read()`、`status()` | ch15 檔案域 |
| tui | 九法遙控介面 | ch17 控制通道 |
| auth | `set()` | ch7 認證 |
| event | `subscribe()` | ch16 SSE |

## 16.5 session 域：二十餘法一覽

建造者最常用的家族，按生命週期記：

- **建與毀**：`create()`、`delete()`、`update()`
- **讀**：`list()`、`get()`、`children()`（子會話樹！）、`messages()`、`message()`
- **派工**：`prompt()`（同步等回覆）、`command()`、`shell()`
- **控制**：`abort()`、`init()`（生成 AGENTS.md）
- **時間旅行**：`revert()`、`unrevert()`（第三冊第 12 章的快照機制從外部操作）
- **分享與摘要**：`share()`、`unshare()`、`summarize()`

其中 `prompt()` 有個關鍵選項 `noReply: true`——只注入內容不觸發 AI 回覆。往會話裡塞上下文而不打斷當前任務，就靠它〔文件〕。

## 16.6 最小可用腳本

串起本章所學，一段「健康檢查＋列最近會話」的完整程式：

```ts
import { createOpencode } from "@opencode-ai/sdk"

const opencode = await createOpencode({ port: 4096 })
try {
  const health = await opencode.client.global.health()
  console.log("版本：", health.data.version)
  const sessions = await opencode.client.session.list()
  for (const s of sessions.data.slice(0, 5)) {
    console.log(s.id, s.title ?? "(無題)")
  }
} finally {
  opencode.server.close()
}
```

注意預設 responseStyle 下每個結果都要過一道 `.data`——再次提醒 16.2 的選擇。

## 本章摘要

- `createOpencode()` 起新引擎（腳本／CI），`createOpencodeClient()` 連舊引擎（日常）
- 預設 `responseStyle: "fields"` 且不丟例外——結果取 `.data`、錯誤查 `.error`，或改用 data＋throwOnError
- 型別由 OpenAPI 生成，編譯期即相容性檢查
- 十域 API 面；session 家族二十餘法含 children/revert/noReply 注入
- 附錄 B 有全量方法×HTTP 對照

## 下章預告 {.unnumbered .unlisted}

地基打好，下一章蓋樓：完整的自動化腳本——批次會話、結構化輸出（json_schema 強制模型吐 JSON）、以及把第三冊的 revert 機制變成腳本裡的撤銷鍵。

## 延伸資源 {.unnumbered .unlisted}

- SDK 文檔：<https://opencode.ai/docs/sdk/>
