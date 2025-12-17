//
//  AnimatedBackgroundView.swift
//  Subscription Reaper
//
//  Created by Anoop Jose on 17/12/2025.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Base background color - Pure white/black for higher contrast
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            // Animated blurred blobs - Increased opacities and switched to more vibrant hues
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    // Blob 1: Intense Blue
                    drawBlob(in: context, size: size, time: time, offset: 0, color: Color(red: 0, green: 0.4, blue: 1.0).opacity(0.35))
                    // Blob 2: Vibrant Indigo/Purple
                    drawBlob(in: context, size: size, time: time, offset: 2, color: Color(red: 0.5, green: 0, blue: 1.0).opacity(0.3))
                    // Blob 3: Saturated Cyan
                    drawBlob(in: context, size: size, time: time, offset: 4, color: Color(red: 0, green: 1.0, blue: 0.9).opacity(0.25))
                    // Blob 4: Bright Glow
                    drawBlob(in: context, size: size, time: time * 0.5, offset: 6, color: Color.white.opacity(0.25))
                }
                .blur(radius: 70) // Slightly tighter blur for punchier colors
            }
            
            // Pattern Overlay (Subtle dots)
            GeometryReader { geo in
                Canvas { context, size in
                    let dotSize: CGFloat = 1.5
                    let spacing: CGFloat = 30
                    let rows = Int(size.height / spacing)
                    let cols = Int(size.width / spacing)
                    
                    for row in 0...rows {
                        for col in 0...cols {
                            let rect = CGRect(
                                x: CGFloat(col) * spacing,
                                y: CGFloat(row) * spacing,
                                width: dotSize,
                                height: dotSize
                            )
                            context.fill(Path(ellipseIn: rect), with: .color(.primary.opacity(0.08)))
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private func drawBlob(in context: GraphicsContext, size: CGSize, time: TimeInterval, offset: Double, color: Color) {
        let x = size.width * (0.5 + 0.3 * cos(time * 0.5 + offset))
        let y = size.height * (0.5 + 0.3 * sin(time * 0.7 + offset))
        let radius = min(size.width, size.height) * 0.4
        
        context.fill(
            Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
            with: .color(color)
        )
    }
}

#Preview {
    AnimatedBackgroundView()
}
