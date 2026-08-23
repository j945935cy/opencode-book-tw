# 第 17 章　自動化腳本：批次、結構化輸出與撤銷

SDK 學會了，本章把它用到「真的省時間」的地方。三個遞進的實戰：單會話全生命週期腳本、用結構化輸出強迫模型吐可解析的 JSON、以及把第三冊講過的快照撤銷變成腳本裡的一顆按鈕。

## 17.1 全生命週期腳本

一段能直接改用的骨架〔文件 API 組合〕：

```ts
import { createOpencode } from "@opencode-ai/sdk"

const opencode = await createOpencode({ port: 4311 })
const client = opencode.client

const session = await client.session.create({
  body: { title: "夜間批次：升級依賴" },
})

const result = await client.session.prompt({
  path: { id: session.data.id },
  body: {
    model: { providerID: "opencode", modelID: "qwen3-coder" },
    parts: [{ type: "text", text: "把 package.json 的依賴全部升到最新小版本，跑測試，回報結果。" }],
  },
})
console.log("代理說：", result.data.parts)

// 收尾三選一
await client.session.share({ path: { id: session.data.id } })   // 生成分享連結
await client.session.summarize({ path: { id: session.data.id }, body: {} })
await opencode.server.close()
```

要點：`prompt()` 是**同步語意**——送出後等到代理回合結束才回來；`parts` 陣列就是第三冊第 4 章解剖過的內容切片。想中途取消用 `session.abort()`。

## 17.2 noReply：只塞上下文不驚動代理

`prompt()` 加 `noReply: true` 變成純注入〔文件〕：

```ts
await client.session.prompt({
  path: { id: session.data.id },
  body: {
    noReply: true,
    parts: [{ type: "text", text: "背景資料：本專案禁用 any，測試框架是 vitest。" }],
  },
})
```

用途：往進行中的會話補充約定、貼上長檔案、或外掛從外部餵事件摘要——模型下個回合自然讀到，但不會立刻產生一次昂貴的回覆。官方文檔明言這是外掛場景的推薦用法。

## 17.3 結構化輸出：json_schema 合約

讓模型「自由發揮」是腳本的天敵。SDK 支援帶 JSON Schema 的輸出合約〔文件〕：

```ts
const result = await client.session.prompt({
  path: { id: session.data.id },
  body: {
    parts: [{ type: "text", text: "研究這個 repo 的依賴健康度" }],
    format: {
      type: "json_schema",
      schema: {
        type: "object",
        properties: {
          riskLevel: { type: "string", description: "low|medium|high" },
          outdated: { type: "number", description: "過期依賴數量" },
          actions: { type: "array", items: { type: "string" } },
        },
        required: ["riskLevel", "outdated"],
      },
      retryCount: 2,
    },
  },
})

const out = result.data.info.structured_output
if (result.data.info.error?.name === "StructuredOutputError") {
  console.error("模型吐不出合格 JSON，已重試", result.data.info.error.retries, "次")
}
```

機制上模型是被給了一個 `StructuredOutput` 工具去填，填不合格式就重試（預設兩次）〔文件〕。四條官方最佳實踐值得抄進團隊規範：schema 欄位描述寫清楚、required 標必填、結構別嵌太深、retryCount 依任務複雜度調。有了這招，「AI 輸出接程式處理」從機率遊戲變成工程介面。

## 17.4 批次模式：多會話並行

真正的自動化是一次開 N 個會話分頭做事：

```ts
const targets = ["src/auth", "src/billing", "src/notifications"]

await Promise.all(targets.map(async (dir) => {
  const s = await client.session.create({ body: { title: `審查 ${dir}` } })
  await client.session.prompt({
    path: { id: s.data.id },
    body: {
      noReply: false,
      parts: [{ type: "text", text: `審查 ${dir} 目錄的錯誤處理品質，列出前三名問題。` }],
    },
  })
}))
```

每個會話在 DB 裡各自成樹（第三冊第 5 章的 parent_id 結構），互不污染上下文。配 `find.text()` 先掃出目標清單再動態生成批次，就是一支完整的「倉庫巡檢機」。注意供應商速率限制——並行數從小調起，失敗重試要有上限。

## 17.5 revert／unrevert：腳本裡的撤銷鍵

第三冊講過：每次工具呼叫前都有快照，revert 以標記而非刪除實現。從 SDK 看：

```ts
await client.session.revert({ path: { id, body: { messageID: targetMsgId } } })
// 反悔了？
await client.session.unrevert({ path: { id } })
```

批次腳本的標準防護：每個危險步驟後跑測試，不過就 revert 到該步之前、換提示詞重試。自動化不再怕「改壞了」，因為時間旅行是 API。

## 本章摘要 {.unnumbered .unlisted}

- create→prompt→messages→share/summarize 是單會話閉環；abort 可中斷
- noReply 注入上下文不觸發回覆，外部餵料的正門
- json_schema 格式＋StructuredOutput 工具＝可解析、可重試的 AI 輸出合約
- Promise.all 多會話並行即批次模式；速率限制要自備保險
- revert/unrevert 把快照撤銷變成自動化流程的控制流

## 下章預告 {.unnumbered .unlisted}

腳本是單向指揮；下一章加上耳朵——訂閱事件流做一個終端儀表板，即時看見所有會話的心跳，並順手用 tui 九法反向遙控介面。

## 延伸資源 {.unnumbered .unlisted}

- SDK 文檔：<https://opencode.ai/docs/sdk/>
