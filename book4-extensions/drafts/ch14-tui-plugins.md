# 第 14 章　TUI 外掛：把介面當畫布

核心外掛改行為，TUI 外掛改長相與互動。它跑在終端機渲染層，能註冊路由頁面、綁快捷鍵、加斜線指令、彈四種對話框、插側欄資訊——本質上你拿到的是 OpenCode 介面的插件式 UI 框架。本章導覽 `TuiPluginApi` 的完整地圖（依 510 行的 tui.d.ts〔實測〕整理）。

## 14.1 TUI 外掛的形狀

TUI 外掛同樣從 `.opencode/plugins/` 或 npm 載入，但匯出形態多一個 `tui` 欄位〔實測自 d.ts〕：

```ts
import type { TuiPlugin, TuiPluginModule } from "@opencode-ai/plugin"

export const MyPanel: TuiPlugin = async (api, options, meta) => {
  // api 是整個介面的控制台
}

export const MyPluginModule: TuiPluginModule = {
  server: ServerSideHooks,
  tui: MyPanel,
}
```

一個模組可以同時帶 server 側（第 7 章的鉤子）與 tui 側（本章）——這就是 oh-my-openagent 那類生態外掛的組織方式：後端邏輯與介面元素住在同一包裡。

`meta` 告知安裝狀態（first／updated／same），可用來做「升級後顯示更新說明」；`options` 接住設定檔裡 `[套件名, options]` 陣列寫法傳入的參數。清理用回傳的 dispose 生命週期鉤子。

## 14.2 能加什麼：API 地圖

`TuiPluginApi` 的能力面按用途分七類：

| 類別 | 能做什麼 |
|------|----------|
| 路由 | 註冊新頁面（TuiRouteDefinition），有自己的渲染樹 |
| 鍵盤 | keymap／binding 系統，序列鍵（如 `<leader>x`）也能綁 |
| 指令 | 註冊進指令面板的新命令（TuiCommand） |
| 對話框 | alert、confirm、prompt、select 四件套 |
| 提示區 | 自訂 prompt 元件與 toast 通知 |
| 版面槽位 | slots 系統：把元件插進宿主預留的位置 |
| 側欄 | 新增 MCP／LSP／待辦／檔案之外的自訂資訊條目 |

底層是 `@opentui/core` 的 Renderable 渲染體系——型別直接從 plugin 包重匯出，不必另裝依賴就能寫出完整的終端 UI 元件。

## 14.3 實作：一支「今日焦點」面板

概念串接示範（骨架，展示 API 形狀而非完整可跑程式）：

```ts
import type { TuiPlugin } from "@opencode-ai/plugin"

export const FocusBoard: TuiPlugin = async (api) => {
  api.registerCommand({
    name: "focus",
    description: "開啟今日焦點面板",
    handler: async () => {
      const choice = await api.dialog.select({
        title: "今天的主戰場",
        options: ["修 bug", "寫新功能", "清技術債"],
      })
      if (choice) {
        await api.toast.show({ message: `今日聚焦：${choice}`, variant: "success" })
        api.state.set("focus", choice)
      }
    },
  })

  return async () => {
    // dispose：卸載鍵盤綁定與渲染節點
  }
}
```

四步驟的心智流程：**註冊入口**（指令或快捷鍵）→ **互動**（對話框收集輸入）→ **存狀態**（state 或外部檔案）→ **回饋**（toast）。任何面板需求都能拆進這個循環。

## 14.4 slots：不搶版位的擴充哲學

slots 是 TUI 外掛設計裡最優雅的部分：宿主介面預先留好若干插槽，外掛宣告「我要插哪個槽」而不是「我要蓋掉哪塊版」。多支外掛各自插各自的槽，互不打架〔實測自 d.ts 的 TuiSlotPlugin／TuiSlotMap〕。

設計自己的 TUI 外掛時遵守同一哲學：能用 toast 就別開新頁、能塞現有槽就別自畫全屏。終端機的可貴空間有限，克制是專業感的一部分。

## 14.5 除錯 TUI 外掛

介面程式最怕死給你看。三招保命：

1. **日誌照舊**：tui 側同樣能用 client.app.log()（透過 serverUrl 或 SDK），出事看 logfmt 日誌
2. **漸進上線**：先用純 toast＋dialog 做互動閉環，確認生命週期無誤，再上自訂渲染樹
3. **dispose 必寫**：TUI 外掛持有渲染節點與鍵盤綁定，不清理會殘影或攔鍵——每次 register 都配對一次 cleanup

## 本章摘要 {.unnumbered .unlisted}

- TuiPluginModule 同時裝 server 鉤子與 tui 函式；meta 報安裝狀態
- 七類能力：路由、鍵盤、指令、四種對話框、toast、slots、側欄；底層 @opentui/core
- 標準循環：註冊入口→對話框互動→存狀態→toast 回饋
- slots 哲學：插槽不蓋版，多外掛和平共存
- 先互動閉環再上渲染，dispose 與註冊配對

## 下章預告 {.unnumbered .unlisted}

介面有了，還差「叫得動你」的機制。下一章研究注意力系統：OpenCode 怎麼判斷該不該提醒你、六種事件音效怎麼換成自己的一套、以及無人值守長任務的桌面整合。

## 延伸資源 {.unnumbered .unlisted}

- 外掛文檔：<https://opencode.ai/docs/plugins/>
