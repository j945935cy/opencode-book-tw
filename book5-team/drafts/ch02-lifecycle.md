# 第 2 章　安裝生命週期

團隊裡最怕兩種機器：版本落後三個月的、和沒人記得怎麼裝的。這一章把 OpenCode 的安裝生命週期講透——升級、降級、解除安裝，以及一個團隊除錯的救命旗標 `--pure`。

## 2.1 upgrade：升級與指定版本

```bash
opencode upgrade          # 升到最新
opencode upgrade 1.18.21  # 升（或降）到指定版本
```

`upgrade` 接受位置參數 target，格式如 `0.1.48` 或帶 v 前綴〔實測 --help〕。對團隊而言，第二種寫法才是日常——**版本釘選**：

- 個人機：追最新沒問題，新功能即時享受
- 團隊倉庫：在 README 或 setup 腳本寫死版本號，全員一致
- CI：永遠釘死。GitHub Action 的 `anomalyco/opencode/github@latest` 之類引用也建議改鎖 tag（第 7 章細談）

升級前的小儀式：`opencode --version` 記下現行版本；出問題時 `upgrade <舊版>` 一行回到已知良好狀態。第三冊講過資料庫有 migration 機制，跨大版本升級後若行為異常，先查 log 裡的 migration 紀錄再懷疑自己。

## 2.2 uninstall：清得多乾淨

```bash
opencode uninstall
```

解除安裝會移除相關檔案〔文件〕。但「相關」有三層，動手前心裡要有圖（路徑細節承接第三冊第 3 章）：

| 層 | 內容 | uninstall 之後 |
|----|------|----------------|
| 執行體 | ~/.local/bin/opencode、node_modules | 移除 |
| 快取 | ~/.cache/opencode/（外掛套件、bin、models.json） | 可重下，刪了無妨 |
| 資料 | ~/.local/share/opencode/（**資料庫、auth.json、日誌**） | **你的全部歷史** |

重點在最後一行：資料目錄是所有會話、憑證與統計的家。卸載重裝是小事，誤刪 opencode.db 是大事——本書撰寫環境的那顆 398MB 資料庫就是四冊書的工作痕跡。團隊標準作業：卸載前先跑一次 export（下一章）或直接備份整個資料目錄。

## 2.3 completion：讓 shell 記住命令

```bash
opencode completion   # 產生 shell 補全腳本
```

按你的 shell（bash/zsh/fish）把輸出掛進設定檔，之後 Tab 鍵補全子命令與旗標。團隊推廣期的小技巧：把這步寫進新人環境腳本，降低「指令打不出來」的摩擦。

## 2.4 --pure：團隊除錯神器

全域旗標〔實測 --help〕：

```bash
opencode --pure
```

意義：**不載入任何外部外掛**啟動。使用場景按頻率排：

1. 「OpenCode 怪怪的」——第一步永遠先 `--pure` 開一次。怪象消失＝問題在外掛（某支 npm 更新新壞了），縮小一半排查範圍
2. 二分定位：`--pure` 正常後，逐步把 plugin 清單減半載回，兩三次就抓到元凶
3. CI 環境：需要可重現的最小執行時，--pure 保證行為不受本地外掛污染

它和第四冊教的除錯管道是一套組合拳：--pure 切乾淨 → --print-logs --log-level DEBUG 看過程 → 日誌 logfmt 取證。

## 2.5 團隊版本治理一頁規範

把本章濃縮成可以直接貼進團隊 wiki 的規則：

- 全員版本 = README 宣告的釘選版本；個人嘗鮮用分支機器
- 升級流程：備份資料目錄 → upgrade → `--version` 確認 → 跑一次日常任務煙霧測試
- 出事三步：`--pure` 重現 → 查 log → `upgrade <舊版>` 回退
- 卸載必先 export 會話＋確認 auth.json 備份

## 本章摘要 {.unnumbered .unlisted}

- upgrade 支持指定版本；團隊釘選、CI 必釘
- uninstall 三層結構中，資料目錄（db/auth/日誌）是唯一不可再生資產
- completion 腳本進新人環境清單
- --pure 不載外部外掛，是團隊除錯的第一反應
- 版本治理一頁規範可直接落地

## 下章預告 {.unnumbered .unlisted}

引擎管好了，接著管燃料的帳：會話怎麼列、怎麼刪、怎麼打包成 JSON 帶走、成本怎麼報表化——下一章把會話變成真正的團隊資產。

## 延伸資源 {.unnumbered .unlisted}

- CLI 文檔：<https://opencode.ai/docs/cli/>
