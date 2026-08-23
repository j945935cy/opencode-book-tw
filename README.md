# OpenCode 技術叢書（繁體中文版）

系統性、深度化、實戰型的 OpenCode 學習資源，涵蓋從入門到精通的完整學習路徑。

## 叢書總覽

| 冊序 | 書名 | 定位 | 難度 | 狀態 |
|------|------|------|------|------|
| 第一冊 | 《OpenCode 入門指南》 | 30分鐘快速上手 | ⭐⭐ | 🚧 大綱定稿 |
| 第二冊 | 《OpenCode 實戰寶典》 | 系統學習完整功能 | ⭐⭐⭐ | 📝 規劃中 |
| 第三冊 | 《OpenCode 架構解密》 | 內部設計深度解析 | ⭐⭐⭐⭐⭐ | 📝 規劃中 |
| 第四冊 | 《OpenCode 擴展開發》 | 打造專屬工具鏈 | ⭐⭐⭐⭐ | 📝 規劃中 |
| 第五冊 | 《The OpenCode Stack》 | 省錢出活週末實戰 | ⭐⭐⭐ | 📝 規劃中 |

## 目錄結構

```
├── book1-intro/           第一冊：入門指南（大綱＋書稿）
├── book2-practical/       第二冊：實戰寶典
├── book3-architecture/    第三冊：架構解密
├── book4-extension/       第四冊：擴展開發
├── book5-stack/           第五冊：省錢實戰
├── samples/               書中範例程式碼（依章節歸節歸檔）
├── templates/             撰寫模板
├── glossary/              術語表（台灣慣用詞對照）
├── docs/                  撰寫規範、版本凍結記錄
└── errata/                勘誤表（另見 GitHub Issues）
```

## 工作流程

1. **版本凍結**：全書範例固定於特定 OpenCode 穩定版，詳見 `docs/version-freeze.md`
2. **撰寫**：依 `templates/chapter-template.md` 格式，書稿置於各冊目錄 `drafts/`
3. **審稿**：技術審稿者逐條重現書中指令，勘誤以 GitHub Issues 回報
4. **出版**：Pandoc 轉出 PDF / EPUB / 印刷檔

## 讀者服務

- **勘誤回報**：請開 Issue，標註 `[勘誤] 冊別-章節`
- **範例下載**：`samples/` 目錄依冊別章節歸檔，可整包 clone
- **內容更新**：OpenCode 改版時，變更摘要發布於 Releases

## 授權

書籍內容著作權保留（All Rights Reserved）。
範例程式碼以 [MIT License](LICENSE-CODE) 釋出，方便讀者自由取用。
