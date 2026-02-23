---
description: Xcodeプロジェクトのビルド・検証ワークフロー
---

# Xcode Build & Verification

## ビルド検証

// turbo-all

### 1. 利用可能なスキーマを確認
```bash
xcodebuild -project RouletteApp.xcodeproj -list
```

### 2. iOS Simulator向けビルド
```bash
xcodebuild -project RouletteApp.xcodeproj \
  -scheme RouletteApp \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  build 2>&1 | tail -20
```

### 3. ビルド結果確認
- `BUILD SUCCEEDED` が表示されること
- コンパイルエラーが0であること
- 警告がある場合は内容を確認

## トラブルシューティング

### Scheme が見つからない場合
```bash
xcodebuild -project RouletteApp.xcodeproj -list
```
出力されたスキーマ名を使う。

### Simulator名が無効な場合
```bash
xcrun simctl list devices available | grep iPhone
```
利用可能なデバイス名を確認。
