# 附錄 B：設定選項速查

> 設定檔為 JSONC（支援註解），全域 `~/.config/opencode/opencode.json`、專案 `.opencode/opencode.json`。完整欄位以官方文件〈Config〉與 schema 自動補全為準。

## 主要設定區塊總覽

| 區塊 | 用途 | 詳見 |
|------|------|------|
| `permission` | allow／ask／deny 權限規則 | 第 3、21 章 |
| `mcp` | MCP 伺服器註冊（local／remote） | 第 10 章 |
| `provider` | 供應商與端點設定（含本地模型） | 第 19 章 |
| `share` | 會話分享政策（`"disabled"` 封鎖） | 第 19 章 |
| `tui`（tui.json） | 主題與快捷鍵 | 第 6、12 章 |

## permission 範例速查

```json
{
  "permission": {
    "edit": "allow",
    "webfetch": "allow",
    "bash": {
      "git push*": "ask",
      "rm -rf *": "deny",
      "*": "ask"
    },
    "mcp": {
      "github_*": "allow",
      "*_delete*": "deny"
    }
  }
}
```

語意要點：

- 字串值套用到整個類別；物件值按「指令前綴」或「伺服器_工具」細分。
- 萬用字元 `*` 支援前綴與包含匹配。
- 三層值：`allow` 放行、`ask` 確認、`deny` 拒絕。

## mcp 註冊範例速查

```json
{
  "mcp": {
    "local-tool": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/srv/data"],
      "enabled": true
    },
    "remote-tool": {
      "type": "remote",
      "url": "https://example.com/mcp/",
      "enabled": true
    }
  }
}
```

## provider（本地模型）範例速查

```json
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://localhost:11434/v1" }
    }
  }
}
```

## 排查口訣

設定沒生效時的檢查順序（第 12 章七層優先序，由高到低）：CLI 旗標→代理定義→額外指定檔→專案層→XDG→全域→內建預設。九成案例是「被更高層蓋掉了」。
