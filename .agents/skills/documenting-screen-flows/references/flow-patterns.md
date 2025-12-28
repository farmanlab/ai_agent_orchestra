# 画面フローパターン集

一般的な画面遷移パターンを定義します。

## 目次

1. [ナビゲーション種別](#ナビゲーション種別)
2. [一覧・詳細パターン](#一覧詳細パターン)
3. [フォームフロー](#フォームフロー)
4. [認証フロー](#認証フロー)
5. [モーダルフロー](#モーダルフロー)
6. [タブ・ステップ](#タブステップ)
7. [エラーフロー](#エラーフロー)
8. [Mermaid記法](#mermaid記法)

---

## ナビゲーション種別

### 遷移タイプ

| タイプ | 説明 | アニメーション | 戻り方 |
|--------|------|---------------|--------|
| push | 新画面をスタックに追加 | 右からスライド | popで戻る |
| pop | スタックから画面を削除 | 左へスライド | - |
| replace | 現在の画面を置換 | フェード | 戻れない |
| modal | オーバーレイ表示 | 下からスライド/フェード | dismiss |
| reset | スタックをリセット | フェード | 戻れない |

### 使い分け

| シナリオ | タイプ |
|----------|--------|
| 一覧 → 詳細 | push |
| 詳細 → 一覧（戻る） | pop |
| ログイン成功 → ホーム | reset |
| ログアウト → ログイン | reset |
| フィルター表示 | modal |
| 確認ダイアログ | modal |
| タブ切り替え | replace（同一画面内） |

---

## 一覧・詳細パターン

### 基本パターン

```mermaid
flowchart LR
    List[一覧画面] -->|アイテム選択| Detail[詳細画面]
    Detail -->|戻る| List
```

### パラメータ

| 遷移 | パラメータ | 型 | 説明 |
|------|-----------|-----|------|
| 一覧 → 詳細 | itemId | string | アイテム識別子 |
| 詳細 → 編集 | itemId | string | 編集対象ID |

### 派生パターン

#### 一覧 → 詳細 → 編集

```mermaid
flowchart LR
    List[一覧] -->|選択| Detail[詳細]
    Detail -->|編集| Edit[編集]
    Edit -->|保存| Detail
    Edit -->|キャンセル| Detail
    Detail -->|戻る| List
```

#### 一覧 → 詳細 → 関連詳細

```mermaid
flowchart LR
    List[講座一覧] -->|選択| Detail[講座詳細]
    Detail -->|講師リンク| Instructor[講師詳細]
    Instructor -->|戻る| Detail
    Detail -->|戻る| List
```

---

## フォームフロー

### 基本パターン（単一画面）

```mermaid
flowchart LR
    Form[フォーム入力] -->|送信成功| Complete[完了画面]
    Form -->|送信失敗| Form
```

### 確認画面ありパターン

```mermaid
flowchart LR
    Input[入力] -->|確認| Confirm[確認]
    Confirm -->|修正| Input
    Confirm -->|送信| Complete[完了]
    Complete -->|トップへ| Home[ホーム]
```

### パラメータ

| 遷移 | パラメータ | 説明 |
|------|-----------|------|
| 入力 → 確認 | formData | フォームデータ全体 |
| 確認 → 入力 | formData | 修正用データ |
| 確認 → 完了 | resultId | 登録結果ID |

### ステップフォーム

```mermaid
flowchart LR
    Step1[基本情報] -->|次へ| Step2[詳細情報]
    Step2 -->|戻る| Step1
    Step2 -->|次へ| Step3[確認]
    Step3 -->|戻る| Step2
    Step3 -->|送信| Complete[完了]
```

### 条件分岐フォーム

```mermaid
flowchart TD
    Input[入力] -->|送信| Validate{バリデーション}
    Validate -->|成功| API{API送信}
    Validate -->|失敗| Input
    API -->|成功| Complete[完了]
    API -->|失敗| Error[エラー表示]
    Error -->|再試行| Input
```

---

## 認証フロー

### ログインフロー

```mermaid
flowchart TD
    Guest[未ログイン画面] -->|ログインボタン| Login[ログイン画面]
    Login -->|成功| Redirect{リダイレクト先}
    Login -->|失敗| Login
    Redirect -->|元の画面| Previous[元の画面]
    Redirect -->|指定なし| Home[ホーム]
```

### パラメータ

| 遷移 | パラメータ | 説明 |
|------|-----------|------|
| 任意 → ログイン | redirectTo | ログイン後の遷移先 |
| ログイン → 元の画面 | - | redirectToを使用 |

### 会員登録フロー

```mermaid
flowchart LR
    Register[登録フォーム] -->|送信| Verify[メール確認待ち]
    Verify -->|確認完了| Profile[プロフィール設定]
    Profile -->|完了| Home[ホーム]
```

### ログアウトフロー

```mermaid
flowchart LR
    Any[任意の画面] -->|ログアウト| Confirm{確認ダイアログ}
    Confirm -->|はい| Login[ログイン画面]
    Confirm -->|いいえ| Any
```

### 認証チェック

```mermaid
flowchart TD
    Page[保護されたページ] --> Check{ログイン済み?}
    Check -->|Yes| Content[コンテンツ表示]
    Check -->|No| Login[ログイン画面]
    Login -->|成功| Page
```

---

## モーダルフロー

### 基本パターン

```mermaid
flowchart LR
    Screen[画面] -->|トリガー| Modal[モーダル]
    Modal -->|閉じる| Screen
    Modal -->|アクション完了| Screen
```

### 確認ダイアログ

```mermaid
flowchart TD
    Screen[画面] -->|削除ボタン| Dialog{確認ダイアログ}
    Dialog -->|キャンセル| Screen
    Dialog -->|確認| Action[削除実行]
    Action -->|成功| Screen
    Action -->|失敗| Error[エラー表示]
```

### ネストしたモーダル

```mermaid
flowchart LR
    Screen[画面] -->|設定| Modal1[設定モーダル]
    Modal1 -->|詳細設定| Modal2[詳細モーダル]
    Modal2 -->|閉じる| Modal1
    Modal1 -->|閉じる| Screen
```

### フルスクリーンモーダル

```mermaid
flowchart LR
    List[一覧] -->|新規作成| CreateModal[作成モーダル]
    CreateModal -->|保存| List
    CreateModal -->|キャンセル| List
```

---

## タブ・ステップ

### タブ切り替え

```mermaid
flowchart LR
    subgraph TabContainer[タブコンテナ]
        Tab1[タブ1] ---|切り替え| Tab2[タブ2]
        Tab2 ---|切り替え| Tab3[タブ3]
    end
```

- URLは変更しない（同一画面内）
- または `/page?tab=1` のようにクエリパラメータで管理

### ウィザードステップ

```mermaid
flowchart LR
    Step1[Step 1] -->|次へ| Step2[Step 2]
    Step2 -->|次へ| Step3[Step 3]
    Step2 -->|戻る| Step1
    Step3 -->|戻る| Step2
    Step3 -->|完了| Done[完了]
```

### パラメータ

| パターン | パラメータ | 説明 |
|----------|-----------|------|
| タブ | tab | アクティブなタブID |
| ステップ | step | 現在のステップ番号 |
| ステップ | formData | 累積フォームデータ |

---

## エラーフロー

### APIエラー

```mermaid
flowchart TD
    Action[アクション実行] --> API{API呼び出し}
    API -->|成功| Success[成功処理]
    API -->|認証エラー| Login[ログイン画面]
    API -->|権限エラー| Forbidden[403ページ]
    API -->|サーバーエラー| Error[エラー画面]
    API -->|ネットワークエラー| Retry[リトライ表示]
```

### 404パターン

```mermaid
flowchart LR
    Any[任意のURL] -->|存在しない| NotFound[404ページ]
    NotFound -->|ホームへ| Home[ホーム]
    NotFound -->|戻る| Previous[前の画面]
```

### セッション切れ

```mermaid
flowchart TD
    Protected[保護ページ] --> Check{セッション有効?}
    Check -->|Yes| Content[コンテンツ]
    Check -->|No| Modal[再ログインモーダル]
    Modal -->|ログイン| Protected
    Modal -->|キャンセル| Home[ホーム]
```

---

## Mermaid記法

### 基本構文

```mermaid
flowchart LR
    A[四角] --> B[四角]
    A --> C(丸角)
    A --> D{ひし形}
    A --> E((円))
```

### 方向

| 記法 | 方向 |
|------|------|
| `flowchart LR` | 左から右 |
| `flowchart RL` | 右から左 |
| `flowchart TD` | 上から下 |
| `flowchart BT` | 下から上 |

### ノード形状

| 記法 | 形状 | 用途 |
|------|------|------|
| `[テキスト]` | 四角 | 画面 |
| `(テキスト)` | 丸角四角 | 処理 |
| `{テキスト}` | ひし形 | 分岐 |
| `((テキスト))` | 円 | 開始/終了 |
| `[[テキスト]]` | 二重四角 | サブルーチン |

### 矢印

| 記法 | 意味 |
|------|------|
| `-->` | 通常の矢印 |
| `-->｜ラベル｜` | ラベル付き矢印 |
| `---` | 線（矢印なし） |
| `-.->` | 点線矢印 |
| `==>` | 太い矢印 |

### サブグラフ

```mermaid
flowchart LR
    subgraph 認証
        Login[ログイン]
        Register[登録]
    end
    
    subgraph メイン
        Home[ホーム]
        List[一覧]
    end
    
    Login --> Home
    Register --> Home
```

### スタイル

```mermaid
flowchart LR
    A[通常] --> B[強調]
    style B fill:#f9f,stroke:#333,stroke-width:2px
```

---

## 複合パターン例

### ECサイトフロー

```mermaid
flowchart TD
    Home[ホーム] --> List[商品一覧]
    List --> Detail[商品詳細]
    Detail --> Cart[カート]
    Cart --> Checkout[購入手続き]
    Checkout --> Confirm[確認]
    Confirm --> Complete[完了]
    
    Detail -->|お気に入り| Favorite{ログイン済み?}
    Favorite -->|Yes| AddFav[お気に入り追加]
    Favorite -->|No| Login[ログイン]
    Login --> Detail
```

### 管理画面フロー

```mermaid
flowchart TD
    Dashboard[ダッシュボード] --> Users[ユーザー一覧]
    Dashboard --> Products[商品一覧]
    Dashboard --> Orders[注文一覧]
    
    Users --> UserDetail[ユーザー詳細]
    UserDetail --> UserEdit[ユーザー編集]
    
    Products --> ProductDetail[商品詳細]
    ProductDetail --> ProductEdit[商品編集]
    Products --> ProductCreate[商品作成]
```

### SNSアプリフロー

```mermaid
flowchart LR
    subgraph TabBar
        Feed[フィード]
        Search[検索]
        Create[投稿]
        Notifications[通知]
        Profile[プロフィール]
    end
    
    Feed --> PostDetail[投稿詳細]
    PostDetail --> UserProfile[ユーザープロフィール]
    Search --> UserProfile
    Create --> PostEdit[投稿編集]
    PostEdit --> Feed
```
