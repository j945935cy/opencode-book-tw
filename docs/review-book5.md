# 《OpenCode 團隊作戰》技術審稿報告

- 審稿日期：2026-08-24
- 驗證版本：opencode-ai 1.18.21
- 方法：CLI 全命令 help 實測＋關鍵命令實跑（stats/export/db）；九份官方文檔頁逐字核對；URL 全查

## 一、總評

**通過。** 撰寫期間即以「邊抓文檔邊寫」模式確保每一章的引用都是當下最新版官方內容（各頁最後更新 2026-08-23）；審稿複檢通過。

## 二、URL 審查：16/16 通過

opencode.ai 文檔群（cli/enterprise/github/gitlab/models/network/rules/share/tools/web/windows-wsl/zen/docs）＋config.json＋install 腳本＋github.com/apps/opencode-agent 全數 200。書中另含 proxy.example.com、your-company.jfrog.io 等**刻意佔位**的教學範例網址，非引用主張。

## 三、CLI 實測紀錄

| 主張 | 實測結果 |
|------|----------|
| `stats` 表格輸出（ch3） | 實跑：267 sessions／8,896 messages／29 days／平均與中位 token 並排 ✓ |
| `session list` 三欄格式 | ses_ ULID＋標題＋時間 ✓ |
| `export` 無參數開互動選單、帶 ID 直接輸出 | 兩者皆驗證；JSON 頂層 `{info, messages}` ✓ |
| `db "SELECT count(*)..."` | 實跑回 267，與 session list 對帳一致 ✓ |
| `attach <url>`／`pr <number>`／`web`／`github install/run` | help 描述與書中定位吻合 ✓ |
| 全域旗標 --pure／--mdns/--mdns-domain／--cors／-m | help 列出 ✓ |

## 四、文檔核對清單（撰稿時逐頁抓取）

share（三模式/unshare 真刪/企業選項）、web（埠/hostname/mDNS/CORS/密碼/設定檔 server 區塊）、github（六事件表/App+Action/config inputs/GITHUB_TOKEN 權限組合/排程 prompt 必填）、gitlab（component nagyv/gitlab-opencode@2/Duo 六步/AI_FLOW_* 變數/glab）、zen（三步啟用/opencode/<id> 格式/auto-reload/月上限/退役表/免費模型資料政策/workspace 角色/BYOK）、network（三代理變數/NO_PROXY 警告/NODE_EXTRA_CA_CERTS）、rules（/init 行為/三層搜尋/instructions glob+URL 5 秒逾時/@檔案懶載入）、tools（十三工具/edit 統管寫入/lsp 實驗旗標/apply_patch 的 tool 名與 patchText/Exa 綁定/.ignore 反向允許）、enterprise（三底線/per-seat/central config/SSO/private npmrc）——全數吻合，無發現需修正項。

## 五、結論

- 書稿可信度高：所有平台整合主張皆有一手文檔依據，本地命令皆有實測樣本
- 排版修正已先行處理：摘要屬性補掛 20 處、ch11 編號節改標準屬性節、角括號洩漏 3 處
- 成品：PDF 51 頁/733K、EPUB 103K、TOC 127 項零殘留

— 審稿：Happy eBook Authors 技術編輯管線（自動化實測）
