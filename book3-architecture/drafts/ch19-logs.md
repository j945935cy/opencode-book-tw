# 第 19 章　日誌系統解剖

日誌是架構的黑盒子記錄器。這一章解讀 OpenCode 日誌的格式語法，建立「一次執行」的追蹤方法，並示範如何把自己的事件寫進同一條時間軸。

## 19.1 logfmt：機器友好的人類日誌

實測 `~/.local/share/opencode/log/opencode.log` 開頭：

```text
timestamp=2026-07-26T15:20:33.677Z level=INFO run=ea74fd41 message="creating instance" directory=/home/j945935/test
timestamp=2026-07-26T15:20:33.936Z level=INFO run=ea74fd41 message=loading path=/home/j945935/.config/opencode/config.json
```

logfmt 格式：每行一筆、鍵值對並列。四個固定欄位：

| 欄位 | 含義 | 用法 |
|------|------|------|
| timestamp | ISO 8601 毫秒級 | 對齊其他系統的時間軸 |
| level | INFO/DEBUG/ERROR… | grep 過濾嚴重度 |
| run | 執行 ID | **同一進程的所有日誌共用** |
| message＋附加鍵 | 事件描述與上下文 | 每種事件帶不同欄位 |

`run=` 是精華：多視窗同時開著好幾個 OpenCode，日誌全寫同一個檔——靠 run ID 才能把線索歸回各自的執行。

## 19.2 追蹤一次執行

標準除錯三式：

```bash
# 一式：抓出某次執行的完整生命史
grep 'run=ea74fd41' opencode.log

# 二式：只看錯誤與警告
grep -E 'level=(ERROR|WARN)' opencode.log

# 三式：DEBUG 級重現（另開終端跑，別汙染日常會話）
opencode --print-logs --log-level DEBUG
```

第 8 章的設定除錯正是用一式：確認目標設定檔有沒有出現 `loading path=` 行——五秒判定「沒讀到」還是「讀了被蓋」。

## 19.3 把自己寫進時間軸

架構彩蛋：日誌不只是給你看的，也是給你**寫**的。

```bash
curl -X POST .../log \
  -d '{"service":"my-ci","level":"INFO","message":"deploy triggered","extra":{"build":1234}}'
```

外部系統的事件（CI 觸發、部署完成）可以注入同一條日誌時間軸。事後排查「代理改壞了什麼」時，你的部署紀錄和代理行為在同一個檔案裡按時間交錯——因果關係一目了然。

## 本章摘要 {.unnumbered .unlisted}

- logfmt 四欄位；run ID 歸屬執行、level 過濾嚴重度。
- 三式追蹤：run 全史、級別過濾、DEBUG 重現。
- POST /log 讓外部事件與代理行為共處一條時間軸。
- 日誌在 local/share 下，與 DB 同域備份考量。

## 下章預告 {.unnumbered .unlisted}

最後一章面對成長的代價：398MB 的教訓、清理策略，以及追蹤架構演進的方法。

## 延伸資源 {.unnumbered .unlisted}

- logfmt：<https://www.brandur.org/logfmt>
- 第二冊第 22 章（問題排除）
