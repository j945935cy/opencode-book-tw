# 第 12 章　外掛即套件：發布與生態

寫在 `.opencode/plugins/` 裡的外掛是「自用資產」；發布到 npm 之後才變成「生態零件」——別人一行設定就能安裝、升級、依賴。本章走完從本地到 registry 的最後一哩，並解剖一支真實生態外掛在你機器上的足跡。

## 12.1 發布三步

外掛就是普通的 npm 套件，沒有特殊儀式〔文件〕：

**第一步：package.json 寫清楚。**

```json
{
  "name": "@my-org/opencode-standup",
  "version": "1.0.0",
  "type": "module",
  "main": "dist/index.js",
  "files": ["dist"],
  "dependencies": {}
}
```

**第二步：匯出具名外掛函式。** 消費端設定裡引用的是套件名，載入後 OpenCode 會抓取模組的具名導出當作外掛——和本地檔的規則一致。

**第三步：`npm publish`。** 一般或 scoped 套件皆可。之後使用者在 `opencode.json` 或 `tui.json` 寫上：

```json
{ "plugin": ["@my-org/opencode-standup@^1.0.0"] }
```

## 12.2 版本策略：@latest 的甜蜜與陷阱

版本字串直接影響升級行為〔實測樣本〕。本書撰寫環境的 `opencode.jsonc` 與 `tui.json` 都寫著 `"oh-my-openagent@latest"`——每次啟動都拿最新版，新功能即時到位；代價是上游一改行為，你的工作流隔天就跟著變。

三種策略按穩定度排：

- `@latest`：永遠最新。個人工具、嘗鮮期適用
- 固定區間（`^1.2.0`）：吃修號更新、鎖小版本。團隊倉庫建議
- 精確釘死（`1.2.3`）：重視可重現性的 CI 或示範環境

反方向也要想：你是作者時，語意化版本是對使用者的承諾——鉤子行為改動算 breaking、加鉤子算 minor。特別是用了 `experimental.*` 鉤子的套件（第 9 章），請在 README 明寫支援的 CLI 版本區間。

## 12.3 安裝足跡解剖

使用者裝了你的套件之後，磁碟上長什麼樣？本書撰寫環境的真實樣本〔實測〕：

```
~/.cache/opencode/packages/oh-my-openagent@latest/
├── package.json
├── package-lock.json
└── node_modules/        # 套件自己的依賴樹
```

三個觀察。第一，每個外掛一個 `<名>@<版規>` 目錄，依賴不共用——你宣告的 dependencies 會完整落在自己的樹裡，不必擔心與其他外掛衝突。第二，目錄由 Bun 在啟動時自動維護，使用者不需要手動 npm install。第三，外掛若需要持久資料，慣例是放 `~/.local/share/opencode/storage/<外掛名>/`——oh-my-openagent 就有一個同名資料夾，與書中第三冊講的 storage 佈局呼應。

順帶勘誤：官方文檔把快取位置描述為 `~/.cache/opencode/node_modules/`，本機實況則是 `packages/<名>@<版>/` 形態。兩者語意相同（啟動時自動安裝的快取），但以實測形態為準。

## 12.4 本地開發的依賴管理

還沒要發布？本地外掛照樣能用外部套件：在設定目錄（專案的 `.opencode/` 或全域 `~/.config/opencode/`）放一份 package.json 列出依賴，OpenCode 啟動時會自動 bun install〔文件＋本機佐證：`~/.config/opencode/package.json` 正是這個機制，裡面釘著 `@opencode-ai/plugin`〕。之後外掛檔案裡直接 import 即可。

型別體驗靠它：

```ts
import type { Plugin } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin"
```

`PluginInput.client` 就是完整的 SDK 客戶端——外掛內部呼叫 API 不必自己起伺服器，第五篇的 SDK 知識全部直接可用。

## 12.5 載入順序與重複載入

多來源並存時的規則〔文件〕：全域設定 → 專案設定 → 全域 plugins 目錄 → 專案 plugins 目錄，全部依序載入、所有鉤子依序執行。同名同版的 npm 套件只載入一次；但「本地檔」與「npm 套件」即使名字相近也各自載入——除錯時留意別讓兩份相似外掛同時生效。

---

下一章起進入介面層：先做主題，再深入 TUI 外掛的完整 API 面。

## 本章摘要 {.unnumbered .unlisted}

- 外掛發布＝普通 npm 套件：具名導出＋package.json＋publish
- 版本字串決定升級節奏：@latest 嘗鮮、區間給團團隊、釘死給可重現環境
- 快取實測位於 `~/.cache/opencode/packages/<名>@<版>/`，Bun 啟動時自動安裝
- 本地開發依賴放設定目錄的 package.json；@opencode-ai/plugin 提供型別與 tool()
- 載入順序四層依序執行；同名同版去重、本地與 npm 各自載入

## 下章預告 {.unnumbered .unlisted}

配色也是擴充點。下一章拆解 theme.json 的完整格式——defs 色票、明暗雙軌、ANSI 相容與 none 透明——帶你從零做出一套屬於自己的終端機主題。

## 延伸資源 {.unnumbered .unlisted}

- 外掛文檔：<https://opencode.ai/docs/plugins/>
- 生態頁：<https://opencode.ai/docs/ecosystem/>
- Bun Shell：<https://bun.com/docs/runtime/shell>
