---
description: Enforces testing conventions and best practices for reliable test suites. Use when writing or reviewing test code.

globs: "**/*Test.ts", "**/*Test.js", "**/*_test.py", "**/test/**"
alwaysApply: false
---


# Testing Rules

## Test Structure
- AAA パターン（Arrange, Act, Assert）を使用
- テスト名は「should_期待結果_when_条件」形式
- 1つのテストで1つの観点のみ検証

### Example: AAA Pattern

**Bad**:
```typescript
test('user creation', () => {
  const user = createUser('test@example.com');
  expect(user.email).toBe('test@example.com');
  user.activate();
  expect(user.isActive).toBe(true);
  // Multiple concerns in one test
});
```

**Good**:
```typescript
test('should_create_user_with_email_when_valid_email_provided', () => {
  // Arrange
  const email = 'test@example.com';

  // Act
  const user = createUser(email);

  // Assert
  expect(user.email).toBe(email);
});

test('should_activate_user_when_activate_called', () => {
  // Arrange
  const user = createUser('test@example.com');

  // Act
  user.activate();

  // Assert
  expect(user.isActive).toBe(true);
});
```

## Test Coverage
- 新規機能には必ずテストを追加
- 重要なビジネスロジックは100%カバレッジ
- エッジケースと異常系のテストを含める

## Mocking
- 外部依存は必ずモック化
- テストダブルは適切に使い分け
  - Stub: 入力の代替
  - Mock: 振る舞いの検証
  - Spy: 呼び出しの記録

### Example: Mocking External Dependencies

**Bad** (real API call):
```typescript
test('should fetch user data', async () => {
  const data = await fetchUserFromAPI('123');  // Real network call
  expect(data.name).toBeDefined();
});
```

**Good** (mocked):
```typescript
test('should fetch user data', async () => {
  // Arrange
  const mockApi = jest.fn().mockResolvedValue({ name: 'John' });
  const service = new UserService(mockApi);

  // Act
  const data = await service.getUser('123');

  // Assert
  expect(data.name).toBe('John');
  expect(mockApi).toHaveBeenCalledWith('123');
});
```

## Test Organization
- テストファイルは対象ファイルと同じディレクトリ構造
- 共通のテストユーティリティは test/helpers/ に配置
- テストデータは test/fixtures/ に配置

## Best Practices
- テストは独立して実行可能に
- テストの実行順序に依存しない
- テストは高速に（単体テストは1秒以内）
- テストコードも本番コードと同じ品質で
