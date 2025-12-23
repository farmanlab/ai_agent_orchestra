---
paths:  "**/*.{ts,js,py}"
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

### Example: Layer Dependencies

**Bad** (domain depends on infrastructure):
```typescript
// domain/usecases/GetUser.ts
import { PrismaClient } from '@prisma/client';  // infrastructure leak

export class GetUser {
  constructor(private prisma: PrismaClient) {}
}
```

**Good** (domain uses interface):
```typescript
// domain/interfaces/UserRepository.ts
export interface UserRepository {
  findById(id: string): Promise<User | null>;
}

// domain/usecases/GetUser.ts
export class GetUser {
  constructor(private userRepo: UserRepository) {}
}

// infrastructure/repositories/PrismaUserRepository.ts
export class PrismaUserRepository implements UserRepository {
  constructor(private prisma: PrismaClient) {}
}
```

## Design Principles
- 単一責務の原則 (SRP)
- 開放閉鎖の原則 (OCP)
- 依存性逆転の原則 (DIP)

## Code Organization
- 関連する機能は同じディレクトリに配置
- ファイル名は役割を明確に表現
- 1ファイル300行以内を目安に
