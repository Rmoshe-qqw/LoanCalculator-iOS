import SwiftUI

struct LoanDiscreteSlider: View {
    @Binding var value: Int
    let options: [Int]

    let activeColor: Color
    let inactiveAlpha: Double
    let trackHeight: CGFloat
    let thumbSize: CGFloat
    let thumbBorder: CGFloat
    let minLabel: String
    let maxLabel: String

    @State private var rawValue: Double?

    var body: some View {
        let sorted = options.sorted()
        let minV = Double(sorted.first ?? value)
        let maxV = Double(sorted.last ?? value)

        LoanSliderDouble(
            value: Binding(
                get: {
                    rawValue ?? Double(value)
                },
                set: { v in
                    rawValue = v
                }
            ),
            range: minV...maxV,
            activeColor: activeColor,
            inactiveAlpha: inactiveAlpha,
            trackHeight: trackHeight,
            thumbSize: thumbSize,
            thumbBorder: thumbBorder,
            minLabel: minLabel,
            maxLabel: maxLabel,
            onDragEnded: {
                let current = rawValue ?? Double(value)
                let snapped = Double(nearestOption(to: Int(current.rounded()), in: sorted))
                withAnimation(.easeOut(duration: 0.18)) {
                    rawValue = snapped
                }
                value = Int(snapped)
            }
        )
        .onAppear {
            rawValue = Double(value)
        }
        .onChange(of: value) { _, newValue in
            rawValue = Double(newValue)
        }
    }

    private func nearestOption(to v: Int, in sorted: [Int]) -> Int {
        sorted.min(by: { abs($0 - v) < abs($1 - v) }) ?? v
    }
}

private struct LoanSliderDouble: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    let activeColor: Color
    let inactiveAlpha: Double
    let trackHeight: CGFloat
    let thumbSize: CGFloat
    let thumbBorder: CGFloat
    let minLabel: String
    let maxLabel: String
    let onDragEnded: (() -> Void)?

    @State private var isDragging: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = max(trackHeight, thumbSize)
                let fraction = fractionForValue(value)
                let x = w * fraction

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(activeColor.opacity(inactiveAlpha))
                        .frame(height: trackHeight)

                    Capsule()
                        .fill(activeColor)
                        .frame(width: max(0, x), height: trackHeight)

                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay(
                            Circle().stroke(activeColor, lineWidth: thumbBorder)
                        )
                        .position(
                            x: clamp(x, min: thumbSize / 2, max: w - thumbSize / 2),
                            y: h / 2
                        )
                        .shadow(radius: isDragging ? 2 : 0)
                }
                .frame(height: h)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            isDragging = true
                            value = valueForLocation(g.location.x, width: w)
                        }
                        .onEnded { _ in
                            isDragging = false
                            onDragEnded?()
                        }
                )
            }
            .frame(height: max(trackHeight, thumbSize))

            HStack {
                Text(minLabel)
                Spacer()
                Text(maxLabel)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func fractionForValue(_ v: Double) -> CGFloat {
        let minV = range.lowerBound
        let maxV = range.upperBound
        guard maxV > minV else { return 0 }
        let clamped = min(max(v, minV), maxV)
        return CGFloat((clamped - minV) / (maxV - minV))
    }

    private func valueForLocation(_ x: CGFloat, width: CGFloat) -> Double {
        let minV = range.lowerBound
        let maxV = range.upperBound
        if width <= 0 || maxV <= minV { return minV }
        let fraction = Double(clamp(x, min: 0, max: width) / width)
        return minV + ((maxV - minV) * fraction)
    }

    private func clamp(_ x: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(x, min), max)
    }
}
