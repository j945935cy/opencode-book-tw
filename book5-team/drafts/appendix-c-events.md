# 附錄 C　事件×權限矩陣速查

GitHub 整合六事件的觸發、輸入與權限需求一覽。整理自官方文檔〔文件〕。

| 事件 | 觸發時機 | 指令來源 | prompt | 建議權限 |
|------|----------|----------|--------|----------|
| issue_comment | issue/PR 新留言 | /oc 或 /opencode | 否（讀留言） | id-token: write |
| pull_request_review_comment | PR 代碼行留言 | 行內 /oc | 否（帶檔案/行號/diff） | id-token: write |
| issues | issue 開啟或編輯 | 自動 | **必填** | + contents/issues: write |
| pull_request | PR 開啟/同步/重開 | 自動 | 否＝預設審查 | 唯讀組合即可 |
| schedule | cron 排程 | cron | **必填** | 寫入需 contents/pull-requests: write |
| workflow_dispatch | Actions 手動 | UI | **必填** | 同 schedule |

## GITHUB_TOKEN 路線的完整權限

不裝 App 改用 runner 內建 token 時〔文件〕：

```yaml
permissions:
  id-token: write
  contents: write        # 開分支、提交
  pull-requests: write   # 開 PR、回覆
  issues: write          # 留言
```

唯讀審查場景把三個 write 降為 read。

## Action inputs

model（必填）｜agent｜share｜prompt｜token／use_github_token——細節見第 7.4 節與附錄 A。

## 延伸資源 {.unnumbered .unlisted}

- GitHub 整合文檔：<https://opencode.ai/docs/github/>
