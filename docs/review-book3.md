# 《OpenCode 架構解密》技術審稿報告

- 審稿日期：2026-08-23
- 驗證版本：opencode-ai 1.18.21（`~/.local/lib/node_modules/opencode-ai/`）
- 方法：比照第二冊流程——所有可執行主張逐一實測；本冊主軸為 API／DB／旗標，故以「live 伺服器＋唯讀真庫」為準繩

## 一、總評

**通過（含一項已修正的計數錯誤）。**

全書核心主張——20 張資料表 schema、35 條 HTTP 端點、logfmt 日誌格式、目錄結構、CLI 旗標——經實測與線上規格逐條核對，除「19 張」計數筆誤外全部屬實。

## 二、URL 審查：23/23 通過

外部引用連結全數回傳 200：

| 類別 | 數量 | 結果 |
|------|------|------|
| opencode.ai/docs/*（server/plugins/acp/web/lsp/formatters/mcp-servers/providers/config/permissions/sdk/ide/troubleshooting） | 12 | 全 200 |
| 外部權威來源（SQLite WAL/URI/dbstat、MDN SSE、ACP 規格、Martin Fowler EventSourcing、brandur logfmt、Pro Git zh-tw、OpenAPI 3.1 spec） | 11 | 全 200 |

## 三、API 端點審查：34/34 命中 live 規格

以 `opencode serve --port 4311` 起站，抓取 `GET /doc` 的 OpenAPI 3.1 規格（478,747 bytes、188 個操作），將書中 **34 條端點主張**逐條比對：

- 端點存在性：**34/34 命中**（session/message/revert/diff/todo/prompt_async、config PATCH、provider、mcp、lsp、formatter、find/file/content、tui control 全系列、log、event、global/event）
- `GET /doc` 未列於規格 paths 屬正常（其本身即規格端點），實測可用
- 唯讀端點實測 13/13 回 200（config/project/path/provider/agent/command/lsp/formatter/mcp/session/session/status/log/find）
- SSE `GET /event`：首事件即 `{"id":"evt_...","type":"server.connected",...}`，與第 16 章描述一致
- 參數名抽查：`/find?pattern=`（必填 pattern）、`/find/file?query=`（必填 query）——附錄 A 與 ch15 寫法正確（審稿初測誤用 `q=` 得 400 為審稿側失誤，非書稿問題）

## 四、SQL／Schema 審查：完全吻合

對真庫 `~/.local/share/opencode/opencode.db` 以 SQLite 唯讀模式驗證：

| 主張 | 結果 |
|------|------|
| 資料表白名單（ch05 分組列舉 20 名） | 與 `sqlite_master` 完全一致，零缺漏零多餘 |
| session 關鍵欄位（parent_id、五 token 欄、cost、revert、time_compacting、share_url、summary_*） | 13/13 存在 |
| session_input 佇列欄位（delivery、admitted_seq、promoted_seq） | 3/3 存在 |
| event 表事件溯源欄位（id、aggregate_id、seq、type、data） | 吻合 |

**發現並修正**：書中原寫「19 張資料表」（ch01/ch04/ch05×2/ch20 共 5 處＋封面終端機輸出 1 處）。真庫為 **20 張**——探索期筆記計數遺傳錯誤。已全數改為 20，ch05 分組列舉本身無誤（4+3+5+2+6=20）。

## 五、CLI 旗標審查：全數屬實

| 主張 | 實測 |
|------|------|
| `--print-logs --log-level DEBUG`（ch19） | logfmt 輸出：`timestamp=… level=INFO run=b78b7844 message="creating instance" directory=…` |
| run= 關聯 ID | 同一次 run 內一致（樣本 32 行） |
| 頂層 `-c/--continue`、`-s/--session`、`--fork`（ch05、附錄 C） | help 列出 ✓ |
| serve 五旗標 `--port/--hostname/--cors/--mdns/--mdns-domain`（ch14、附錄 C） | help 列出 ✓，port/hostname 已用於本次驗證環境 |
| 版本凍結 | `opencode --version` → 1.18.21 ✓ |

## 六、目錄結構抽查

- `snapshot/<40 位十六進制 hash>/` 內容定址命名 ✓
- `tool-output/tool_<ulid>` 溢寫檔命名 ✓

## 七、結論

- 書稿可信度高：所有架構敘述均有可重現的驗證路徑，且路徑本身可用
- 已修正：「19→20 張資料表」6 處（5 草稿＋封面），成書 PDF/EPUB 已重建
- 無其他需修改項

— 審稿：Happy eBook Authors 技術編輯管線（自動化實測）
