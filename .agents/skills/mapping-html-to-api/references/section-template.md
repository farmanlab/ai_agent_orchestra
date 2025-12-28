# APIマッピングセクション テンプレート

spec.md の「APIマッピング」セクションに挿入する内容のテンプレートです。

---

## セクション全体（API連携あり）

```markdown
## APIマッピング

> **ステータス**: 完了 ✓  
> **生成スキル**: mapping-html-to-api  
> **更新日**: {{DATE}}

### 使用API一覧

| エンドポイント | メソッド | 用途 | 呼び出しタイミング |
|---------------|---------|------|------------------|
| {{ENDPOINT}} | {{METHOD}} | {{PURPOSE}} | {{TIMING}} |

### データバインディング

#### {{METHOD}} {{ENDPOINT}}

**リクエスト**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|:----:|------|
| {{PARAM_NAME}} | {{PARAM_TYPE}} | {{REQUIRED}} | {{PARAM_DESC}} |

**レスポンス**

\`\`\`typescript
{{RESPONSE_TYPE}}
\`\`\`

**UIマッピング**

| UI要素 | data-figma-content | APIフィールド | 変換 |
|--------|-------------------|--------------|------|
| {{UI_ELEMENT}} | {{DATA_ATTR}} | {{API_FIELD}} | {{TRANSFORM}} |

### API呼び出しタイミング

| タイミング | API | トリガー | 備考 |
|----------|-----|---------|------|
| {{TIMING}} | {{API}} | {{TRIGGER}} | {{NOTE}} |

### エラーハンドリング

| HTTPステータス | エラー種別 | UI対応 |
|--------------|----------|--------|
| {{STATUS}} | {{ERROR_TYPE}} | {{UI_ACTION}} |

### 特記事項

- {{NOTE_1}}
```

---

## セクション全体（API連携なし）

```markdown
## APIマッピング

> **ステータス**: 該当なし  
> **生成スキル**: mapping-html-to-api  
> **更新日**: {{DATE}}

この画面にはAPI連携がありません。
```

---

## spec.md 更新時の追加変更

### 1. 完了チェックリスト

```markdown
- [x] APIマッピング (mapping-html-to-api)
```

### 2. 変更履歴

```markdown
| {{DATE}} | APIマッピング | mapping-html-to-apiにより生成 |
```
