# 第 9 章　作戰配方：四套可直接抄的部署

規格講完，本章給成品。四套配方按導入難度排序，每套都是完整可跑的 workflow 片段加營運注意事項。抄進 `.github/workflows/`、換掉 model 與金鑰就能上陣。

## 9.1 配方一：留言修 issue，自動開 PR

第 7 章的基礎 workflow 就夠。實戰語錄〔文件範例精神〕：

```
/opencode fix this
```

代理讀整條討論串 → 開新分支 → 實作 → 開 PR → 在原 issue 回報連結。營運注意：

- 建議限定觸發者（workflow 加條件判斷 comment 作者權限），避免任何訪客都能消耗你的 token 額度
- 產出的 PR 一律當「初稿」看待：人類審查不可省

## 9.2 配方二：PR 自動初審（唯讀安全版）

```yaml
name: opencode-review
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
      pull-requests: read
      issues: read
    steps:
      - uses: actions/checkout@v6
        with: { persist-credentials: false }
      - uses: anomalyco/opencode/github@latest
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          model: anthropic/claude-sonnet-4-20250514
          use_github_token: true
          prompt: |
            審查這個 PR：
            - 代碼品質與潛在 bug
            - 效能影響
            - 改善建議
```

全唯讀權限——它只能說話不能動手，是導入期最安心的形態。`synchronize` 讓每次 push 都重審一次；嫌吵就刪掉只留 opened。

## 9.3 配方三：週巡檢報告

```yaml
name: weekly-patrol
on:
  schedule:
    - cron: "0 9 * * 1"
jobs:
  patrol:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: write
      issues: write
    steps:
      - uses: actions/checkout@v6
        with: { persist-credentials: false }
      - uses: anomalyco/opencode/github@latest
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        with:
          model: anthropic/claude-sonnet-4-20250514
          prompt: |
            每週巡檢：
            1. 掃描 TODO/FIXME/HACK 註解，統計並列出高風險項
            2. 檢查依賴宣告中的明顯過期主版本
            3. 若發現值得追蹤的事項，各開一個 issue（標記 patrol）
            4. 沒有新發現就不要製造噪音
```

最後一句「沒有新發現就不要製造噪音」是排程任務的靈魂——自動化的最大風險不是做太少，是洗板洗到大家開始無視它。

## 9.4 配方四：防 spam 的議題分流

公開倉庫的新 issue 分流，先過帳齡閘再叫代理〔文件範例〕：

```yaml
on:
  issues:
    types: [opened]
jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - name: 檢查帳號年齡
        id: check
        uses: actions/github-script@v7
        with:
          script: |
            const user = await github.rest.users.getByUsername({
              username: context.payload.issue.user.login,
            });
            const days = (Date.now() - new Date(user.data.created_at)) / 86400000;
            return days >= 30;
          result-encoding: string
      - uses: actions/checkout@v6
        if: steps.check.outputs.result == 'true'
        with: { persist-credentials: false }
      - uses: anomalyco/opencode/github@latest
        if: steps.check.outputs.result == 'true'
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        with:
          model: anthropic/claude-sonnet-4-20250514
          prompt: |
            審查這個 issue。若能給出修法或文件連結就回覆；
            資訊不足時引導補充；沒有價值就不要留言。
```

兩層防線：帳齡 30 天擋掉大量一次性 spam 帳號；prompt 尾句的沉默指令防止代理為了回應而回應。成本隨之可控——**不觸發就是最大的省**。

## 9.5 上線檢查單

四套配方的共同收尾：

- model 與 Action tag 是否釘版（非 @latest）
- Secrets 是否齊備且未寫死在 YAML
- 權限是否最小化（唯讀優先，write 只給真的要寫的）
- 有没有留「關閉開關」：workflow 檔本身就是開關，刪除或 disable 即停
- 跑滿一週後回看 Action 用量，估算月成本

## 本章摘要 {.unnumbered .unlisted}

- 四配方遞進：互動修碼→唯讀初審→週巡檢→防 spam 分流
- 唯讀權限版是導入第一步，零風險建立信任
- 排程 prompt 必須包含「沒事別出聲」條款
- 帳齡閘＋沉默指令雙層控管公開倉庫的成本與品質
- 上線五查：釘版、Secrets、最小權限、開關、成本回顧

## 下章預告 {.unnumbered .unlisted}

GitHub 之外還有半個世界。下一章看 GitLab 的對應方案——同樣的代理駐守模式在另一套平台怎麼落地。

## 延伸資源 {.unnumbered .unlisted}

- GitHub 整合文檔：<https://opencode.ai/docs/github/>
