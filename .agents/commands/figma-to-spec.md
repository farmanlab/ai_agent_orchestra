---
name: figma-to-spec
description: Converts Figma designs to comprehensive screen specifications by orchestrating multiple specialized agents. Use when creating implementation-ready specs from Figma designs.
---

# Figma to Spec Command

FigmaデザインURLから画面仕様書を生成するコマンドです。

## 使用方法

```bash
/figma-to-spec <figma-url> [options]
```

**引数**:

| 引数 | 必須 | 説明 |
|------|:----:|------|
| `figma-url` | ✅ | FigmaデザインのURL |
| `--screen-id` | - | 出力ディレクトリ名（省略時はFigmaから自動生成） |
| `--screen-name` | - | 日本語画面名（省略時はFigmaから取得） |
| `--openapi` | - | OpenAPI仕様書のパス（APIマッピング用） |

## 使用例

### 基本

```bash
/figma-to-spec https://figma.com/design/XXXXX/Project?node-id=1234-5678
```

### オプション指定

```bash
/figma-to-spec https://figma.com/design/XXXXX/Project?node-id=1234-5678 --screen-id=course-list --screen-name=講座一覧
```

### OpenAPI指定

```bash
/figma-to-spec https://figma.com/design/XXXXX/Project?node-id=1234-5678 --openapi=openapi/index.yaml
```

---

## 実行手順

このコマンドは `orchestrating-figma-to-spec` スキルを起動し、以下のPhaseを順次実行します。

### Phase概要

| Phase | 内容 | サブエージェント |
|:-----:|------|-----------------|
| 0 | MCP接続確認 | - |
| 1 | HTML変換 | converting-figma-to-html |
| 2 | HTML検証（ユーザー承認必須） | comparing-figma-html |
| 3 | 仕様書初期化 | - |
| 4 | セクション生成 | documenting-ui-states, extracting-interactions, etc. |
| 5 | 最終検証 | - |
| 6 | 完了レポート | - |

### 詳細手順

詳細は以下のスキルドキュメントを参照:

- **[SKILL.md](../skills/orchestrating-figma-to-spec/SKILL.md)**: コア指示
- **[workflow.md](../skills/orchestrating-figma-to-spec/references/workflow.md)**: 各Phase詳細

---

## 出力成果物

```
.outputs/{screen-id}/
├── index.html              # 生成HTML
├── spec.md                 # 画面仕様書
├── mapping-overlay.js      # マッピング可視化
├── assets/                 # アセット
└── comparison/             # 比較成果物
    ├── figma.png
    ├── html.png
    ├── diff.png
    └── README.md
```

---

## 実行フロー

```
1. URL解析
   └─> fileKey, nodeId を抽出

2. Phase 0: MCP接続確認
   └─> mcp__figma__whoami

3. Phase 1: HTML変換
   └─> Task(subagent_type="converting-figma-to-html")

4. Phase 2: HTML検証（ハードゲート）
   ├─> Task(subagent_type="comparing-figma-html")
   └─> ⚠️ ユーザー承認待ち

5. Phase 3-4: 仕様書生成
   └─> 各専門サブエージェントを順次起動

6. Phase 5-6: 検証・完了
   └─> 成果物確認、レポート出力
```

---

## 注意事項

### Phase 2 ユーザー承認

Phase 2（HTML検証）完了後、ユーザーの明示的な承認が必要です。
「続行」「はい」「OK」等の回答を待ってからPhase 3に進みます。

### API仕様の推測禁止

`--openapi` オプションが指定されていない場合、APIマッピングセクションは「API仕様書未提供のためスキップ」と記載されます。推測でAPI仕様を記述することはありません。

### Figma MCP必須

このコマンドはFigma MCPサーバーが起動している必要があります。
接続エラーが発生した場合は `/mcp` で再接続してください。

---

## エラー時の対処

| エラー | 対処法 |
|--------|--------|
| MCP接続失敗 | `/mcp` で再接続 |
| Figma権限エラー | Figmaファイルへのアクセス権を確認 |
| 無効なnode-id | URLのnode-idが正しいか確認 |
| HTML生成失敗 | Figmaノードの構造を確認 |
