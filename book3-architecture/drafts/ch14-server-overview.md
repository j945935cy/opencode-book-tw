# 第 14 章　HTTP Server 全景

第四篇從最高速的整合面開始：把伺服器當成產品來檢視。旗標、規格、SDK、遠端場景，一網打盡。

## 14.1 serve 旗標全表

官方文件〈Server〉頁的完整選項（本書撰寫基準）：

| 旗標 | 預設 | 用途 |
|------|------|------|
| `--port` | 4096 | 監聽埠 |
| `--hostname` | 127.0.0.1 | 綁定位址 |
| `--mdns` | false | 區網探索公告 |
| `--mdns-domain` | opencode.local | 自訂探索網域 |
| `--cors` | 空 | 額外放行的瀏覽器源（可多次） |

加上第 7 章的兩個環境變數（OPENCODE_SERVER_PASSWORD/USERNAME），這就是全部的暴露面控制組。

## 14.2 規格即真相

```bash
curl http://127.0.0.1:4096/doc
```

回傳 OpenAPI 3.1 規格——不是人寫的文件，而是**機器消費的契約**。官方 SDK 直接由它生成，意味著：文件落後程式的經典悲劇在這個架構裡被結構性消滅了。

對你的含義：想確認「某功能有沒有 API」，別翻部落格，直接讀 spec。用任何 Swagger 檢視器打開，全部端點一目了然。

## 14.3 端點地圖預覽

全 API 約十個功能域，後三章逐域實戰；先給全景：

| 域 | 代表端點 | 詳見 |
|----|----------|------|
| Global | /global/health、/global/event | 14 章 |
| Project/Path | /project、/path、/vcs | 15 章 |
| Config | GET/PATCH /config | 第 8 章 |
| Provider | /provider 系列 | 第 13 章 |
| Session | /session CRUD＋fork/share/revert… | 15 章 |
| Message | /session/:id/message、prompt_async | 15 章 |
| Files | /find、/file 系列 | 15 章 |
| LSP/MCP | /lsp、/formatter、/mcp | 9、10 章 |
| TUI 控制 | /tui/* 家族 | 17 章 |
| Events | /event（SSE） | 16 章 |

## 14.4 遠端場景配置

三種典型拓樸：

**本機自用**：什麼都不配，預設 127.0.0.1 已安全。

**區網協作**：`--hostname 0.0.0.0 --cors http://同事的介面:5173` ＋密碼必開。mDNS 讓同一辦公室的機器互相找到你。

**雲端長駐**：伺服器跑在算力主機，客戶端從筆電連入。密碼保護是底線，正式環境再加反向代理與 TLS。

原則複習：預設最小暴露，每一步擴大都要明示。

## 本章摘要 {.unnumbered .unlisted}

- 五旗標＋兩環境變數＝完整暴露面。
- /doc 的 OpenAPI 3.1 是唯一真相，SDK 由其生成。
- 十個功能域構成完整 API 地圖。
- 三種遠端拓樸各有最小安全配置。

## 下章預告 {.unnumbered .unlisted}

下一章用純 curl 走完一個會話的一生——不碰任何 UI。

## 延伸資源 {.unnumbered .unlisted}

- Server 文件：<https://opencode.ai/docs/server/>
- OpenAPI 3.1 規格：<https://spec.openapis.org/oas/v3.1.0>
