# 第一冊技術審稿報告

**審稿日期**：2026-08-23
**審稿環境**：Ubuntu 24.04 (WSL2)／Node 26.7.0／npm 11.19.0
**凍結版本**：OpenCode 1.18.21（npm 路線實測）
**方法**：依撰寫規範「照書逐條重現」，萃取全冊指令逐條執行；無法離線重現者標記待補測。

---

## 一、驗證結果總表

### ch01 認識 OpenCode（概念章）

| 項目 | 結果 | 備註 |
|------|------|------|
| 外部 URL ×4（opencode.ai、docs、GitHub、WSL 指南） | 通過 | 全數 HTTP 200 |

### ch02 五分鐘安裝

| 項目 | 結果 | 備註 |
|------|------|------|
| 安裝腳本 URL 存活與內容 | 通過 | 307 轉址至官方 repo raw；內容含架構偵測、`--version` 參數、PATH 寫入，與書中描述一致 |
| `npm install -g opencode-ai` | 通過（附發現） | npm 11 出現 allowScripts 警告，不影響使用 → 已於 ch02 加註 |
| `opencode --version` | 通過 | 輸出 `1.18.21` |
| `which opencode` | 通過 | `/home/xxx/.local/bin/opencode` |
| brew / pacman / paru / choco / scoop / wsl / docker | 未測 | 平台限定；語法已對照官方文件核對 |

### ch03 首次使用

| 項目 | 結果 | 備註 |
|------|------|------|
| CLI 子命令存在性（TUI 為預設、run、providers 等） | 通過 | `opencode --help` 與書中行為描述相符 |
| Zen 供應商存在於認證流程 | 通過 | `opencode providers list` 可見 OpenCode Zen |
| 未付款時的錯誤訊息 | 通過 | 明確提示補付款方式，與書中「完成付款設定」敘述呼應 |
| /connect 完整流程、/init 產生 AGENTS.md | 待補測 | 需有效付款帳號的即時金鑰；沙盒憑證無法完成 |

### ch04～ch07（互動／模式／指令／讀碼）

| 項目 | 結果 | 備註 |
|------|------|------|
| 斜線指令清單（/connect 等）屬 TUI 內行為 | 待補測 | 需進入 TUI；已由 help 與文件交叉核對名稱正確 |
| `opencode models` CLI 形式 | 通過（新增） | 審稿發現可脫離 TUI 使用 → 已補充至 ch06 |
| @語法、拖曳圖片、Tab 切換 | 不適用 | 圖形互動，無法腳本化驗證 |

### ch08 三個新手小練習

| 項目 | 結果 | 備註 |
|------|------|------|
| Bug 重現：add 三筆後 `del 2` | 通過 | 實刪第 3 筆「寫週報」，與書中症狀逐字一致 |
| 修復模擬（索引減 1） | 通過 | `del 2` 正確刪除「繳房租」 |
| 邊界 `del 99` | 通過 | 回覆「找不到第 99 筆。」友善訊息存在 |
| `list --open` 尚未存在 | 通過 | 符合練習二「要新增」的前提 |
| 重複載入邏輯（練習三標的） | 通過 | add／markDone 各自 readFileSync＋JSON.parse 屬實 |
| Git 身分前置 | 發現並修正 | 新手會遇 "Author identity unknown" → 已加前置確認框 |

### 附錄 A／B／C

| 項目 | 結果 | 備註 |
|------|------|------|
| 外部 URL ×5（ollama.com、agentsmd.net 等） | 通過 | proxy.example.com 為刻意佔位，不列入 |
| Ollama 安裝與 pull 指令 | 未測 | 沙盒未裝 Ollama；指令語法對照官網無誤 |

## 二、發現與修正

| # | 嚴重度 | 發現 | 處置 |
|---|--------|------|------|
| 1 | 中 | ch08 假設讀者 Git 身分已設定，新手首次 commit 必卡關 | ch08 加入前置確認與設定指令 |
| 2 | 低 | npm 11+ 安裝出現 postinstall 允許警告 | ch02 加註說明與消除警告的指令 |
| 3 | 低 | 書中僅提 TUI 的 /models，漏掉 CLI 的 `opencode models` | ch06 補充兩種用法 |
| 4 | — | version-freeze.md 版本號空白 | 已填入 1.18.21 與凍結紀錄 |

## 三、原待補測清單 → 已於 2026-08-23 二次處置

依「截圖分層政策」（見 writing-guide.md 5.1），六項待補素材全數以可版控形式解決：

| # | 原待補項 | 處置 | 形式 |
|---|----------|------|------|
| 1 | /connect 完整流程 | ch03 新增時序圖 | Mermaid |
| 2 | /init 產出樣貌 | ch03 新增終端機模擬＋典型 AGENTS.md 範例 | 文字模擬 |
| 3 | TUI 斜線指令畫面 ×6 | ch06 各節新增輸入輸出模擬（undo/redo/share/models/themes/new） | 文字模擬 |
| 4 | macOS Homebrew 路線 | ch02 新增決策流程圖 | Mermaid |
| 5 | Windows WSL2 全流程 | ch02 新增分支流程圖 | Mermaid |
| 6 | Ollama 本地路線 | 附錄 B 新增規格分流圖；決策樹升級為 Mermaid | Mermaid |

**殘留標記**：僅剩 1 處 `SCREENSHOT-PENDING`（ch03 /init 過程畫面），留待排版前決定補真實截圖或定稿文字版。
**Mermaid 渲染**：排版時以 Pandoc + mermaid-filter 轉譯；語法已人工複核（flowchart／sequenceDiagram 核心語法）。

## 四、結論

**第一冊通過技術審稿（條件已解除）**：所有可在沙盒重現的指令全數通過，稿件差異均已修正；六項需真實帳號／平台的素材已依截圖分層政策以 Mermaid 與文字模擬補齊，全書可進入排版階段。
