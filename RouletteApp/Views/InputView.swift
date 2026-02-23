import SwiftUI

struct InputView: View {
    @ObservedObject var viewModel: RouletteViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Candidate Section
            Label("候補リスト", systemImage: "list.bullet")
                .font(.headline)
            
            HStack {
                TextField("候補を追加 (例: カレー)", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    withAnimation { viewModel.addCandidate(name: viewModel.inputText) }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.inputText.isEmpty)
            }
            
            // Candidate List with weight bars
            ForEach(viewModel.candidates) { candidate in
                HStack(spacing: 8) {
                    Circle()
                        .fill(candidate.color)
                        .frame(width: 16, height: 16)
                    
                    Text(candidate.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    // Weight bar
                    let totalWeight = viewModel.candidates.reduce(0) { $0 + $1.weight }
                    let percentage = totalWeight > 0 ? candidate.weight / totalWeight : 0
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(candidate.color.opacity(0.7))
                                .frame(width: geo.size.width * CGFloat(percentage))
                        }
                    }
                    .frame(width: 60, height: 12)
                    
                    Text("\(Int(percentage * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(.vertical, 2)
            }
            .onDelete(perform: viewModel.removeCandidate)
            
            Divider()
            
            // MARK: - Opinion Section
            Label("みんなの意見", systemImage: "bubble.left.and.bubble.right.fill")
                .font(.headline)
                .foregroundColor(.purple)
            
            HStack {
                TextField("名前", text: $viewModel.opinionAuthor)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 70)
                
                TextField("意見を入力 (例: 辛いものが食べたい)", text: $viewModel.opinionText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    withAnimation { viewModel.addOpinion() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
                .disabled(viewModel.opinionText.isEmpty)
            }
            
            // Opinion list
            if !viewModel.opinions.isEmpty {
                ForEach(viewModel.opinions) { opinion in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.purple.opacity(0.6))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(opinion.author)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(opinion.text)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.purple.opacity(0.05))
                    .cornerRadius(8)
                }
                .onDelete(perform: viewModel.removeOpinion)
            }
            
            Divider()
            
            // MARK: - AI Analysis Button
            Button(action: {
                Task { await viewModel.analyzeOpinions() }
            }) {
                HStack {
                    if viewModel.isAnalyzing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(viewModel.isAnalyzing ? "AI分析中..." : "AIで重みを計算")
                    
                    Spacer()
                    
                    // Remaining count badge
                    Text("残り\(viewModel.rateLimiter.remaining)回")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.body.bold())
            }
            .disabled(viewModel.candidates.isEmpty || viewModel.isAnalyzing || !viewModel.rateLimiter.canMakeRequest)
            .opacity(viewModel.rateLimiter.canMakeRequest ? 1.0 : 0.5)
            
            // MARK: - Error Message
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // MARK: - AI Reasons
            if !viewModel.aiReasons.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("AI分析結果", systemImage: "brain.head.profile")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    ForEach(viewModel.aiReasons, id: \.self) { reason in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .foregroundColor(.blue)
                            Text(reason)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
    }
}
