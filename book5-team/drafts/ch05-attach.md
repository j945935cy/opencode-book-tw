# 第 5 章　attach：一台引擎，多個入口

第三冊講過 client/server 分離——TUI 只是伺服器的客戶端之一。這一章把這個架構用出團隊價值：`opencode attach` 讓任何終端機接管同一台引擎；mDNS 讓區網裡的引擎自己報名；一個長任務從筆電交接到桌機，會話不斷線。

## 5.1 attach：接管執行中的引擎

```bash
opencode serve --port 4096        # 終端 A：引擎起來
opencode attach http://localhost:4096   # 終端 B：接管
```

attach 接一個 URL（必填位置參數）〔實測 --help〕，開出一個完整 TUI 指向那台伺服器。兩個終端看到的會話、訊息、權限請求完全一致——因為它們本來就是同一個後端的兩張臉。

典型場景：

- **長任務交接**：筆電上派的重構任務要跑一小時，回到桌機 attach 同一位址繼續盯
- **結對除錯**：兩人兩終端接同一引擎，一人下提示一人看日誌（--print-logs 那台）
- **容器內開發**：引擎跑在 devcontainer 裡，宿主機 attach 進去

## 5.2 mDNS：讓引擎自己報名

記 IP 和埠很煩？serve 的兩個旗標〔文件＋第三冊〕：

```bash
opencode serve --mdns
# 引擎以 opencode.local 名稱在區網廣播（--mdns 開啟時 hostname 預設改為 0.0.0.0）
```

之後區網內任何機器：

```bash
opencode attach http://opencode.local:4096
```

自訂名稱用 `--mdns-domain mydev.local`。注意安全半徑：0.0.0.0 意味著**整個區網**都碰得到這台引擎——咖啡廳 Wi-Fi 上別開。搭配第 14 章的伺服器密碼（OPENCODE_SERVER_PASSWORD）是遠距場景的基本配備。

## 5.3 一引擎多客戶端的全景

把已學過的介面排在同一台伺服器前，你會看到 OpenCode 協作面的全貌：

| 入口 | 命令 | 適合 |
|------|------|------|
| TUI | `opencode` 或 `attach <url>` | 重度鍵盤流 |
| Web | `opencode web`（下一章） | 圍著螢幕討論、遠端瀏覽器 |
| SDK 腳本 | createOpencodeClient | 自動化與儀表板（第四冊） |
| IDE | ACP 整合 | 編輯器內嵌 |

同一份會話狀態、同一條事件流（GET /event）、同一套 REST API。第四冊第 18 章做的儀表板可以盯著別人 attach 的會話心跳——現在你知道這不是巧合，是架構使然。

## 5.4 團隊場景：共用引擎的三種姿態

**姿態一：接力。** 白天筆電 serve + mDNS，晚上桌機 attach 接力長任務。零額外設定。

**姿態二：指揮車。** 資深工程師的機器 serve 一台「會診引擎」，團隊成員輪流 attach 把卡住的問題帶上來，現場示範提示技巧——比截圖教學高效一個量級。

**姿態三：儀表板常駐。** 樹莓派或舊筆電掛一台 serve，團隊儀表板（SDK event.subscribe）盯著全組會話活動；任何人 ssh 進去 attach 就能介入。

三種姿態共用同一套安全底線：區網之外必加密碼、金鑰放環境變數不放設定檔、敏感專案遵守上一章的 share=disabled。

## 5.5 故障排查速查

| 症狀 | 先查 |
|------|------|
| attach 連不上 | 伺服器活著嗎（curl /global/health）？埠對嗎？ |
| mDNS 找不到名字 | 同網段嗎？路由器擋多播嗎？（公司網常擋）退回直連 IP |
| 對方看得到我的會話嗎 | 會話在伺服器端，所有客戶端等權限——介意就別共引擎 |
| 斷線後進度丟了嗎 | 不會。狀態在伺服器與 DB，重 attach 即恢復 |

## 本章摘要

- attach <url> 開出指向既有引擎的完整 TUI；長任務跨機接力不斷線
- --mdns 讓引擎以 opencode.local 在區網報名；公開網路務必關閉或加密碼
- TUI/Web/SDK/IDE 四入口同源於 client/server 架構
- 共用引擎三姿態：接力、指揮車、儀表板常駐
- 狀態住在伺服器端，斷線重連即恢復

## 下章預告 {.unnumbered .unlisted}

attach 是給你自己用的入口；Web 是給「不想裝終端機的人」的入口。下一章打開 opencode web——瀏覽器裡的完整 OpenCode，以及把它安全地放到團隊面前的方法。

## 延伸資源 {.unnumbered .unlisted}

- CLI 文檔：<https://opencode.ai/docs/cli/>
