# 第 3 章　會話即資產：統計、匯出與治理

個人用 OpenCode，會話是用完即丟的草稿；團隊用 OpenCode，會話是可稽核、可遷移、可計價的資產。這一章給你三件資產管理工具：stats 的成本報表、export/import 的 JSON 交換格式，以及一套會話治理的最小規範。

## 3.1 stats：一屏看清團隊消耗

```bash
opencode stats
```

輸出是一張框線表格〔實測樣本，撰寫環境的真實數據〕：

```
┌────────────────────────────────────────────────────────┐
│                       OVERVIEW                         │
├────────────────────────────────────────────────────────┤
│Sessions                                            267 │
│Messages                                          8,896 │
│Days                                                 29 │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┤
│                    COST & TOKENS                       │
├────────────────────────────────────────────────────────┤
│Total Cost                                        $0.00 │
│Avg Cost/Day                                      $0.00 │
│Avg Tokens/Session                                 3.2M │
│Median Tokens/Session                            124.5K │
```

解讀要點：OVERVIEW 給規模（會話數、訊息數、活躍天數），COST & TOKENS 給消耗。平均與**中位數**並排是有意義的設計——平均被少數長任務拉高時，中位數才是「一般會話」的真相。這份數據與第三冊第 5 章的 session 表欄位（tokens_*、cost）同源：stats 就是把整張表聚合起來的唯讀視圖。

管理用途：月度成本回顧、找出異常耗量的會話（配合 `session list` 對帳）、以及向管理層證明「AI 預算花在哪」。免費模型下 Total Cost 是 $0.00——token 欄位仍在動，換付費供應商前先看 token 趨勢。

## 3.2 session list / delete：名冊與銷毀

```bash
opencode session list            # 列出會話
opencode session delete <id>     # 刪除指定會話
```

list 輸出三欄〔實測〕：Session ID（ses_ 前綴 ULID）、標題（自動生成或自訂）、更新時間。delete 接完整 ID。治理建議：實驗性亂試會話定期清理；有留存價值的先 export 再刪。注意刪除走的是 DB 層——第三冊講過 session.deleted 事件會廣播，分享連結與子會話關聯一併失效，不可逆。

## 3.3 export / import：JSON 交換格式

不帶參數的 `opencode export` 會開互動選單挑選會話〔實測〕；腳本場景直接給 ID：

```bash
opencode export ses_fd386bcecffeUT5zSSus8XZccf > session.json
```

產物是一個 JSON 物件〔實測〕：

```json
{
  "info": { "id": "ses_...", "title": "...", "tokens": { ... } },
  "messages": [ ... ]
}
```

頂層兩鍵：`info` 是會話中繼資料（對應 DB 的 session 列），`messages` 是完整訊息陣列（每則含 parts——第四冊 SDK 章節的老朋友）。本書撰寫環境實測一份中型會話約 4.5MB，長開發會話會更大，傳輸與歸檔請預留空間。

反向操作把 JSON 帶進另一台機器：

```bash
opencode import session.json
```

import 也接受 URL〔文件〕——把 export 產物放上內部物件儲存，新人一句命令就能重現「當時那個會話」。典型工作流：

1. 資深成員把疑難雜症會話 export 成 JSON 進倉庫 issue 或內網
2. 同事 import 後接著除錯，上下文無損延續
3. 結案後 delete 本地副本

## 3.4 隱私紅線

export 匯出的是**全文**——包含你在會話裡貼過的所有程式碼、金鑰誤貼、客戶資料。三條紅線：

- 匯出前掃一眼敏感內容（或先用第四冊的外掛把金鑰打碼）
- 公開倉庫、外部服務只放脫敏後的樣本
- 分享連結（下一章）同理：share 之前想清楚誰看得到

## 3.5 最小治理規範

可直接落地的三條：

- **命名**：重要會話當場改標題（TUI 內建），別讓 ses_fd38... 占滿名冊
- **歸檔**：里程碑會話 export 進版本控管的 docs/sessions/（脫敏後）
- **對帳**：每月跑一次 stats 截圖進週報；異常 token 量追到具體 session

## 本章摘要

- stats 聚合 session 表：平均與中位數並排看消耗才不失真
- list 三欄、delete 不可逆；先匯出再刪除
- export 產生 `{info, messages}` JSON；import 收檔案或 URL，跨機遷移零損
- 全文匯出＝隱私責任隨行，敏感內容先處理再流通
- 命名、歸檔、對帳三條治理即可起步

## 下章預告 {.unnumbered .unlisted}

會話能帶走了，接著解決「人在另一台機器」的問題：分享連結怎麼開、怎麼收回，以及哪些東西絕對不能分享——下一章進入第二篇。

## 延伸資源 {.unnumbered .unlisted}

- CLI 文檔：<https://opencode.ai/docs/cli/>
