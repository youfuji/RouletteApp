# RouletteApp 🎰

シンプルで使いやすいルーレットアプリです。SwiftUIで作られており、iOS、macOS、visionOSのマルチプラットフォームに対応しています。

## 特徴 ✨

- **直感的なUI**: 分かりやすいインターフェースで誰でも簡単に使用可能
- **カスタマイズ可能**: 候補を自由に追加・削除できます
- **美しいアニメーション**: スムーズな回転アニメーションで楽しい体験
- **マルチプラットフォーム対応**: iOS、macOS、visionOSで動作
- **自動カラーリング**: 候補ごとに自動で美しい色が割り当てられます

## スクリーンショット 📱

```
        🎯 シンプルルーレット
    
    ↓
   ┌─────────────────────────┐
   │       ラーメン          │
   │   ┌─────────┐           │
   │   │   寿司   │  カレー   │
   │   └─────────┘           │
   │       パスタ            │
   └─────────────────────────┘
   
      結果: カレー 🍛
   
      [ スタート ]
```

## 機能 🚀

### 基本機能
- ✅ 候補の追加・削除
- ✅ ルーレット回転アニメーション
- ✅ ランダム選択結果表示
- ✅ リアルタイムプレビュー

### UI/UX
- 🎨 候補ごとの自動カラーリング（虹色グラデーション）
- 🎯 視覚的な針（矢印）による結果表示
- 📱 レスポンシブデザイン
- ⌨️ キーボード自動非表示（iOS/visionOS）

## システム要件 📋

- **iOS**: 17.0以降
- **macOS**: 14.0以降  
- **visionOS**: 1.0以降
- **Xcode**: 15.0以降
- **Swift**: 5.0以降

## インストール・実行方法 🛠️

### 1. リポジトリのクローン
```bash
git clone <repository-url>
cd RouletteApp
```

### 2. Xcodeで開く
```bash
open RouletteApp.xcodeproj
```

### 3. ビルド・実行
1. Xcodeでターゲットデバイス（iOS Simulator、Mac、visionOS Simulator）を選択
2. `⌘ + R` でビルド・実行

## 使い方 📖

### 1. 候補の追加
1. 画面下部の入力フィールドに候補名を入力
2. 「追加」ボタンをタップ
3. 候補がルーレットとリストに追加されます

### 2. ルーレットを回す
1. 「スタート」ボタンをタップ
2. ルーレットが回転し、約4秒後に結果が表示されます

### 3. 候補の削除
- リストの項目を左にスワイプして「削除」

## プロジェクト構造 🏗️

```
RouletteApp/
├── RouletteApp/
│   ├── RouletteAppApp.swift      # アプリのエントリーポイント
│   ├── ContentView.swift         # メインのUI・ロジック
│   └── Assets.xcassets/          # アプリアイコン・アセット
├── RouletteApp.xcodeproj/        # Xcodeプロジェクトファイル
└── README.md                     # このファイル
```

## 技術詳細 🔧

### アーキテクチャ
- **MVVM パターン**: `RouletteViewModel`でビジネスロジックを分離
- **SwiftUI**: 宣言的UIフレームワークを使用
- **Combine**: リアクティブプログラミングで状態管理

### 主要コンポーネント

#### 1. データモデル
```swift
struct Candidate: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
}
```

#### 2. ViewModel
```swift
class RouletteViewModel: ObservableObject {
    @Published var candidates: [Candidate] = []
    @Published var rotationAngle: Double = 0
    @Published var selectedResult: String = ""
    // ...
}
```

#### 3. カスタムビュー
- `RouletteWheelView`: Canvas APIを使用した円グラフ描画
- 扇形の計算とテキスト配置の最適化

### アニメーション
```swift
withAnimation(.easeOut(duration: 4.0)) {
    rotationAngle += totalSpin
}
```

## カスタマイズ 🎨

### 回転時間の変更
```swift
// ContentView.swift の spinRoulette() 内
withAnimation(.easeOut(duration: 4.0)) { // <- この値を変更
```

### 色のカスタマイズ
```swift
// RouletteViewModel の addCandidate() 内
let color = Color(hue: hue, saturation: 0.6, brightness: 0.9) // <- 彩度・明度を調整
```

### 最小回転数の変更
```swift
// 最低5回転 + ランダム角度
let totalSpin = 360.0 * 5.0 + randomAngle // <- 5.0を変更
```

## マルチプラットフォーム対応 🌐

このアプリは条件付きコンパイルを使用してマルチプラットフォームに対応しています：

```swift
#if canImport(UIKit)
import UIKit    // iOS/visionOS専用
#endif

// プラットフォーム固有の機能
#if canImport(UIKit)
UIApplication.shared.sendAction(...)  // iOS/visionOSのみ
#endif
```

## トラブルシューティング 🔍

### よくある問題

#### 1. "No such module 'UIKit'" エラー
- **原因**: macOSビルド時にUIKitが見つからない
- **解決**: 条件付きコンパイルが正しく設定されているか確認

#### 2. 候補が表示されない
- **原因**: 候補リストが空
- **解決**: 少なくとも1つの候補を追加

#### 3. アニメーションが動かない
- **原因**: シミュレータの「Reduce Motion」設定
- **解決**: デバイス設定で「視差効果を減らす」をオフ

## 貢献 🤝

バグ報告や機能リクエストはIssueでお知らせください。プルリクエストも歓迎します！

### 開発の流れ
1. フォークする
2. 機能ブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエストを作成

## ライセンス 📄

このプロジェクトはMITライセンスの下で公開されています。詳細は`LICENSE`ファイルを確認してください。

## 作者 👨‍💻

藤原洋希 - 2025年11月24日作成

---

⭐ このプロジェクトが役に立ったら、ぜひスターをお願いします！
