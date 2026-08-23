# 範例程式碼索引

本目錄收錄書中所有可執行範例，依冊別與章節歸檔。讀者可直接 clone 後照書操作。

## 目錄規劃

```
samples/
├── book1-intro/
│   ├── ch02-install/        安裝驗證腳本
│   └── ch08-exercises/      三個新手練習的起始專案
├── book2-practical/
│   ├── ch05-skills/         技能範例（SKILL.md）
│   ├── ch10-mcp/            MCP 設定範例
│   └── ch12-config/         設定設定檔範例
├── book3-architecture/
│   └── （以程式碼走讀為主，另見各章附錄）
├── book4-extension/
│   ├── ch04-mcp-server/     MCP 伺服器完整範例
│   ├── ch06-plugins/        外掛範例
│   └── ch07-custom-agent/   自訂代理範例
└── book5-stack/
    ├── ch04-projects-1-3/   部落格、待辦事項、天氣工具
    ├── ch05-projects-4-6/   任務API、圖片壓縮、視覺化面板
    ├── ch06-projects-7-9/   電商、聊天、機器人
    └── ch07-project-10/     SaaS 完整應用
```

## 使用約定

1. 每個專案子目錄必須包含獨立 `README.md`：說明對應書籍章節、執行步驟、預期輸出
2. 每個專案標註測試時的 OpenCode 凍結版本（見 `docs/version-freeze.md`）
3. 敏感資訊一律用環境變數或 `.env.example` 佔位
4. 授權：本目錄所有程式碼以 MIT 釋出

## 品質關卡

送審前每個範例必須通過：

- [ ] 在凍結版本上從零執行成功
- [ ] README 步驟與書中內容一致
- [ ] 無殘留個人資料或金鑰
