# 第 6 章　代理深度客製

第二冊教你寫出第一支代理；這一章用建造者的眼光重新打開它。代理不只是「一段系統提示加一個名字」——它是 OpenCode 裡**權限、模型、步數、可呼叫子代理的總裝配點**。把 frontmatter 的每個欄位當成工程參數來調，你就能造出「只准看不准改」的審計代理、「只能跑 git 唯讀命令」的守門代理，甚至一支會指揮其他代理的總管。

## 6.1 兩種身分：主代理與子代理

代理有兩種身分〔文件〕。主代理（primary）是你直接對話的對象，Tab 鍵循環切換；子代理（subagent）由主代理透過 Task 工具自動派遣，或你用 `@` 提及手動叫喚。內建陣容：主代理 Build（全工具）與 Plan（編輯和 bash 預設 ask）；子代理 General（多步驟通用）、Explore（唯讀探勘）、Scout（唯讀外部依賴研究——它能把依賴庫克隆進受管理的快取再比對原始碼）。另有三個隱藏系統代理：compaction（壓縮長上下文）、title（生成標題）、summary（會話摘要），不會出現在選擇器裡。

`mode` 欄位決定身分：`primary`、`subagent` 或 `all`（預設，兩邊都能用）。加上 `hidden: true` 可以讓子代理從 `@` 自動完成選單隱身——只留給其他代理以 Task 工具程式化呼叫，適合內部零件〔文件〕。

## 6.2 frontmatter 全欄位速覽

Markdown 代理放在專案 `.opencode/agents/` 或全域 `~/.config/opencode/agents/`，檔名即代理名：

```markdown
---
description: 程式碼審查，唯讀
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
steps: 30
permission:
  edit: deny
  bash:
    "*": ask
    "git diff*": allow
    "git log*": allow
---
你是程式碼審查模式。只分析與建議，不做任何修改。
```

| 欄位 | 作用 |
|------|------|
| `description` | 必填；主代理派遣子代理時就靠這段描述判斷派誰 |
| `mode` | primary／subagent／all |
| `model` | `provider/model-id`；未指定時子代理繼承派遣者 |
| `temperature`／`top_p` | 取樣控制；審查類給低值，腦力激盪給高值 |
| `steps` | 代理迴圈上限，到頂強制改以文字收尾——成本保險絲 |
| `prompt` | 可指向外部檔案 `{file:./prompts/review.txt}`，路徑相對設定檔 |
| `permission` | 能力閘門，見 6.3 |
| `disable` | `true` 停用該代理 |
| `color` | UI 辨識色（hex 或主題色票名） |

舊式的 `tools:` 欄位已標記棄用，新配置一律改用 `permission`〔文件〕——兩者語意不同：tools 是開關，permission 是三態閘門且支援萬用字元細控。

## 6.3 權限工程：三態與最後符合者勝

`permission` 的每個鍵對應一組工具，值是 `allow`／`ask`／`deny` 三態。可用鍵涵蓋 read、edit（含 write/edit/apply_patch）、bash、task、webfetch、websearch、lsp、skill、question、todowrite、external_directory 等〔文件〕。

精髓在**物件型細控**：值可以是「模式 → 動作」的表，規則依序評估、**最後符合者勝**：

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status*": "allow",
      "git push": "ask"
    },
    "mymcp_*": "deny"
  }
}
```

三個實戰要點。第一，萬用字元同樣作用於自訂工具與 MCP 工具名——`"mymcp_*": "deny"` 一行封鎖整個 MCP 伺服器的所有工具。第二，`external_directory` 鍵管的是「碰工作樹以外路徑」的任何工具，沙盒政策的關鍵閘門。第三，`doom_loop` 是偵測代理疑似卡死時的恢復提示開關。

## 6.4 總管模式：task 權限面

`permission.task` 控制這支代理能派遣哪些子代理，同樣吃萬用字元〔文件〕：

```json
{
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "permission": {
        "task": {
          "*": "deny",
          "orchestrator-*": "allow",
          "code-reviewer": "ask"
        }
      }
    }
  }
}
```

被 `deny` 的子代理會從 Task 工具的描述中整個移除——模型根本不知道它存在，從源頭杜絕誤派。這就是**編隊模式**的骨架：一支總管代理配一群 `orchestrator-` 前綴的專職工人，外人進不來、工人跑不掉。注意例外：使用者永遠可以自己用 `@` 叫任何子代理，task 權限只約束代理對代理的派遣。

## 6.5 成本與品質的旋鈕

同一套工作流在不同環節該用不同檔位的模型。實務配方：計畫與審查用小模型低溫度（`plan` 配 haiku 級、`temperature: 0.1`）、實作用旗艦、腦力激盪開高溫度。`steps` 是第二道保險——到達上限時代理收到特殊系統提示，被要求總結已完成的工作並列出剩餘任務，而不是無限燒錢〔文件〕。供應商私有參數（如 OpenAI 的 `reasoningEffort`）直接寫在 frontmatter 頂層就會原樣傳遞。

## 6.6 快速造一件：agent create

不想手寫 frontmatter，跑互動指令〔文件〕：

```bash
opencode agent create
```

它會問你存全域還是專案、描述用途、代擬系統提示與識別名、勾選要開放的權限（沒勾的全部拒絕），最後產出 Markdown 檔。把它當起點，之後手工微調 permission 物件。

## 本章摘要 {.unnumbered .unlisted}

- mode 定身分；hidden 讓內部子代理隱形；內建已有五明三暗八支代理
- permission 三態＋物件細控＋最後符合者勝，覆蓋內建、MCP 與自訂工具
- `permission.task` 萬用字元編排子代理派遣權，deny 即從工具描述移除
- steps 是成本保險絲，model/temperature 分檔位是品質旋鈕
- 目錄：`.opencode/agents/`（複數），檔名即代理名

## 下章預告 {.unnumbered .unlisted}

提示層的功夫到這裡告一段落。下一章起進入程式碼層：寫出你的第一支外掛，認識外掛函式收到的資源包與十七個鉤子的全景地圖。

## 延伸資源 {.unnumbered .unlisted}

- 代理文檔：<https://opencode.ai/docs/agents/>
- 權限文檔：<https://opencode.ai/docs/permissions/>
