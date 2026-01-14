---
name: refining-screen-specs
description: Refines screen spec.md by incorporating details from specification documents. Use when enhancing existing screen specifications with business logic, component details, and validation results.
allowed-tools: Read Write Glob Grep Bash
---

# Screen Specification Refinement

既存の画面仕様書（spec.md）を、プロジェクトの仕様書群から詳細情報を抽出して精緻化します。

---

## 目的

figma-to-specで生成されたspec.mdを、以下のソースから情報を追加して精緻化:

1. **specification.md** - 機能仕様・画面一覧
2. **business-logic-specification.md** - ビジネスロジック・同意フロー
3. **frontend-specification.md** - URL構造・API呼び出し
4. **component-specification.md** - コンポーネントProps/State
5. **figma-document-mapping.md** - Figma Node IDマッピング
6. **参照spec.md** - 同プロジェクトの完成したspec.md

---

## 入力

| 項目 | 必須 | 説明 |
|------|:----:|------|
| 対象spec.md | ✅ | 精緻化するspec.mdのパス |
| 仕様書ディレクトリ | ✅ | specification.md等があるディレクトリ |
| 参照spec.md | - | 参照する完成済みspec.md（形式の参考） |

---

## ワークフロー

### Phase 1: 現状分析

1. **対象spec.mdを読み込む**
2. **参照spec.mdがあれば読み込んで形式を把握**
3. **現在のセクション構成を確認**

```bash
grep "^## " {target}/spec.md
```

### Phase 2: 仕様書群から情報収集

以下のファイルを読み込み、対象画面に関連する情報を抽出:

| ファイル | 抽出対象 |
|----------|----------|
| specification.md | 画面仕様、機能説明、テスト項目 |
| business-logic-specification.md | 同意フロー、状態遷移、バリデーション |
| frontend-specification.md | URL、API呼び出し、hook |
| component-specification.md | Props、State、テンプレート |
| figma-document-mapping.md | Node ID、関連仕様書セクション |

### Phase 3: 不足セクションの特定

参照spec.mdと比較し、不足しているセクションを特定:

**必須セクション**:
- 基本情報（HTML検証結果を含む）
- 画面概要
- コンテンツ分析
- ビジネスロジック
- UI状態
- インタラクション
- コンポーネント仕様
- デザイントークン
- アクセシビリティ
- 画面フロー
- APIマッピング
- テスト項目
- 受け入れ要件
- 成果物
- HTML検証結果
- 変更履歴

### Phase 4: セクション追加・更新

1. **不足セクションを追加**
2. **既存セクションに詳細を追加**
3. **成果物セクションを追加**
4. **HTML検証結果セクションを追加**
5. **変更履歴を更新**

### Phase 5: 検証

```bash
# 行数確認
wc -l {target}/spec.md

# セクション数確認
grep -c "^## " {target}/spec.md

# プレースホルダー残存確認
grep -c "{{" {target}/spec.md
```

---

## 追加するセクションのテンプレート

### 成果物セクション

```markdown
## 成果物

### ファイル一覧

| ファイル | 説明 |
|----------|------|
| `index.html` | 生成HTML |
| `spec.md` | 本仕様書 |
| `mapping-overlay.js` | マッピング可視化スクリプト |
| `assets/` | SVGアセットフォルダ |
| `comparison/` | Figma-HTML比較結果フォルダ |

### アセット一覧

| ファイル名 | 説明 | Node ID |
|-----------|------|---------|
| `icon-xxx.svg` | アイコン | XXX:XXX |
```

### HTML検証結果セクション

```markdown
## HTML検証結果

| 項目 | 値 |
|------|-----|
| 比較日時 | YYYY-MM-DD |
| 差異率 | X.XX% |
| 判定 | 🟢/🟠/🔴 |
| Figmaスクリーンショット | `comparison/figma.png` |
| HTMLスクリーンショット | `comparison/html.png` |
| 差分画像 | `comparison/diff.png` |

### 残存差異

| 差異種別 | 原因 | 影響度 |
|---------|------|--------|
| フォントレンダリング | システムフォント差異 | 低 |

### UI要素別検証

| UI要素 | 一致度 | 備考 |
|--------|--------|------|
| ナビゲーション | ✅ 一致 | - |
```

---

## 使い方

### 基本

```
@refining-screen-specs

対象: coaching-chat/doc/askai/tutorial/spec.md
仕様書: coaching-chat/doc/askai/
参照: coaching-chat/doc/askai/chat-list/spec.md
```

### 参照なし

```
@refining-screen-specs

対象: coaching-chat/doc/askai/tutorial/spec.md
仕様書: coaching-chat/doc/askai/
```

---

## 出力

1. **更新されたspec.md**
   - 不足セクション追加
   - 詳細情報追加
   - 成果物セクション
   - HTML検証結果セクション
   - 変更履歴更新

2. **精緻化レポート**

```markdown
## 精緻化完了

### 更新内容

| 項目 | Before | After |
|------|--------|-------|
| 総行数 | XXX行 | YYY行 |
| セクション数 | X | Y |
| HTML検証 | なし | ✅ 追加 |
| 成果物一覧 | なし | ✅ 追加 |

### 追加されたセクション

1. 成果物
2. HTML検証結果
3. ...

### 参照した仕様書

- specification.md - §X.X
- business-logic-specification.md - §X.X
- ...
```

---

## 詳細手順

各Phaseの詳細な手順は以下を参照:

**[references/workflow.md](references/workflow.md)**

---

## 注意事項

1. **推測禁止**: 仕様書に記載がない情報は追加しない
2. **既存内容保持**: 既存のセクション内容を削除しない
3. **ソース明記**: 追加した情報のソースを明記
4. **変更履歴**: 必ず変更履歴を更新
