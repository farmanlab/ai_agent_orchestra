---
name: managing-screen-specs
description: Initializes and updates screen specification documents. Use as a foundation skill for all screen documentation workflows.
allowed-tools: [Read, Write, Glob]
---

# Screen Spec Management Skill

画面仕様書の初期化とセクション更新を管理するヘルパースキルです。

## 概要

各スキル（converting-figma-to-html, documenting-ui-states等）は、このスキルの手順に従って画面仕様書を更新します。

## ファイル構造

```
.agents/
├── templates/
│   ├── screen-spec.md          # 概要仕様書テンプレート（PM/全員向け）
│   ├── screen-spec-visual.md   # ビジュアル仕様書テンプレート（デザイナー/開発者向け）
│   └── screen-spec-behavior.md # 動作仕様書テンプレート（開発者/QA向け）
└── tmp/
    └── {screen-id}/
        ├── spec.md             # 概要仕様書
        ├── spec-visual.md      # ビジュアル仕様書
        ├── spec-behavior.md    # 動作仕様書
        ├── index.html          # 参照用HTML
        └── assets/             # 画像等のアセット
```

### 3ファイル構成の役割分担

| ファイル | 対象読者 | 含まれるセクション |
|----------|----------|-------------------|
| spec.md | PM、全員 | 概要、画面フロー、生成ファイル一覧、変更履歴 |
| spec-visual.md | デザイナー、開発者 | 構造・スタイル、コンテンツ分析、UI状態、デザイントークン |
| spec-behavior.md | 開発者、QA | インタラクション、フォーム仕様、APIマッピング、アクセシビリティ |

## テンプレート構造

3つの仕様書ファイルで構成されます：

### spec.md（概要仕様書）

| セクション | 説明 |
|-----------|------|
| 概要 | 画面の基本情報（名前、Figma URL、HTML、説明） |
| 画面フロー | mermaid stateDiagram-v2と遷移テーブル |
| 生成ファイル一覧 | 関連ファイルの一覧 |
| 変更履歴 | 日付、変更内容、担当の履歴 |

### spec-visual.md（ビジュアル仕様書）

| セクション | 説明 |
|-----------|------|
| 構造・スタイル | HTML構造とdata-figma属性 |
| コンテンツ分析 | 静的/動的コンテンツの分類とAPI依存 |
| UI状態 | デフォルト状態、ボタン状態、タブ状態など |
| デザイントークン | カラー、タイポグラフィ、スペーシング |

### spec-behavior.md（動作仕様書）

| セクション | 説明 |
|-----------|------|
| インタラクション | INT-XXX形式でトリガー、アクション、遷移先を定義 |
| フォーム仕様 | 入力バリデーション、送信処理 |
| APIマッピング | APIエンドポイントとの関連付け |
| アクセシビリティ | セマンティック要件、フォーカス管理、キーボード操作 |

## ワークフロー

### 1. 仕様書の初期化

新しい画面の仕様書を作成する場合、3つのファイルを初期化：

```bash
# テンプレートをコピー
cp .agents/templates/screen-spec.md .outputs/{screen-id}/spec.md
cp .agents/templates/screen-spec-visual.md .outputs/{screen-id}/spec-visual.md
cp .agents/templates/screen-spec-behavior.md .outputs/{screen-id}/spec-behavior.md

# 全ファイル共通の基本情報を置換
- {{SCREEN_NAME}} → 画面名
- {{SCREEN_ID}} → 画面識別子
- {{FIGMA_URL}} → Figma URL
- {{HTML_FILE}} → HTMLファイル名
- {{ROOT_NODE_ID}} → ノードID
- {{DATE}} → 作成日
- {{DESCRIPTION}} → 画面の説明
```

### 2. セクションの更新

各スキルは担当セクションのみを更新します。

#### 更新手順

1. **セクション位置を特定**

```markdown
## {セクション名}

### {サブセクション名}
```

2. **プレースホルダーを内容に置換**

```markdown
{{PLACEHOLDER}} → 実際の内容
```

3. **変更履歴に追記**

```markdown
| {DATE} | {セクション名}を更新 | {担当} |
```

### 3. セクション別の責任範囲

#### spec.md（概要仕様書）

| セクション | 担当スキル | 主なプレースホルダー |
|-----------|-----------|---------------------|
| 概要 | managing-screen-specs | `{{SCREEN_NAME}}`, `{{FIGMA_URL}}`, `{{HTML_FILE}}`, `{{DESCRIPTION}}` |
| 画面フロー | documenting-screen-flows | `{{CURRENT_SCREEN}}`, `{{NEXT_SCREEN}}`, 遷移テーブル |

#### spec-visual.md（ビジュアル仕様書）

| セクション | 担当スキル | 主なプレースホルダー |
|-----------|-----------|---------------------|
| 構造・スタイル | converting-figma-to-html | `{{HTML_STRUCTURE}}`, `{{SCREEN_ID}}`, `{{ROOT_NODE_ID}}` |
| コンテンツ分析 | converting-figma-to-html | `{{CONTENT_NAME}}`, `{{DATA_ATTRIBUTE}}`, `{{API_SOURCE}}` |
| UI状態 | documenting-ui-states | `{{UI_STATES_CONTENT}}` |
| デザイントークン | extracting-design-tokens | `{{DESIGN_TOKENS_CONTENT}}` |

#### spec-behavior.md（動作仕様書）

| セクション | 担当スキル | 主なプレースホルダー |
|-----------|-----------|---------------------|
| インタラクション | extracting-interactions | `{{INTERACTIONS_CONTENT}}` |
| フォーム仕様 | defining-form-specs | `{{FORM_SPECS_CONTENT}}` |
| APIマッピング | mapping-html-to-api | `{{API_MAPPING_CONTENT}}` |
| アクセシビリティ | defining-accessibility-requirements | `{{ACCESSIBILITY_CONTENT}}` |

## セクション更新のルール

### 必須

- 自分の担当セクションのみを更新する
- 変更履歴に記録を追加する
- プレースホルダーを具体的な内容に置換する

### 禁止

- 他のセクションの内容を変更しない
- プレースホルダーを削除せずに残さない

## 初期化の例

### 入力

```
画面名: TOP画面
画面ID: top
Figma URL: https://figma.com/design/xxx/Project?node-id=2350:2662
HTMLファイル: top.html
説明: AskAI機能のエントリーポイント画面
```

### 出力（spec.md 冒頭部分）

```markdown
# 画面仕様書: TOP画面

## 概要

| 項目 | 内容 |
| ---- | ---- |
| 画面名 | TOP画面 |
| Figma URL | https://figma.com/design/xxx/Project?node-id=2350:2662 |
| HTML | top.html |
| 説明 | AskAI機能のエントリーポイント画面 |
```

## セクション更新の例

### documenting-ui-states による更新

**Before:**

```markdown
## UI状態

### デフォルト状態

| 要素 | 状態 | 備考 |
| ---- | ---- | ---- |
| {{ELEMENT_NAME}} | {{ELEMENT_STATE}} | {{ELEMENT_NOTES}} |
```

**After:**

```markdown
## UI状態

### デフォルト状態

| 要素 | 状態 | 備考 |
| ---- | ---- | ---- |
| 背景 | 水色グラデーション表示 | #e1f4ff基調 |
| ナビゲーション | 閉じるボタンのみ表示 | - |
| 写真を共有ボタン | 青背景、有効状態 | #0070e0 |
```

### extracting-interactions による更新

**Before:**

```markdown
### INT-001: {{INTERACTION_NAME_1}}

| 項目 | 内容 |
| ---- | ---- |
| トリガー | {{TRIGGER}} |
| 前提条件 | {{PRECONDITION}} |
| アクション | {{ACTION}} |
| API | {{API_CALL}} |
| 遷移先 | {{DESTINATION}} |
```

**After:**

```markdown
### INT-001: 写真を共有ボタンタップ

| 項目 | 内容 |
| ---- | ---- |
| トリガー | 「写真を共有」ボタンをタップ |
| 前提条件 | - |
| アクション | OSのアクションシートを表示 |
| API | なし |
| 遷移先 | action-sheet.html |
```

## 仕様書の完了判定

全ての必須セクションが具体的な内容で埋まったら完了です。

### 必須セクション

- 概要
- 構造・スタイル
- コンテンツ分析
- UI状態
- インタラクション
- APIマッピング
- アクセシビリティ
- デザイントークン
- 画面フロー
- 変更履歴

### 条件付きセクション（必要に応じて追加）

- フォーム仕様: 入力フォームがある場合

## 参照

- **[screen-spec.md](../../templates/screen-spec.md)**: 概要仕様書テンプレート
- **[screen-spec-visual.md](../../templates/screen-spec-visual.md)**: ビジュアル仕様書テンプレート
- **[screen-spec-behavior.md](../../templates/screen-spec-behavior.md)**: 動作仕様書テンプレート
