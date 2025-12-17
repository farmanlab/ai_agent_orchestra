---
description: アーキテクチャ原則と設計パターン
globs: "**/*.ts", "**/*.js", "**/*.py"
alwaysApply: false
---


# Architecture Guidelines

## Layer Structure

プロジェクトは明確なレイヤー構造を持ちます：

```
project/
├── presentation/     # UI層
│   ├── components/  # UIコンポーネント
│   └── pages/       # ページコンポーネント
├── domain/          # ビジネスロジック層
│   ├── models/      # ドメインモデル
│   ├── usecases/    # ユースケース
│   └── interfaces/  # インターフェース定義
└── infrastructure/  # インフラ層
    ├── repositories/ # データアクセス実装
    ├── api/         # API クライアント
    └── database/    # DB アクセス
```

## Dependency Rules
- presentation → domain → infrastructure
- domain層は他の層に依存しない
- infrastructure層はdomain層のインターフェースを実装

## Design Principles
- 単一責務の原則 (SRP)
- 開放閉鎖の原則 (OCP)
- 依存性逆転の原則 (DIP)

## Code Organization
- 関連する機能は同じディレクトリに配置
- ファイル名は役割を明確に表現
- 1ファイル300行以内を目安に
