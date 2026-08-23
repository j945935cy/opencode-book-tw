# 第 20 章　效能、容量與演進觀察

全書最後一章處理三個「住久了才會遇到」的問題：資料越積越多怎麼辦、系統健不健康怎麼知道、版本一直更新怎麼追。

## 20.1 大 DB 的教訓

實測機器用了一個月，opencode.db 長到 398MB。拆解成長來源：

| 來源 | 機制 | 對策 |
|------|------|------|
| 訊息與 parts | 每回合必增 | 歸檔舊會話（刪除即清鏈） |
| event 表 | 事件溯源全記 | 同上——事件掛在會話聚合下 |
| tool-output 指標 | 大輸出分流後仍留中繼 | 影響小，可忽略 |
| WAL 成長 | 檢查點延遲 | 正常現象，勿手刪 |

務實策略：

1. **會話即單位**：不需要的會話用 `DELETE /session/:id` 整串清除——parts、events、todo 隨之而去
2. **備份先於清理**：整組拷貝 db＋wal＋shm（第 3 章）再動手
3. **量測先行**：清理前後各跑一次體積查詢，確認有效

```sql
SELECT name, SUM(pgsize)/1048576 AS mb
FROM dbstat GROUP BY name ORDER BY mb DESC LIMIT 8;
```

## 20.2 健康檢查與指標

日常巡檢的最小集合：

```bash
curl -s .../global/health     # 活著嗎＋版本號
du -sh ~/.local/share/opencode/opencode.db*   # 容量趨勢
opencode stats                # token/成本對帳（第二冊 ch20）
```

進階指標從 DB 直取：session 表的 cost 總和、tokens_cache_read 佔比（快取命中率越高越省）、time_compacting 出現現頻率（壓縮過勤＝上下文管理有問題）。

## 20.3 追蹤架構演進

工具會長大，你的知識也要能跟著長。三個觀察哨：

**規格 diff。** 版本升級後抓 `/doc` 存檔比對：

```bash
curl -s .../doc > openapi-$(opencode --version).json
```

新增的端點就是新功能的官方公告——比發行說明更快、更準。

**schema diff。** DB 的 sqlite_master 對比舊版快照，看遷移加了什麼表。migration 表本身就是版本史。

**文件站巡禮。** 側欄出現新頁面（如本書撰寫期間冒出的 policies、custom-tools）往往對應新子系統。

把三個哨兵做成每月十五分鐘的例行公事，你對這套系統的認知就永遠不會過期——這正是第 1 章承諾的「方法比版本長壽」。

## 本章摘要 {.unnumbered .unlisted}

- 成長主源是訊息與事件；以會話為單位歸檔，備份先行。
- 最小健康組：health 端點＋容量 du＋stats 對帳。
- 三哨兵追蹤演進：spec diff、schema diff、文件站巡禮。
- 方法論閉環：驗證→理解→觀察→適應。

## 全書總結 {.unnumbered .unlisted}

二十章走完，引擎室已無秘密：client/server 的分工、19 張表的領域模型、迴圈裡的權限閘門、五通道的通訊面、以及一套可重現的取證方法。接下來輪到你——挑一個整合點動手，儀表板也罷、應答機也罷，架構知識只在被使用時才變成力量。第四冊《擴展開發》將帶你從理解者變成建造者。工坊見。

## 延伸資源 {.unnumbered .unlisted}

- SQLite dbstat：<https://www.sqlite.org/dbstat.html>
- Troubleshooting 文件：<https://opencode.ai/docs/troubleshooting/>
