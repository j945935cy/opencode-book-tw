# 第 13 章　models：選型矩陣與多模型策略

第 12 章談供給來源；這一章談供給的調度——`opencode models` 怎麼查、`provider/model` 語法怎麼寫、以及一個團隊該如何為不同任務配不同檔位的模型。目標是建立一套不依賴特定型號壽命的選型方法。

## 13.1 查清單：models 命令

```bash
opencode models            # 全部可用模型
opencode models anthropic  # 只看某個供應商
```

輸出即時反映你已認證的供應商與其模型〔實測〕。TUI 內對應 `/models` 選擇器；SDK 對應 `config.providers()`（含各供應商預設模型的推薦表，第四冊附錄 B）。三條路查到的都是同一份真相——本機快取 `~/.cache/opencode/models.json`〔實測〕。

## 13.2 provider/model 語法

OpenCode 全書統一的模型識別格式：

```text
provider/model-id
anthropic/claude-sonnet-4-5
opencode/gpt-5.5          ← Zen 供應商前綴
github-copilot/claude...  ← 透過 Copilot 合約走 Claude
```

它出現在四個地方：全域設定的 `model` 欄位、代理 frontmatter 的 `model`、指令 frontmatter 的 `model`、以及 CLI 的 `-m` 旗標〔實測 --help〕。優先級從後往前蓋——旗標最臨時、設定最持久。記住這條鏈，就掌握了「這次到底用哪顆模型」的全部變數。

## 13.3 選型矩陣：任務配檔位

把第二冊的成本矩陣升級成團隊版。橫軸是任務性質，縱軸是模型檔位：

| 任務 | 建議檔位 | 理由 |
|------|----------|------|
| 會話標題生成 | nano／haiku／flash 級小模型 | 官方自己就用低階模型做這件事〔文件〕 |
| 計畫、審查、摘要 | 小型主力（plus/mini/flash 級） | 判斷力夠用，成本十分之一 |
| 實作、重構、疑難雜症 | 旗艦 codex/opus/max 級 | 工具迴圈的成敗在模型 |
| 批次巡檢（CI） | 中階＋嚴格 prompt |量大，單次品質要求可妥協 |

落地方式就是第四冊教的配置點組合：代理綁檔位（review 代理配中階）、指令覆寫模型（/quick-fix 配 mini）、experimental.provider.small_model 鉤子換掉標題生成的隱性消耗（第四冊 ch9）。

## 13.4 多供應商並存的現實

OpenCode 不鎖供應商，團隊常見的多源組合：

- **主力＋備援**：旗艦走 A 家，A 家限流或故障時手動切 B 家——`-m` 旗標一行切換
- **合約＋零售**：既有企業合約（BYOK 直結）跑固定工作負載，Zen 或其他零售管道接尖峰
- **免費試錯**：限時免費模型拿來練提示、測流程，機密內容除外（第 12 章的資料代價）

管理面提醒：每多一家供應商就多一份 auth.json 憑證要治理。第三冊講過該檔案的權限是 600——團隊機器上照舊，別為了方便改成群組可讀。

## 13.5 型號壽命與更新節奏

第 12 章的退役表揭示了殘酷現實：模型的生命週期以月計。選型方法的抗老化原則：

1. **配置裡引用角色而非型號**：團隊規範寫「審查代理用中階檔位」，具體 ID 收斂在一處集中維護
2. **季度巡檢**：把「核對 models 清單與退役公告」排進例行維運（第 9 章配方三正好可以讓代理自己幹）
3. **升級靠 A/B**：新旗艦上市別全隊盲切——兩週內讓半數成員雙軌使用，stats 數據說話

## 本章摘要 {.unnumbered .unlisted}

- 三處查清單：models 命令、/models、config.providers()；背後同一份快取
- provider/model 語法貫穿設定、代理、指令、CLI 四層，後者覆蓋前者
- 選型矩陣按任務配檔位；標題類小模型是官方慣例
- 多供應商是常態：主力備援、合約零售、免費試錯各有其位
- 抗老化三招：角色化引用、季度巡檢、A/B 升級

## 下章預告 {.unnumbered .unlisted}

燃料確定了，管線也要通。下一章處理網路的現實：公司代理、防火牆、離線環境——OpenCode 在受限網路裡怎麼活。

## 延伸資源 {.unnumbered .unlisted}

- 模型文檔：<https://opencode.ai/docs/models/>
