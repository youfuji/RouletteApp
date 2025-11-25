import SwiftUI

struct RouletteWheelView: View {
    let candidates: [Candidate]
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            
            if candidates.isEmpty {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .overlay(Text("候補を追加してね").font(.caption))
            } else {
                Canvas { context, size in
                    // Calculate total weight
                    let totalWeight = candidates.reduce(0) { $0 + $1.weight }
                    
                    var currentAngle = Angle.degrees(0)
                    
                    for candidate in candidates {
                        // Calculate slice size based on weight
                        let sliceDegrees = 360.0 * (candidate.weight / totalWeight)
                        let endAngle = currentAngle + Angle.degrees(sliceDegrees)
                        
                        // Draw Slice
                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center,
                                    radius: radius,
                                    startAngle: currentAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                        
                        context.fill(path, with: .color(candidate.color))
                        
                        // Draw Text
                        // Position text in the middle of the slice
                        let textAngle = currentAngle + Angle.degrees(sliceDegrees / 2)
                        let textDistance = radius * 0.65
                        let textX = center.x + CGFloat(cos(textAngle.radians)) * textDistance
                        let textY = center.y + CGFloat(sin(textAngle.radians)) * textDistance
                        
                        context.draw(Text(candidate.name).font(.system(size: 14, weight: .bold)).foregroundColor(.white),
                                     at: CGPoint(x: textX, y: textY))
                        
                        // Advance angle
                        currentAngle = endAngle
                    }
                }
            }
        }
    }
}
