# 第 13 章：IDE 整合

終端機是 OpenCode 的主場，但多數開發者的主戰場是 IDE。感謝第 2 章講過的主從式架構，IDE 整合不是「另一個工具」，而是同一顆伺服器引擎的另幾種殼。本章盤點三條整合路線的安裝、核心體驗與選型建議。

## 13.1 VS Code 與 Cursor

**安裝**

在 VS Code 擴充套件市集搜尋 OpenCode 安裝官方外掛即可；Cursor 相容 VS Code 外掛體系，同樣方式安裝。

**核心體驗：分割視圖**

招牌功能是編輯器內嵌的分割視圖（以快速鍵喚起）：左側是你的程式碼，右側是代理會話。AI 的每一步修改即時以 diff 形式出現在左側，接受或拒絕一目了然。

```text
+---------------------------+---------------------------+
|  login.tsx                |  OpenCode                 |
|                           |                           |
|  - const [loading, ...]   |  已修改 login.tsx          |
|  + const [busy, setBusy]  |  原因：語意更清楚，        |
|    ...diff 高亮...         |  並同步更新了三處引用      |
|                           |                           |
|  [接受] [拒絕]             |  下一步：跑測試驗證         |
+---------------------------+---------------------------+
```

**與 TUI 的關係**

兩者共用同一份會話資料：上午在終端機開的除錯會話，下午打開 IDE 外掛接著聊，脈絡完整延續。這是主從式架構的直接紅利。

**什麼時候用 IDE、什麼時候回終端機**

- 需要盯著逐行 diff、邊看邊改的細緻工作 → IDE 分割視圖。
- 長任務批次執行、腳本自動化、遠端伺服器作業 → 終端機／CLI。

## 13.2 JetBrains 系列

IntelliJ IDEA、PyCharm、WebStorm 等 JetBrains 家族透過官方外掛接入，安裝路徑同樣是外掛市集搜尋 OpenCode。

體驗要點：

- 內嵌工具視窗承載完整會話介面，與 IDE 的 VCS、終端機面板並列。
- 對 JetBrains 慣用的使用者來說，最大價值是不用離開熟悉的視窗佈局。
- diff 審查沿用 JetBrains 原生比對檢視，操作習慣無縫銜接。

JetBrains 外掛的功能節奏通常略慢於 VS Code 版本發布，重度依賴最新功能的讀者可以同時保留 TUI 作為補位。

## 13.3 Neovim 與 Emacs：ACP 協定

Vim／Emacs 陣營走的是標準化路線——ACP（Agent Client Protocol）。OpenCode 內建 ACP 伺服器模式：

```bash
opencode acp
```

支援 ACP 的編輯器外掛（如 Neovim 社群的 CodeCompanion、Emacs 的 gptel 系生態）以客戶端身分連上，獲得與其他前端同級的代理能力。

ACP 路線的意義超過「多一種整合」：它把「編輯器 ↔ 代理」的介面變成公開標準，任何新編輯器只要實作客戶端就能接入任何支援 ACP 的代理。這正是開源生態的典型打法——用協定鎖定自由，而不是用產品鎖定使用者。

**選型速記表**

| 你主要用 | 推薦路線 | 一句話理由 |
|----------|----------|------------|
| VS Code / Cursor | 官方外掛 | 分割視圖體驗最成熟 |
| JetBrains 系列 | 官方外掛 | 原生 diff 檢視、零適應成本 |
| Neovim / Emacs | ACP | 保持你的設定與哲學不動搖 |
| 純終端機派 | TUI 本尊 | 根本不需要這一章 |

## 本章摘要 {.unnumbered .unlisted}

- 主從式架構讓 IDE 外掛只是「另一個殼」；所有前端共用同一份會話狀態。
- VS Code／Cursor 的分割視圖是最成熟的圖形化體驗，diff 即時可見。
- JetBrains 外掛重用原生比對檢視，適合 IntelliJ 系重度使用者。
- Neovim／Emacs 走 ACP 公開協定（`opencode acp`），協定層的開放確保不被任何產品綁架。
- 圖形化盯 diff、終端機跑長活，兩者互補而非互斥。

## 下章預告 {.unnumbered .unlisted}

配備齊全，從第四章起進入真正的戰場。第十四章實戰首課：接到一個陌生程式碼庫，如何在半小時內建立足夠動手改碼的理解——explore 代理的偵察學。

## 延伸資源 {.unnumbered .unlisted}

- 官方文件〈IDE Integrations〉：<https://opencode.ai/docs/ide/>
- ACP 規格：<https://agentclientprotocol.com/>
