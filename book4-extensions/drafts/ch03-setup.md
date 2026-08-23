# 第 3 章　建造環境與除錯管道

寫外掛和寫一般程式最大的差別，不在語言而在「看得見看不見」。你的程式跑在 OpenCode 的進程裡，沒有終端機給你 `console.log`，出錯時也常只是安靜地不生效。這一章把建造環境一次備齊：依賴怎麼宣告、型別從哪來、以及三條讓外掛內部狀態現形的除錯管道。

## 3.1 依賴宣告：兩個 package.json

建造者會碰到兩種依賴場景，位置不同：

**場景一：本地外掛要用第三方套件。** 在設定目錄（全域 `~/.config/opencode/` 或專案 `.opencode/`）放一份 `package.json`：

```json
{
  "dependencies": {
    "shescape": "^2.1.0"
  }
}
```

OpenCode 啟動時偵測到它就執行 `bun install`〔文件〕。之後外掛裡 `import { escape } from "shescape"` 直接可用。

**場景二：只想引入型別。** 外掛開發強烈建議裝官方型別套件——本書撰寫環境就是這麼做的〔實測〕：

```bash
cd ~/.config/opencode && bun add -d @opencode-ai/plugin
```

`@opencode-ai/plugin` 匯出的 `Plugin` 型別會讓編輯器對每一個鉤子的輸入輸出即時補全。這包型別同時重匯出 `@opencode-ai/sdk` 的型別，所以 `client` 參數的方法簽名也一併齊備。

## 3.2 型別即文件

第三冊講過 OpenAPI 規格驅動的 SDK；外掛側同樣是規格驅動。翻開 `node_modules/@opencode-ai/plugin/dist/index.d.ts`，三百多行就把整個鉤子面講完了〔實測〕。本書最重要的參考結構有四個：

- `PluginInput`：外掛函式收到的資源包
- `Hooks`：十七個鉤子的完整介面
- `ToolDefinition`：自訂工具的形狀
- `TuiPluginApi`：介面層外掛能摸到的一切（510 行的 tui.d.ts）

遇到行為爭議時，d.ts 是比文檔更權威的一手資料——它跟著你安裝的版本走，不會騙人。本書附錄 A 的鉤子快查表就是從這份 d.ts 整理的。

## 3.3 除錯管道一：結構化日誌

外掛內部不要用 `console.log`——輸出會混進 TUI 畫面或直接消失。正確做法是透過 SDK 把日誌寫進 OpenCode 的日誌系統〔文件〕：

```ts
export const MyPlugin: Plugin = async ({ client }) => {
  await client.app.log({
    body: {
      service: "my-plugin",
      level: "info",
      message: "initialized",
      extra: { worktree: "/path/to/repo" },
    },
  })
  return {}
}
```

寫進去的日誌用第三冊第 19 章的方法看：啟動時加 `--print-logs --log-level DEBUG`，日誌以 logfmt 直印終端機；平時則躺在 `~/.local/share/opencode/log/opencode.log`。`service` 欄位填你的外掛名，過濾時一搜就中。

## 3.4 除錯管道二：事件流旁觀

第二條管道是被動觀察。寫一支只掛 `event` 鉤子的小外掛，把收到的每個事件類型記下來，就能摸清任何操作的「事件指紋」：

```ts
export const EventProbe = async ({ client }) => {
  return {
    event: async ({ event }) => {
      await client.app.log({
        body: { service: "probe", level: "debug", message: event.type },
      })
    },
  }
}
```

裝上之後正常操作 TUI：開新會話、送提示、批准權限、切主題。回頭看日誌，你會看到 `session.created`、`message.part.updated`、`permission.asked`……每個動作背後的事件序列一目了然。第 10 章的完整事件類型表，就是用這招驗證出來的。

## 3.5 除錯管道三：隔離測試場

第三條管道是別弄髒真環境。兩個習慣：

- **專案沙盒**：所有範例都放在測試專案的 `.opencode/` 裡練，玩壞了刪目錄重來
- **獨立埠伺服器**：涉及 SDK 的章節（第五篇）用 `opencode serve --port 4311` 開乾淨實例，curl 與腳本打這個埠，不干擾日常會話

另外提醒 Windows 讀者：外掛在 WSL 下跑得好好的，換到原生 Windows 可能因路徑分隔線踩雷；反之亦然。跨平台外掛的路徑一律用 `path.join` 拼，別手寫斜線〔文件〕。

## 3.6 版本策略一句話

外掛發布前的最後一道檢查：確認你引用的鉤子在目標讀者的 CLI 版本上存在。`experimental.*` 開頭的六個鉤子尤其如此——它們可能在任何小版本被改名或移除。商業等級的外掛請在 README 寫死支援的版本區間，消費端則避免無腦 `@latest`（第 12 章細談）。

## 本章摘要

- 本地外掛的第三方依賴：設定目錄放 `package.json`，啟動時 Bun 自動安裝
- `@opencode-ai/plugin` 提供全部型別；d.ts 是最權威的一手文件
- 除錯三管道：`client.app.log()` 結構化日誌、event 探針旁觀事件流、沙盒與獨立埠隔離
- 日誌檢視方法承接第三冊 logfmt 取證法
- experimental 鉤子隨時會變，發布前鎖定版本區間

## 下章預告 {.unnumbered .unlisted}

工坊備齊，先從不用寫程式的擴充玩起。下一章上手的自訂指令，可能是一般使用者投資報酬率最高的擴充點——一段 Markdown 就能把重複十次的長提示變成四個鍵。

## 延伸資源 {.unnumbered .unlisted}

- 外掛依賴說明：<https://opencode.ai/docs/plugins/>
- SDK 文檔：<https://opencode.ai/docs/sdk/>
