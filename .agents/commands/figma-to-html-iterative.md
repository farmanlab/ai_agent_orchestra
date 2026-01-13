---
name: figma-to-html-iterative
description: Converts Figma designs to HTML with iterative refinement. Automatically compares output with Figma and fixes differences until pixel-perfect.
---

# Figma to HTML Iterative Command

FigmaデザインをHTMLに変換し、差分がなくなるまで反復的に修正するワークフローです。

## 使用方法

```bash
/figma-to-html-iterative <figma-url> [options]
```

**引数**:

| 引数 | 必須 | 説明 |
|------|:----:|------|
| `figma-url` | ✅ | FigmaデザインのURL |
| `--screen-id` | - | 出力ディレクトリ名（省略時はFigmaから自動生成） |
| `--max-iterations` | - | 最大反復回数（デフォルト: 3） |
| `--threshold` | - | 許容差分率 %（デフォルト: 1.0） |

## 使用例

### 基本

```bash
/figma-to-html-iterative https://figma.com/design/XXXXX/Project?node-id=1234-5678
```

### オプション指定

```bash
/figma-to-html-iterative https://figma.com/design/XXXXX/Project?node-id=1234-5678 --screen-id=course-list --max-iterations=5 --threshold=0.5
```

---

## ワークフロー概要

```
┌─────────────────────────────────────────────────────┐
│  Phase 0: 事前確認                                   │
│  - Figma MCP接続確認                                │
│  - URL解析（fileKey, nodeId抽出）                   │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  Phase 1: 初回HTML生成                              │
│  - converting-figma-to-html エージェント起動        │
│  - HTML + mapping-overlay.js 生成                   │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  Phase 2: 比較検証            │◄─────────────────────────┐
         │  - comparing-figma-html 起動  │                         │
         │  - スクリーンショット取得     │                         │
         │  - ピクセル比較実行           │                         │
         └───────────────────────────────┘                         │
                         │                                         │
                         ▼                                         │
              ┌─────────────────┐                                  │
              │ 差分率 ≤ 閾値？ │                                  │
              └─────────────────┘                                  │
              YES │           │ NO                                 │
                  │           │                                    │
                  ▼           ▼                                    │
         ┌────────────┐  ┌─────────────────┐                       │
         │  完了！    │  │ 反復回数 < 上限？│                       │
         │  Phase 3へ │  └─────────────────┘                       │
         └────────────┘   YES │       │ NO                        │
                              │       │                           │
                              ▼       ▼                           │
                    ┌──────────────┐ ┌─────────────────────────┐  │
                    │ Phase 2.5   │ │ Phase 2.6               │  │
                    │ 自動修正    │ │ ユーザーヒアリング      │  │
                    │ HTML更新    │ │ 「どこを修正？」        │  │
                    └──────────────┘ └─────────────────────────┘  │
                              │               │                   │
                              │      ┌────────┴────────┐          │
                              │      ▼                 ▼          │
                              │ ┌──────────┐   ┌────────────┐     │
                              │ │ 完了選択 │   │ 箇所指定   │     │
                              │ │ Phase 3へ│   │ Phase 2.7へ│     │
                              │ └──────────┘   └────────────┘     │
                              │                       │           │
                              │                       ▼           │
                              │         ┌─────────────────────┐   │
                              │         │ Phase 2.7           │   │
                              │         │ ユーザー指定箇所の  │   │
                              │         │ 重点修正            │   │
                              │         └─────────────────────┘   │
                              │                       │           │
                              └───────────────────────┴───────────┘
```

---

## 実行手順

### Phase 0: 事前確認

```bash
# 1. Figma MCP接続確認
mcp__figma__whoami

# 2. URL解析
# https://figma.com/design/{fileKey}/{fileName}?node-id={nodeId}
# → fileKey, nodeId を抽出
```

**検証**:
- [ ] MCP接続成功
- [ ] fileKey, nodeId 抽出完了

---

### Phase 1: 初回HTML生成

**サブエージェント起動**:

```
Task(
  subagent_type="converting-figma-to-html",
  prompt="
    Figma URL: {figma-url}
    出力先: .outputs/{screen-id}/

    HTMLを生成してください。
  "
)
```

**出力ファイル**:
```
.outputs/{screen-id}/
├── index.html
├── mapping-overlay.js
└── spec.md（コンテンツ分析セクション）
```

**検証**:
- [ ] index.html が生成された
- [ ] mapping-overlay.js が生成された
- [ ] HTMLがブラウザでエラーなく開ける

---

### Phase 2: 比較検証

**サブエージェント起動**:

```
Task(
  subagent_type="comparing-figma-html",
  prompt="
    Figma fileKey: {fileKey}
    HTMLファイル: .outputs/{screen-id}/index.html
    反復回数: {iteration}

    FigmaとHTMLを比較し、差分レポートを生成してください。
    比較結果は .outputs/{screen-id}/comparison/ に保存してください。

    **重要**: ファイル名には反復回数をsuffixとして付与すること。
    例: figma_iter1.png, html_iter1.png, diff_iter1.png
  "
)
```

**出力ファイル**:
```
.outputs/{screen-id}/comparison/
├── figma_iter{N}.png      # Figmaスクリーンショット（反復N回目）
├── html_iter{N}.png       # HTMLスクリーンショット（反復N回目）
├── diff_iter{N}.png       # 差分画像（反復N回目）
└── README.md              # 差分レポート（累積）
```

> **Note**: 反復ごとにファイルが蓄積されるため、改善の過程を追跡できます。

**結果判定**:

| 差分率 | 判定 | アクション |
|--------|------|-----------|
| 0% | ✅ PIXEL PERFECT | Phase 3（完了）へ |
| ≤ 閾値 | 🟡 ACCEPTABLE | Phase 3（完了）へ |
| > 閾値 | 🔴 NEEDS FIX | Phase 2.5（修正）へ |

---

### Phase 2.5: 差分修正（反復）

**反復回数チェック**:
- 現在の反復回数 < 最大反復回数 → 修正を実行
- 現在の反復回数 ≥ 最大反復回数 → ユーザーに手動修正を促す

**サブエージェント起動（修正）**:

```
Task(
  subagent_type="converting-figma-to-html",
  prompt="
    ## 修正タスク

    以下の差分を修正してください。

    ### 対象ファイル
    - HTMLファイル: .outputs/{screen-id}/index.html
    - Figma fileKey: {fileKey}
    - Figma nodeId: {nodeId}

    ### 比較画像（必ず確認すること）
    - Figmaスクリーンショット: .outputs/{screen-id}/comparison/figma_iter{N}.png
    - HTMLスクリーンショット: .outputs/{screen-id}/comparison/html_iter{N}.png
    - **差分画像: .outputs/{screen-id}/comparison/diff_iter{N}.png**（赤い箇所が差異）

    ※ {N} は現在の反復回数

    ### 検出された差分
    {comparison-report の差分リスト}

    ### 修正指示
    1. **diff_iter{N}.png を確認**して差異箇所を特定
    2. figma_iter{N}.png と html_iter{N}.png を並べて比較
    3. 差分レポートの各項目を修正
    4. HTMLを更新

    ### 注意
    - Figmaの視覚情報が唯一の正（Single Source of Truth）
    - diff.png の赤い部分が修正対象
    - 差分レポートの指摘を正確に反映すること
  "
)
```

**修正後**:
- Phase 2（比較検証）に戻る
- 反復回数をインクリメント

---

### Phase 2.6: ユーザーヒアリング（最大反復到達時）

最大反復回数に達しても閾値を超えている場合、ユーザーに差分箇所をヒアリングして追加修正を行う。

**トリガー条件**:
- 反復回数 ≥ 最大反復回数
- 差分率 > 閾値

**ユーザーへの質問**:

```markdown
## 自動修正の限界に達しました

最大反復回数（{max-iterations}回）に達しましたが、差分率は {final-diff-percentage}% です（目標: ≤{threshold}%）。

### 現在の状況

| 反復 | 差分率 | 改善 |
|------|--------|------|
| 1 | X.XX% | - |
| 2 | X.XX% | -X.XX% |
| 3 | X.XX% | -X.XX% |

### 差分画像を確認してください

- **差分画像**: .outputs/{screen-id}/comparison/diff_iter{N}.png
- **Figma**: .outputs/{screen-id}/comparison/figma_iter{N}.png
- **HTML**: .outputs/{screen-id}/comparison/html_iter{N}.png

赤い部分が差異箇所です。

### 質問

修正が必要な箇所を具体的に教えてください。例：

- 「ヘッダーの高さが違う」
- 「ボタンの角丸が足りない」
- 「アイコンの色がおかしい」
- 「テキストの行間が広い」

複数ある場合は箇条書きで教えてください。

**選択肢:**
1. 差分箇所を指定して追加修正を依頼
2. 現状で完了とする（手動で微調整）
3. 閾値を上げて完了とする
```

**ユーザー回答後のフロー**:

| 選択 | アクション |
|------|-----------|
| 差分箇所を指定 | Phase 2.7（追加修正）へ |
| 現状で完了 | Phase 3（完了）へ |
| 閾値を上げる | 閾値を更新して Phase 3（完了）へ |

---

### Phase 2.7: ユーザー指定箇所の重点修正

ユーザーが指定した差分箇所を重点的に修正する。

**サブエージェント起動**:

```
Task(
  subagent_type="converting-figma-to-html",
  prompt="
    ## 重点修正タスク（ユーザー指定）

    ユーザーが以下の差分箇所を指定しました。これらを重点的に修正してください。

    ### 対象ファイル
    - HTMLファイル: .outputs/{screen-id}/index.html
    - Figma fileKey: {fileKey}
    - Figma nodeId: {nodeId}

    ### 比較画像（必ず確認すること）
    - Figmaスクリーンショット: .outputs/{screen-id}/comparison/figma_iter{N}.png
    - HTMLスクリーンショット: .outputs/{screen-id}/comparison/html_iter{N}.png
    - **差分画像: .outputs/{screen-id}/comparison/diff_iter{N}.png**（赤い箇所が差異）

    ### ⚠️ ユーザー指定の修正箇所（最優先）

    {user-specified-differences}

    ### 修正指示
    1. **ユーザー指定箇所を最優先**で修正
    2. 各箇所について Figma を再確認（get_screenshot または get_design_context）
    3. ピクセル単位で正確に合わせる
    4. 修正後、変更内容を詳細に報告

    ### 注意
    - Figmaの視覚情報が唯一の正（Single Source of Truth）
    - ユーザーが指摘した箇所は**必ず**修正すること
    - 推測ではなく、Figmaを実際に確認して修正すること
  "
)
```

**修正後**:
- Phase 2（比較検証）に戻る
- 反復カウントは継続（例: 反復4回目、5回目...）
- ユーザーが「完了」を選択するまで Phase 2.6 → 2.7 → 2 のループを継続可能

---

### Phase 3: 完了

**最終レポート出力**:

```markdown
# Figma to HTML 変換完了レポート

## 概要

| 項目 | 値 |
|------|-----|
| Figma URL | {url} |
| 画面ID | {screen-id} |
| 反復回数 | {iteration-count} |
| 最終差分率 | {final-diff-percentage}% |
| 判定 | ✅ PIXEL PERFECT / 🟡 ACCEPTABLE |

## 生成ファイル

```
.outputs/{screen-id}/
├── index.html              # 生成HTML
├── mapping-overlay.js      # マッピング可視化
├── spec.md                 # 画面仕様書
├── assets/                 # Figmaからダウンロードしたアセット
│   ├── icon-*.svg
│   └── image-*.png
└── comparison/             # 比較成果物（反復ごとに蓄積）
    ├── figma_iter1.png     # 反復1回目
    ├── html_iter1.png
    ├── diff_iter1.png
    ├── figma_iter2.png     # 反復2回目
    ├── html_iter2.png
    ├── diff_iter2.png
    └── README.md           # 累積差分レポート
```

## 反復履歴

| 回 | 差分率 | 主な修正内容 |
|----|--------|-------------|
| 1 | X.XX% | 初回生成 |
| 2 | X.XX% | {修正内容} |
| 3 | X.XX% | {修正内容} |

## 次のステップ

1. ブラウザでHTMLを開く: `open .outputs/{screen-id}/index.html`
2. 必要に応じて手動で微調整
3. API統合のためコンテンツ分析を確認
```

---

## 設定パラメータ

| パラメータ | デフォルト | 説明 |
|-----------|-----------|------|
| `max-iterations` | 3 | 最大反復回数。超過時は手動修正を促す |
| `threshold` | 1.0 | 許容差分率（%）。この値以下で完了とみなす |

### 閾値の目安

| 閾値 | ユースケース |
|------|-------------|
| 0% | 完全一致が必要（デザインシステムコンポーネント等） |
| 1% | 一般的なUI画面（デフォルト） |
| 5% | プロトタイプ・PoC |

---

## エラー時の対処

| エラー | 対処法 |
|--------|--------|
| MCP接続失敗 | `/mcp` で再接続 |
| HTML生成失敗 | Figmaノードの構造を確認 |
| 比較スクリプトエラー | Node.js依存関係を確認 |
| 最大反復回数超過 | 閾値を上げるか、手動で修正 |

---

## 内部実装メモ

### 反復ループの実装

```
iteration = 0
max_iterations = args.max_iterations or 3
threshold = args.threshold or 1.0

while iteration < max_iterations:
    iteration += 1

    # Phase 2: 比較
    comparison_result = Task(comparing-figma-html)

    if comparison_result.diff_percentage <= threshold:
        # 完了
        break

    # Phase 2.5: 修正
    Task(converting-figma-to-html, mode="fix", diff_report=comparison_result)

if comparison_result.diff_percentage > threshold:
    # 最大反復回数超過
    prompt_user_for_manual_fix()
```

### 状態管理

各反復の状態は `.outputs/{screen-id}/iteration-log.json` に記録:

```json
{
  "iterations": [
    {
      "number": 1,
      "timestamp": "2026-01-09T10:00:00Z",
      "diff_percentage": 5.2,
      "status": "needs_fix"
    },
    {
      "number": 2,
      "timestamp": "2026-01-09T10:05:00Z",
      "diff_percentage": 0.8,
      "status": "acceptable"
    }
  ],
  "final_status": "completed",
  "total_iterations": 2
}
```
