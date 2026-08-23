# 第 8 章：三個新手小練習

> **本章學習目標**
>
> - 完整走過「Plan → Build → 驗證 → 提交」的實戰循環
> - 練習一：修復一個真實的 Bug
> - 練習二：新增一個小功能
> - 練習三：重構一段重複程式碼
>
> **預估閱讀時間**：10 分鐘
> **實作時間**：約 60 分鐘

---

本章的三個練習共用同一個練習專案（本書官方範例庫的 `samples/book1-intro/ch08-exercises/`），一個一百多行、刻意埋了問題的待辦事項命令列小程式。請先取得它：

```bash
git clone https://github.com/j945935cy/opencode-book-tw.git
cd opencode-book-tw/samples/book1-intro/ch08-exercises
node todo.js list          # 先跑一次確認環境正常
```

每個練習都先在終端機該目錄下執行 `opencode`。開始前先 `git init` 並做首次提交，讓每一輪變更都可回退。

> **前置確認**：首次提交需要 Git 身分。若從未設定過，先執行（--global 之後就不必再設）：
>
> ```bash
> git config --global user.name "你的名字"
> git config --global user.email "you@example.com"
> ```

---

## 練習一：修復 Bug

### 症狀

```bash
node todo.js add "買牛奶"
node todo.js add "繳房租"
node todo.js add "寫週報"
node todo.js del 2           # 想刪掉「繳房租」（第 2 筆）
node todo.js list
```

你會發現被刪掉的是「寫週報」——**刪錯行了**，而且清單編號也跟著亂掉。

### 走黃金工作流

切到 Plan 模式：

```text
這個程式的 del 功能有 Bug：刪除第 N 筆時刪到別筆。
@todo.js
先找出原因並說明，提出最小幅度的修法，先不要動程式碼。
```

代理應該會指出經典的「使用者編號從 1 起、陣列索引從 0 起」的差一錯誤（off-by-one）。確認它的診斷聽起來有理後，切回 Build：

```text
照你的方案修正。
```

### 驗證

```bash
node todo.js del 2 && node todo.js list   # 刪掉的必須是「繳房租」
node todo.js del 99                       # 邊界：不存在的編號要給友善錯誤訊息
```

第二條驗證如果表現不佳，順手要求代理補上邊界處理——真實工作裡，測試邊界永遠是你的責任，不是代理的。

最後提交：

```bash
git add . && git commit -m "fix: 修正刪除待辦事項的差一錯誤"
```

## 練習二：新增功能

需求：**完成的事項要有完成時間標記，且 list 可以只看未完成**。

Plan 模式提案：

```text
我想加兩個相關功能：
1. done <編號> 把事項標記為完成，list 時完成的項目顯示 [x] 與完成日期
2. list --open 只顯示未完成的事項
資料儲存格式若需要調整，請考慮向下相容既有的 items.json。
提出方案。
```

特別注意「向下相容」四個字——這是在給代理圈範圍。討論定案後 Build 執行，然後完整驗證：

```bash
node todo.js add "測試項目" && node todo.js done 1 && node todo.js list
node todo.js list --open
cat items.json                             # 檢查舊資料讀取正常
```

滿意後提交，commit message 寫清楚兩個功能的行為。

## 練習三：重構

打開 todo.js 找找看——`add` 與 `done` 都各自寫了一段幾乎相同的「載入檔案、解析 JSON、處理檔案不存在」的程式碼。重複就是壞味道。

Plan 模式：

```text
@todo.js
add 和 done 有重複的載入與驗證邏輯。
請規劃重構：抽成共用函式，但對外行為必須完全不變。
列出你要動的部分與不動的部分。
```

「列出你不動的部分」這句很關鍵：逼代理明確承諾行為凍結範圍。Build 執行後的驗證方式只有一個鐵律——**把前兩個練習的所有驗證指令全部重跑一遍**。重構的驗收標準不是程式碼變漂亮，而是所有既有行為分毫未變。

```bash
git add . && git commit -m "refactor: 抽出共用的載入與驗證邏輯"
```

---

## 本章摘要 {.unnumbered .unlisted}

- 三個練習對應三種日常：修 Bug（診斷導向）、加功能（設計導向）、重構（守恆導向）。
- 共同節奏：Plan 提案並圈範圍、Build 執行、手動驗證含邊界情況、立即 commit。
- 重構的驗收＝既有驗證全數通過；「列出你不動的部分」是約束代理的有效句型。
- 完成三個練習，你就已經走完第一冊的全部核心技能。

## 下章預告 {.unnumbered .unlisted}

沒有下一章了——但有附錄。遇到安裝或使用上的疑難雜症時翻附錄 A；想零元上路翻附錄 B；快速鍵忘了就查附錄 C。祝你用得順手，我們第二冊見。

## 延伸資源 {.unnumbered .unlisted}

- 本書範例庫：<https://github.com/j945935cy/opencode-book-tw>
