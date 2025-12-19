# Common Patterns and Solutions

## Pattern 1: God Object (神オブジェクト)

### 問題
単一のクラスやモジュールに多くの責務が集中している

### 例
```typescript
class UserManager {
  createUser() { }
  deleteUser() { }
  sendEmail() { }
  validateInput() { }
  logActivity() { }
  generateReport() { }
  // ... さらに多くのメソッド
}
```

### 解決策
責務ごとにクラスを分割

```typescript
class UserService {
  createUser() { }
  deleteUser() { }
}

class EmailService {
  sendEmail() { }
}

class ValidationService {
  validateInput() { }
}

class ActivityLogger {
  logActivity() { }
}

class ReportGenerator {
  generateReport() { }
}
```

## Pattern 2: Nested Callbacks (コールバック地獄)

### 問題
非同期処理のネストが深い

### 例
```typescript
fetchUser(userId, (user) => {
  fetchPosts(user.id, (posts) => {
    fetchComments(posts[0].id, (comments) => {
      // ...
    });
  });
});
```

### 解決策
async/await を使用

```typescript
const user = await fetchUser(userId);
const posts = await fetchPosts(user.id);
const comments = await fetchComments(posts[0].id);
```

## Pattern 3: Magic Numbers (マジックナンバー)

### 問題
数値の意味が不明

### 例
```typescript
if (user.age > 18) {
  // ...
}

setTimeout(() => {}, 3600000);
```

### 解決策
定数で意味を明確に

```typescript
const LEGAL_AGE = 18;
if (user.age > LEGAL_AGE) {
  // ...
}

const ONE_HOUR_MS = 60 * 60 * 1000;
setTimeout(() => {}, ONE_HOUR_MS);
```

## Pattern 4: Shotgun Surgery (散弾銃手術)

### 問題
1つの変更に多数のファイル修正が必要

### 例
APIのレスポンス形式変更で50ファイル修正

### 解決策
共通インターフェースや抽象化レイヤーを導入

```typescript
// Before: 各所で直接API型を参照
function processUser(apiUser: ApiUserResponse) { }

// After: ドメインモデルに変換
interface User {
  id: string;
  name: string;
}

function toUser(apiUser: ApiUserResponse): User {
  // 変換ロジックは1箇所に集約
  return { id: apiUser.userId, name: apiUser.fullName };
}

function processUser(user: User) { }
```

## Pattern 5: Feature Envy (機能の横恋慕)

### 問題
あるクラスが他のクラスのデータに過度に依存

### 例
```typescript
class Order {
  calculateTotal(customer: Customer) {
    let discount = 0;
    if (customer.isPremium) {
      discount = customer.premiumDiscount;
    }
    return this.subtotal - discount;
  }
}
```

### 解決策
ロジックを適切なクラスに移動

```typescript
class Customer {
  getDiscount(): number {
    return this.isPremium ? this.premiumDiscount : 0;
  }
}

class Order {
  calculateTotal(customer: Customer) {
    return this.subtotal - customer.getDiscount();
  }
}
```

## Pattern 6: N+1 Query Problem

### 問題
ループ内でデータベースクエリを実行

### 例
```typescript
const users = await db.getUsers();
for (const user of users) {
  const posts = await db.getPostsByUserId(user.id); // N回実行
}
```

### 解決策
一括取得

```typescript
const users = await db.getUsers();
const userIds = users.map(u => u.id);
const posts = await db.getPostsByUserIds(userIds); // 1回で取得
```

## Pattern 7: Primitive Obsession (基本型への執着)

### 問題
基本型を過度に使用し、ドメインの概念が不明確

### 例
```typescript
function sendEmail(email: string) {
  // emailが有効かチェック
}
```

### 解決策
値オブジェクトを導入

```typescript
class Email {
  constructor(private value: string) {
    if (!this.isValid(value)) {
      throw new Error('Invalid email');
    }
  }

  private isValid(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  toString(): string {
    return this.value;
  }
}

function sendEmail(email: Email) {
  // 既に検証済み
}
```
