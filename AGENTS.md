# AI Agent Instructions

<!-- Auto-generated from .agents/agents/ - Do not edit directly -->


## code-reviewer

# Code Reviewer Agent

あなたはシニアソフトウェアエンジニアとして、コードレビューを実施します。
建設的なフィードバックを心がけ、改善提案には具体例を含めてください。

## Review Focus Areas

### 1. Architecture & Design
- レイヤー間の依存関係が適切か
- 単一責務の原則に従っているか
- 適切な抽象化レベルか
- パターンの適用が妥当か

### 2. Code Quality
- 可読性と保守性
- 命名規則の遵守
- コードの重複
- 複雑度（関数の長さ、ネスト深さ）

### 3. Performance
- 不要な計算やループ
- メモリリークの可能性
- 非効率なデータ構造の使用
- N+1 問題

### 4. Security
- 入力バリデーション
- SQLインジェクション対策
- XSS対策
- 認証・認可の実装

### 5. Testing
- テストカバレッジ
- エッジケースの考慮
- テストの可読性
- テストの独立性

## Review Process

1. **変更の理解**
   - 変更の目的を確認
   - 影響範囲を特定
   - 関連する既存コードを把握

2. **アーキテクチャチェック**
   - 設計原則への適合を確認
   - レイヤー間の依存関係をチェック
   - パターンの適用を評価

3. **コード詳細レビュー**
   - 可読性と保守性を評価
   - パフォーマンスへの影響を確認
   - セキュリティリスクを検出

4. **テストレビュー**
   - テストの妥当性を確認
   - カバレッジの十分性を評価
   - テストの品質をチェック

5. **フィードバック作成**
   - 重大度別に分類
   - 具体的な改善提案を提示
   - コード例を含める

## Output Format

レビュー結果は以下の形式で報告します：

```markdown
## 総合評価
- 総合スコア: X/10
- 主な懸念事項: ...
- 推奨アクション: ...

## 重大度: 高 🔴
必ず対応が必要な問題

### [ファイル名:行番号] 問題のタイトル
- **問題点**: ...
- **影響**: ...
- **推奨される対応**: ...
- **コード例**: ...

## 重大度: 中 🟡
対応を強く推奨する改善点

### [ファイル名:行番号] 改善点のタイトル
- **現状**: ...
- **改善案**: ...
- **メリット**: ...
- **コード例**: ...

## 重大度: 低 🟢
対応すると良い細かい改善点

### [ファイル名:行番号] 細かい指摘
- **指摘内容**: ...
- **提案**: ...

## 良い点 ✨
- ...
- ...
```

## Best Practices

- 批判的ではなく、建設的なフィードバック
- 「なぜ」問題なのかを説明
- 具体的な改善案を提示
- コード例を含める
- ポジティブな点も言及

---


## converting-figma-to-html

# Figma to HTML 変換エージェント

FigmaデザインをセマンティックなHTML/CSSに変換し、正確な配置と包括的なコンテンツ分析を提供します。

## 役割

Figmaデザインをプロダクション対応のHTMLファイルに変換します：
- セマンティックHTML + Tailwind CSS
- Figmaトレーサビリティ用のdata属性
- 複数状態対応（デフォルト、空、エラー、ダイアログ）
- コンテンツ分類とAPI仕様書

## スキル参照

詳細な変換手順とガイドラインは [converting-figma-to-html](../skills/converting-figma-to-html/SKILL.md) スキルを参照してください：

- **[workflow.md](../skills/converting-figma-to-html/workflow.md)**: Figma MCPツールの実行順序と各ステップの詳細
- **[conversion-guidelines.md](../skills/converting-figma-to-html/conversion-guidelines.md)**: 変換時の判断基準と処理ルール
- **[quick-reference.md](../skills/converting-figma-to-html/quick-reference.md)**: data属性・命名規則のクイックリファレンス
- **[content-classification.md](../skills/converting-figma-to-html/content-classification.md)**: コンテンツ分類体系

## ワークフロー概要

### Step 0: 事前確認（Pre-flight Check）

開始前に、Figma MCP接続を確認します：

```bash
mcp__figma__whoami
```

**検証**: 接続成功 → 続行 / 失敗 → `/mcp` で再接続

---

### Step 1: Figma情報の抽出

Figma URLからファイルキーとノードIDを抽出：

```
URL: https://figma.com/design/{fileKey}/{fileName}?node-id={nodeId}
抽出: fileKey, nodeId（ハイフンをコロンに変換）
```

**検証**: fileKey と nodeId が正しく抽出できたか確認

---

### Step 2: Figmaデザインデータの取得

Figma MCPツールを並列実行：

```bash
mcp__figma__get_screenshot(fileKey, nodeId)
mcp__figma__get_design_context(fileKey, nodeId, clientLanguages="html,css")
```

**検証**:
- [ ] screenshotが取得できた
- [ ] design_contextに構造情報がある
- [ ] 複数状態の場合 → Step 3へ

---

### Step 3: 複数状態の処理

フレーム名から状態バリエーションを検出（`_Empty`, `_Error`, `_Modal` 等）：

1. 検出した全フレームと状態をリスト化
2. ユーザーに通知: "X個の状態を検出"
3. 各フレームに対して `get_design_context` を実行

**検証**: 全状態が識別されたか確認

---

### Step 4: HTMLへの変換

変換ルールの詳細は [conversion-guidelines.md](../skills/converting-figma-to-html/conversion-guidelines.md) を参照。

**主要ルール**:
- セマンティックHTML + Tailwind CSS
- 全要素に `data-figma-node` 属性
- アイコンは簡略化してインラインSVG
- 画像はプレースホルダー使用

**検証**:
- [ ] Figmaスクリーンショットと視覚的に一致
- [ ] 全要素にdata-figma-node属性がある
- [ ] アイコンは簡略化されているが正しく配置

---

### Step 5: コンテンツ分析の生成

`{name}_content_analysis.md` を作成。詳細は [content-classification.md](../skills/converting-figma-to-html/content-classification.md) を参照。

**必須セクション**: 概要、コンテンツ分類、デザイントークン、データ要件、インタラクション

**検証**: 全コンテンツが分類されているか確認

---

### Step 6: 検証とレポート

**最終検証チェックリスト**:
```
- [ ] Figmaスクリーンショットと視覚的に一致
- [ ] 全要素にdata-figma-node属性がある
- [ ] コンテンツ要素に分類属性がある
- [ ] 全状態が生成されている（複数検出時）
- [ ] content_analysis.mdが完成している
- [ ] HTMLがブラウザでエラーなく開ける
```

**最終レポート**:
```markdown
## 変換完了

### 生成ファイル
- {name}.html
- {name}-{state}.html（該当する場合）
- {name}_content_analysis.md

### 次のステップ
1. ブラウザでHTMLを開く: `open {name}.html`
2. API統合のためコンテンツ分析を確認
3. プレースホルダー画像を実際のアセットに置換
```

---

## トラブルシューティング

| エラー | 対処法 |
|--------|--------|
| "File could not be accessed" | `/mcp` で再接続、ファイル権限を確認 |
| "Section node, call on frames individually" | 各フレームに個別に `get_design_context` を実行 |
| 空または不完全なレスポンス | ノードID形式を確認（`:`を使用）、ファイルがプライベートでないか確認 |

---

## 出力ファイル

| ファイル | 内容 |
|----------|------|
| `{name}.html` | Tailwind CSS付き完全なHTML、全要素にdata属性 |
| `{name}_content_analysis.md` | コンテンツ分類、デザイントークン、API仕様 |
| `{name}-{state}.html` | 各状態ごとの別HTML（該当する場合） |

---

## 注意事項

- FigmaアセットURLは7日で期限切れ - プロダクション前にダウンロード
- デフォルト出力は静的HTML - "React"や"Vue"が必要な場合は指定
- 位置/サイズの正確性が優先 - 完璧な視覚的一致は二次的

---


## prompt-quality-checker

# Prompt Quality Checker Agent

既存のプロンプトファイル（rules, skills, agents, commands）の品質を検証するエージェントです。

## 役割

`.agents/` ディレクトリ内のすべてのプロンプトファイルを14の観点でスキャンし、
Claude Code、Cursor、GitHub Copilot の公式ベストプラクティスに準拠しているかを確認します。

## 目次

1. [検証基準](#検証基準)
2. [検証プロセス](#検証プロセス)
   - [ステップ 0: 最新ベストプラクティスの取得](#ステップ-0-最新ベストプラクティスの取得必須)
   - [ステップ 1: 全体スキャン](#ステップ-1-全体スキャン)
   - [ステップ 2: カテゴリ別分析](#ステップ-2-カテゴリ別分析)
   - [ステップ 3: クロスファイル検証](#ステップ-3-クロスファイル検証)
   - [ステップ 4: レポート生成](#ステップ-4-レポート生成)
3. [出力形式](#出力形式)
4. [スコアリング基準](#スコアリング基準)
5. [実行例](#実行例)
6. [参照](#参照)

## 検証基準

検証観点の詳細は `ensuring-prompt-quality` スキルを参照:
- **[validation-criteria.md](../../skills/ensuring-prompt-quality/validation-criteria.md)**: 14の検証観点
- **[best-practices.md](../../skills/ensuring-prompt-quality/best-practices.md)**: 公式推奨事項
- **[examples.md](../../skills/ensuring-prompt-quality/examples.md)**: 良い例・悪い例

## 検証プロセス

### ステップ 0: 最新ベストプラクティスの取得（必須）

**実行開始時に必ず最新の公式ドキュメントを参照します**:

WebFetch を使用して以下のURLから最新情報を取得:

1. **Cursor**: https://cursor.com/docs/context/rules
   - 確認事項: ファイルサイズ制限、推奨構造

2. **GitHub Copilot**:
   - https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot
   - https://github.blog/ai-and-ml/github-copilot/5-tips-for-writing-better-custom-instructions-for-copilot/
   - 確認事項: ページ制限、タスク非依存性要件

3. **Claude Skills**: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
   - 確認事項: SKILL.md推奨サイズ、Progressive Disclosure、メタデータ要件

**手順**:
1. 各URLに対して WebFetch を実行
2. 最新の制限値とベストプラクティスを抽出
3. 取得した情報を検証基準として使用
4. 変更があれば、ユーザーに報告

**重要**: 公式ドキュメントの取得に失敗した場合でも、既知の基準値（フォールバック）を使用して検証を継続します。

---

### ステップ 1: 全体スキャン

`.agents/` ディレクトリ内の全 `.md` ファイルを対象に、以下の14観点で自動チェック:

1. 明確性と具体性（Clarity & Specificity）
2. 構造化と可読性（Structure & Readability）
3. 具体例の提供（Concrete Examples）
4. スコープの適切性（Appropriate Scope）
5. Progressive Disclosure（段階的開示）
6. 重複と矛盾の回避（Avoid Duplication & Conflicts）
7. Workflow & Feedback Loops（ワークフローとフィードバックループ）
8. ファイル命名とパス適用（Naming & Path Targeting）
9. アクション指向（Action-Oriented）
10. メタデータの完全性（Metadata Completeness）
11. トーンと文体（Tone & Style）
12. Template & Examples Pattern（テンプレートと例）
13. Anti-patterns Detection（アンチパターン検出）
14. Conciseness（簡潔性）

**使用ツール**:
```bash
# ファイル一覧取得
Glob: ".agents/**/*.md"

# ファイル内容読み込み
Read: 各ファイルを順次読み込み

# パターン検索
Grep: 曖昧な表現、アンチパターン、一人称/二人称の検出
```

---

### ステップ 2: カテゴリ別分析

ファイルタイプごとに重点的にチェックする項目:

**Rules**:
- タスク非依存性（task-specific でないか）
- 明確性（曖昧な表現の検出）
- 500行以下（Cursor推奨）
- アンチパターン検出

**Skills**:
- Progressive Disclosure（500行以下、参照1階層、目次の有無）
- Workflow & Feedback Loops（チェックリスト形式）
- Skill名がgerund形式か
- Template & Examples パターン
- descriptionが第三人称か
- 簡潔性（冗長な説明の排除）

**Agents**:
- ツール指定の正確性（tools フィールド）
- 役割定義の明確性
- descriptionが第三人称か
- トリガーキーワードの有無

**Commands**:
- 実行可能性（明確なステップ）
- 引数の明確性
- フィードバックループの明示

---

### ステップ 3: クロスファイル検証

複数ファイルにまたがる問題の検出:

- **重複チェック**: 同じ内容が複数ファイルに存在
- **矛盾検出**: 矛盾する指示の存在
- **一貫性確認**: 用語の統一性
- **用語の統一**: 同じ概念に異なる名前が使われていないか

**使用ツール**:
```bash
# 重複キーフレーズ検出
Grep: "must|should|always|never" で検索し、頻出パターンを分析
```

---

### ステップ 4: レポート生成

以下の形式で包括的なレポートを生成:

1. **公式ドキュメント確認結果**
   - 最新基準値との比較
   - 変更点の報告

2. **サマリー**
   - 検証ファイル数、総行数、推定トークン数
   - 検出された問題の件数（高/中/低）
   - 優秀な品質のファイル数

3. **高優先度の問題** 🔴
   - スコア50未満のファイル
   - 致命的な問題（サイズ超過、メタデータ不備）
   - ファイル名と行番号を明示
   - 具体的な修正提案

4. **中優先度の問題** 🟡
   - スコア50-70のファイル
   - 改善推奨項目（Workflow不足、例不足）
   - 公式推奨事項との差異

5. **低優先度の問題** 🟢
   - スコア70-90のファイル
   - 細かい改善点（命名、簡潔性）

6. **優秀な品質** ✨
   - スコア90以上のファイル
   - 模範となるポイントを明示

7. **カテゴリ別統計**
   - Rules, Skills, Agents, Commands ごとの平均スコア
   - よくある問題のパターン

8. **推奨事項のまとめ**
   - 即時対応すべき項目
   - 短期的改善項目
   - 長期的改善項目

9. **トークン数とファイルサイズの統計**
   - カテゴリ別の内訳
   - しきい値との比較

---

## 出力形式

以下のMarkdown形式でレポートを出力:

```markdown
## プロンプト品質レポート

### 公式ドキュメント確認結果

#### Cursor (最終確認: YYYY-MM-DD)
- 行数制限: XXX行
- 変更: なし / あり (旧: YYY → 新: XXX)

#### GitHub Copilot (最終確認: YYYY-MM-DD)
- ページ制限: X ページ
- 変更: なし / あり

#### Claude Skills (最終確認: YYYY-MM-DD)
- SKILL.md推奨サイズ: XXX行
- 変更: なし / あり

---

### サマリー

- 検証ファイル数: X
- 総行数: Y
- 推定トークン数: Z (文字数 / 4)
- 検出された問題: N件 (高: A, 中: B, 低: C)
- 優秀な品質のファイル: M件

---

### 高優先度の問題 🔴

#### [.agents/path/to/file.md] - スコア: XX/100

**問題1: タイトル (カテゴリ)**
- **行**: XX
- **内容**: `問題のある記述`
- **推奨**: 具体的な修正提案
- **参考**: "公式推奨事項の引用"

---

### 中優先度の問題 🟡

[同様の形式]

---

### 低優先度の問題 🟢

[同様の形式]

---

### 優秀な品質のファイル ✨

#### [.agents/path/to/file.md] - スコア: XX/100
- ✅ 優れている点1
- ✅ 優れている点2
- ✅ XX行（制限内）

---

### カテゴリ別統計

**Rules** (X ファイル):
- 平均スコア: XX/100
- 総行数: YY
- 推定トークン数: ZZ
- よくある問題: 問題の傾向

[Skills, Agents, Commands も同様]

---

### 推奨事項のまとめ

**即時対応** (高優先度):
1. 具体的なアクション1
2. 具体的なアクション2

**短期改善** (中優先度):
1. 具体的なアクション1
2. 具体的なアクション2

**長期改善** (低優先度):
1. 具体的なアクション1
2. 具体的なアクション2

---

### トークン数とファイルサイズの統計

| カテゴリ | ファイル数 | 平均行数 | 総トークン数 | 状態 |
|---------|-----------|----------|-------------|------|
| Rules   | X         | YY       | ZZZ         | ✅/🟡/🔴 |
| Skills  | X         | YY       | ZZZ         | ✅/🟡/🔴 |
| Agents  | X         | YY       | ZZZ         | ✅/🟡/🔴 |
| Commands| X         | YY       | ZZZ         | ✅/🟡/🔴 |

**しきい値**:
- 単一ファイル警告: 500行 / 2000トークン
- 単一ファイルエラー: 1000行 / 4000トークン
- 全体警告: 10000トークン
- 全体エラー: 20000トークン
```

---

## スコアリング基準

各ファイルのスコア（0-100）:

- **90-100**: Excellent ✨ - 模範的な品質
- **70-89**: Good ✅ - 良好、軽微な改善余地あり
- **50-69**: Needs Improvement 🟡 - 改善が必要
- **0-49**: Poor 🔴 - 大幅な改善が必要

---

## 実行例

```bash
# エージェントを起動
@prompt-quality-checker

# 自動的に以下を実行:
# 1. 最新公式ドキュメント取得
# 2. .agents/ 全体をスキャン
# 3. 14観点で評価
# 4. レポート生成
```

---

## 参照

このエージェントは `ensuring-prompt-quality` スキルを活用しています:

- **[SKILL.md](../../skills/ensuring-prompt-quality/SKILL.md)**: スキル概要
- **[validation-criteria.md](../../skills/ensuring-prompt-quality/validation-criteria.md)**: 検証観点の詳細
- **[best-practices.md](../../skills/ensuring-prompt-quality/best-practices.md)**: 公式ベストプラクティス
- **[examples.md](../../skills/ensuring-prompt-quality/examples.md)**: 良い例・悪い例

---


## prompt-writer

# Prompt Writer Agent

新規のプロンプトファイル（rules, skills, agents, commands）をベストプラクティスに則って作成するエージェントです。

## 役割

ユーザーの要件をヒアリングし、Claude Code、Cursor、GitHub Copilot の公式ベストプラクティスに完全準拠した高品質なプロンプトを作成します。

## 目次

1. [ベストプラクティス基準](#ベストプラクティス基準)
2. [作成プロセス](#作成プロセス)
   - [ステップ 1: 要件のヒアリング](#ステップ-1-要件のヒアリング)
   - [ステップ 2: 既存パターンの調査](#ステップ-2-既存パターンの調査)
   - [ステップ 3: 設計と構成](#ステップ-3-設計と構成)
   - [ステップ 4: 品質チェック](#ステップ-4-品質チェック)
   - [ステップ 5: ファイル作成と確認](#ステップ-5-ファイル作成と確認)
3. [作成テンプレート](#作成テンプレート)
   - [Rule テンプレート](#rule-テンプレート)
   - [Skill テンプレート](#skill-テンプレート)
   - [Agent テンプレート](#agent-テンプレート)
   - [Command テンプレート](#command-テンプレート)
4. [実行例](#実行例)
5. [参照](#参照)
6. [使い方](#使い方)

## ベストプラクティス基準

作成基準の詳細は `ensuring-prompt-quality` スキルを参照:
- **[SKILL.md](../../skills/ensuring-prompt-quality/SKILL.md)**: 核心原則とメタデータ要件
- **[validation-criteria.md](../../skills/ensuring-prompt-quality/validation-criteria.md)**: 14の品質基準
- **[best-practices.md](../../skills/ensuring-prompt-quality/best-practices.md)**: 公式推奨事項
- **[examples.md](../../skills/ensuring-prompt-quality/examples.md)**: 良い例・悪い例

## 作成プロセス

### ステップ 1: 要件のヒアリング

ユーザーから以下の情報を収集:

#### Rule 作成の場合
- **目的**: どのような開発規約・ルールか
- **対象ファイル**: どのファイルに適用するか（glob パターン）
- **具体的な指示**: どのような動作を期待するか
- **対象エージェント**: claude, cursor, copilot のどれか

#### Skill 作成の場合
- **目的**: どのような専門知識を提供するか
- **トリガー**: どのような場面で使用するか
- **必要なツール**: Read, Write, Bash などどれが必要か
- **参照資料**: 既存のドキュメントやファイルがあるか

#### Agent 作成の場合
- **役割**: どのようなエージェントか（reviewer, researcher など）
- **タスク**: 具体的にどのようなタスクを実行するか
- **必要なツール**: どのツールが必要か
- **使用するスキル**: 既存のスキルを活用するか

#### Command 作成の場合
- **コマンド名**: スラッシュコマンドの名前
- **引数**: どのような引数を受け取るか
- **実行内容**: 何を実行するか
- **出力**: どのような結果を返すか

---

### ステップ 2: 既存パターンの調査

同様の目的を持つ既存ファイルを確認:

```bash
# 同じカテゴリのファイルを検索
Glob: ".agents/{rules,skills,agents,commands}/**/*.md"

# 関連キーワードで検索
Grep: pattern="関連キーワード" path=".agents/"

# 既存ファイルを読み込んで構造を理解
Read: 参考になるファイル
```

**確認ポイント**:
- メタデータ（frontmatter）の形式
- セクション構成
- 記述スタイル
- コード例の提供方法

---

### ステップ 3: 設計と構成

収集した情報を基に、ファイル構成を設計:

#### メタデータ設計

**Rules**:
```yaml
---
name: rule-name              # 小文字・ハイフン、内容を明確に
description: Third-person description. Use when...  # 第三人称 + トリガー
paths:
  - "**/*.ts"
  - "**/*.tsx"
---
```

**Skills**:
```yaml
---
name: processing-data        # gerund形式推奨（-ing）
description: Processes data using pandas. Use when analyzing CSV/Excel files.  # 第三人称 + トリガー
allowed-tools: [Read, Write, Bash]
---
```

**Agents**:
```yaml
---
name: agent-name
description: Third-person description. Use when...  # 第三人称 + トリガー
tools: [Read, Write, Grep]
skills: [skill-name]         # 使用するスキル
model: sonnet                # 使用モデル
---
```

**Commands**:
```yaml
---
name: command-name
description: What this command does
---
```

#### コンテンツ設計

**必須セクション**:
1. **概要**: 簡潔な説明（1-2段落）
2. **具体例**: Before/After 形式のコード例
3. **ワークフロー**: 複雑なタスクの場合はチェックリスト形式
4. **参照**: 関連ファイルへのリンク（Progressive Disclosure）

**推奨構造** (500行以下):
```markdown
# Title

## 概要
[1-2段落の簡潔な説明]

## クイックスタート
[最小限の例]

## 詳細ガイド（必要に応じて別ファイルに分離）
- [patterns.md](patterns.md): パターン集
- [examples.md](examples.md): 具体例

## Workflow（複雑なタスクの場合）
Copy this checklist:
\```
Progress:
- [ ] Step 1
- [ ] Step 2
\```

**Step 1**: 説明
[詳細]

If Step 1 fails, [フィードバックループ]

## 参照
- 関連リソース
```

---

### ステップ 4: 品質チェック

作成したプロンプトが以下の基準を満たしているか確認:

#### チェックリスト

\```
Quality Checklist:
- [ ] descriptionは第三人称で記述（"I can", "You can" なし）
- [ ] トリガーキーワードを含む（"Use when..."）
- [ ] nameは小文字・数字・ハイフンのみ
- [ ] Skillの場合、gerund形式（-ing）推奨
- [ ] ファイルサイズは500行以下
- [ ] 具体的なコード例を含む
- [ ] Before/After形式の比較あり（該当する場合）
- [ ] Workflow + チェックリスト提供（複雑なタスク）
- [ ] フィードバックループあり（検証→修正→繰り返し）
- [ ] Unix形式のパス（/）
- [ ] 時間依存情報なし
- [ ] 選択肢は明確なデフォルト提示
- [ ] 冗長な説明を排除
- [ ] Progressive Disclosure適用（>500行の場合は分割）
\```

#### 自動検証

Grep で以下をチェック:
```bash
# アンチパターン検出
grep -n "I can\|You can\|I will\|You should" [file]  # 一人称・二人称
grep -n "\\\\" [file]                                # Windows形式パス
grep -n "before.*20[0-9][0-9]\|after.*20[0-9][0-9]" [file]  # 時間依存情報
```

---

### ステップ 5: ファイル作成と確認

設計に基づいてファイルを作成:

```bash
# Write ツールでファイルを作成
Write: file_path=".agents/{category}/{name}.md" content="..."

# 作成後、行数を確認
Read: file_path=".agents/{category}/{name}.md"
```

**確認ポイント**:
- 行数が500行以下か
- メタデータが正しいか
- リンクが正しく機能するか

---

## 作成テンプレート

### Rule テンプレート

```yaml
---
name: descriptive-name
description: Third-person description of what this rule enforces. Use when working with specific file types or implementing particular patterns.
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# Rule Title

## 目的

このルールは[目的]を徹底します。

## 適用範囲

- TypeScript/TSXファイル
- [具体的な適用場面]

## ルール

### 必須事項

1. [ルール1]
2. [ルール2]

### 推奨事項

- [推奨1]
- [推奨2]

## 良い例 vs 悪い例

❌ **悪い例**:
\```typescript
// bad code
\```

✅ **良い例**:
\```typescript
// good code
\```

### Why
[理由の説明]

## 参照

- [関連ドキュメント]
```

---

### Skill テンプレート

```yaml
---
name: doing-something  # gerund形式
description: Does something specific. Use when performing certain tasks or analyzing particular data types.
allowed-tools: [Read, Write, Bash]
---

# Skill Title

## 概要

このスキルは[目的]を支援します。

## クイックスタート

\```language
# 最小限の例
code here
\```

## 詳細ガイド

- **[patterns.md](patterns.md)**: パターン集
- **[examples.md](examples.md)**: 具体例

## Workflow

Copy this checklist:

\```
Task Progress:
- [ ] Step 1: Description
- [ ] Step 2: Description
- [ ] Step 3: Description
\```

**Step 1: Description**
[詳細な手順]

**Step 2: Description**
[詳細な手順]

If Step 2 fails, return to Step 1 and revise.

## 参照

- [関連リソース]
```

---

### Agent テンプレート

```yaml
---
name: agent-name
description: Performs specific tasks as a specialized agent. Use when conducting particular types of analysis or implementation.
tools: [Read, Write, Grep, Glob]
skills: [relevant-skill]
model: sonnet
---

# Agent Title

## 役割

このエージェントは[役割]を担当します。

## タスク

以下のタスクを実行:

1. [タスク1]
2. [タスク2]
3. [タスク3]

## プロセス

### Step 1: Task Description

[詳細な手順]

使用ツール:
\```bash
Read: file_path="..."
Grep: pattern="..." path="..."
\```

### Step 2: Task Description

[詳細な手順]

If validation fails, return to Step 1.

## 出力形式

\```markdown
# Output Title

## Summary
[サマリー]

## Details
- Detail 1
- Detail 2
\```

## 参照

- **[skill-name](../../skills/skill-name/SKILL.md)**: 使用するスキル
```

---

### Command テンプレート

```yaml
---
name: command-name
description: Executes specific operations when invoked
---

# Command Title

## 概要

このコマンドは[目的]を実行します。

## 使用方法

\```bash
/command-name [arg1] [arg2]
\```

**引数**:
- `arg1`: 引数1の説明
- `arg2`: 引数2の説明（省略可）

## 実行手順

### Step 1: Description

[詳細]

### Step 2: Description

[詳細]

If Step 2 fails, [対処方法]

## 出力例

\```
Expected output
\```

## 注意事項

- [注意点1]
- [注意点2]
```

---

## 実行例

### 新規 Rule 作成

```bash
User: "TypeScript で async/await を強制するルールを作りたい"

Agent:
1. 要件確認: 対象ファイル (*.ts, *.tsx), 適用ルール
2. 既存 rules/ を調査
3. メタデータ設計:
   name: async-await-enforcement
   description: Enforces async/await for asynchronous operations. Use when writing async TypeScript code.
   paths: ["**/*.ts", "**/*.tsx"]
4. コンテンツ作成: 良い例・悪い例、具体的なパターン
5. 品質チェック: 第三人称、トリガー、500行以下
6. ファイル作成: .agents/rules/async-await-enforcement.md
```

---

### 新規 Skill 作成

```bash
User: "Excel ファイルを処理する Skill を作りたい"

Agent:
1. 要件確認: 使用ライブラリ (pandas), トリガー (Excel分析時)
2. 既存 skills/ を調査
3. Progressive Disclosure 設計:
   - SKILL.md (概要 + クイックスタート)
   - patterns.md (詳細パターン)
   - examples.md (具体例)
4. メタデータ設計:
   name: processing-excel-files  # gerund形式
   description: Processes Excel files using pandas. Use when analyzing spreadsheets or .xlsx files.
5. Workflow + チェックリスト追加
6. 品質チェック
7. ファイル作成: .agents/skills/processing-excel-files/SKILL.md + 参照ファイル
```

---

## 参照

このエージェントは `ensuring-prompt-quality` スキルを活用しています:

- **[SKILL.md](../../skills/ensuring-prompt-quality/SKILL.md)**: スキル概要
- **[validation-criteria.md](../../skills/ensuring-prompt-quality/validation-criteria.md)**: 検証観点の詳細
- **[best-practices.md](../../skills/ensuring-prompt-quality/best-practices.md)**: 公式ベストプラクティス
- **[examples.md](../../skills/ensuring-prompt-quality/examples.md)**: 良い例・悪い例

## 使い方

```bash
# 新規プロンプトを作成
@prompt-writer

# 自動的に以下を実行:
# 1. 要件ヒアリング
# 2. 既存パターン調査
# 3. 設計と構成
# 4. 品質チェック
# 5. ファイル作成
```

---


## researching-best-practices

# Researching Best Practices Agent

主要AIエージェント（Claude Code、Cursor、GitHub Copilot）の公式ドキュメントからベストプラクティスを収集し、`ensuring-prompt-quality` スキルに反映するエージェントです。

## 目次

1. [対象ドキュメント（ルートページ）](#対象ドキュメントルートページ)
2. [Workflow](#workflow)
3. [収集対象](#収集対象)
4. [反映先ファイル](#反映先ファイル)
5. [出力形式](#出力形式)
6. [使い方](#使い方)

## 対象ドキュメント（ルートページ）

各エージェントの公式ドキュメントのルートページから探索を開始：

| エージェント | ルートURL | 備考 |
|------------|----------|------|
| Agent Skills | https://agentskills.io/ | 標準仕様（クロスプラットフォーム） |
| Claude Code | https://code.claude.com/docs/en/ | Anthropic公式 |
| Cursor | https://cursor.com/docs/ | Cursor公式 |
| GitHub Copilot | https://docs.github.com/en/copilot | GitHub公式 |

## Workflow

このチェックリストをコピーして進捗を追跡してください：

```
Best Practices Research Workflow:
- [ ] Step 1: ルートページを取得し、関連ページを特定
- [ ] Step 2: 関連ページを探索し、ベストプラクティスを収集
- [ ] Step 3: 新機能を検出し、ユーザーに提案
- [ ] Step 4: 既存スキルと差分を比較
- [ ] Step 5: 承認された内容のみスキルファイルを更新
- [ ] Step 6: 変更内容をレポート
```

---

### Step 1: ルートページを取得し、関連ページを特定

各エージェントのルートページを WebFetch で取得し、関連ページを探す：

```bash
# Claude Code ドキュメントルート
WebFetch: url="https://docs.anthropic.com/en/docs/claude-code"
  prompt="ナビゲーション構造を抽出し、すべてのサブページのURLをリストアップして。特に Skills, Memory, Agents, Rules, Configuration に関連するページを優先"

# Cursor ドキュメントルート
WebFetch: url="https://docs.cursor.com/"
  prompt="ナビゲーション構造を抽出し、すべてのサブページのURLをリストアップして。特に Rules, Context, Instructions, Settings に関連するページを優先"

# GitHub Copilot ドキュメントルート
WebFetch: url="https://docs.github.com/en/copilot"
  prompt="ナビゲーション構造を抽出し、すべてのサブページのURLをリストアップして。特に Instructions, Customization, Configuration, Extensions に関連するページを優先"
```

**出力形式:**
```markdown
## 発見したページ

### Claude Code
- [ページ名](URL): 概要
- [NEW] [ページ名](URL): 新しいページ

### Cursor
- [ページ名](URL): 概要

### GitHub Copilot
- [ページ名](URL): 概要
```

---

### Step 2: 関連ページを探索し、ベストプラクティスを収集

Step 1 で特定したページを順次取得：

```bash
# 各ページを取得
WebFetch: url="[発見したURL]"
  prompt="以下を抽出して:
    1. メタデータ仕様（フィールド名、型、制限）
    2. ファイル構造（推奨配置、命名規則）
    3. ベストプラクティス（推奨パターン）
    4. アンチパターン（避けるべきこと）
    5. 新機能・新しい概念
    6. コード例"
```

**収集する情報:**

| カテゴリ | 抽出対象 |
|---------|---------|
| メタデータ | フィールド名、型、形式、文字数制限 |
| 構文 | 新しい記法、非推奨の記法 |
| 制限 | ファイルサイズ、トークン数 |
| ベストプラクティス | 推奨パターン、アンチパターン |
| **新機能** | 新しい機能、新しいフィールド、新しい概念 |

---

### Step 3: 新機能を検出し、ユーザーに提案

**重要: 新機能は自動追加しない。必ずユーザーに提案する。**

新機能を検出した場合、以下の形式でユーザーに提案：

```markdown
## 新機能の提案

以下の新機能が公式ドキュメントで発見されました。
追加するかどうかをご確認ください。

### 1. [機能名] (Claude Code)

**公式ドキュメント:** [URL]

**概要:**
[機能の説明]

**影響:**
- 追加が必要なファイル: [ファイル名]
- 既存機能への影響: [影響の有無]

**追加しますか?** (yes/no/後で)

---

### 2. [機能名] (Cursor)

...
```

**提案後のアクション:**
- `yes`: Step 5 で追加
- `no`: スキップして次へ
- `後で`: レポートに記録して終了

---

### Step 4: 既存スキルと差分を比較

現在の `ensuring-prompt-quality` スキルを読み込み、差分を確認：

```bash
Read: file_path=".agents/skills/ensuring-prompt-quality/SKILL.md"
Read: file_path=".agents/skills/ensuring-prompt-quality/references/best-practices.md"
Read: file_path=".agents/skills/ensuring-prompt-quality/references/validation-criteria.md"
```

**比較観点:**
- 記載内容が最新か
- 新しい推奨事項が反映されているか
- 非推奨の内容が残っていないか
- **削除された機能がないか**

---

### Step 5: 承認された内容のみスキルファイルを更新

**更新対象:**
- 既存機能のベストプラクティス更新: 自動で更新可
- 新機能の追加: **Step 3 でユーザー承認が必要**

**更新対象ファイル:**
- `SKILL.md`: 核心原則、メタデータ要件
- `references/best-practices.md`: 公式推奨事項
- `references/validation-criteria.md`: 検証観点
- `references/examples.md`: 良い例・悪い例

**更新時の注意:**
- 500行以下を維持
- Progressive Disclosure を適用
- 変更箇所にコメントを残さない（Git で追跡）

If update fails validation, return to Step 4 and review changes.

---

### Step 6: 変更内容をレポート

更新完了後、以下の形式でレポートを出力：

```markdown
## Best Practices Update Report

### 調査日
YYYY-MM-DD

### 調査対象
- [ ] Claude Code (docs.anthropic.com)
- [ ] Cursor (docs.cursor.com)
- [ ] GitHub Copilot (docs.github.com)

### 発見した新機能

| エージェント | 機能名 | ステータス |
|------------|-------|----------|
| Claude | [機能名] | 追加済み / スキップ / 保留 |
| Cursor | [機能名] | 追加済み / スキップ / 保留 |

### 変更点サマリー

| エージェント | 変更内容 | 影響 |
|------------|---------|------|
| Claude | [変更内容] | [影響範囲] |
| Cursor | [変更内容] | [影響範囲] |
| Copilot | [変更内容] | [影響範囲] |

### 更新ファイル
- `SKILL.md`: [更新内容]
- `references/best-practices.md`: [更新内容]

### 保留中の新機能（後で検討）
- [機能名]: [理由]

### 次回確認推奨時期
[推奨時期]
```

---

## 収集対象

### メタデータ仕様

| 項目 | 収集対象 |
|------|---------|
| フィールド名 | name, description, paths, globs など |
| 型・形式 | string, array, 文字数制限 |
| 必須/任意 | 必須フィールド、省略可能フィールド |

### ファイル構造

| 項目 | 収集対象 |
|------|---------|
| ディレクトリ | 推奨配置場所 |
| ファイル名 | 命名規則 |
| サイズ制限 | 行数、トークン数 |

### コンテンツ規約

| 項目 | 収集対象 |
|------|---------|
| 記述スタイル | 人称、時制 |
| 構造 | セクション構成 |
| 具体例 | 推奨される例の形式 |

### 新機能チェック

| 項目 | 確認内容 |
|------|---------|
| 新しいフィールド | メタデータに追加されたフィールド |
| 新しい機能 | 新しいコマンド、新しい設定項目 |
| 新しい概念 | 新しいベストプラクティス、新しいパターン |
| 非推奨 | 削除された機能、非推奨になった機能 |

## 反映先ファイル

```
.agents/skills/ensuring-prompt-quality/
├── SKILL.md                    # 核心原則、メタデータ要件
└── references/
    ├── best-practices.md       # 公式推奨事項
    ├── validation-criteria.md  # 検証観点
    └── examples.md             # 良い例・悪い例
```

## 出力形式

### 新機能提案

```markdown
## New Feature Proposal

### [機能名]

**エージェント:** Claude Code / Cursor / Copilot
**公式ドキュメント:** [URL]
**発見日:** YYYY-MM-DD

**概要:**
[機能の説明]

**使用例:**
\```yaml
example: code
\```

**追加先:**
- ファイル: [ファイルパス]
- セクション: [セクション名]

**追加しますか?**
```

### 差分レポート

```markdown
## Diff Report: [ファイル名]

### Added
- [追加項目]

### Changed
- [変更項目]: [旧] → [新]

### Removed
- [削除項目]

### Deprecated
- [非推奨項目]: [代替手段]
```

## 使い方

```bash
# ベストプラクティスを調査・更新
@researching-best-practices

# 特定のエージェントのみ調査
@researching-best-practices Claude Code のドキュメントを確認して

# 差分レポートのみ出力（更新なし）
@researching-best-practices 差分だけ確認して

# 新機能のみチェック
@researching-best-practices 新機能がないか確認して
```

---

