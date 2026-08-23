# 附錄 A　GitHub workflow 配方庫

六種事件的 YAML 骨架集。共用前置：App 安裝或 GITHUB_TOKEN 權限、Secrets 放供應商金鑰、checkout persist-credentials: false。全部整理自官方文檔（2026-08-23 版）〔文件〕。

## 留言觸發（issue_comment / pull_request_review_comment）

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
      - uses: anomalyco/opencode/github@latest
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        with:
          model: anthropic/claude-sonnet-4-20250514
```

## PR 自動審查（pull_request）

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
# 唯讀權限組合：
permissions:
  id-token: write
  contents: read
  pull-requests: read
  issues: read
# 不給 prompt ＝ 預設執行 PR 審查；自訂 prompt 覆蓋審查重點
```

## 新 issue 分流（issues，prompt 必填）

```yaml
on:
  issues:
    types: [opened]
# prompt 必填；可先以 github-script 做帳齡檢查再觸發（防 spam）
```

## 排程巡檢（schedule，prompt 必填）

```yaml
on:
  schedule:
    - cron: "0 9 * * 1"
# 需寫入時明確放行 contents/pull-requests/issues: write
# prompt 建議含「沒有新發現就不要留言」條款
```

## 手動觸發（workflow_dispatch，prompt 必填）

```yaml
on:
  workflow_dispatch:
# Actions 分頁手動執行；輸出進日誌與 PR
```

## 共同設定項

| input | 必填 | 說明 |
|-------|------|------|
| model | ✓ | provider/model |
| agent | — | 主代理；回退 default_agent → build |
| share | — | 公開倉庫預設 true |
| prompt | 自動事件必填 | 任務書 |
| token / use_github_token | — | App token / GITHUB_TOKEN / PAT 三選一 |

## 延伸資源 {.unnumbered .unlisted}

- GitHub 整合文檔：<https://opencode.ai/docs/github/>
