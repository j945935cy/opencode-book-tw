# 第 7 章　GitHub 整合：代理進駐代碼平台

前六章的 AI 都在「你的機器」上；這一章開始，它駐進 GitHub——在 issue 留言 `/oc` 就有人（準確說，有代理）來解讀問題、開分支、提交 PR。整個過程跑在你的 GitHub Actions runner 裡，代碼不出你的管轄範圍。

## 7.1 三十秒理解架構

```
你在 issue 留言 "/oc 幫我修這個"
        │ webhook
        ▼
GitHub Actions runner（你的倉庫、你的機器規格）
        │ 執行
        ▼
anomalyco/opencode/github Action
        │ 內部跑
        ▼
OpenCode 引擎 → 讀 issue 上下文 → 開分支改碼 → 提交 PR → 在討論串回報
```

兩個關鍵安全設計〔文件〕：執行環境是你的 runner（不是官方雲），模型金鑰走你自己的 Secrets。AI 的手就長在你自己的地盤上。

## 7.2 安裝：一條命令或三步手動

```bash
opencode github install
```

在隸屬 GitHub 倉庫的專案裡執行，它會引導完成三件事〔文件〕：安裝 GitHub App、建立 workflow 檔、設定 Secrets。

想手動來也可以：

**第一步，安裝 App。** 到 `github.com/apps/opencode-agent` 裝到目標倉庫。

**第二步，加 workflow。** `.github/workflows/opencode.yml`：

```yaml
name: opencode
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  opencode:
    if: >-
      contains(github.event.comment.body, '/oc') ||
      contains(github.event.comment.body, '/opencode')
    runs-on: ubuntu-latest
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v6
        with: { fetch-depth: 1, persist-credentials: false }
      - name: Run OpenCode
        uses: anomalyco/opencode/github@latest
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        with:
          model: anthropic/claude-sonnet-4-20250514
```

**第三步，放金鑰。** 倉庫 Settings → Secrets and variables → Actions，加入供應商 API key。

## 7.3 觸發語法

之後在 issue 或 PR 的留言裡：

```
/opencode 解釋一下這個 issue 的根因
/oc fix this
```

`/opencode` 與 `/oc` 等效；workflow 的 `if` 條件就是比對留言內容包含哪個前綴〔文件〕。在 PR 的 Files 分頁對特定行數留言也行——代理會收到檔案路徑、行號與 diff 上下文，實現「指著這三行說話」的精準請求。

## 7.4 Action 的五個設定項

| 項 | 必填 | 說明 |
|----|------|------|
| `model` | ✓ | provider/model 格式 |
| `agent` | — | 指定主代理；缺省回退設定的 default_agent，再退 build |
| `share` | — | 是否分享會話；公開倉庫預設 true |
| `prompt` | — | 自訂提示覆蓋預設行為 |
| `token` | — | GitHub token；缺省用 App 的 installation token |

token 一項有門道〔文件〕。預設走 OpenCode GitHub App 的 installation token——commit、留言、PR 都以 **app 身分**出現，乾淨分明。不想裝 App？改用 runner 內建的 GITHUB_TOKEN（配 `use_github_token: true`），但要在 workflow 補權限：

```yaml
permissions:
  id-token: write
  contents: write
  pull-requests: write
  issues: write
```

個人存取權杖（PAT）也是合法選項。三者按「治理清晰度」排序：App 專用身分 > GITHUB_TOKEN > PAT。

## 7.5 版本釘選提醒

範例裡的 `anomalyco/opencode/github@latest` 是文檔寫法；第 2 章的版本紀律在 CI 同樣適用——正式倉庫建議鎖到具體 tag，升級走 PR 審查而非自動跟隨。model 字串同理：今天能用的型號明天可能退役，CI 裡的 model 是配置不是常數。

## 本章摘要 {.unnumbered .unlisted}

- `/oc` 或 `/opencode` 觸發；引擎跑在你自己的 Actions runner，金鑰自備
- 安裝：github install 一條龍，或 App+workflow+secrets 三步手動
- 行內留言自動帶檔案、行號與 diff 上下文
- token 三選一：App installation（預設最乾淨）、GITHUB_TOKEN（補權限）、PAT
- CI 中的 @latest 與 model 字串都該釘版本

## 下章預告 {.unnumbered .unlisted}

本章只開了 issue_comment 一扇門。下一章把六種觸發事件全部攤開——排程巡檢、PR 自動審查、新 issue 自動分流——每種事件的必要輸入與權限要求各不相同，一張矩陣講清楚。

## 延伸資源 {.unnumbered .unlisted}

- GitHub 整合文檔：<https://opencode.ai/docs/github/>
- GitHub App：<https://github.com/apps/opencode-agent>
