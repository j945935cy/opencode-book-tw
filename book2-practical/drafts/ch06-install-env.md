# 第 6 章：安裝與環境設定

第一冊已經帶你跑過最短路徑的安裝。這一章補齊實務上會遇到的進階題目：多種安裝方式該怎麼選、版本怎麼釘住與升級、Docker 裡怎麼跑，以及——多數人忽略但體感差最多的——終端機環境本身的優化。

## 6.1 多平台安裝詳解

四種主流安裝方式的選型建議：

| 方式 | 指令 | 適合誰 |
|------|------|--------|
| 安裝腳本 | `curl -fsSL https://opencode.ai/install \| bash` | Linux／macOS 個人機，要獨立執行檔 |
| npm | `npm install -g opencode-ai` | 已有 Node 生態的開發者；Windows 首選 |
| Homebrew | `brew install opencode` | macOS 上習慣用 brew 統一管理工具的人 |
| 原始碼 | git clone 後以 Bun 建置 | 想追開發版或改原始碼的人 |

**版本管理三件事**

釘版本是團隊協作的基本功——所有成員同一版本，行為才可比較：

```bash
npm install -g opencode-ai@1.18.21
opencode --version
opencode upgrade
```

升級前先看 release notes 是好習慣：v1.x 仍在快速迭代，偶有設定欄位調整。公司專案建議在內部文件寫死基準版本；個人機想嘗鮮就另開環境測，不影響團隊基準。

**解除安裝**

`opencode uninstall` 移除程式本體並清理相關檔案。只想移除程式、保留會話歷史的話，手動刪除執行檔即可——資料庫在 `~/.local/share/opencode/`，不會跟著消失。

**Docker 部署要領**

容器中執行的核心考量只有兩個：把工作目錄掛進去、把供應商金鑰用環境變數帶進去。映像標籤以官方文件為準：

```bash
docker run -it --rm \
  -v "$PWD":/workspace -w /workspace \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  <official-image> opencode run "檢查這個專案的測試覆蓋缺口"
```

容器化最常見的場景是 CI 與一次性分析任務：環境乾淨、用完即丟。第 18 章的 GitHub 整合會回到這個模式。

## 6.2 終端環境優化

TUI 是你最長時間相處的介面，值得花十分鐘調到舒服。

**字型：裝一套 Nerd Font**

TUI 的圖示（檔案類型、狀態符號）依賴 Nerd Font 的擴充字形，沒裝的話圖示位置會出現方框或問號。JetBrainsMono Nerd Font 與 FiraCode Nerd Font 都是安全牌，裝好後在終端模擬器設定中選用它即可。

**配色：挑一個低刺激主題**

長時間使用的畫面，純黑底反而累眼。OpenCode 內建多套主題，TUI 內輸入 `/themes` 即時預覽切換；選定後寫進全域設定持久化：

```json
{
  "tui": {
    "theme": "opencentured"
  }
}
```

主題名稱以 `/themes` 清單顯示為準。挑選原則：深色底配柔和前景色、語法高亮對比適中、你半夜看著不刺眼的，就是對的主題。

**終端模擬器選擇**

OpenCode 的 TUI 對現代終端特性（真彩、連字、捲動效能）要求不低。實測體驗順序參考：

- macOS：Ghostty、iTerm2、kitty 都流暢；Terminal.app 能用但色彩與效能居末。
- Linux：kitty、Alacritty、Konsole 表現接近，擇一習慣者即可。
- Windows：Windows Terminal 為唯一推薦入口，搭配 WSL 使用（第一冊附錄有完整設定路徑）。

**最小可用清單**

如果只做三件事：裝 Nerd Font、`/themes` 換主題、確認終端是真彩模式（多數現代模擬器預設支援）。其餘等用到不順再調。

## 本章摘要 {.unnumbered .unlisted}

- 安裝方式四選一：腳本（獨立執行檔）、npm（Node 生態與 Windows）、Homebrew（macOS）、原始碼（追新版）；團隊務必釘版本，`opencode upgrade` 一鍵升級。
- 容器部署兩要素：掛工作目錄、環境變數帶金鑰；最適合 CI 與一次性任務。
- 終端優化三件事：Nerd Font 解決圖示、`/themes` 選低刺激配色、用支援真彩的現代模擬器。

## 下章預告 {.unnumbered .unlisted}

環境就緒，接著把專案「教」給 OpenCode。第七章是全書最重要的一章之一：AGENTS.md 怎麼寫才能讓 AI 第一次就做對事，以及整個 `.opencode/` 目錄如何變成團隊共用的資產。

## 延伸資源 {.unnumbered .unlisted}

- 安裝文件：<https://opencode.ai/install>
- 主題清單：TUI 內輸入 `/themes`
