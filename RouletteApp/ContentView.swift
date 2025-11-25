import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RouletteViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("AI ルーレット")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Roulette Area
            ZStack(alignment: .top) {
                // Pointer
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .zIndex(1)
                    .shadow(radius: 2)
                
                // Wheel
                RouletteWheelView(candidates: viewModel.candidates)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(viewModel.rotationAngle))
                    .shadow(radius: 5)
                    .padding(.top, 10)
            }
            
            // Result
            Text(viewModel.selectedResult)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.blue)
                .animation(.none, value: viewModel.selectedResult)
            
            // Spin Button
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
            
            // Input Area
            InputView(viewModel: viewModel)
                .padding(.horizontal)
            
            Spacer()
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
