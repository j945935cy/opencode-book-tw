# 第 16 章　內建工具全目錄

代理的每一個動作都透過工具完成。前四冊你已經零散認識過它們；這一章做一次全點驗——十三支內建工具的職責、權限歸屬、以及三個容易被忽略的深水區（實驗 LSP 工具、apply_patch 的鉤子陷阱、ripgrep 忽略規則）。

## 16.1 全目錄速覽

| 工具 | 職責 | 權限鍵 |
|------|------|--------|
| bash | 執行 shell 命令 | bash |
| edit | 精確字串替換修改檔案 | edit |
| write | 建立或覆寫檔案 | edit |
| apply_patch | 套用 patch 檔 | edit |
| read | 讀檔（支援行範圍） | read |
| grep | 正則搜內容 | grep |
| glob | 樣式搜檔名（按修改時間排序） | glob |
| lsp（實驗） | 定義/引用/hover/呼叫階層 | lsp |
| skill | 載入 SKILL.md 全文 | skill |
| todowrite | 會話內任務清單 | todowrite |
| webfetch | 抓指定 URL 內容 | webfetch |
| websearch | Exa 驅動的網路搜尋 | websearch |
| question | 向使用者提問收選擇 | question |

預設全部啟用且不需批准；行為控制一律走 permission 三態（第四冊 ch6）。兩個分組記憶點：**edit/write/apply_patch 共享 `edit` 一個權限鍵**——管住一個等於管住所有寫入；**todowrite 對子代理預設關閉**〔文件〕，需要工人列清單得手動開。

## 16.2 三個深水區

**深水區一：lsp 工具是實驗性的。** 需要 `OPENCODE_EXPERIMENTAL_LSP_TOOL=true` 或總開關 `OPENCODE_EXPERIMENTAL=true` 才會出現〔文件〕。開啟後代理能用 goToDefinition、findReferences、hover、incomingCalls 等九種操作——從「靠 grep 猜」升級成「問語意」。搭配第 6 章的 lsp 權限與第二冊第 9 章的 LSP 配置，是大型代碼庫導航的正解。

**深水區二：apply_patch 的鉤子陷阱。** 它受 `edit` 權限管制沒問題，但寫外掛攔截時有兩個坑〔文件〕：判斷工具名要寫 `input.tool === "apply_patch"`（不是 "patch"）；它的參數不是 filePath 而是 `output.args.patchText`——路徑嵌在 patch 標記行裡（`*** Update File: src/x.ts`），相對專案根。第 8 章的 .env 保護外掛若沒處理它，就有一扇繞過的後門。

**深水區三：websearch 的供應商綁定。** 它走 Exa AI 的託管服務：僅在 OpenCode／OpenCode Go 供應商下可用，或設 `OPENCODE_ENABLE_EXA=1` 強制開啟，免 API key〔文件〕。離線環境（第 14 章）它自然失效，別排進自動化流程的依賴。

## 16.3 ignore 規則：搜尋的隱形邊界

grep/glob 底層是 ripgrep，預設尊重 .gitignore〔文件〕——node_modules 裡的東西搜不到通常是好事。要讓特定被忽略目錄重新可見，在專案根放 `.ignore`：

```
!node_modules/
!dist/
!build/
```

反直覺但好用：`.ignore` 可以「反向允許」.gitignore 排除的路徑。除錯打包產物、查依賴原始碼時臨時加上，用完刪掉。

## 16.4 工具×擴充的覆蓋全景

第四冊教的三種介入方式對內建工具各有效果，複習並對位：

| 介入方式 | 效果範例 |
|----------|----------|
| permission（軟閘） | bash: ask、mymcp_*: deny |
| 自訂工具同名覆蓋（硬換） | tools/bash.ts 換掉官方 bash |
| 外掛鉤子（生產線） | tool.execute.before 改 args、tool.definition 改描述 |
| AGENTS.md（軟引導） | 「優先用 rg 別用 grep -r」 |

四層由硬到軟。團隊治理的黃金順序：能靠 permission 解決就不要換工具實作，能靠工具解決就不要只靠提示詞——越硬的約束越不依賴模型的自覺。

## 本章摘要 {.unnumbered .unlisted}

- 十三支內建工具；edit 一鍵統管 write/apply_patch 所有寫入
- lsp 工具需實驗旗標，九種語意操作是代碼庫導航正解
- apply_patch 攔截要看 tool 名與 patchText 參數，別留後門
- websearch 走 Exa 託管：OpenCode 供應商或 OPENCODE_ENABLE_EXA=1
- ripgrep 尊重 .gitignore；.ignore 反向允許；治理順序硬先於軟

## 下章預告 {.unnumbered .unlisted}

單一倉庫的規矩齊了，最後一站是整個組織：SSO、集中政策、自架託管——下一章進入 enterprise 世界。

## 延伸資源 {.unnumbered .unlisted}

- Tools 文檔：<https://opencode.ai/docs/tools/>
