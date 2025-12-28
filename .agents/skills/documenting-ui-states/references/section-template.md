# UI状態セクション テンプレート

spec.md の「UI状態」セクションに挿入する内容のテンプレートです。

---

## セクション全体

```markdown
## UI状態

> **ステータス**: 完了 ✓  
> **生成スキル**: documenting-ui-states  
> **更新日**: {{DATE}}

### 状態一覧

| 状態 | 条件 | Figma Node |
|------|------|------------|
| default | {{DEFAULT_CONDITION}} | `{{DEFAULT_NODE_ID}}` |
| empty | {{EMPTY_CONDITION}} | `{{EMPTY_NODE_ID}}` |
| loading | {{LOADING_CONDITION}} | `{{LOADING_NODE_ID}}` |
| error | {{ERROR_CONDITION}} | `{{ERROR_NODE_ID}}` |

### 状態詳細

#### default

| 項目 | 内容 |
|------|------|
| 条件 | {{DEFAULT_CONDITION}} |
| 表示内容 | {{DEFAULT_DISPLAY}} |
| Figma Node | `{{DEFAULT_NODE_ID}}` |

#### empty

| 項目 | 内容 |
|------|------|
| 条件 | {{EMPTY_CONDITION}} |
| 表示内容 | {{EMPTY_DISPLAY}} |
| Figma Node | `{{EMPTY_NODE_ID}}` |
| default との差分 | {{EMPTY_DIFF}} |

#### loading

| 項目 | 内容 |
|------|------|
| 条件 | {{LOADING_CONDITION}} |
| 表示内容 | {{LOADING_DISPLAY}} |
| Figma Node | `{{LOADING_NODE_ID}}` |
| default との差分 | {{LOADING_DIFF}} |

#### error

| 項目 | 内容 |
|------|------|
| 条件 | {{ERROR_CONDITION}} |
| 表示内容 | {{ERROR_DISPLAY}} |
| Figma Node | `{{ERROR_NODE_ID}}` |
| default との差分 | {{ERROR_DIFF}} |

### 未定義状態

| 状態 | 必要性 | 理由 | 推奨対応 |
|------|--------|------|----------|
| {{UNDEFINED_STATE}} | {{PRIORITY}} | {{REASON}} | {{RECOMMENDATION}} |

**必要性の凡例**: 🔴 高（必須） / 🟡 中（推奨） / 🟢 低（任意）

### 状態遷移図

\```mermaid
stateDiagram-v2
    [*] --> loading: 画面表示
    loading --> default: データあり
    loading --> empty: データなし
    loading --> error: API失敗
    error --> loading: リトライ
    default --> loading: リフレッシュ
    empty --> loading: リフレッシュ
\```

### 状態遷移表

| From | To | トリガー | 条件 | 備考 |
|------|-----|----------|------|------|
| [*] | loading | 画面表示 | - | 初期状態 |
| loading | default | APIレスポンス | 成功 & データあり | |
| loading | empty | APIレスポンス | 成功 & データなし | |
| loading | error | APIレスポンス | 失敗 | |
| error | loading | リトライボタン | - | |
| default | loading | リフレッシュ | - | Pull-to-refresh等 |

### 状態別の主要要素

| 要素 | default | empty | loading | error |
|------|:-------:|:-----:|:-------:|:-----:|
| ヘッダー | ✓ | ✓ | ✓ | ✓ |
| コンテンツリスト | ✓ | - | スケルトン | - |
| 空状態メッセージ | - | ✓ | - | - |
| エラーメッセージ | - | - | - | ✓ |
| リトライボタン | - | - | - | ✓ |
| ローディング表示 | - | - | ✓ | - |
```

---

## 変数一覧

| 変数 | 説明 |
|------|------|
| `{{DATE}}` | 更新日 |
| `{{XXX_CONDITION}}` | 状態になる条件 |
| `{{XXX_DISPLAY}}` | 表示内容の説明 |
| `{{XXX_NODE_ID}}` | FigmaノードID |
| `{{XXX_DIFF}}` | default状態との差分 |
| `{{UNDEFINED_STATE}}` | 未定義の状態名 |
| `{{PRIORITY}}` | 必要性（🔴/🟡/🟢） |
| `{{REASON}}` | 必要な理由 |
| `{{RECOMMENDATION}}` | 推奨対応 |

---

## spec.md 更新時の追加変更

セクション更新と同時に以下も更新：

### 1. 完了チェックリスト

```markdown
- [x] UI状態 (documenting-ui-states)
```

### 2. 変更履歴

```markdown
| {{DATE}} | UI状態 | documenting-ui-statesにより生成 |
```
