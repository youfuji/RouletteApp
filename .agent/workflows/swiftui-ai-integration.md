---
description: SwiftUIアプリにGemini APIを統合するワークフロー
---

# SwiftUI + Gemini API 統合ガイド

## 1. Gemini REST API 呼び出しパターン

### エンドポイント
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={API_KEY}
```

### リクエスト構造 (Swift)
```swift
struct GeminiRequest: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig
    
    struct Content: Codable {
        let parts: [Part]
    }
    
    struct Part: Codable {
        let text: String
    }
    
    struct GenerationConfig: Codable {
        let responseMimeType: String  // "application/json"
        let maxOutputTokens: Int      // コスト制御: 256推奨
        let temperature: Double       // 0.3-0.5が安定
    }
}
```

### レスポンス構造
```swift
struct GeminiResponse: Codable {
    let candidates: [Candidate]
    
    struct Candidate: Codable {
        let content: Content
    }
    
    struct Content: Codable {
        let parts: [Part]
    }
    
    struct Part: Codable {
        let text: String
    }
}
```

## 2. JSON構造化レスポンス

`generationConfig.responseMimeType = "application/json"` を指定することで、
レスポンスが必ずJSON形式になる。プロンプトで出力スキーマを明示する。

```swift
let systemPrompt = """
JSON形式で回答。スキーマ:
{"weights":{"候補名":0.0〜1.0},"reasons":["理由1","理由2"]}
"""
```

## 3. APIキー管理

- **UserDefaults**でアプリ内に保存（設定画面から入力）
- キーは`SecureField`で表示/入力
- 起動時に`hasAPIKey`フラグを設定

## 4. コスト最適化戦略（App Store向け）

| 戦略 | 実装方法 |
|------|----------|
| 軽量モデル | `gemini-2.0-flash` |
| トークン制限 | `maxOutputTokens: 256` |
| レート制限 | UserDefaultsで日次カウント管理 |
| 出力圧縮 | 箇条書き指定・要約指示 |
| プロンプト最小化 | システムプロンプトを最短に |

## 5. エラーハンドリング

```swift
enum AIServiceError: LocalizedError {
    case noAPIKey
    case rateLimitExceeded(remaining: Int)
    case networkError(Error)
    case invalidResponse
    case apiError(String)
}
```

- `401/403`: APIキー無効 → 設定画面へ誘導
- `429`: レート制限 → リトライ待機メッセージ
- `500+`: サーバーエラー → フォールバック（モック結果）
- ネットワーク不通 → オフラインメッセージ
