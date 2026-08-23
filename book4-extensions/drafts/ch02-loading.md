# 第 2 章　載入時序與快取底盤

擴充最常見的慘案不是寫不是寫錯，而是「寫對了卻沒生效」。九成的原因藏在載入時序裡：你放的目錄優先序輸給了另一份設定、npm 套件還沒被安裝、或同名檔案被更高層覆蓋。本章把 OpenCode 的底盤完整翻出來，以後遇到「沒生效」，照著這張時序圖走一遍就能定位。

## 2.1 兩份設定檔的分工

OpenCode 讀兩份 JSON 設定〔實測〕：

- `opencode.json`（或 `.jsonc`）：**核心行為**——供應商與模型、MCP 伺服器、外掛清單、權限、代理覆蓋、自訂指令的 JSON 寫法
- `tui.json`：**終端介面偏好**——主題名稱、TUI 專屬外掛

兩份都支援 `$schema` 欄位指向官方 schema（`https://opencode.ai/config.json` 與 `https://opencode.ai/tui.json`），編輯器就能即時補全與驗錯。第二冊教過設定入門；這裡只補建造者視角：`plugin` 欄位在兩份檔案裡都可以出現，核心外掛放前者、純介面外掛放後者，職責清楚就好。

層級上，全域（`~/.config/opencode/`）先讀、專案（`<專案>/opencode.json`）後讀，後者覆蓋前者。外掛目錄的載入順序則是：全域設定宣告的外掛 → 專案設定宣告的外掛 → 全域 plugins 目錄 → 專案 plugins 目錄〔文件〕。

## 2.2 npm 外掛的去處：快取實況

在設定裡寫 `"plugin": ["oh-my-openagent@latest"]` 之後，OpenCode 會在啟動時用 Bun 自動安裝這個套件。它去哪了？官方文檔說快取在 `~/.cache/opencode/node_modules/`〔文件〕；但本書撰寫環境實際翻查到的結構是〔實測〕：

```
~/.cache/opencode/
├── bin/rg                          # OpenCode 自帶的工具二進位
├── models.json                     # 模型目錄快取
├── packages/
│   └── oh-my-openagent@latest/     # 每個外掛一個資料料夾，帶版本號
│       ├── package.json
│       ├── package-lock.json
│       └── node_modules/           # 外掛自己的依賴樹
└── skills/
    ├── security-research/          # 隨產品分發的技能也住在快取
    └── security-review/
```

重點有二。第一，每個外掛套件是**獨立目錄、獨立依賴樹**——兩個外掛依賴不同版本的同一個函式庫不會打架。第二，除錯外掛時可以直接進這個目錄看它實際被安裝的程式碼長什麼樣；懷疑安裝壞掉就整個資料夾刪掉重啟，OpenCode 會重新安裝。

## 2.3 本地外掛與依賴

放在 `.opencode/plugins/` 或 `~/.config/opencode/plugins/` 的本地外掛不經過安裝程序，啟動時直接載入〔文件〕。但它們若 import 了第三方套件（例如拿來做參數跳脫的 shescape），你需要在設定目錄放一份 `package.json` 列出依賴——OpenCode 啟動時會執行 `bun install` 把它們裝好〔文件〕。

本書撰寫環境的真實樣本〔實測〕：`~/.config/opencode/package.json` 只有一個依賴 `"@opencode-ai/plugin": "1.18.5"`，對應的 `node_modules/@opencode-ai/{plugin,sdk}` 就躺在同一層。順帶一提一個值得警惕的細節：當時 CLI 已是 1.18.21，而這份鎖定的型別套件還停在 1.18.5——本地開發用的型別與執行引擎可能存在版本偏移，寫外掛時若用到新鉤子卻編譯報錯，先升級這個依賴再找自己的毛病。

## 2.4 同名衝突的裁決規則

各擴充點對「同名」的處理不同，記錯就會鬧鬼：

- **主題**：四層覆蓋序，高層直接蓋掉低層同名主題（第 13 章詳表）
- **Skills**：全部位置一起掃描，名稱必須全域唯一，撞名會導致載入問題〔文件〕
- **自訂工具**：同名會**取代內建工具**——這是特性不是事故，第 11 章會用它做一個閹割版 bash
- **指令**：同名自訂指令**覆蓋內建指令**〔文件〕
- **外掛**：npm 同名同版只載一次；本地外掛與 npm 外掛即使名字相似也各自載入〔文件〕

## 2.5 一條通用的除錯動線

任何「擴充沒生效」，按這個順序排查：

1. 放對目錄了嗎？專案層 `.opencode/<種類>/` 必須在工作樹根，不是子目錄
2. 檔名對嗎？指令與工具的名字來自檔名；Skill 名必須等於資料夾名
3. 被蓋掉了嗎？回頭核對 2.4 的裁決規則
4. 是 npm 外掛嗎？去 `~/.cache/opencode/packages/` 看裝到了沒
5. 還不行？開 `--print-logs --log-level DEBUG` 重啟，看載入了什麼（第三冊第 19 章的 logfmt 解讀法在這裡派上用場）

## 本章摘要 {.unnumbered .unlisted}

- 核心行為住 `opencode.json`、介面偏好住 `tui.json`；全域先讀、專案後讀且後者勝
- npm 外掛由 Bun 在啟動時自動安裝，實際落在 `~/.cache/opencode/packages/<名>@<版>/`，各帶獨立依賴樹
- 本地外掛免安裝，第三方依賴靠設定目錄的 `package.json`＋啟動時 `bun install`
- 同名裁決：主題覆蓋、Skill 唯一、工具與指令可取代內建、npm 外掛同版去重
- 除錯五步：目錄→檔名→覆蓋→快取→日誌

## 下章預告 {.unnumbered .unlisted}

底盤清楚了，還缺一套儀表：怎麼知道你的外掛被載入、鉤子有沒有被觸發、事件流裡發生了什麼？下一章把建造者的三條除錯管道接好——之後二十章的每一行程式碼，你都有辦法親眼看見它的效果。

## 延伸資源 {.unnumbered .unlisted}

- 外掛文檔（含載入順序）：<https://opencode.ai/docs/plugins/>
- 設定總覽：<https://opencode.ai/docs/config/>
