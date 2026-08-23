# 第 17 章　enterprise：組織級部署

個人工具變組織標配，問題就從「好不好用」變成「可不可管」：資料出不出得去、誰批准模型存取、憑證怎麼發放。OpenCode Enterprise 的答案是一套中心化配置：SSO 認證＋內部 AI 閘道，確保代碼與資料不離開你的基礎設施。

## 17.1 底線聲明

三句官方原話值得逐字記住〔文件〕：

- **OpenCode 不儲存你的代碼或上下文資料。** 所有處理在本地或直連你選的 AI 供應商
- **你擁有 OpenCode 產出的所有代碼**——無授權限制、無所有權主張
- 唯一例外是 `/share`：啟用後對話會送到 opencode.ai 的託管服務（CDN 邊緣快取）

第三條就是試用期的頭號建議〔文件〕：專案層 `share: "disabled"`（第 4 章），讓資料邊界從第一天就閉合。

## 17.2 導入路徑：先試用再簽約

官方規劃的節奏〔文件〕：內部試用（開源版即可，因為預設不儲存資料）→ 聯繫官方談 Enterprise 定價與實作 → 按席計費；自備 LLM gateway 的話 token 不另收費。

這個順序對採購流程友善：工程團隊零成本跑兩週試點，拿著真實數據（第 3 章 stats）與安全評估去談，比空對空議價有力得多。

## 17.3 四大部署能力

| 能力 | 解決什麼 |
|------|----------|
| Central Config | 全組織一份中央配置，統一發布設定與政策 |
| SSO 整合 | 用既有身分系統認證，代理憑證由 IdM 發放 |
| 內部 AI 閘道 | 強制所有請求走公司核准的通道，可停用其他供應商 |
| 自架分享頁 | 連 share 託管都能搬進自己機房（roadmap 項目） |

中央配置與第四冊 ch19 的 policies 是同一哲學的兩端：policies 管「哪些行為禁止」，central config 管「整套配置從哪來」。疊起來的效果是——終端使用者的本地設定只能在組織畫出的框框裡揮灑。

## 17.4 私有 npm registry

企業環境常被忽略的一塊：外掛安裝走 Bun 的 .npmrc 支援〔文件〕。JFrog Artifactory、Nexus 之類私有倉庫的接法：

```bash
npm login --registry=https://your-company.jfrog.io/api/npm/npm-virtual/
```

登入會產生 ~/.npmrc，OpenCode 啟動時自動沿用〔文件〕。注意 Caution：必須先登入再跑 OpenCode——否則啟動時的外掛 bun install 會因為拉不到私有套件而失敗。手動寫 .npmrc 也行（registry＋_authToken 兩行）。

這一塊和第 14 章的網路設定同屬「新人環境包」：proxy 變數、CA 憑證、npmrc 三件套齊了，企業網路裡才算能開工。

## 17.5 給架構師的決策清單

評估要不要上 Enterprise（而非開源版自湊）：

1. 合規要求「代碼不出基礎設施」是硬性還是彈性？→ 硬性才需要
2. 已有內部 LLM gateway？→ 有則 Enterprise 的 per-seat 模式最划算（token 不抽成）
3. SSO 發放代理憑證是需求還是加分？→ 是需求就走 central config
4. 分享功能要完全禁絕或自架？→ 完全禁絕用開源版＋share disabled 就夠；自架等 roadmap
5. 私有 npm registry 是否為外掛分發的唯一管道？→ 是則照 17.4 配置

多數中小團隊算下來：開源版＋本書前十七章的紀律已經覆蓋八成需求——Enterprise 買的是最後兩成的集中治理與責任歸屬。

## 本章摘要

- 底線三句話：不儲存資料、代碼歸你、share 是唯一外流例外
- 導入節奏：免費試用拿數據→談 per-seat；自備 gateway 不收 token 費
- 四能力：central config、SSO、內部 gateway、自架分享頁
- 私有 registry 靠 .npmrc；先登入再啟動 OpenCode
- 五題決策清單幫你判斷是否需要 Enterprise

## 下章預告 {.unnumbered .unlisted}

治理講完回到手上功夫：opencode db 開出互動 sqlite shell——第三冊學過的 20 張表，現在可以直接在命令列查詢與維運。

## 延伸資源 {.unnumbered .unlisted}

- Enterprise 文檔：<https://opencode.ai/docs/enterprise/>
