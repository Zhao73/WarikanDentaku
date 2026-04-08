# 割り勘電卓（WarikanDentaku）

日本の飲み会・食事会向けの割り勘計算アプリです。シンプルな均等割りから、傾斜配分や個別注文まで対応します。

## 機能

### 1. 基本割り勘
- 合計金額と人数を入力するだけのシンプル計算
- 100円単位に自動丸め
- 端数処理：誰が何円多く払うかを自動計算

### 2. 傾斜割り勘
- 「幹事」「一般」「新人」など複数グループを設定
- グループごとに人数と比率（例: 幹事1.5倍、新人0.5倍）を指定
- 各グループの一人あたり金額を自動計算（100円単位）

### 3. 個別注文対応
- 参加者ごとに名前を設定
- 注文項目ごとに「みんなで割る」or「個人負担」を選択
- 共有分は均等割り、個人分はそのまま加算して最終金額を算出

### 4. 幹事向け機能
- 計算結果をワンタップでコピー（LINEグループに貼り付け可能）
- 共有シートからLINE・メッセージなどに直接送信
- PayPay / LINE Pay 送金リンクの挿入に対応

### 5. 履歴
- 計算結果をSwiftDataで自動保存
- 日付別に過去の割り勘記録を一覧表示
- 詳細画面で内訳確認・結果の再コピーが可能
- スワイプで削除

### 6. 広告
- 各タブ画面下部にBanner広告（AdMobプレースホルダー）
- 3回計算ごとにInterstitial広告を表示

## スクリーンショット

| 基本割り勘 | 傾斜割り勘 | 個別注文 | 履歴 |
|:---:|:---:|:---:|:---:|
| 金額÷人数 | グループ別比率計算 | 項目別分担 | 過去の記録一覧 |

## 技術スタック

| 項目 | 内容 |
|------|------|
| 言語 | Swift |
| UI | SwiftUI |
| 最低OS | iOS 16.0 |
| データ保存 | SwiftData |
| アーキテクチャ | MVVM |
| バックエンド | 不要（ローカル完結） |
| Bundle ID | `com.warikandentaku.app` |

## プロジェクト構成

```
WarikanDentaku/
├── WarikanDentakuApp.swift          # アプリエントリポイント
├── ContentView.swift                # タブナビゲーション + 広告管理
├── Models/
│   ├── WarikanRecord.swift          # SwiftData 履歴モデル
│   ├── PersonResult.swift           # 個人結果モデル
│   ├── WarikanGroup.swift           # 傾斜グループ定義
│   └── OrderItem.swift              # 注文項目 + 参加者定義
├── ViewModels/
│   ├── BasicWarikanViewModel.swift  # 基本割り勘ロジック
│   ├── KeishaWarikanViewModel.swift # 傾斜割り勘ロジック
│   └── KobetsuWarikanViewModel.swift# 個別注文ロジック
├── Views/
│   ├── BasicWarikan/
│   │   └── BasicWarikanView.swift
│   ├── KeishaWarikan/
│   │   └── KeishaWarikanView.swift
│   ├── KobetsuWarikan/
│   │   └── KobetsuWarikanView.swift
│   ├── History/
│   │   ├── HistoryListView.swift
│   │   └── HistoryDetailView.swift
│   └── Components/
│       ├── BannerAdView.swift       # Banner広告プレースホルダー
│       └── InterstitialAdManager.swift # Interstitial広告管理
├── Utilities/
│   ├── CurrencyFormatter.swift      # 通貨フォーマット
│   └── PaymentLinkHelper.swift      # PayPay/LINE Pay リンク生成
└── Assets.xcassets/
    ├── AccentColor.colorset/        # アクセントカラー (#4CAF50)
    └── PrimaryGreen.colorset/       # メインカラー（ライト/ダーク対応）
```

## デザイン

- **カラー**: 清爽なグリーン (`#4CAF50`) + ホワイト
- **スタイル**: シンプル・かわいい、日本のユーザー向けデザイン
- **フォント**: 金額は大きく太い Rounded フォントで一目瞭然
- **ダークモード**: 完全対応（カラーアセットでライト/ダーク切替）
- **カード UI**: 各セクションは白背景カード + 軽い影

## セットアップ

1. Xcode 15以上でプロジェクトを開く
2. シミュレータまたは実機を選択
3. `Cmd + R` でビルド&実行

AdMob広告を有効にするには、Google Mobile Ads SDKを導入し、`BannerAdView.swift` と `InterstitialAdManager.swift` を実際のAdMob実装に置き換えてください。

## ライセンス

MIT
