import SwiftUI

struct InputView: View {
    @ObservedObject var viewModel: RouletteViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("候補と意見")
                .font(.headline)
            
            // Candidate Input
            HStack {
                TextField("候補を追加 (例: カレー)", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("追加") {
                    withAnimation {
                        viewModel.addCandidate(name: viewModel.inputText)
                    }
                }
                .disabled(viewModel.inputText.isEmpty)
            }
            
            // List of Candidates
            List {
                ForEach(viewModel.candidates) { candidate in
                    HStack {
                        Circle()
                            .fill(candidate.color)
                            .frame(width: 20, height: 20)
                        Text(candidate.name)
                        Spacer()
                        Text(String(format: "%.2f", candidate.weight))
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .onDelete(perform: viewModel.removeCandidate)
            }
            .listStyle(PlainListStyle())
            .frame(height: 150) // Limit height
            
            Divider()
            
            // Opinion Input (Placeholder for now, or simple implementation)
            Text("みんなの意見 (AI分析用)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // For MVP, we'll just show a button to trigger AI analysis with dummy data or current state
            Button(action: {
                Task {
                    await viewModel.analyzeOpinions()
                }
            }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text(viewModel.isAnalyzing ? "AI分析中..." : "AIで重みを計算")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.candidates.isEmpty || viewModel.isAnalyzing)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
    }
}
