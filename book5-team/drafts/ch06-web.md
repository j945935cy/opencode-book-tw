# 第 6 章　Web 介面：瀏覽器裡的 OpenCode

終端機勸退了半個世界的人。當你想跟設計師、PM 或主管展示「AI 代理是這樣工作的」，開一個黑底白字的 TUI 不是好主意——打開瀏覽器才是。`opencode web` 把完整體驗放進瀏覽器分頁，而且它和 TUI、SDK 共享同一顆引擎。

## 6.1 啟動與預設行為

```bash
opencode web
```

一行命令〔實測 --help；文件〕：啟動伺服器（綁 127.0.0.1、隨機可用埠）並自動打開預設瀏覽器。介面提供會話列表（查看活躍會話、開新會話）與伺服器狀態頁（See Servers 查看連線中的引擎）。功能與 TUI 同源——因為背後就是同一套 REST API 與事件流。

兩條官方提醒〔文件〕值得原樣轉述：未設 `OPENCODE_SERVER_PASSWORD` 時伺服器無防護，本機用可以、上網路不行；Windows 使用者建議在 WSL 內執行而非 PowerShell，檔案系統與終端整合表現較佳。

## 6.2 網路化的三個旋鈕

讓團隊其他人從他們的瀏覽器連進來：

```bash
OPENCODE_SERVER_PASSWORD=secret opencode web --hostname 0.0.0.0 --port 4096
```

- **--hostname 0.0.0.0**：對外外監聽。啟動訊息會同時列出本機位址（http://localhost:4096）與網路位址（如 http://192.168.1.100:4096）
- **密碼**：環境變數 OPENCODE_SERVER_PASSWORD 啟用基本授權，使用者名預設 opencode、可用 OPENCODE_SERVER_USERNAME 改〔文件〕。第三冊第 14 章講過同一組變數——所有對外暴露的場景都適用
- **mDNS**：加 `--mdns` 以 opencode.local 廣播；多實例並存時用 `--mdns-domain myproject.local` 分開命名

CORS 還有一個給進階玩家的旋鈕：`--cors https://example.com` 放行自訂前端跨域呼叫 API〔文件〕——第四冊的儀表板想掛在公司網域下就用得上。

## 6.3 設定檔寫法

旗標之外，伺服器參數可固化進 opencode.json〔文件〕：

```json
{
  "server": {
    "port": 4096,
    "hostname": "0.0.0.0",
    "mdns": true,
    "cors": ["https://example.com"]
  }
}
```

命令列旗標優先於設定檔。團隊標準化作業：把 server 區塊連同 share=disabled 一起放進專案層設定提交入庫，新人 clone 下來的環境行為全員一致。

## 6.4 終端機與瀏覽器並存

Web 伺服器跑著，照樣 attach：

```bash
opencode web --port 4096          # 瀏覽器入口起來了
opencode attach http://localhost:4096   # 同一台引擎的 TUI 入口
```

兩邊看到同一份會話與狀態〔文件〕。實戰畫面：會議室投影幕開 Web 版給大家看討論過程，你自己旁邊的終端機繼續敲指令；或反過來——工程師住 TUI，訪客拿平板開 Web 圍觀。第五架構章的老原則：客戶端只是皮，引擎才是命。

## 6.5 何時用 Web、何時不用

| 情境 | 選擇 |
|------|------|
| 對非工程背景者演示 | Web |
| 平板／手機臨時查看 | Web |
| 重度鍵盤流、快捷鍵肌肉記憶 | TUI |
| 自動化與儀表板 | SDK |
| 公開網路暴露 | 都不要——除非有密碼＋VPN |

最後一列再強調一次：0.0.0.0 加無密碼等於把你的代碼庫與供應商金鑰攤在網路上。Web 的便利以「記得設密碼」為前提。

## 本章摘要

- opencode web 一行啟動：本機隨機埠＋自動開瀏覽器
- 三旋鈕上網路：--hostname 0.0.0.0、OPENCODE_SERVER_PASSWORD、--mdns
- server 區塊可固化進 opencode.json，旗標優先
- Web 與 TUI/attach 共享同一引擎，會議室投影與個人終端互不干擾
- 無密碼不外露——便利的前提是那行環境變數

## 下章預告 {.unnumbered .unlisted}

第二篇解決了「人之間」的分享。接下來換主角：讓 AI 代理直接駐守 GitHub——在 issue 留言 /oc 就有隊友開分支、提 PR。第三篇 Git 平台作戰，正式開打。

## 延伸資源 {.unnumbered .unlisted}

- Web 文檔：<https://opencode.ai/docs/web/>
