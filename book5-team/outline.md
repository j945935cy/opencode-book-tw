# 《OpenCode 團隊作戰》大綱（book5-team）

- 版本凍結：opencode-ai 1.18.21（2026-08-24 探測）
- 定位：叢書第五冊。前四冊解決「個人會用→懂原理→會擴充」，本冊解決「組織怎麼用」：分享、遠距、Git 平台自動化、模型供給與企業治理
- 副標候選：從個人效率到組織級 AI 工程化
- 方法論不變：〔實測〕＝撰寫環境驗證；〔文件〕＝官方文檔附出處

## 事實基礎（探測於 2026-08-24）

### CLI 全命令清單〔實測 --help〕
completion｜acp｜mcp｜opencode(TUI)｜attach <url>｜run｜debug｜providers(auth)｜agent｜upgrade｜uninstall｜serve｜**web**｜models｜**stats**｜export/import｜**github(install/run)**｜**pr <number>**｜session(list/delete)｜plugin｜db(sqlite3 shell)
全域旗標：--pure(不載外部外掛)、-m provider/model、--port/--hostname/--mdns/--mdns-domain/--cors/--print-logs/--log-level

### GitHub 整合〔文件 /docs/github，更新 2026-08-23〕
- 觸發：留言提及 `/opencode` 或 `/oc`；`opencode github install` 引導安裝
- App：github.com/apps/opencode-agent；Action：anomalyco/opencode/github@latest
- 設定：model(必填)、agent(主代理)、share(公開倉庫預設 true)、prompt、token/GITHUB_TOKEN(use_github_token)、permissions(id-token: write；GITHUB_TOKEN 路線需 contents/pull-requests/issues: write)
- 六事件：issue_comment、pull_request_review_comment(帶檔案/行號/diff 上下文)、issues(prompt 必填)、pull_request(預設審查)、schedule(cron，prompt 必填，輸出進日誌與 PR)、workflow_dispatch(同前)
- 能力：讀整條 issue 討論串回覆、開新分支提交 PR、同一 PR 內追加 commit、行內精準回應
- 範例：排程 TODO 巡檢開 issue、PR 自動審查、議題分流（30 天帳齡防 spam）

### 待探頁面（各章撰稿時抓取核實）
/docs/share、/docs/web、/docs/zen、/docs/gitlab、/docs/enterprise、/docs/network、/docs/models、/docs/rules、/docs/tools、/docs/windows-wsl

## 章節架構（五篇 20 章＋附錄 ABCD）

### 第一篇 從 me 到 we
- ch01 第五冊地圖：組織採用的四道關卡（個人習慣→共享資產→平台自動化→治理）
- ch02 安裝生命週期：upgrade/uninstall/completion、--pure 除錯模式、版本釘選策略
- ch03 會話即資產：session list/delete、export/import(JSON 交換格式)、stats 成本報表

### 第二篇 分享與遠距
- ch04 分享機制：share_url 生命週期、公開/私有倉庫差異、敏感碼流出防護
- ch05 attach 與多介面：attach <url> 接管、serve+mdns 區網、一引擎多客戶端
- ch06 Web 介面：opencode web、瀏覽器全功能、遠端存取與 CORS

### 第三篇 Git 平台作戰
- ch07 GitHub 整合：App+Action 架構、install 流程、手動設定三步
- ch08 六事件全解：觸發源×必要輸入×權限矩陣
- ch09 作戰配方：修 issue 自動開 PR／行內審查／排程巡檢／防 spam 分流
- ch10 GitLab 對應方案
- ch11 本地 git 流：pr <number> 檢出、與第二冊 commit 紀律接軌

### 第四篇 模型供給
- ch12 Zen 模型閘道
- ch13 models 深度：命令、provider/model 語法、選型矩陣
- ch14 network：代理、防火牆、受限網路

### 第五篇 組織工程化
- ch15 rules 分層：AGENTS.md 的團隊紀律
- ch16 tools 全目錄：內建工具×配置項
- ch17 enterprise：政策部署與集中管理
- ch18 db 與營運：sqlite3 shell、容量治理（第三冊對接）
- ch19 windows-wsl 標準化作業環境
- ch20 大結局：AI 工程化成熟度五級＋系列完結

### 附錄
- appendix-a-workflows：六事件 YAML 配方庫
- appendix-b-cli：CLI 命令總表（含本冊新登場子命令）
- appendix-c-events：GitHub 事件×權限矩陣速查
- appendix-d-glossary：名詞表

## 待驗證風險清單（撰稿時處理）
- share 是否需要帳號？私有倉庫分享行為
- web 介面的認證方式（OPENCODE_SERVER_PASSWORD 對接？）
- zen 定價/可用模型的時效性——只寫機制不寫價格
- gitlab 與 github 文檔差異點逐條比對
