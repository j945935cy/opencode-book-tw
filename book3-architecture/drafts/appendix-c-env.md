# 附錄 C　環境變數與旗標清單

> 標記〔實測〕者在本書撰寫環境驗證過；其餘出自官方文件並附出處。

## 環境變數

| 變數 | 作用 | 出處 |
|------|------|------|
| OPENCODE_SERVER_PASSWORD | 伺服器/Web 基本授權密碼 | docs/server〔文件〕 |
| OPENCODE_SERVER_USERNAME | 同上，使用者名（預設 opencode） | docs/server〔文件〕 |
| XDG_CONFIG_HOME / XDG_DATA_HOME | 設定與資料根目錄慣例 | XDG 規格〔文件〕 |

> 供應商金鑰多經 `opencode auth login` 存入 auth.json；直接用環境變數注入金鑰的支援因供應商而異，以 providers 文件為準。

## serve / web 共同旗標

| 旗標 | 預設 | 作用 |
|------|------|------|
| --port | 4096 | 監聽埠 |
| --hostname | 127.0.0.1 | 綁定位址 |
| --cors | 空 | 放行瀏覽器源（可多次） |
| --mdns / --mdns-domain | false / opencode.local | 區網探索 |

## 常用 CLI 旗標（架構相關）

| 旗標 | 用途 | 本書章節 |
|------|------|----------|
| --print-logs | 日誌印到 stdout | ch19〔實測〕 |
| --log-level DEBUG | 提高日誌級別 | ch19〔實測〕 |
| -c/--continue、-s/--session、--fork | 會話續接與分岔 | ch5〔實測〕 |
| --port／--hostname（TUI 亦可指定） | 固定內嵌伺服器位址 | ch2〔文件〕 |

## 資料目錄一覽〔實測〕

```text
~/.config/opencode/     opencode.json(c)、tui.json、skills/
~/.local/share/opencode/ opencode.db(-wal/-shm)、auth.json、
                         log/、repos/、snapshot/、storage/、tool-output/
```
