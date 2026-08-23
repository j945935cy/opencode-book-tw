# 第 19 章　實驗疆域：工作區、ACP 與政策

本章收攏三個「邊界上」的擴充面：實驗性的遠端工作區、站在編輯器端打造 ACP 代理、以及企業環境的政策約束。它們的共同點是——今天寫的程式碼，明天可能要跟著上游改介面。這正是考驗第 3.6 節版本策略的地方。

## 19.1 experimental_workspace：註冊工作區適配器

回頭看外掛資源包裡最神祕的一把鑰匙〔實測自 d.ts〕：

```ts
experimental_workspace: {
  register(type: string, adapter: WorkspaceAdapter): void
}
```

`WorkspaceAdapter` 的五個方法定義了一種「工作區從哪來、怎麼進去」：

```ts
type WorkspaceAdapter = {
  name: string
  description: string
  configure(config: WorkspaceInfo): WorkspaceInfo | Promise<WorkspaceInfo>
  create(config, env, from?): Promise<void>
  remove(config): Promise<void>
  target(config): WorkspaceTarget | Promise<WorkspaceTarget>
}
```

`target()` 回傳 `{ type: "local", directory }` 或 `{ type: "remote", url, headers }`——後者就是遠端引擎的入口。應用想像空間：接公司內部的開發容器平臺（每個會話自動開一個乾淨容器）、雲端開發機池、或一次性 PR 沙盒。名字裡的 experimental 提醒你：介面會動，鎖版本區間再出貨。

## 19.2 ACP：你的代理住進別人的編輯器

第二冊用過 IDE 整合，第三冊第 18 章拆過 ACP 協議的通訊面；建造者的視角是第四種——**你寫一個 ACP 伺服器，讓任何支援該協定的編輯器把你的代理當成原生功能**。

ACP 是 Agent Client Protocol：編輯器（客戶端）與代理（伺服器）之間的開放標準，涵蓋會話、提示串流、權限請求、檔案操作等消息〔文件，https://agentclientprotocol.com/〕。OpenCode 自己就同時是 ACP 客戶端的服務對象與提供者。打造自有代理的最小閉環：

1. 實作 ACP 伺服器（stdio 或網路傳輸），處理初始化握手與會話建立
2. 內部把請求轉發給 OpenCode 引擎——用第 17 章的 SDK `prompt()` 帶結構化輸出
3. 把權限請求映射到編輯器的 UI（ACP 的 permission 消息）
4. 在編輯器設定裡註冊你的代理命令

價值場景：團隊想把「審查風格」「部署流程」做成編輯器裡一等公民的代理按鈕，而不依賴每個人自己配 OpenCode。工程量不小，但每一層都有現成規格可循。

## 19.3 policies：企業的緊箍咒

個人玩擴充求自由，組織部署求可控。OpenCode 的政策面〔文件，/docs/policies/〕讓管理員在組織層級強制約束：禁用的供應商與模型、強制的權限預設、資料外流的紅線。對建造者的意義有二：

- **讀懂限制**：你的外掛在企業客戶那裡可能被政策蓋掉部分能力（例如 websearch 全域 deny），程式要有優雅降級
- **善用介面**：政策本質上是更高優先級的設定層——你的外掛若透過 `config` 鉤子改設定，記得政策永遠贏你

搭配第 6 章的 permission 物件與第 9 章的治理外掛，組織可以疊出三層防護：政策（不可違）→ 治理外掛（可稽核）→ 代理權限（日常細控）。三層各司其職，誰也不搶誰的戲。

## 19.4 疆域行為守則

在三個實驗面上做事，四條守則延長你的程式壽命：

1. **型別鎖版**：package.json 釘死 @opencode-ai/* 的版本區間，升級前跑完整測試
2. **特性偵測**：呼叫前檢查能力存在與否（try/catch 包註冊、typeof 檢查），別假設鉤子一定在
3. **降級路徑**：實驗功能缺席時退回穩定替代（如 WorkspaceAdapter 不在就用本地目錄）
4. **上游雷達**：盯著 release notes 與 d.ts diff——第三冊教的「schema 就躺在磁碟上」在外掛世界同樣成立

## 本章摘要 {.unnumbered .unlisted}

- WorkspaceAdapter 五法定義工作區生命週期；remote target 打開雲端引擎想像
- ACP 讓你的代理成為編輯器原生功能；內核是把 SDK prompt 包成協議伺服器
- 政策層高於一切擴充；三層防護＝政策→治理外掛→代理權限
- 實驗疆域四守則：鎖版、偵測、降級、盯上游

## 下章預告 {.unnumbered .unlisted}

終點站：把你做的東西交出去。生態頁怎麼上架、README 怎麼寫才有人敢裝、版本相容承諾怎麼下——以及二十章走完，回望整個系列的 最後一課。

## 延伸資源 {.unnumbered .unlisted}

- ACP 規格：<https://agentclientprotocol.com/>
- 政策文檔：<https://opencode.ai/docs/policies/>
