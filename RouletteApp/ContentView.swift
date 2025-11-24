//
//  ContentView.swift
//  RouletteApp
//
//  Created by 藤原洋希 on 2025/11/24.
//

import SwiftUI
import UIKit    // 追加: キーボードを閉じる処理(UIApplication)に必要
import Combine  // 追加: ObservableObjectや@Publishedの動作を安定させるために必要

// MARK: - 1. アプリのエントリーポイント
// アプリ起動時に最初に呼ばれる部分です。
//@main
//struct RouletteApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// MARK: - 2. データモデル
// ルーレットの候補を表すデータ構造です。
struct Candidate: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
}

// MARK: - 3. ViewModel (ロジック担当)
// 画面のデータや計算処理（回転ロジックなど）を管理します。
class RouletteViewModel: ObservableObject {
    @Published var candidates: [Candidate] = []
    @Published var inputText: String = ""
    @Published var rotationAngle: Double = 0 // ルーレットの回転角度
    @Published var selectedResult: String = "スタートボタンを押してね"
    @Published var isSpinning: Bool = false
    
    init() {
        // 初期データを入れておく（空でもOK）
        addCandidate(name: "ラーメン")
        addCandidate(name: "カレー")
        addCandidate(name: "寿司")
        addCandidate(name: "パスタ")
    }
    
    // 候補の追加
    func addCandidate(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        // 色を自動生成（虹色のようにずらす）
        let hue = Double(candidates.count) * 0.15
        let color = Color(hue: hue.truncatingRemainder(dividingBy: 1.0), saturation: 0.6, brightness: 0.9)
        
        candidates.append(Candidate(name: trimmed, color: color))
        inputText = "" // 入力欄をクリア
    }
    
    // 候補の削除
    func removeCandidate(at offsets: IndexSet) {
        candidates.remove(atOffsets: offsets)
    }
    
    // ルーレットを回す処理
    func spinRoulette() {
        guard !candidates.isEmpty, !isSpinning else { return }
        
        isSpinning = true
        selectedResult = "抽選中..."
        
        // ランダムな回転量（最低5回転 + ランダムな角度）
        let randomAngle = Double.random(in: 0..<360)
        let totalSpin = 360.0 * 5.0 + randomAngle
        
        // アニメーション設定
        withAnimation(.easeOut(duration: 4.0)) {
            rotationAngle += totalSpin
        }
        
        // アニメーション終了後の判定
        // NOTE: DispatchQueueで遅延させて結果を表示します
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.calculateResult()
            self.isSpinning = false
        }
    }
    
    // 止まった角度から当選者を計算するロジック
    private func calculateResult() {
        let count = Double(candidates.count)
        let sliceAngle = 360.0 / count
        
        // 現在の角度を360で割った余りを取得（正規化）
        // SwiftUIの円は右(0度)から始まり時計回り。
        // 上(-90度/270度)にある針の位置を考慮して補正計算します。
        let currentRotation = rotationAngle.truncatingRemainder(dividingBy: 360)
        
        // 針(上)の位置に来ている角度を逆算
        // 360 - currentRotation で「どれだけ回ったか」の逆位置を取得し、針のオフセット(90度)を足す
        let pointerAngle = (360.0 - currentRotation + 90.0).truncatingRemainder(dividingBy: 360.0)
        
        // インデックスを計算
        let index = Int(pointerAngle / sliceAngle)
        
        if indices.contains(index) {
            selectedResult = "結果: \(candidates[index].name)"
        }
    }
    
    // 安全なインデックスアクセス用
    private var indices: Range<Int> {
        candidates.indices
    }
}

// MARK: - 4. ルーレット描画View
// Canvasを使って円グラフを描画します
struct RouletteWheelView: View {
    let candidates: [Candidate]
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            
            // 候補が0の場合はグレーの円を表示
            if candidates.isEmpty {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .overlay(Text("候補を追加してね").font(.caption))
            } else {
                // 円グラフの描画
                Canvas { context, size in
                    let sliceAngle = Angle.degrees(360.0 / Double(candidates.count))
                    
                    for (index, candidate) in candidates.enumerated() {
                        let startAngle = sliceAngle * Double(index)
                        let endAngle = startAngle + sliceAngle
                        
                        // パス（扇形）の作成
                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                        
                        // 塗りつぶし
                        context.fill(path, with: .color(candidate.color))
                        
                        // テキストの描画（角度に合わせて回転させる）
                        // 中心から少し外側にテキストを配置する計算
                        let textAngle = startAngle + (sliceAngle / 2)
                        let textDistance = radius * 0.65
                        let textX = center.x + CGFloat(cos(textAngle.radians)) * textDistance
                        let textY = center.y + CGFloat(sin(textAngle.radians)) * textDistance
                        
                        context.draw(Text(candidate.name).font(.system(size: 14, weight: .bold)).foregroundColor(.white),
                                     at: CGPoint(x: textX, y: textY))
                    }
                }
            }
        }
    }
}

// MARK: - 5. メイン画面 (ContentView)
struct ContentView: View {
    // ViewModelを所有（StateObjectで保持）
    @StateObject private var viewModel = RouletteViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // タイトル
            Text("シンプルルーレット")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // --- ルーレット表示エリア ---
            ZStack(alignment: .top) {
                // 針（逆三角形）
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .zIndex(1) // 最前面に表示
                    .shadow(radius: 2)
                
                // ルーレット本体
                RouletteWheelView(candidates: viewModel.candidates)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(viewModel.rotationAngle)) // ここで回転させる
                    .shadow(radius: 5)
                    .padding(.top, 10) // 針とかぶらないように少し下げる
            }
            
            // 結果表示
            Text(viewModel.selectedResult)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.blue)
                .animation(.none, value: viewModel.selectedResult) // 文字の変化はアニメーションさせない
            
            // スタートボタン
            Button(action: {
                viewModel.spinRoulette()
            }) {
                Text(viewModel.isSpinning ? "回転中..." : "スタート")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.candidates.isEmpty || viewModel.isSpinning ? Color.gray : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(viewModel.candidates.isEmpty || viewModel.isSpinning)
            .padding(.horizontal)
            
            Divider()
            
            // --- 候補入力・リストエリア ---
            VStack {
                HStack {
                    TextField("候補を入力 (例: カレー)", text: $viewModel.inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("追加") {
                        withAnimation {
                            viewModel.addCandidate(name: viewModel.inputText)
                        }
                    }
                    .disabled(viewModel.inputText.isEmpty)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(viewModel.candidates) { candidate in
                        HStack {
                            Circle()
                                .fill(candidate.color)
                                .frame(width: 20, height: 20)
                            Text(candidate.name)
                        }
                    }
                    .onDelete(perform: viewModel.removeCandidate)
                }
                .listStyle(PlainListStyle())
            }
        }
        // タップ時にキーボードを閉じる
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
