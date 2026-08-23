# ch08 練習專案：todo-cli

《OpenCode 入門指南》第 8 章的三個練習共用本專案。程式刻意埋了一個 Bug，且缺少兩個功能，供讀者練習「修復、新增、重構」。

## 環境需求

- Node.js 18 以上（`node --version` 檢查）

## 開始前

```bash
git init
git add .
git commit -m "init: 練習起點"
```

## 可用指令

```bash
node todo.js add "事項"    # 新增
node todo.js list          # 列出全部
node todo.js done <編號>   # 標記完成
node todo.js del <編號>    # 刪除
```

## 三個練習目標

| 練習 | 任務 | 對應章節 |
|------|------|----------|
| 一 | 修復 del 的差一錯誤 | 8.1 |
| 二 | 新增 done 顯示完成時間＋ list --open | 8.2 |
| 三 | 重複的載入／驗證邏輯抽成共用函式 | 8.3 |

> 提示：done 功能已存在；練習二的重點是「顯示完成時間」與 --open 過濾。

## 已知埋點（教師／自學對照用）

1. `deleteItem()` 的索引未減 1 → 差一錯誤
2. `add` 與 `markDone` 各自重複實作載入與驗證 → 重構標的
3. 邊界情況：del 不存在編號時，錯誤訊息未提示有效範圍

測試版本：見 repo 根目錄 docs/version-freeze.md。
