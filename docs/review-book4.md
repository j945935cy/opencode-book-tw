# 《OpenCode 擴展開發》技術審稿報告

- 審稿日期：2026-08-24
- 驗證版本：opencode-ai 1.18.21；@opencode-ai/plugin 1.18.5（本機設定目錄釘選）；@opencode-ai/sdk 1.18.21
- 方法：URL 全查、CLI 實測、SDK 型別對照（安裝於本機的 d.ts/gen 為準繩）、外掛 API 對照 d.ts

## 一、總評

**通過（含一項已修正的 URL 主張）。**

全書主張——17 支鉤子、TUI 外掛能力面、Skills 規格、指令插值語法、SDK 方法面——撰寫期間即以本機 d.ts 與官方文檔逐條核對；審稿複檢確認無誤。

## 二、URL 審查：17/18 通過，1 项已修正

| 結果 | 說明 |
|------|------|
| 200 ×17 | opencode.ai 文檔群（agents/commands/config/custom-tools/ecosystem/permissions/plugins/policies/sdk/skills/themes/docs）＋config.json＋tui.json＋agentclientprotocol.com＋bun.com |
| **404** | `https://opencode.ai/theme.json`——官方文檔範例引用的主題 schema 位址 |

**修正**：ch13 原主張「掛 $schema 可獲得編輯器補全與驗錯」，因該 URL 實測 404 而不成立。已改寫為誠實版本：欄位可留作自我標註，但不承諾編輯器輔助。

## 三、CLI 主張抽查

| 主張 | 實測 |
|------|------|
| `opencode agent create`（ch6） | help 存在："create a new agent" ✓ |
| `opencode models`（ch6） | 存在："list all available models" ✓ |

## 四、外掛 API 主張（對照本機 index.d.ts/tool.d.ts/tui.d.ts）

- Hooks 十七支清單與簽名（附錄 A）：與 1.18.5 d.ts 一致〔實測〕
- PluginInput 七鑰匙、ToolContext 欄位（含 metadata()/ask()）、ToolAttachment attachments：吻合
- TuiPluginApi 能力七類（路由/鍵盤/指令/四對話框/toast/slots/側欄）與六音效名：tui.d.ts 吻合
- WorkspaceAdapter 五方法與 local/remote target：d.ts 吻合

## 五、SDK 主張（對照本機 sdk dist）

| 主張 | 核驗 |
|------|------|
| session.children / prompt noReply | types.gen.d.ts 命中 ✓ |
| structured output / StructuredOutputError | types.gen.d.ts、sdk.gen.js 命中 ✓ |
| tui 九法端點 | gen 中 append-prompt/clear-prompt/execute-command/open-help/open-models/open-sessions/open-themes/show-toast/submit-prompt 全數命中 ✓ |

## 六、其他事實核驗

- 快取位置差異：文檔稱 `~/.cache/opencode/node_modules/`，本機實況為 `packages/<名>@<版>/`——書中 ch2/ch12 以實測形態為準並明註差異（誠實處理，非錯誤）
- Skills 六搜尋路徑、frontmatter 欄位與名稱正則：與官方 skills 文檔一致；本機 ebook-publish SKILL.md 為活體佐證
- 指令插值 `$ARGUMENTS`/`$1..$n`/`` !`cmd` ``/`@file`：與 commands 文檔一致
- 主題鍵位群、覆蓋序、truecolor 主張：與 themes 文檔一致

## 七、結論

- 書稿可信度高：建造者主張全部有一手依據（d.ts 或官方文檔），快取位置等文檔與實況不一致處已如實並陳
- 已修正：theme.json schema URL 的 404 主張（ch13 一處）
- 成品：PDF 60 頁/833K、EPUB 116K、TOC 133 項零殘留

— 審稿：Happy eBook Authors 技術編輯管線（自動化實測）
