//
//  CountdownRing.swift
//  EstacioneAqui
//


import SwiftUI

struct CountdownRing: View {
    let progress: Double
    var lineWidth: CGFloat = 14
    var tint: Color = .primaryBlue

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    tint,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
    }
}

#Preview {
    CountdownRing(progress: 0.65)
        .frame(width: 220, height: 220)
        .padding()
}
