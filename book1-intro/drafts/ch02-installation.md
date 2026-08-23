# 第 2 章：五分鐘安裝

> **本章學習目標**
>
> - 在 macOS、Linux 或 Windows（WSL）上完成 OpenCode 安裝
> - 用 `opencode --version` 驗證安裝成功
> - 學會看懂三種最常見的安裝失敗訊息並自行排除
>
> **預估閱讀時間**：10 分鐘
> **實作時間**：約 5 分鐘（不含 WSL 安裝）

---

## 2.1 macOS 安裝

macOS 是本書推薦的主要示範環境，安裝方式有兩種，擇一即可。

### 方式一：Homebrew（建議）

先確認你的機器上有 Homebrew（macOS 的事實標準套件管理器）：

```bash
brew --version
```

有輸出版本號就直接安裝：

```bash
brew install anomalyco/tap/opencode
```

這裡刻意使用 OpenCode 官方維護的 tap，而不是 Homebrew 官方倉庫的 `brew install opencode`。原因很簡單：官方 tap 由開發團隊直接推送更新，版本最新；官方倉庫的公式由 Homebrew 團隊維護，更新頻率較低。對一個迭代很快的工具來說，跟緊上游比較不吃虧。

### 方式二：安裝腳本

沒有 Homebrew、或不想裝套件管理器的人，一行搞定：

```bash
curl -fsSL https://opencode.ai/install | bash
```

腳本會偵測你的 CPU 架構（Apple Silicon 或 Intel），下載對應的執行檔放到你的 PATH 裡。

> **注意**：把網路上的腳本直接餵給 bash 執行前，習慣上應該先看過內容。想檢查的話，先用瀏覽器打開 `https://opencode.ai/install` 掃一眼再執行。

## 2.2 Linux 安裝

Linux 的選擇最多，同樣擇一即可。

### 通用方式：安裝腳本

與 macOS 相同的一行指令，支援主流發行版與 x86_64／ARM64 架構：

```bash
curl -fsSL https://opencode.ai/install | bash
```

### Arch Linux 使用者

```bash
sudo pacman -S opencode           # 官方倉庫（穩定版）
paru -S opencode-bin              # AUR（最新版，需已安裝 paru）
```

### 其他發行版（Ubuntu／Debian／Fedora）

使用上面的安裝腳本即可；或透過 Node.js 生態系安裝（見下方「通用備援」）。

### 通用備援：npm

任何平台只要有 Node.js 18 以上版本，都能用套件管理器安裝：

```bash
npm install -g opencode-ai        # npm
bun install -g opencode-ai        # Bun
pnpm install -g opencode-ai       # pnpm
yarn global add opencode-ai       # Yarn
```

## 2.3 Windows 安裝

Windows 有兩條路：WSL2（本書強烈建議）與原生安裝。

### 建議路線：WSL2 + Ubuntu

OpenCode 的完整功能在 Linux 環境下表現最好。微軟官方的 WSL 安裝只需在 PowerShell（以系統管理員員執行）輸入：

```powershell
wsl --install
```

完成後重新開機，首次進入 Ubuntu 會要求你設定使用者名稱與密碼。之後在 Ubuntu 視窗內，就照 2.2 節的 Linux 流程安裝。

> **注意**：WSL 內與 Windows 是兩個獨立環境。OpenCode 要裝在「WSL 裡面」，不是 Windows 的 PowerShell 裡。判斷方法很簡單：你是在 Ubuntu 視窗（提示符長得像 `user@machine:~$`）還是 PowerShell（提示符像 `C:\Users\xxx>`）？

### 原生路線：不透過 WSL

如果公司政策或個人偏好不允許 WSL，也有原生選項：

```powershell
choco install opencode            # Chocolatey
scoop install opencode            # Scoop
npm install -g opencode-ai        # Node.js
```

原生方式可用，但部分 TUI 繪圖效果與 Unix 工具鏈整合不如 WSL 完整。遇到問題時，官方文件的第一建議永遠是「改用 WSL」。

### Docker 路線

想在隔離環境試用、或不想污染主機的人：

```bash
docker run -it --rm ghcr.io/anomalyco/opencode
```

## 2.4 驗證安裝成功

打開你的終端機（第 1 章 1.3 節挑的那支），輸入：

```bash
opencode --version
```

看到版本號輸出（例如 `1.x.x`）就是成功了。順手確認一下執行檔位置：

```bash
which opencode                    # macOS / Linux / WSL
where.exe opencode                # Windows 原生
```

把實際輸出的版本號記到 `docs/version-freeze.md` 對照的筆記裡——本書所有範例都以你凍結的這個版本為準。

### 常見錯誤排解

| 錯誤訊息 | 原因 | 解法 |
|----------|------|------|
| `command not found: opencode` | 執行檔不在 PATH | 重開終端機；仍失敗則檢查 shell 設定檔（`~/.zshrc` 或 `~/.bashrc`）是否包含安裝目錄 |
| `permission denied` | 執行檔沒有執行權限（常見於手動下載） | `chmod +x $(which opencode)` |
| `EACCES` npm 全域安裝錯誤 | npm 全域目錄權限不足 | 改用安裝腳本路線，或設定 npm prefix 到使用者目錄 |
| 下載中斷／逾時 | 網路不穩或需代理伺服器 | 設定 `https_proxy` 環境變數後重試 |

---

## 本章摘要

- macOS 建議用官方 tap 的 Homebrew 安裝；Linux 用安裝腳本或 pacman；Windows 首選 WSL2。
- npm 生態系是全平台通用備援。
- 安裝後用 `opencode --version` 驗證，並記錄版本號作為本書範例的凍結基準。
- 四大常見錯誤：PATH 沒吃到、執行權限、npm 權限、網路代理。

## 下章預告

工具裝好了，但還沒有大腦。第 3 章帶你完成首次啟動：接上模型（/connect）、讓 OpenCode 認識你的專案（/init 與 AGENTS.md），並完成你的第一次對話。

## 延伸資源

- 官方安裝文件：<https://opencode.ai/docs>
- WSL 安裝指南：<https://learn.microsoft.com/windows/wsl/install>
- Homebrew：<https://brew.sh>
