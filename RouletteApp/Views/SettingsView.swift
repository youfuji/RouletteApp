import SwiftUI

struct SettingsView: View {
    @ObservedObject var apiKeyManager: APIKeyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.orange)
                        Text("Gemini API")
                            .font(.headline)
                    }
                } header: {
                    Text("API設定")
                }
                
                Section {
                    SecureField("Gemini APIキーを入力", text: $apiKeyManager.apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                    
                    if apiKeyManager.hasAPIKey {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("APIキー設定済み")
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("APIキー未設定（モックモード）")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                } footer: {
                    Text("Google AI Studio からAPIキーを取得してください。\nhttps://aistudio.google.com/apikey")
                }
                
                if apiKeyManager.hasAPIKey {
                    Section {
                        Button(role: .destructive) {
                            apiKeyManager.clearAPIKey()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("APIキーを削除")
                            }
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("gemini-2.0-flash 使用", systemImage: "bolt.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("1日10回まで分析可能", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("出力トークンを最小限に抑制", systemImage: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("コスト最適化")
                }
            }
            .navigationTitle("⚙️ 設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}
