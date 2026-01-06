# Figma to Spec Workflow 詳細手順

オーケストレーターが各Phaseで実行すべき詳細手順を定義します。

## Phase 0: 事前確認

### Step 0.1: Figma MCP接続確認

```bash
mcp__figma__whoami
```

**検証**:
- ✅ 接続成功 → Phase 1 へ
- ❌ 接続失敗 → `/mcp` で再接続を案内

### Step 0.2: 入力情報の確認

| 項目 | 必須 | 説明 |
|------|:----:|------|
| Figma URL | ✅ | デザインのURL |
| 画面ID | ✅ | 出力ディレクトリ名（例: `course-list`） |
| 画面名 | - | 日本語画面名（例: `講座一覧`） |
| OpenAPI | - | API仕様書のパス（APIマッピング用） |

**URLからの抽出**:
```
URL: https://figma.com/design/{fileKey}/{fileName}?node-id={nodeId}
抽出: fileKey, nodeId（ハイフンをコロンに変換）
```

### Step 0.3: 出力ディレクトリの準備

```bash
mkdir -p .outputs/{screen-id}
mkdir -p .outputs/{screen-id}/assets
mkdir -p .outputs/{screen-id}/comparison
```

---

## Phase 1: HTML変換

### Step 1.1: converting-figma-to-html サブエージェント起動

```xml
<invoke name="Task">
  <parameter name="subagent_type">converting-figma-to-html</parameter>
  <parameter name="prompt">
    Figma URL: {url}
    File Key: {fileKey}
    Node ID: {nodeId}
    出力先: .outputs/{screen-id}/

    HTMLを生成し、spec.md「コンテンツ分析」セクションを更新してください。
  </parameter>
  <parameter name="description">Figma to HTML変換</parameter>
</invoke>
```

**期待される出力**:
- `index.html`
- `spec.md`（コンテンツ分析セクション更新済み）
- `mapping-overlay.js`
- `index-{state}.html`（複数状態の場合）

**検証チェックリスト**:
```
- [ ] HTMLファイルが生成された
- [ ] spec.md「コンテンツ分析」セクションが更新された
- [ ] mapping-overlay.js が生成された
- [ ] 全状態のHTMLが生成された（複数状態の場合）
- [ ] data-figma-node 属性が付与されている
```

---

## Phase 2: HTML検証・修正ループ

### Step 2.1: comparing-figma-html サブエージェント起動

```xml
<invoke name="Task">
  <parameter name="subagent_type">comparing-figma-html</parameter>
  <parameter name="prompt">
    Figma URL: {url}
    HTMLファイル: .outputs/{screen-id}/index.html

    FigmaデザインとHTMLを比較し、差異を報告してください。
  </parameter>
  <parameter name="description">Figma-HTML比較検証</parameter>
</invoke>
```

**検証結果の解釈**:
- ✅ ピクセルパーフェクト → Step 2.3 へ
- ❌ 差異あり → Step 2.2 へ

### Step 2.2: 差分修正ループ

1. 差分レポートを確認
2. HTMLを修正
3. 再度 comparing-figma-html を実行
4. ピクセルパーフェクトになるまで繰り返し（最大3回）

**ループ上限到達時**:
```markdown
⚠️ **修正ループ上限到達**

3回の修正を試みましたが、以下の差異が残っています:
- [差異1]
- [差異2]

**選択肢**:
1. 現状で続行する
2. 追加で修正を試みる
3. 手動で修正後、再実行する
```

### Step 2.3: ユーザー承認（必須）

comparing-figma-html の結果をユーザーに報告し、承認を得る:

```markdown
## Phase 2 完了 - 承認待ち

### HTML検証結果

| 項目 | 結果 |
|------|------|
| 比較回数 | X回 |
| 最終ステータス | [ピクセルパーフェクト / 軽微な差異あり] |
| 修正回数 | X回 |

**Phase 3（仕様書生成）に進みますか？**
- 「続行」または「はい」と回答してください
```

---

## Phase 3: 仕様書初期化

### Step 3.1: spec.md の初期化

テンプレートから spec.md を生成：

```bash
Read: .agents/templates/screen-spec.md
```

以下の変数を置換：
- `{{SCREEN_NAME}}`: 画面名
- `{{SCREEN_ID}}`: 画面ID
- `{{FIGMA_URL}}`: Figma URL
- `{{ROOT_NODE_ID}}`: ルートノードID
- `{{DATE}}`: 現在日時

---

## Phase 4: 仕様書セクション生成

各サブエージェントを順次起動してspec.mdを更新。

### Step 4.1: UI状態 (documenting-ui-states)

**実行条件**: 常に実行

```xml
<invoke name="Task">
  <parameter name="subagent_type">documenting-ui-states</parameter>
  <parameter name="prompt">Figma URL: {url}, 画面ID: {screen-id}, 出力先: .outputs/{screen-id}/spec.md</parameter>
  <parameter name="description">UI状態の文書化</parameter>
</invoke>
```

### Step 4.2: インタラクション (extracting-interactions)

**実行条件**: 常に実行

```xml
<invoke name="Task">
  <parameter name="subagent_type">extracting-interactions</parameter>
  <parameter name="prompt">Figma URL: {url}, 画面ID: {screen-id}, 出力先: .outputs/{screen-id}/spec.md</parameter>
  <parameter name="description">インタラクション抽出</parameter>
</invoke>
```

### Step 4.3: フォーム仕様 (defining-form-specs)

**実行条件**: spec.md「コンテンツ分析」に入力フィールドがある場合

```xml
<invoke name="Task">
  <parameter name="subagent_type">defining-form-specs</parameter>
  <parameter name="prompt">Figma URL: {url}, 画面ID: {screen-id}, 出力先: .outputs/{screen-id}/spec.md</parameter>
  <parameter name="description">フォーム仕様定義</parameter>
</invoke>
```

### Step 4.4: APIマッピング (mapping-html-to-api)

**実行条件**: OpenAPI仕様書が提供された場合のみ

```xml
<invoke name="Task">
  <parameter name="subagent_type">mapping-html-to-api</parameter>
  <parameter name="prompt">Figma URL: {url}, OpenAPI: {openapi-path}, 出力先: .outputs/{screen-id}/spec.md</parameter>
  <parameter name="description">APIマッピング</parameter>
</invoke>
```

**OpenAPIがない場合**: 「API仕様書未提供のためスキップ」と記載

### Step 4.5: デザイントークン (extracting-design-tokens)

**実行条件**: 常に実行

```xml
<invoke name="Task">
  <parameter name="subagent_type">extracting-design-tokens</parameter>
  <parameter name="prompt">Figma URL: {url}, 画面ID: {screen-id}, 出力先: .outputs/{screen-id}/spec.md</parameter>
  <parameter name="description">デザイントークン抽出</parameter>
</invoke>
```

### Step 4.6: アクセシビリティ (defining-accessibility-requirements)

**実行条件**: 常に実行

```xml
<invoke name="Task">
  <parameter name="subagent_type">defining-accessibility-requirements</parameter>
  <parameter name="prompt">Figma URL: {url}, 画面ID: {screen-id}, 出力先: .outputs/{screen-id}/spec.md</parameter>
  <parameter name="description">アクセシビリティ要件定義</parameter>
</invoke>
```

### Step 4.7: 画面フロー (documenting-screen-flows)

**実行条件**: 複数画面間の遷移がある場合（ユーザーに確認）

```xml
<invoke name="Task">
  <parameter name="subagent_type">documenting-screen-flows</parameter>
  <parameter name="prompt">Figma URL: {url}, 画面ID: {screen-id}, 出力先: .outputs/{screen-id}/spec.md</parameter>
  <parameter name="description">画面フロー文書化</parameter>
</invoke>
```

### Step 4.8: APIバインディング (binding-figma-content-to-api)

**実行条件**: OpenAPI提供 AND mapping-html-to-api 実行済み

```xml
<invoke name="Task">
  <parameter name="subagent_type">binding-figma-content-to-api</parameter>
  <parameter name="prompt">spec.md: .outputs/{screen-id}/spec.md, OpenAPI: {openapi-path}</parameter>
  <parameter name="description">APIバインディング設計</parameter>
</invoke>
```

---

## Phase 5: 最終検証

### Step 5.1: 成果物ファイルの確認

**必須ファイルチェックリスト**:
```
- [ ] index.html が存在
- [ ] spec.md が存在
- [ ] mapping-overlay.js が存在
- [ ] comparison/figma.png が存在
- [ ] comparison/html.png が存在
- [ ] comparison/diff.png が存在
- [ ] comparison/README.md が存在
```

**不足ファイルがある場合**:

| 不足ファイル | 対処法 |
|-------------|--------|
| comparison/* | comparing-figma-html エージェントを再実行 |
| assets/* | downloading-figma-assets スキルを使用 |
| spec.md | 各セクション生成エージェントを再実行 |

### Step 5.2: セクション完了確認

各セクションが「完了 ✓」または「該当なし」になっているか確認。

---

## Phase 6: 完了レポート

最終成果物を報告:

```markdown
## 画面仕様書生成完了: {画面名}

### 生成ファイル

| ファイル | パス |
|----------|------|
| index.html | `.outputs/{screen-id}/index.html` |
| spec.md | `.outputs/{screen-id}/spec.md` |
| mapping-overlay.js | `.outputs/{screen-id}/mapping-overlay.js` |
| comparison/ | `.outputs/{screen-id}/comparison/` |

### 次のステップ

1. `open .outputs/{screen-id}/spec.md` で仕様書を確認
2. `[要確認]` ラベルの項目を関係者と確認
3. 実装チームに仕様書を共有
```

---

## エラーハンドリング

| Phase | エラー | 対処法 |
|-------|--------|--------|
| 0 | MCP接続失敗 | `/mcp` で再接続 |
| 1 | HTML生成失敗 | Figma権限確認、ノードID確認 |
| 2 | 修正ループ上限 | ユーザー判断を仰ぐ |
| 3 | テンプレート不在 | テンプレートパスを確認 |
| 4 | セクション生成失敗 | スキップして続行、後で再実行 |
| 5 | 検証失敗 | 未完了セクションを報告 |

---

## 成果物フォルダ構造

```
.outputs/{screen-id}/
├── index.html              # [必須] 生成HTML
├── spec.md                 # [必須] 画面仕様書
├── mapping-overlay.js      # [必須] マッピング可視化
├── assets/                 # [必須] アセットフォルダ
│   ├── *.svg               # アイコン
│   └── *.png               # 画像
└── comparison/             # [必須] 比較成果物
    ├── figma.png           # Figmaスクリーンショット
    ├── html.png            # HTMLスクリーンショット
    ├── diff.png            # 差分画像
    └── README.md           # 比較レポート
```

---

## データソースラベル

仕様書内の各項目に付与するソースラベル:

| ラベル | 意味 | 信頼度 |
|--------|------|--------|
| `[Figma]` | Figmaデザインから直接取得 | ✅ 確実 |
| `[API]` | OpenAPI仕様書から取得 | ✅ 確実 |
| `[推奨]` | ベストプラクティスからの提案 | ⚠️ レビュー推奨 |
| `[要確認]` | 別途確認が必要な仮定 | ❌ 要確認 |
