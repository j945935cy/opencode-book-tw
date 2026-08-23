# 第 14 章　受限網路：代理、憑證與離線

理想環境裡 OpenCode 直連供應商 API；企業現實裡，中間隔著公司代理、自簽憑證與防火牆。這一章處理三種受限場景的標準解法——它們全是環境變數層級的事，設定一次終身受用。

## 14.1 公司代理：三個變數

OpenCode 遵循標準代理環境變數〔文件〕：

```bash
export HTTPS_PROXY=https://proxy.example.com:8080   # 建議
export HTTP_PROXY=http://proxy.example.com:8080     # 備用
export NO_PROXY=localhost,127.0.0.1                 # 必要！
```

**NO_PROXY 是生死線**。第三冊的核心架構在此現形：TUI 本來就要連本機 HTTP 伺服器。若不把 localhost 排除在代理之外，本機流量也被送去公司代理——輕則慢，重則路由迴圈直接掛掉〔文件〕。官方用 Caution 級別強調這一條。

代理需要帳密認證時，把憑證寫進 URL：

```bash
export HTTPS_PROXY=http://user:pass@proxy.example.com:8080
```

但硬編碼密碼是紅線——放 shell profile 或秘密管理器注入。NTLM／Kerberos 這類企業認證超出標準變數的能力範圍，官方建議改用支援該認證的 LLM Gateway 中轉〔文件〕。

## 14.2 自訂 CA：自簽憑證環境

企業用內部 CA 簽 HTTPS 憑證時，Node 會不認帳。一行解法〔文件〕：

```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem
```

對代理連線與直連 API 都生效——同一個變數同時治好「連不上供應商」和「連不上公司代理」兩種症狀。

## 14.3 排障決策樹

網路類問題按此順序收斂：

1. **引擎活著嗎？** curl http://127.0.0.1:4096/global/health 通＝本地無罪，問題在外連
2. **外連走對路了嗎？** env | grep -i proxy 核對三變數；NO_PROXY 含 localhost 嗎？
3. **憑證過關了嗎？** 報 self-signed certificate 錯＝NODE_EXTRA_CA_CERTS 沒設或路徑錯
4. **還不通？** --print-logs 看 logfmt 日誌裡的外連錯誤（第三冊取證法）
5. **全公司只有你不通？** 反過來查：是不是你漏了大家都有的一條 profile 設定

## 14.4 離線半離線策略

嚴格斷網的環境（氣隔網路）跑不了雲端模型，但 OpenCode 的本地部分照樣有價值：

- **--pure 啟動**：跳過外掛安裝的聯網需求
- **本地 MCP 工具**：MCP 是本機程序（第四冊），不依賴外部網路——檔案檢索、資料庫查詢類工具照常運作
- **db/匯出/統計**：第 3 章與第 18 章的資產操作全離線可用

半離線（僅白名單出網）最常見：請網管放行供應商 API 網域＋opencode.ai（Zen、分享、模型清單）＋GitHub，其餘走代理。白名單清單本身就是一份合規文件，比「全開」好談判得多。

## 14.5 團隊落地：一份 env 模板

```bash
# company-net.env — 新人環境腳本 source 之
export HTTPS_PROXY=https://proxy.example.com:8080
export NO_PROXY=localhost,127.0.0.1
export NODE_EXTRA_CA_CERTS=/etc/ssl/company-ca.pem
export OPENCODE_SERVER_PASSWORD=...   # 對外暴露時才需要
```

連同第 2 章的版本釘選、第 6 章的 server 區塊，湊成新人 Day 1 的完整環境包——這正是第五篇 rules 分層的前奏。

## 本章摘要 {.unnumbered .unlisted}

- 標準三變數：HTTPS_PROXY／HTTP_PROXY／NO_PROXY；localhost 不排除會迴圈打結
- 帳密進 URL 但不進版控；NTLM/Kerberos 改走 LLM Gateway
- NODE_EXTRA_CA_CERTS 一行吃下自簽 CA，代理與直連通吃
- 五步排障從本機往外收斂；logfmt 取證法全程通用
- 氣隔環境仍有價值：--pure＋本地 MCP＋資產操作；半離線走白名單

## 下章預告 {.unnumbered .unlisted}

管線通了，接著立規矩。第五篇組織工程化從 AGENTS.md 開始：rules 的分層機制如何讓「團隊規範」成為每個會話的自動前提。

## 延伸資源 {.unnumbered .unlisted}

- Network 文檔：<https://opencode.ai/docs/network/>
