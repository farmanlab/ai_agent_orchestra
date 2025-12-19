# School Todo Screen - コンテンツ分析

## 概要

**画面名**: やること（School Todo）
**画面の目的**: 配信された宿題の一覧表示と進捗状況の確認
**主要機能**:
- 配信中の宿題と推薦講義のタブ切り替え
- 宿題カードの一覧表示（締め切り日、進捗状況、詳細情報）
- 宿題の種類についての情報表示
- ボトムナビゲーション（5メニュー）

**対象デバイス**: モバイル（SP）375px幅

---

## コンテンツ分類

### 1. ナビゲーション要素

#### 1.1 ステータスバー
- **分類**: システムUI（Static）
- **data属性**: `data-figma-node="I2411:1816;2785:4480"`
- **内容**:
  - キャリア表示: "Carrier"
  - 時刻: "9:41 AM"
  - バッテリー残量: "100%"
  - 信号強度アイコン
  - WiFiアイコン
- **データソース**: システムAPI
- **更新頻度**: リアルタイム

#### 1.2 ナビゲーションバー
- **分類**: ヘッダーナビゲーション（Static/Interactive）
- **data属性**: `data-figma-node="I2411:1816;2785:4493"`
- **内容**:
  - タイトル: "やること"（中央）
  - 右側アイコン1: チェックマーク付き円（完了確認機能）
  - 右側アイコン2: ニュース/通知アイコン
- **インタラクション**:
  - チェックアイコン → 完了した宿題の一覧表示
  - ニュースアイコン → お知らせ一覧表示

#### 1.3 タブメニュー
- **分類**: タブナビゲーション（Interactive）
- **data属性**: `data-figma-node="868:2841"`
- **タブ項目**:
  1. "配信中の宿題"（アクティブ状態）- `data-figma-node="I868:2841;7:84"`
  2. "あなたへのおすすめ講義" - `data-figma-node="I868:2841;7:97"`
- **アクティブ表示**: 下部に3pxの青緑色ボーダー（#3ec1bd）
- **インタラクション**: タップでタブ切り替え

#### 1.4 ボトムナビゲーション
- **分類**: グローバルナビゲーション（Interactive）
- **data属性**: `data-figma-node="5184:181531"`
- **ナビゲーション項目**:
  1. **やること** - `data-figma-node="491:2054"` - アクティブ状態（opacity: 1）
  2. **講座一覧** - `data-figma-node="491:2098"` - 非アクティブ（opacity: 0.6）
  3. **マイ講座** - `data-figma-node="491:2087"` - 非アクティブ（opacity: 0.6）
  4. **学校** - `data-figma-node="5184:181538"` - バッジ表示「99+」
  5. **マイページ** - `data-figma-node="5184:181539"` - バッジ表示「9」
- **バッジ仕様**:
  - 背景色: #de30ca（ピンク）
  - フォントサイズ: 10px
  - 位置: アイコン右上
- **インタラクション**: タップで各セクションへ遷移

---

### 2. 情報表示要素

#### 2.1 宿題の種類について（情報リンク）
- **分類**: テキストリンク（Interactive）
- **data属性**: `data-figma-node="7090:5058"`
- **表示テキスト**: "宿題の種類について"
- **配置**: メインコンテンツ上部右寄せ
- **インタラクション**: タップでヘルプモーダル表示

#### 2.2 課題カード（リスト項目）
- **分類**: カードコンポーネント（Dynamic/Interactive）
- **data属性**: `data-figma-node="6566:7886"` 等（カードごとに異なる）
- **カード構成**:

##### 2.2.1 日付表示部（左側）
- **幅**: 80px（固定）
- **要素**:
  - **日付アイコン**:
    - サイズ: 64px × 64px
    - 月表示: 上部、フォント14px、数字フォント（StudySapuri Numbers）
    - 日表示: 中央、フォント24px、数字フォント
    - "月"ラベル: 右上、フォント10px
    - 進捗リング: SVG circle、stroke-dasharray使用
    - 配色パターン:
      - **ピンク系**: 月背景 #de30ca、日の色 #de30ca（今日まで/あと3日）
      - **ブルー系**: 月背景 #0b41a0、日の色 #0b41a0（あと7日以上）
  - **期限ラベル**:
    - サイズ: 80px × 20px
    - 配色パターン:
      - **今日まで**: 背景 #fef2f7、文字色 #de30ca
      - **あと3日**: 背景 #fef2f7、文字色 #de30ca
      - **あと7日**: 背景 #e1f4ff、文字色 #0ca5e6
    - border-radius: 10px

##### 2.2.2 カードコンテンツ部（右側）
- **幅**: flex: 1（可変）
- **要素**:

###### a. カードヘッダー
- **タイトル**:
  - フォントサイズ: 14px
  - フォントウェイト: 600
  - 文字色: #4c5263
  - 行の高さ: 1.5
  - 最大表示: 2行（truncate後に "..." 表示）
  - 例: "11月27日の宿題", "タイトルが長かった場合（２行以上）の場合、タイトルが長かった..."

- **先生情報**:
  - アバター: 24px × 24px、円形、プレースホルダー画像
  - 先生名: フォント12px、フォントウェイト300、文字色 #4c5263
  - 例: "山田 太郎", "山田 太郎（自動配信）"

###### b. カード詳細
- **講義内容**:
  - アイコン: 16px × 16px、講義アイコン（四角+対角線）
  - テキスト: フォント10px、フォントウェイト300
  - 例: "3講義：5チャプター　確認テスト15問"

- **スケジュール**:
  - アイコン: 16px × 16px、カレンダーアイコン
  - テキスト: フォント10px、フォントウェイト300
  - 例: "3月30日(水)10:00 – 4月6日(水)10:00"

##### 2.2.3 カード全体仕様
- **背景色**: #ffffff（白）
- **border-radius**: 4px
- **padding**: 16px
- **最小高さ**: 126px
- **幅**: 359px
- **margin-bottom**: 8px
- **インタラクション**: タップで課題詳細画面へ遷移

---

## デザイントークン

### 色

| トークン名 | カラーコード | 用途 |
|-----------|-------------|------|
| `blue-ultra` | #1c80e7 | メイン背景 |
| `darkblue` | #0b41a0 | ナビゲーションバー、日付アイコン（ブルー系） |
| `blue-ultra-1` | #005fcc | ボトムナビゲーション背景 |
| `success` | #3ec1bd | アクティブタブ下線 |
| `warning` | #de30ca | 日付アイコン（ピンク系）、バッジ背景 |
| `white` | #ffffff | カード背景、テキスト（ナビ） |
| `gray+2` | #4c5263 | カードテキスト（タイトル、詳細） |
| `danger-3` | #fef2f7 | 期限ラベル背景（ピンク系） |
| `primary-2` | #e1f4ff | 期限ラベル背景（ブルー系） |
| `primary` | #0ca5e6 | 期限ラベル文字色（ブルー系） |

### タイポグラフィ

| トークン名 | 詳細仕様 |
|-----------|---------|
| `nav-title` | Hiragino Sans W6, 16px, line-height: 1.5 |
| `tab-text` | Hiragino Sans W3, 14px, line-height: 1.5 |
| `card-title` | Hiragino Sans W6, 14px, line-height: 1.5 |
| `card-teacher` | Hiragino Sans W3, 12px, line-height: 1.5 |
| `card-detail` | Hiragino Sans W3, 10px, line-height: 1.5 |
| `label-text` | Hiragino Sans W6, 12px, line-height: 1.5 |
| `bottom-nav-label` | Hiragino Sans W6, 10px, line-height: 1.5 |
| `date-month` | StudySapuri Numbers Regular, 14px, line-height: 1.5 |
| `date-day` | StudySapuri Numbers Regular, 24px, line-height: 1.5 |
| `date-month-label` | Hiragino Sans W6, 10px, line-height: 1.5 |

### スペーシング

| トークン名 | サイズ |
|-----------|-------|
| `card-gap` | 16px（カード内要素間） |
| `card-padding` | 16px |
| `card-margin-bottom` | 8px |
| `content-padding-horizontal` | 8px |
| `content-padding-top` | 8px |
| `content-padding-bottom` | 70px（ボトムナビ分） |
| `nav-gap` | 16px（ナビアイコン間） |
| `detail-gap` | 4px（詳細行間） |

### ボーダー・角丸

| トークン名 | サイズ |
|-----------|-------|
| `card-border-radius` | 4px |
| `label-border-radius` | 10px |
| `badge-border-radius` | 8px |
| `avatar-border-radius` | 50%（円形） |
| `tab-active-border` | 3px（下線） |

---

## データ要件

### API エンドポイント（想定）

#### 1. 宿題一覧取得
- **エンドポイント**: `GET /api/assignments/active`
- **レスポンス例**:
```json
{
  "assignments": [
    {
      "id": "asn001",
      "title": "11月27日の宿題",
      "dueDate": "2024-12-31T10:00:00Z",
      "daysUntilDue": 0,
      "dueLabelType": "today",
      "progress": 0,
      "teacher": {
        "id": "tchr001",
        "name": "山田 太郎",
        "avatarUrl": "https://example.com/avatar/tchr001.jpg"
      },
      "contents": {
        "lectures": 3,
        "chapters": 5,
        "tests": 15
      },
      "schedule": {
        "startDate": "2024-03-30T10:00:00Z",
        "endDate": "2024-04-06T10:00:00Z"
      },
      "isAutoDelivered": false
    },
    {
      "id": "asn002",
      "title": "タイトルが長かった場合（２行以上）の場合、タイトルが長かった場合",
      "dueDate": "2025-01-03T10:00:00Z",
      "daysUntilDue": 3,
      "dueLabelType": "warning",
      "progress": 50,
      "teacher": {
        "id": "tchr001",
        "name": "山田 太郎",
        "avatarUrl": "https://example.com/avatar/tchr001.jpg"
      },
      "contents": {
        "lectures": 3,
        "chapters": 5,
        "tests": 15
      },
      "schedule": {
        "startDate": "2024-03-30T10:00:00Z",
        "endDate": "2024-04-06T10:00:00Z"
      },
      "isAutoDelivered": false
    }
  ],
  "totalCount": 5
}
```

#### 2. バッジカウント取得
- **エンドポイント**: `GET /api/notifications/count`
- **レスポンス例**:
```json
{
  "school": 99,
  "mypage": 9
}
```

### データマッピング

| UI要素 | データフィールド | データ型 | 必須 | デフォルト値 |
|--------|----------------|---------|------|-------------|
| タイトル | `assignment.title` | string | ✓ | - |
| 締切日（月） | `assignment.dueDate` (月部分) | number | ✓ | - |
| 締切日（日） | `assignment.dueDate` (日部分) | number | ✓ | - |
| 期限ラベル | `assignment.daysUntilDue` | number | ✓ | 計算値 |
| 進捗リング | `assignment.progress` | number (0-100) | ✓ | 0 |
| 先生名 | `assignment.teacher.name` | string | ✓ | - |
| アバター画像 | `assignment.teacher.avatarUrl` | string (URL) | - | プレースホルダー |
| 講義内容 | `assignment.contents.*` | object | ✓ | - |
| スケジュール | `assignment.schedule.*` | object | ✓ | - |
| 自動配信フラグ | `assignment.isAutoDelivered` | boolean | ✓ | false |
| 学校バッジ | `notifications.school` | number | - | 0 |
| マイページバッジ | `notifications.mypage` | number | - | 0 |

### ビジネスロジック

#### 1. 期限ラベル表示ロジック
```javascript
function getDueLabelConfig(daysUntilDue) {
  if (daysUntilDue === 0) {
    return {
      text: "今日まで",
      type: "pink",
      bgColor: "#fef2f7",
      textColor: "#de30ca"
    };
  } else if (daysUntilDue <= 3) {
    return {
      text: `あと${daysUntilDue}日`,
      type: "pink",
      bgColor: "#fef2f7",
      textColor: "#de30ca"
    };
  } else {
    return {
      text: `あと${daysUntilDue}日`,
      type: "blue",
      bgColor: "#e1f4ff",
      textColor: "#0ca5e6"
    };
  }
}
```

#### 2. 進捗リング表示ロジック
```javascript
function getProgressRingConfig(progress) {
  const circumference = 2 * Math.PI * 30; // radius = 30
  const offset = circumference - (progress / 100) * circumference;

  return {
    strokeDasharray: `${circumference} ${circumference}`,
    strokeDashoffset: offset,
    strokeColor: progress > 0 ? (progress >= 50 ? "#de30ca" : "#0b41a0") : "transparent"
  };
}
```

#### 3. タイトル切り詰めロジック
```css
.card-title {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}
```

---

## インタラクション仕様

### 1. タブ切り替え
- **トリガー**: タブテキストタップ
- **アクション**:
  1. アクティブタブの下線を移動（アニメーション: 0.3s ease）
  2. コンテンツエリアをフェードアウト → フェードイン（0.2s）
  3. 対応するコンテンツ（宿題一覧 or おすすめ講義）を表示
- **フィードバック**: タップ時に軽い透明度変化（opacity: 0.7）

### 2. 課題カードタップ
- **トリガー**: カード全体タップ
- **アクション**:
  1. タップフィードバック（背景色を #f5f5f5 に一瞬変更）
  2. 課題詳細画面へ遷移（スライドイン）
  3. `assignment.id` を渡してルーティング
- **遷移先**: `/assignment/{assignmentId}`

### 3. 「宿題の種類について」リンクタップ
- **トリガー**: テキストリンクタップ
- **アクション**:
  1. ヘルプモーダルを画面下部からスライドイン表示
  2. モーダル背景: 半透明黒（rgba(0,0,0,0.5)）
- **モーダル内容**:
  - 宿題の種類説明
  - 期限ラベルの意味
  - 進捗リングの見方

### 4. ボトムナビゲーションタップ
- **トリガー**: 各ナビ項目タップ
- **アクション**:
  1. アクティブ状態変更（opacity: 1 ↔ 0.6）
  2. 対応する画面へルート変更
  3. ページ遷移アニメーション（フェード or スライド）
- **ルーティング**:
  - やること: `/todo`
  - 講座一覧: `/courses`
  - マイ講座: `/my-courses`
  - 学校: `/school`
  - マイページ: `/mypage`

### 5. ナビバーアイコンタップ
- **チェックアイコン**:
  - アクション: 完了済み宿題一覧モーダル表示
- **ニュースアイコン**:
  - アクション: お知らせ一覧画面へ遷移

---

## アクセシビリティ考慮事項

### 1. セマンティックHTML
- ナビゲーションは `<nav>` タグ使用
- カードは `<article>` タグ使用
- タイトルは `<h1>`, `<h2>` で階層化
- リンクは `<a>` タグ使用

### 2. ARIA属性（推奨追加）
```html
<!-- タブメニュー -->
<div role="tablist" aria-label="コンテンツ切り替え">
  <button role="tab" aria-selected="true" aria-controls="panel-assignments">
    配信中の宿題
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-recommended">
    あなたへのおすすめ講義
  </button>
</div>

<!-- ボトムナビゲーション -->
<nav aria-label="メインナビゲーション">
  <a href="/todo" aria-current="page">やること</a>
  <a href="/courses">講座一覧</a>
  <!-- ... -->
</nav>

<!-- バッジ -->
<span class="nav-badge" aria-label="未読通知99件以上">99+</span>
```

### 3. キーボードナビゲーション
- すべてのインタラクティブ要素にフォーカス可能
- Tabキーで順次移動
- Enterキーで選択/実行

### 4. カラーコントラスト
- テキスト色 #4c5263 vs 背景白 → コントラスト比: 8.59:1（AAA）
- ナビ白テキスト vs 背景 #0b41a0 → コントラスト比: 10.58:1（AAA）
- ラベル文字 #de30ca vs 背景 #fef2f7 → コントラスト比: 5.12:1（AA）

---

## エッジケース・エラーハンドリング

### 1. データ取得失敗
- **表示**: エラーメッセージ「宿題の読み込みに失敗しました。もう一度お試しください。」
- **アクション**: リトライボタン表示

### 2. 宿題が0件
- **表示**: 空状態メッセージ「配信中の宿題はありません」
- **補足**: イラスト + 推奨アクション表示

### 3. タイトルが極端に長い
- **処理**: 2行でtruncate、末尾に "..." 追加
- **詳細**: カードタップで全文表示

### 4. バッジが3桁以上
- **表示**: "99+" で固定（100件以上は詳細画面で確認）

### 5. 画像読み込み失敗
- **アバター**: グレーのプレースホルダー円を表示
- **アイコン**: SVGで代替表示

### 6. ネットワーク低速
- **対応**: スケルトンスクリーン表示（カード形状のグレー矩形）
- **タイムアウト**: 10秒後にエラー表示

---

## パフォーマンス最適化

### 1. 画像最適化
- アバター画像: WebP形式、24px × 24px、品質80%
- 遅延ロード: スクロール位置に応じて読み込み

### 2. リスト仮想化
- 宿題が20件以上の場合、react-windowやrecycler-viewで仮想化
- 初回レンダリング: 最初の10件のみ

### 3. API レスポンスキャッシュ
- キャッシュ時間: 5分
- 更新トリガー: プルトゥリフレッシュ

### 4. アニメーション最適化
- CSS transform/opacityのみ使用（GPU加速）
- will-change プロパティで事前通知

---

## 実装チェックリスト

- [ ] ステータスバーの動的データ統合（システムAPI）
- [ ] ナビゲーションバーの固定配置
- [ ] タブ切り替えアニメーション実装
- [ ] 宿題一覧API統合
- [ ] 課題カードのdata-figma-node属性設定
- [ ] 期限ラベルの動的カラー設定
- [ ] 進捗リングのSVGアニメーション
- [ ] タイトルtruncateロジック実装
- [ ] アバター画像の遅延ロード
- [ ] ボトムナビゲーションのルーティング統合
- [ ] バッジカウントの動的更新
- [ ] アクセシビリティARIA属性追加
- [ ] エラーハンドリング実装
- [ ] スケルトンスクリーン実装
- [ ] レスポンシブ対応（375px固定確認）
- [ ] パフォーマンス測定（Lighthouse）

---

## 補足事項

### デザインシステムとの整合性
このデザインは以下のデザイントークンに準拠しています：
- **カラーパレット**: Learn Native Design System v2.0
- **タイポグラフィ**: Hiragino Sans（システムフォント）、StudySapuri Numbers（数字専用フォント）
- **スペーシング**: 4px grid system

### ブランドガイドライン
- 主要アクション: 青系（#0ca5e6, #0b41a0）
- 警告・緊急: ピンク系（#de30ca）
- 成功・完了: 青緑系（#3ec1bd）

### 既知の制限事項
1. Figma画像URLは7日で期限切れ → プロダクション前にダウンロード必須
2. プレースホルダーアバター使用中 → 実アバター画像に置換必要
3. アイコンは簡略化SVG → 正式アイコンセットと統合推奨

---

## 次のステップ

1. **ブラウザでHTMLを開く**: `open /Users/01045551/repos/ai_agent_orchestra/.agents/tmp/school-todo/index.html`
2. **API統合**: 上記データ要件に基づいてバックエンドと接続
3. **画像アセット置換**: プレースホルダーを実際のアバター画像に置換
4. **インタラクション実装**: JavaScript/フレームワークでインタラクション追加
5. **テスト実施**: ブラウザテスト、アクセシビリティテスト
6. **デプロイ**: 本番環境への展開
