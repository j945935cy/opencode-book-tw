# 第 19 章　Windows/WSL：標準化作業環境

本系列撰寫環境就是 Windows＋WSL——四冊書的每一段實測都跑在這個組態上。這一章把它整理成團隊可直接複製的標準作業環境：為什麼推薦 WSL、三種混合架構、以及跨檔案系統的效能地雷。

## 19.1 為什麼是 WSL

OpenCode 能直接跑在 Windows，但官方明言 WSL 體驗最佳〔文件〕。理由三條：檔案系統效能、完整終端支援、與 OpenCode 依賴的開發工具鏈相容。第 6 章已經引用過同一建議的具體案例——`opencode web` 在 WSL 裡跑而非 PowerShell。

安裝兩步〔文件〕：

```bash
# 1. 依微軟指南裝好 WSL 後，在 WSL 終端：
curl -fsSL https://opencode.ai/install | bash
```

設定與會話資料住在 WSL 側 `~/.local/share/opencode/`〔文件〕——記住這點，備份策略才不會找錯目錄。

## 19.2 三種混合架構

**架構一：純 WSL（最簡）。** 專案放 WSL 檔案系統（~/code/），一切在 WSL 內完成。官方 tip 明說這是最順滑的路〔文件〕。

**架構二：WSL 伺服器＋桌面 App／Web 客戶端。**

```bash
# WSL 側
OPENCODE_SERVER_PASSWORD=secret opencode serve --hostname 0.0.0.0 --port 4096
```

桌面 App 或 Windows 瀏覽器連 http://localhost:4096〔文件〕。localhost 不通時用 WSL 的 IP（WSL 內 hostname -I 查詢）。--hostname 0.0.0.0 必配密碼——官方 Caution 原文級別的提醒。

**架構三：跨檔案系統開發。** 專案留在 Windows 磁碟，從 /mnt/c/... 存取〔文件〕。可行但有代價——見下節。

## 19.3 /mnt/c 的效能稅

Windows 檔案系統掛載在 /mnt/c、/mnt/d〔文件〕。但 9P 協定的跨界 IO 很慢：git status、grep、glob 在大倉庫上可能慢數倍到數十倍。決策規則：

| 情況 | 放哪 |
|------|------|
| 新專案、可遷移 | WSL 檔案系統（~/code/） |
| 必須留在 Windows（如 C#/.NET 工作負載、Office 相鄰檔案） | /mnt/c，接受搜尋類操作變慢 |
| 本書出版流程的實例 | 書稿在 WSL 原生 FS；GPB 上傳暫存與瀏覽器自動化在 /mnt/c |

第三種是我們的真實經驗：把「需要跨界」的部分（給 Windows Chrome 讀的上傳檔、PowerShell 腳本）集中在 /mnt/c/Users/jack/ 一個目錄，其餘全留 WSL 側——跨界次數最小化。

## 19.4 團隊標準化清單

```text
□ WSL2 安裝並設為預設版本
□ OpenCode 裝在 WSL 內（install 腳本），釘選團隊版本
□ 專案放 ~/code/；確需 /mnt/c 時知會效能影響
□ VS Code 裝 WSL 擴充，Remote-WSL 模式搭配 OpenCode〔文件〕
□ 第 14 章環境包（proxy/CA/npmrc）寫進 shell profile
□ 備份目標：WSL 側 ~/.local/share/opencode/
```

## 19.5 跨界除錯心法

WSL 環境特有的症狀速查：

- **localhost 不通**：WSL2 NAT 網路特性，改用 hostname -I 的 IP 或啟用 mirrored 網路模式
- **權限行為怪異**：/mnt/c 下 chmod 不生效（DrvFs 限制）；auth.json 的 600 保護在原生 FS 才有意義
- **路徑分隔線炸裂**：外掛裡手寫 \ 或 / 都要改成 path.join（第四冊 ch3 的提醒在此最常兌現）
- **瀏覽器打不開 Web**：WSL 內起服務、Windows 側開 http://localhost:port 通常自動轉發；不轉發就用 WSL IP

## 本章摘要

- WSL 是官方推薦的 Windows 使用方式：效能、終端、工具鏈三贏
- 三架構：純 WSL 最順、serve+App/Web 混合要配密碼、跨 FS 開發有性能稅
- 跨界集中管理：把必須跨界的檔案收攏一處，最小化 9P 往返
- 六項標準化清單直接進新人手冊
- 四症狀速查涵蓋 localhost、chmod、路徑、Web 轉發

## 下章預告 {.unnumbered .unlisted}

所有零件到齊。終章把二十章收攏成一個框架——AI 工程化成熟度五級模型，然後向整個系列告別。

## 延伸資源 {.unnumbered .unlisted}

- Windows (WSL) 文檔：<https://opencode.ai/docs/windows-wsl/>
