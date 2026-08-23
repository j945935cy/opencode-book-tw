# 第 5 章：技能系統

每個團隊都有一些「不用寫在程式裡，但新人一定要懂」的知識：提交訊息的格式慣例、部署前的檢查清單、某個內部平台的操作步驟。傳統做法是塞在 wiki 或口耳相傳；OpenCode 的答案是技能（Skill）——一份份 Markdown 說明文件，AI 在需要時自動載入照辦。這一章講清楚規範、放置位置與載入機制，然後動手寫出你的第一支技能。

## 5.1 SKILL.md 檔案規範

一支技能就是一個資料夾加一份 `SKILL.md`，格式如下：

```markdown
---
name: commit-helper
description: 產生符合團隊規範的 git 提交訊息。涉及 commit、提交訊息時使用。
---

# 提交訊息規範

1. 格式為 `<type>: <主旨>`，type 僅限 feat / fix / refactor / docs / test / chore
2. 主旨使用繁體中文，不超過 30 字，句尾不加句號
3. 內文說明「為什麼」而非「做了什麼」，空一行後撰寫
4. 有對應 Issue 時，內文末行加上 `Refs: #編號`

## 範例

feat: 支援報表匯出 CSV

訂單組需要原始資料做月結對帳，網頁列印無法滿足，
故新增後端直出 CSV 的匯出端點。

Refs: #482
```

兩個 frontmatter 欄位都是必要欄位：

- **name**：技能識別名稱，小寫連字號格式，同時是資料夾名稱。
- **description**：最重要的欄位——它是 AI 判斷「現在該不該載入這支技能」的唯一依據。寫作要領：一句話講「做什麼」，一句話講「什麼時候用」，並把觸發關鍵詞自然埋進去（上例的「commit」「提交訊息」）。

正文就是普通 Markdown，想寫多長都可以。原則是**寫給 AI 執行的作業程序書**：步驟編號、規則明確、範例具體，避免空泛形容詞。

## 5.2 技能載入機制

技能放對位置就會生效，有兩個層級：

| 層級 | 路徑 | 生效範圍 |
|------|------|----------|
| 專案級 | `.opencode/skill/<名稱>/SKILL.md` | 只在該專案內 |
| 全域級 | `~/.config/opencode/skills/<名稱>/SKILL.md` | 所有專案 |

載入採**漸進揭露**（progressive disclosure）設計：啟動時，系統只把每支技能的 name 與 description 送給模型當索引；當對話內容命中某支描述，模型才把完整 SKILL.md 讀進來照辦。好處顯而易見——你可以養上百支技能，日常卻只付出極小的上下文成本。

版控策略建議：專案級技能放 `.opencode/skill/` 一起進 git，全隊共用同一套知識（第 19 章有完整的團隊版控策略）；個人偏好的全域技能則留在 home 目錄不進版控。

## 5.3 自訂技能入門

跟著做一次，五分鐘上線你的第一支技能。場景：要求 AI 每次修改 Python 程式碼後，自動執行專案的 lint 與測試。

**第一步：建立資料夾與檔案**

```bash
mkdir -p .opencode/skill/python-checklist
```

**第二步：撰寫 SKILL.md**

```markdown
---
name: python-checklist
description: 修改任何 .py 檔案後的品質檢查程序。涉及編輯 Python 程式碼、跑測試時使用。
---

# Python 修改後檢查程序

每次完成 .py 檔案修改後，依序執行：

1. `uv run ruff check --fix <修改的檔案>`，修正所有可自動修復問題
2. `uv run ruff format <修改的檔案>`
3. `uv run pytest tests/ -x -q`，有任何失敗立即修復後重跑
4. 三步全綠才算完成；無法修復時停止並回報，不得略過測試繼續其他工作
```

**第三步：驗證**

重啟 OpenCode（或開新會話），丟一個小修改任務給它，觀察它是否在改完檔案後主動跑 ruff 與 pytest。若沒觸發，九成是 description 寫得不夠命中——把實際任務的用詞加進描述再試。

**除錯心法**

技能沒生效時按順序檢查：路徑對不對（資料夾名等於 name？）、YAML frontmatter 格式對不對（冒號後要有空格）、description 是否含觸發詞。技能不是萬能觸發器，它是「提高 AI 做對事的機率」的工程手段；關鍵流程的強制力，搭配第 12 章的自訂指令（明確叫用）一起用。

## 本章摘要 {.unnumbered .unlisted}

- 技能＝資料夾＋SKILL.md；frontmatter 的 description 是自動觸發的唯一線索，要寫「做什麼＋何時用＋關鍵詞」。
- 專案級放 `.opencode/skill/`、全域級放 `~/.config/opencode/skills/`；漸進揭露讓大量技能幾乎零上下文成本。
- 正文寫成給 AI 的作業程序書：編號步驟、明確命令、具體範例。
- 觸發不靈先查路徑、frontmatter、關鍵詞；強制性需求搭配自訂指令使用。

## 下章預告 {.unnumbered .unlisted}

概念篇到此完結，接下來捲起袖子。第六章環境設定：多平台安裝的細節差異（含 Docker 部署）、終端機的字型與配色怎麼調，才能讓 TUI 發揮十成功力。

## 延伸資源 {.unnumbered .unlisted}

- 官方文件〈Skills〉：<https://opencode.ai/docs/skills/>
- 本系列第四冊《OpenCode 擴展開發》：技能、外掛、MCP 的深度擴充實戰
