# Screen Spec Refinement Workflow 詳細手順

spec.md精緻化の各Phaseで実行すべき詳細手順を定義します。

---

## 目次

1. [Phase 1: 現状分析](#phase-1-現状分析)
2. [Phase 2: 仕様書群から情報収集](#phase-2-仕様書群から情報収集)
3. [Phase 3: 不足セクションの特定](#phase-3-不足セクションの特定)
4. [Phase 4: セクション追加・更新](#phase-4-セクション追加更新)
5. [Phase 5: 検証](#phase-5-検証)
6. [エラーハンドリング](#エラーハンドリング)
7. [チェックリスト](#チェックリスト)

---

## Phase 1: 現状分析

### Step 1.1: 対象spec.mdの読み込み

```bash
Read: {target}/spec.md
```

### Step 1.2: 現在のセクション構成を確認

```bash
grep "^## " {target}/spec.md
```

**確認ポイント**:
- 既存セクション数
- プレースホルダーの有無
- 行数

### Step 1.3: 参照spec.mdの読み込み（あれば）

```bash
Read: {reference}/spec.md
```

**抽出ポイント**:
- セクション構成
- 各セクションの粒度
- 表形式の使い方
- HTML検証結果の書き方
- 成果物セクションの書き方

---

## Phase 2: 仕様書群から情報収集

### Step 2.1: specification.md

```bash
Read: {docs}/specification.md
```

**抽出対象**:
- 画面仕様（§2.2.X）
- テスト項目（§6.X）
- 画面遷移図（§2.1）

**抽出例（チュートリアル画面）**:
```
§2.2.2 AskAI TOP画面
- 使い方ガイド機能
- ヘルプアイコン押下でガイド表示
- 「次へ」ボタンで次ページへ
- 「スキップ」ボタンで残りページを省略

テスト項目 No.589, 590
```

### Step 2.2: business-logic-specification.md

```bash
Read: {docs}/business-logic-specification.md
```

**抽出対象**:
- バリデーションルール（§2.X）
- 状態遷移（§6.X）
- 条件分岐（§4.X）
- エラーハンドリング（§5.X）

**抽出例（同意フロー）**:
```
§4.2 同意フロー
- 未同意 → TutorialPageへリダイレクト
- 同意ボタン押下 → POST /consents
- useAskAiConsent hook
```

### Step 2.3: frontend-specification.md

```bash
Read: {docs}/frontend-specification.md
```

**抽出対象**:
- URL構造（§2.1）
- API呼び出しタイミング（§3.X）
- 使用フック（§3.X）
- キャッシュ戦略（§5.X）

**抽出例**:
```
§2.1 URL構造
- /{locale}/ask_ai/tutorial → TutorialPage

§3.1 InitialPage
- GET /student_api/ask_ai/consents（画面表示時）
- POST /student_api/ask_ai/consents（同意ボタン押下時）
```

### Step 2.4: component-specification.md

```bash
Read: {docs}/component-specification.md
```

**抽出対象**:
- コンポーネント階層（§2.X）
- Props定義（§3.X）
- State定義（§4.X）
- テンプレート仕様（§3.1）

**抽出例**:
```
§3.1 AskAiPageTemplate
interface AskAiPageTemplateProps {
  backgroundType: 'top' | 'normal' | 'tutorial';
  ...
}
```

### Step 2.5: figma-document-mapping.md

```bash
Read: {docs}/figma-document-mapping.md
```

**抽出対象**:
- Node IDマッピング（§1.X）
- 関連仕様書セクション

**抽出例（チュートリアル）**:
```
§1.5 チュートリアル画面
| チュートリアル01 | 2350:6396 | specification.md §2.2.2 |
| チュートリアル02 | 2350:6375 | ... |
```

---

## Phase 3: 不足セクションの特定

### Step 3.1: 必須セクションのチェックリスト

```
- [ ] 基本情報（HTML検証結果を含む）
- [ ] 関連ドキュメント
- [ ] 画面概要
- [ ] 構造・スタイル
- [ ] コンテンツ分析
- [ ] ビジネスロジック
- [ ] UI状態
- [ ] インタラクション
- [ ] コンポーネント仕様
- [ ] デザイントークン
- [ ] アクセシビリティ
- [ ] 画面フロー
- [ ] APIマッピング
- [ ] テスト項目
- [ ] 受け入れ要件
- [ ] アセット一覧
- [ ] ネイティブ実装ガイド（該当時）
- [ ] 備考
- [ ] 成果物
- [ ] HTML検証結果
- [ ] 変更履歴
```

### Step 3.2: 比較分析

**参照spec.mdと比較**:
```bash
# 参照のセクション
grep "^## " {reference}/spec.md > /tmp/ref_sections.txt

# 対象のセクション
grep "^## " {target}/spec.md > /tmp/target_sections.txt

# 差分
diff /tmp/ref_sections.txt /tmp/target_sections.txt
```

---

## Phase 4: セクション追加・更新

### Step 4.1: 基本情報の更新

**追加項目**:
- `HTML検証 | ✅ 完了 (差異率 X.XX%)`

```markdown
| 項目 | 値 |
|------|-----|
| ... | ... |
| HTML検証 | ✅ 完了 (差異率 X.XX%) |
```

### Step 4.2: 成果物セクションの追加

**挿入位置**: 備考セクションの後

```markdown
## 成果物

### ファイル一覧

| ファイル | 説明 |
|----------|------|
| `index.html` | 生成HTML（Figmaアセット反映済み） |
| `spec.md` | 本仕様書 |
| `mapping-overlay.js` | マッピング可視化スクリプト |
| `download-assets.js` | アセットダウンロードスクリプト（あれば） |
| `ASSETS.md` | アセット一覧・ダウンロード手順（あれば） |
| `assets/` | SVGアセットフォルダ |
| `comparison/` | Figma-HTML比較結果フォルダ |

### アセット一覧

| ファイル名 | 説明 | Node ID |
|-----------|------|---------|
| `icon-xxx.svg` | アイコン | XXX:XXX |
```

### Step 4.3: HTML検証結果セクションの追加

**挿入位置**: 成果物セクションの後

**comparison/README.mdから情報を取得**:
```bash
Read: {target}/comparison/README.md
```

```markdown
## HTML検証結果

| 項目 | 値 |
|------|-----|
| 比較日時 | YYYY-MM-DD |
| 差異率 | X.XX% |
| 判定 | 🟢 NEARLY PERFECT / 🟠 NOTICEABLE / 🔴 SIGNIFICANT |
| Figmaスクリーンショット | `comparison/figma.png` |
| HTMLスクリーンショット | `comparison/html.png` |
| 差分画像 | `comparison/diff.png` |

### 残存差異

| 差異種別 | 原因 | 影響度 |
|---------|------|--------|
| フォントレンダリング | システムフォント差異 | 低 |
| 背景ブラー効果 | backdrop-filterの差異 | 低 |

### UI要素別検証

| UI要素 | 一致度 | 備考 |
|--------|--------|------|
| ナビゲーションバー | ✅ 一致 | - |
| ボタン | ✅ 一致 | - |
| 背景 | △ 軽微差異 | ブラー効果 |
```

### Step 4.4: 変更履歴の更新

```markdown
| YYYY-MM-DD | 仕様書精緻化（specification.md等から詳細追加） | refining-screen-specs |
```

### Step 4.5: 既存セクションの強化

**情報追加のパターン**:

1. **ビジネスロジック** ← business-logic-specification.md
2. **コンポーネント仕様** ← component-specification.md
3. **APIマッピング** ← frontend-specification.md
4. **テスト項目** ← specification.md
5. **画面フロー** ← specification.md

---

## Phase 5: 検証

### Step 5.1: 基本検証

```bash
# 行数
wc -l {target}/spec.md

# セクション数
grep -c "^## " {target}/spec.md

# プレースホルダー残存
grep -c "{{" {target}/spec.md || echo "0"
```

### Step 5.2: 必須セクション確認

```bash
for section in "基本情報" "画面概要" "UI状態" "インタラクション" "成果物" "HTML検証結果" "変更履歴"; do
  grep -q "## $section" {target}/spec.md && echo "✅ $section" || echo "❌ $section"
done
```

### Step 5.3: 最終レポート生成

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
3. (その他追加セクション)

### 参照した仕様書

- `specification.md` - §X.X
- `business-logic-specification.md` - §X.X
- `frontend-specification.md` - §X.X
- `component-specification.md` - §X.X
- `figma-document-mapping.md` - §X.X
```

---

## エラーハンドリング

| 状況 | 対処法 |
|------|--------|
| 仕様書が見つからない | 利用可能な仕様書のみで精緻化 |
| 参照spec.mdがない | 必須セクションリストのみで確認 |
| comparison/がない | HTML検証結果セクションをスキップ |
| 対象画面の情報がない | その旨を記載、推測しない |

---

## チェックリスト

### 精緻化前

- [ ] 対象spec.mdのパスを確認
- [ ] 仕様書ディレクトリのパスを確認
- [ ] 参照spec.mdのパスを確認（あれば）
- [ ] comparison/ディレクトリの存在確認

### 精緻化後

- [ ] 全必須セクションが存在
- [ ] HTML検証結果セクションが追加された
- [ ] 成果物セクションが追加された
- [ ] 変更履歴が更新された
- [ ] プレースホルダーが残っていない
- [ ] 行数が増加した
