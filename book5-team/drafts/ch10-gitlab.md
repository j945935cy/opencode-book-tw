# 第 10 章　GitLab 對應方案

GitHub 之外，OpenCode 官方同樣支援 GitLab——而且有兩條路：輕量的 **CI component** 與深度的 **GitLab Duo 整合**。本章把兩條路的適用場景、設定步驟與 GitHub 版的差異講清楚。

## 10.1 兩條路怎麼選

| | GitLab CI（component） | GitLab Duo 整合 |
|--|------------------------|-----------------|
| 觸發方式 | pipeline 定義（手動/排程/事件） | 留言 `@opencode` |
| 安裝成本 | 一段 include＋一個變數 | 六步環境設定 |
| 適合 | 已有 CI 紀律的團隊、批次任務 | 想要 GitHub 版那種「留言叫人」體驗 |
| 依賴 | 社群 component nagyv/gitlab-opencode | GitLab Duo Agent Platform |

兩者共同點〔文件〕：代理跑在你自己的 GitLab runners 上，代碼不出門。

## 10.2 路 A：CI component（快）

社群維護的 CI/CD component `nagyv/gitlab-opencode` 把 OpenCode 的安裝與執行打包好〔文件〕。三步：

**第一步，放認證。** Settings → CI/CD → Variables，把 OpenCode 的認證 JSON 存成 File 型變數，務必勾「Masked and hidden」。

**第二步，include。**

```yaml
include:
  - component: $CI_SERVER_FQDN/nagyv/gitlab-opencode/opencode@2
    inputs:
      config_dir: ${CI_PROJECT_DIR}/opencode-config
      auth_json: $OPENCODE_AUTH_JSON
      message: "你的提示"
```

`config_dir` 指向自訂設定目錄是它的亮點——每個 job 可以掛不同的 opencode 設定，這個 job 開審查代理、那個 job 跑測試修復，互不干擾〔文件〕。更多 inputs（如自訂 command）見 component 自己的目錄頁。

## 10.3 路 B：GitLab Duo（留言驅動）

想要 GitHub 版的體驗——在 issue/MR 留言 `@opencode fix this` 就有人來開分支提 merge request——走 Duo Agent Platform 整合。前置六步〔文件〕：

1. 設定 GitLab 環境（Duo 功能）
2. 建置 CI/CD
3. 取得 AI 供應商 API key
4. 建立 service account（代理的身分）
5. 配置 CI/CD variables
6. 寫 flow config

官方文檔明言最新步驟以 GitLab 文檔為準；書中保留其 flow config 的骨架供理解機制〔文件〕：

```yaml
image: node:22-slim
commands:
  - npm install --global opencode-ai        # 裝引擎
  - apt-get install --yes glab              # 裝 GitLab CLI
  # auth.json 寫入 anthropic key、git 身分設為 OpenCode
  - opencode run "
      You are an AI assistant helping with GitLab operations.
      Context: $AI_FLOW_CONTEXT   Task: $AI_FLOW_INPUT
      Please use the glab CLI to access data from GitLab.
    "
  # 變更偵測後自動 commit + push 到工作分支 $CI_WORKLOAD_REF
```

讀懂三個環境變數就懂了整條鏈路：GitLab 把使用者的留言塞進 `AI_FLOW_INPUT`、上下文塞進 `AI_FLOW_CONTEXT`，代理用 glab CLI（預先授權）讀寫 GitLab 資源，檔案變更由平臺自動提交到 `$CI_WORKLOAD_REF` 分支。

## 10.4 與 GitHub 版的差異對照

| 面 | GitHub | GitLab |
|----|--------|--------|
| 觸發語法 | `/oc` 或 `/opencode` | `@opencode`（可自訂） |
| 官方 Action | anomalyco/opencode/github | 無官方 action；component 為社群版 |
| 代碼變更交付 | 自動開 PR / 追加 commit | MR（Duo 路線自動 push 工作分支） |
| 平台身分 | GitHub App installation token | service account＋glab token |
| 文檔成熟度 | 六事件完整規格 | 以 GitLab 官方文檔為準（變動較快） |

實務建議：GitHub 路線照本冊第 7–9 章抄即可；GitLab 路線把本書當「地圖」而非「導航」——component 版本與 Duo 步驟以當下官方頁面為準，書中教的是判讀框架。

## 10.5 共同的安全備忘

不管哪個平台：金鑰一律走平台 Secrets/Variables 並遮罩、代理身分用專用帳號不借真人、write 權限只給真的需要寫入的 pipeline、留言觸發記得限制誰能叫得動它。第 9 章的上線五查在 GitLab 同樣逐條成立。

## 本章摘要

- GitLab 兩條路：nagyv/gitlab-opencode component（pipeline 驅動）與 Duo 整合（@opencode 留言驅動）
- component 三步：File 型遮罩變數、include、給 prompt；config_dir 支援 per-job 設定
- Duo 六步前置；核心機制＝AI_FLOW_* 變數＋glab CLI＋工作分支自動 push
- GitHub/GitLab 差異主要在觸發語法與官方支援度；安全原則完全通用

## 下章預告 {.unnumbered .unlisted}

平台的自動化說完了，別忘了本地端還藏著一顆彩蛋：opencode pr <number>——一行命令把任何 PR 檢出到本地並直接進入會話。下一章收尾第三篇。

## 延伸資源 {.unnumbered .unlisted}

- GitLab 整合文檔：<https://opencode.ai/docs/gitlab/>
