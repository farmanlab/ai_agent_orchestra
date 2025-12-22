---
name: terminology
description: Provides business term to code mapping rules. Use when interpreting user requests that include Japanese business terms like 一覧画面, 詳細画面, etc.
agents: [claude, cursor, copilot]
priority: 80
---

# Terminology Mapping

ビジネス用語とコード（ファイル名・コンポーネント名）の対応表。

## 画面系

| 用語 | コード | 備考 |
|------|--------|------|
| 一覧画面 | `page.ts` | リスト表示画面 |

## コンポーネント系

| 用語 | コード | 備考 |
|------|--------|------|

## 処理系

| 用語 | コード | 備考 |
|------|--------|------|

## 使い方

ユーザーが上記の用語を使った場合、対応するコードを参照・編集する。

**例:**
- 「一覧画面を修正して」→ `page.ts` を編集
- 「一覧画面にボタンを追加して」→ `page.ts` 内のコンポーネントを編集
