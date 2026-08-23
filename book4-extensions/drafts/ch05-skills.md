# 第 5 章　Agent Skills：讓代理自己翻說明書

指令是你按了才生效；Skills 是代理看到任務時「想起來」去翻的參考手冊。你把領域知識寫成 SKILL.md，OpenCode 只把技能清單（名字加描述）放進系統提示，等代理判斷需要時才呼叫 `skill` 工具載入全文。這個「先給目錄、按需借書」的設計，讓你可以堆幾十份專業知識而不撐爆上下文。

## 5.1 放哪裡、怎麼被發現

一個技能一個資料夾，資料夾裡一份 `SKILL.md`〔文件〕。搜尋位置共六處：

```
.opencode/skills/<名>/SKILL.md          # 專案
~/.config/opencode/skills/<名>/SKILL.md # 全域
.claude/skills/<名>/SKILL.md            # 專案（Claude 相容）
~/.claude/skills/<名>/SKILL.md          # 全域（Claude 相容）
.agents/skills/<名>/SKILL.md            # 專案（通用代理相容）
~/.agents/skills/<名>/SKILL.md          # 全域（通用代理相容）
```

後四格是刻意設計的相容層——Claude Code 或其他支援 SKILL.md 慣例的工具的既有技能，OpenCode 直接認。發現機制還有一個細節：專案層路徑會從當前工作目錄**向上走到 git 工作樹根**，沿途每一層的技能都算數〔文件〕——monorepo 裡子目錄自帶技能是可行的。

本書撰寫環境的快取裡就有官方隨附樣本〔實測〕：`~/.cache/opencode/skills/` 下躺著 `security-research` 與 `security-review` 兩份技能，連工具二進位（`bin/rg`）都備好了。

## 5.2 frontmatter 規格

```markdown
---
name: release-captain
description: 建立一致性版本發布與變更日誌。當要打 tag 發版或整理 changelog 時使用。
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
---
## 我做什麼
- 從合併的 PR 彙整發布說明
- 建議版本號跳升
- 給出可複製的 gh release create 指令

## 何時用我
準備帶版本的發布時。版本規則不清楚就先問。
```

欄位規則〔文件〕：

- `name`：必填，1–64 字元，小寫英數字加單層連字號（正則 `^[a-z0-9]+(-[a-z0-9]+)*$`），**且必須等於資料夾名**
- `description`：必填，1–1024 字元——這是代理決定要不要載入的唯一線索，寫清楚「做什麼」與「何時用」
- `license`、`compatibility`：選填字串
- `metadata`：選填的字串對字串表，自由標註

frontmatter 之後的內文完全自由格式。實務上「我做什麼／何時用我」兩段式被證明好用：前者讓代理知道能期待什麼，後者降低誤觸發。

## 5.3 注入與載入的機制

代理的系統提示裡會出現一段 `<available_skills>` 清單，每筆只有名字與描述〔文件〕：

```
<available_skills>
  <skill>
    <name>release-captain</name>
    <description>建立一致性版本發布與變更日誌…</description>
  </skill>
</available_skills>
```

代理認為相關時呼叫 `skill({ name: "release-captain" })`，全文才進上下文。所以 description 寫得好壞直接決定技能的命中率——把它當成搜尋引擎的網頁標題來寫，而不是內部代號。

## 5.4 權限：誰准用哪些技能

技能可能含敏感流程，OpenCode 用模式比對的權限面控制〔文件〕：

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

- `allow`：直接可載入
- `deny`：從清單隱藏、請求直接拒絕
- `ask`：每次載入前跳權限確認

萬用字元支援前綴匹配。也可以在自訂代理的 frontmatter 裡覆蓋（`permission.skill`），或在 `opencode.json` 對內建代理覆蓋；要整個關掉技能功能則在代理設定寫 `tools: { skill: false }`——連 `<available_skills>` 段落都不會出現〔文件〕。

## 5.5 實作：把出版流程做成技能

本書撰寫環境的真實技能〔實測〕就是現成教材：`ebook-publish` 技能把「Google Play Books 上架」這套十幾步的工作流寫成一個 SKILL.md——前置條件（Chrome 除錯埠）、架構圖、鐵律（密碼與發布鍵一律人工）、腳本清單。之後任何會話只要提到上架，代理就知道該載入它並照著走。

輪到你的練習：把團隊裡那份「沒人讀的 wiki 頁」改造成技能。挑選標準有三——多步驟、有明確觸發情境、步驟間有順序依賴。符合的都值得做成 SKILL.md；只是查一次的資料留給普通提示就好。

## 5.6 疑難排解

技能沒出現在清單裡？照官方檢查單走〔文件〕：

1. `SKILL.md` 五個字母全大寫
2. frontmatter 有 `name` 與 `description`
3. 名稱在所有位置間唯一
4. 沒被 `deny` 權限擋掉

## 本章摘要 {.unnumbered .unlisted}

- 六處搜尋路徑（opencode／claude／agents 慣例 × 專案／全域），專案層向上走到工作樹根
- name 必須符合正則且等於資料夾名；description 決定命中率
- 先注入清單、按需載入全文——上下文友善
- `permission.skill` 三態加萬用字元，可逐代理覆蓋
- 多步驟＋明確觸發情境的團隊流程最值得技能化

## 下章預告 {.unnumbered .unlisted}

指令與 Skills 都是在「餵提示」。下一章回到代理本身：frontmatter 裡的工具開關、權限面與模型綁定怎麼組合出「只能看不能跑」的審計代理、「只管測試」的守門代理——建造者視角的代理工程。

## 延伸資源 {.unnumbered .unlisted}

- Agent Skills 文檔：<https://opencode.ai/docs/skills/>
