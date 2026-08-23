# 第 13 章　主題設計

配色是最誠實的擴充點——改得好不好，一眼就見分曉。OpenCode 的主題是一份 JSON 色盤，支援明暗雙軌、色票引用與 ANSI 降級。本章從規格講到實作，帶你做出一套「叢書綠」主題：和本系列封面同一個薄荷綠。

## 13.1 先決條件與內建清單

主題要完整顯色，終端機必須支援 **truecolor**（24 位元色彩）〔文件〕。檢查方法：

```bash
echo $COLORTERM   # 應輸出 truecolor 或 24bit
```

不支援時會降級到最近的 256 色近似，細膩的色階會失真。

不想自製也有十一種以上內建可選〔文件〕：system、tokyonight、everforest、ayu、catppuccin、catppuccin-macchiato、gruvbox、kanagawa、nord、matrix、one-dark……切換方式兩條：TUI 的 `/theme` 選擇器，或 `tui.json` 寫死：

```json
{ "$schema": "https://opencode.ai/tui.json", "theme": "tokyonight" }
```

其中 `system` 值得特別一提：它不用固定色，而是讀取你終端機的背景色生成灰階、沿用 ANSI 0–15 色做語法高亮、文字與背景全部交還終端機預設（`none`）。重度終端機客製玩家的最愛——OpenCode 從此隱形，融入你既有的配色哲學。

## 13.2 四層覆蓋序

自訂主題是放對位置的 JSON 檔，同名時高層蓋低層〔文件〕：

1. 內建主題（編譯進程式裡）
2. 使用者層：`~/.config/opencode/themes/*.json`（或 `$XDG_CONFIG_HOME`）
3. 專案根：`<專案根>/.opencode/themes/*.json`
4. 當前目錄：`./.opencode/themes/*.json`

第 2 層是個人品味，第 3、4 層是團隊統一——把品牌主題放進倉庫的 `.opencode/themes/`，全隊的 OpenCode 從此長同一張臉。

## 13.3 格式五要素

一份主題 JSON 由五種語言零件組成〔文件〕：

- **十六進位**：`"#ffffff"`，最直覺
- **ANSI 編號**：`"3"` 或 `"245"`（0–255），終端機調色盤索引
- **引用**：`"primary"` 引用其他鍵的值；`defs` 區可自訂色票名再全檔引用
- **明暗雙軌**：`{"dark": "#000", "light": "#fff"}`，跟隨終端機深淺自動切換
- **none**：透明，交回終端機預設

檔頭掛 `$schema: "https://opencode.ai/theme.json"` 可獲得編輯器補全與驗錯。

## 13.4 鍵位地圖

`theme` 物件下的鍵分四群〔文件範例整理〕：

| 群 | 鍵 |
|----|----|
| 語意 UI | primary、secondary、accent、error、warning、success、info、text、textMuted |
| 背景 | background、backgroundPanel、backgroundElement |
| 邊框 | border、borderActive、borderSubtle |
| Diff | diffAdded／Removed／Context／HunkHeader／HighlightAdded／HighlightRemoved、diffAddedBg、diffRemovedBg、diffContextBg、diffLineNumber、diffAddedLineNumberBg、diffRemovedLineNumberBg |
| Markdown | markdownText／Heading／Link／LinkText／Code／BlockQuote／Emph／Strong／HorizontalRule／ListItem／ListEnumeration／Image／ImageText／CodeBlock |
| 語法 | syntaxComment／Keyword／Function／Variable／String／Number／Type／Operator／Punctuation |

不必一次填滿——未指定的鍵會有合理 fallback。實務順序：先定 background／text／primary 三大件定調，再補 diff 四色（日常最有感），最後雕語法九色。

## 13.5 實作：叢書綠主題

用本系列封面的三個顏色造一套主題〔文件格式＋自訂值〕：

```json
{
  "$schema": "https://opencode.ai/theme.json",
  "defs": {
    "ink": "#0A0E14",
    "panel": "#0F172A",
    "mint": "#3DDC97",
    "cyan": "#22D3EE",
    "dim": "#9FB0C3",
    "paper": "#E6EDF3"
  },
  "theme": {
    "background": { "dark": "ink", "light": "paper" },
    "backgroundPanel": { "dark": "panel", "light": "#FFFFFF" },
    "text": { "dark": "paper", "light": "ink" },
    "textMuted": { "dark": "dim", "light": "#66788F" },
    "primary": { "dark": "mint", "light": "#0B8A5C" },
    "secondary": { "dark": "cyan", "light": "#0E7490" },
    "accent": { "dark": "cyan", "light": "#0E7490" },
    "error": { "dark": "#FF5F57", "light": "#B91C1C" },
    "warning": { "dark": "#FEBC2E", "light": "#A16207" },
    "success": { "dark": "mint", "light": "#15803D" },
    "border": { "dark": "#1E293B", "light": "#CBD5E1" }
  }
}
```

存成 `~/.config/opencode/themes/book-green.json`，`/theme` 選 `book-green` 即生效。`defs` 讓封面色與介面色同源——改一行 mint，整個工作環境跟著換季。淺色軌刻意壓深綠而非原薄荷：亮底上太淺的主色會失去對比，**雙軌不是複製貼上，是各自成立**。

## 13.6 驗收清單

主題做完跑一遍這些畫面再收工：diff 檢視（四色是否分明）、Markdown 渲染的標題與行內碼、權限詢問對話框（error/warning 是否醒目）、淺色終端下的整體可讀性。主題是給眼睛用的，最終裁判不是 schema 而是你的疲勞度。

## 本章摘要 {.unnumbered .unlisted}

- truecolor 是前提；十一種以上內建主題兜底，`/theme` 或 tui.json 切換
- 四層覆蓋序：內建 → 使用者層 → 專案根 → 當前目錄
- 五要素：hex、ANSI、引用＋defs、明暗雙軌、none
- 鍵位四群：語意 UI／背景邊框、Diff 十二鍵、Markdown 十四鍵、語法九鍵
- 先三大件、再 Diff、後語法；雙軌各自設計不複製

## 下章預告 {.unnumbered .unlisted}

換色只是妝容。下一章動手術：TUI 外掛能加路由、綁快捷鍵、註冊指令、彈對話框、插側欄面板——把 OpenCode 的介面當成你的畫布。

## 延伸資源 {.unnumbered .unlisted}

- 主題文檔：<https://opencode.ai/docs/themes/>
