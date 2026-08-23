# 《OpenCode 擴展開發》大綱（book4-extensions）

- 版本凍結：opencode-ai 1.18.21（2026-08-23 探測）
- 定位：叢書第四冊，從理解者變成建造者（承接第三冊 ch20 預告）
- 副標候選：從自訂工具到生態發布的建造者指南
- 方法論不變：只寫能驗證的事；〔實測〕＝本書環境驗證過，〔文件〕＝官方文檔並附出處

## 事實基礎（探測於 2026-08-23）

### 本機活體證據〔實測〕
- `~/.config/opencode/opencode.jsonc`："plugin": ["oh-my-openagent@latest"]、mcp.playwright、model、$schema
- `~/.config/opencode/tui.json`：也有 plugin 陣列（TUI 與核心分開掛）
- `~/.config/opencode/skills/ebook-publish/SKILL.md`：frontmatter 僅 name+description（皆必填）
- `~/.config/opencode/package.json`：依賴 "@opencode-ai/plugin": "1.18.5"（注意：低於 CLI 1.18.21，版本偏移實例）
- `~/.config/opencode/node_modules/@opencode-ai/{plugin,sdk}` 兩包都在
- plugin 套件 d.ts：index(322 行)/tui(510 行)/tool(60 行)/shell(109 行)+example*
- 外掛安裝實際位置：`~/.cache/opencode/packages/oh-my-openagent@latest/`（內含自己的 node_modules＋package-lock）
  ⚠️ 文檔寫 `~/.cache/opencode/node_modules/`——以實測 packages/<名>@<版> 為準並註明差異
- `~/.cache/opencode/`：bin/rg、models.json、packages/、skills/{security-research,security-review}（內建技能也住這）
- storage/ 有插件資料夾：oh-my-openagent、agent-usage-reminder

### PluginInput／Hooks〔實測自 d.ts〕
- input：{project, directory, worktree, client(SDK), serverUrl, $(BunShell), experimental_workspace.register(WorkspaceAdapter)}
- Hooks 17：dispose、event、config、tool{map}、auth、provider、
  chat.message、chat.params、chat.headers、permission.ask、
  command.execute.before、tool.execute.before、tool.execute.after、shell.env、tool.definition、
  experimental.{chat.messages.transform, chat.system.transform, provider.small_model, session.compacting, compaction.autocontinue, text.complete}
- tool()：args=zod(ZodRawShape)、execute(args,ctx)、回傳 string｜{title,output,metadata,attachments[{type:"file",mime,url,filename}]}
- ToolContext：sessionID,messageID,agent,directory,worktree,abort,metadata(),ask()(permission/patterns/always/metadata)
- TuiPlugin(api:TuiPluginApi,options,meta)：路由/鍵盤/指令/對話框(alert,confirm,prompt,select)/toast/attention 音效(default,question,permission,error,done,subagent_done)/theme/slots/側欄/state/eventBus/lifecycle；@opentui/core renderable
- WorkspaceAdapter：name,description,configure,create,remove,target(local|remote url+headers)

### 文檔規格〔文件〕（最後更新 2026-08-23）
- plugins.md：位置(.opencode/plugins/、~/.config/opencode/plugins/)、npm 自動安裝(Bun)、載入序(全域config→專案config→全域dir→專案dir)、同名同版只載一次、deps 用 config 目錄 package.json+bun install、client.app.log()、事件類型全表(command.executed,file.edited,file.watcher.updated,installation.updated,lsp.client.diagnostics,lsp.updated,message.part.removed/updated,message.removed/updated,permission.asked/replied,server.connected,session.created/compacted/deleted/diff/error/idle/status/updated,todo.updated,shell.env,tool.execute.after/before,tui.prompt.append,tui.command.execute,tui.toast.show)、範例(通知/.env保護/env注入/自訂工具/日誌/壓縮鉤子 context.push 或 output.prompt 全面取代)
- custom-tools.md：.opencode/tools/、檔名=工具名、多重導出=<檔名>_<導出名>、同名覆蓋內建、zod 直用也可、任意語言實作(Bun.$ 呼叫 python)
- commands.md：commands/*.md(全域/專案)、frontmatter(description,agent,model,subtask)+template、$ARGUMENTS/$1..$n、!`cmd` 注入、@file 引用、可覆蓋內建指令
- skills.md：六搜尋路徑(.opencode/.claude/.agents × 專案/全域)、cwd 向上走到 worktree、frontmatter(name 必填 ^[a-z0-9]+(-[a-z0-9]+)*$ ≤64=目錄名、description 必填 1-1024、license/compatibility/metadata 可選)、skill 工具 <available_skills> 注入、permission.skill 模式(*、prefix-*、allow/deny/ask)、per-agent 覆蓋、tools.skill:false 停用、疑難排解清單
- themes.md：tui.json theme 或 /themes 指令、truecolor(COLORTERM)需求、四層序(內建→~/.config/opencode/themes→專案根.opencode/themes→cwd .opencode/themes)、$schema theme.json、defs 參照、hex/ANSI0-255/none/{dark,light}、鍵位群(primary…syntax*九群+markdown*十五+diff*十一)、內建清單(system,tokyonight,everforest,ayu,catppuccin,catppuccin-macchiato,gruvbox,kanagawa,nord,matrix,one-dark,…)
- sdk.md：npm @opencode-ai/sdk@1.18.21〔實測 npm view 吻合〕、createOpencode(){client,server{url,close}} opts(hostname,port,signal,timeout,config)、createOpencodeClient({baseUrl,fetch,parseAs,responseStyle:data|fields 預設 fields!,throwOnError})、型別由 OpenAPI 生成、structured output(format.type=json_schema+schema+retryCount→info.structured_output；StructuredOutputError 含 retries)、API 面(global.health,app.log/agents,project.list/current,path.get,config.get/providers,session 20 法含 noReply/children/init/abort/share/unshare/summarize/command/shell/revert/unrevert,find.text/files{type,directory,limit}/symbols,file.read/status,tui 9 法,auth.set,event.subscribe async 迭代器)

### 銜接原則
- 第二冊已教：MCP 使用、agent 基本撰寫、CLI/TUI 操作——本冊引用不重教
- 第三冊已教：REST/SSE/control API、DB schema——ch16-18 只補「建造者怎麼用」

## 章節架構（五篇 20 章＋附錄 ABCD）

### 第一篇 工坊地圖
- ch01 八個擴充點總覽與選型決策（plugins/tools/commands/skills/agents/themes/MCP/config）
- ch02 底盤：載入時序、目錄優先序、Bun 安裝與快取實況、opencode.json vs tui.json 分工
- ch03 建造環境：依賴管理、TS 型別、三條除錯管道（--print-logs/client.app.log/event 流）

### 第二篇 提示層擴充（零程式碼）
- ch04 自訂指令：md 檔＋frontmatter、引數、shell 注入、檔案引用、subtask、覆蓋內建
- ch05 Agent Skills：SKILL.md 規格與發現機制、權限模式、實作一本書工作流為 skill
- ch06 代理深度客製：tools/permission/model 權限面、主子代理協同（建造者視角）

### 第三篇 程式碼層擴充
- ch07 第一支外掛：位置/匯出/PluginInput/Hooks 總表
- ch08 攔截與改寫：tool.execute.before/after、tool.definition、permission.ask 三實例
- ch09 對話管線鉤子：chat.*、shell.env、experimental 六鉤子
- ch10 事件驅動：event 類型全表應用、生命週期與 dispose
- ch11 自訂工具實戰：tool() 全規格、attachments、覆蓋內建、Python 混搭
- ch12 外掛即套件：npm 發布、版本策略、oh-my-openagent 剖析、載入順序細節

### 第四篇 介面層擴充
- ch13 主題設計：theme.json schema、四層覆蓋、「叢書綠」主題實作
- ch14 TUI 外掛：路由/鍵盤/指令/對話框/toast/slots/側欄
- ch15 注意力系統：通知策略、音效板、桌面整合

### 第五篇 整合層
- ch16 SDK 入門：兩種建立方式、responseStyle 陷阱、型別即文件
- ch17 自動化腳本：session 生命週期、noReply、structured output
- ch18 儀表板實戰：event.subscribe＋tui 遠控，終端儀表板範例
- ch19 實驗疆域：WorkspaceAdapter 遠端工作區、ACP 建造視角、企業 policies
- ch20 發布與生態：ecosystem、版本相容策略、系列完結

### 附錄
- appendix-a-hooks：17 鉤子快查（簽名/時機/可改輸出欄位）
- appendix-b-sdk-methods：SDK 方法×HTTP 對照（銜接第三冊附錄 A）
- appendix-c-paths：擴充點路徑總表（全域/專案/快取＋載入順序）
- appendix-d-glossary：名詞表
