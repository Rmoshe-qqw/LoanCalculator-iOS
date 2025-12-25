import SwiftUI

struct LoanSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int

    let snapToStepOnChange: Bool
    let snapToStepOnEnd: Bool
    let onDragEnded: (() -> Void)?

    let activeColor: Color
    let inactiveAlpha: Double
    let trackHeight: CGFloat
    let thumbSize: CGFloat
    let thumbBorder: CGFloat
    let minLabel: String
    let maxLabel: String

    @State private var isDragging: Bool = false

    init(
        value: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int,
        activeColor: Color,
        inactiveAlpha: Double,
        trackHeight: CGFloat,
        thumbSize: CGFloat,
        thumbBorder: CGFloat,
        minLabel: String,
        maxLabel: String,
        snapToStepOnChange: Bool = true,
        snapToStepOnEnd: Bool = true,
        onDragEnded: (() -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.activeColor = activeColor
        self.inactiveAlpha = inactiveAlpha
        self.trackHeight = trackHeight
        self.thumbSize = thumbSize
        self.thumbBorder = thumbBorder
        self.minLabel = minLabel
        self.maxLabel = maxLabel
        self.snapToStepOnChange = snapToStepOnChange
        self.snapToStepOnEnd = snapToStepOnEnd
        self.onDragEnded = onDragEnded
    }

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
                            let newValue = valueForLocation(g.location.x, width: w)
                            value = snapToStepOnChange ? snapToStep(newValue) : newValue
                        }
                        .onEnded { _ in
                            isDragging = false
                            if snapToStepOnEnd {
                                value = snapToStep(value)
                            }
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

    private func fractionForValue(_ v: Int) -> CGFloat {
        let minV = range.lowerBound
        let maxV = range.upperBound
        guard maxV > minV else { return 0 }
        let clamped = min(max(v, minV), maxV)
        return CGFloat(Double(clamped - minV) / Double(maxV - minV))
    }

    private func valueForLocation(_ x: CGFloat, width: CGFloat) -> Int {
        let minV = range.lowerBound
        let maxV = range.upperBound
        if width <= 0 || maxV <= minV { return minV }
        let fraction = Double(clamp(x, min: 0, max: width) / width)
        let raw = Double(minV) + (Double(maxV - minV) * fraction)
        return Int(raw.rounded())
    }

    private func snapToStep(_ v: Int) -> Int {
        let minV = range.lowerBound
        let maxV = range.upperBound
        let clamped = min(max(v, minV), maxV)
        let offset = clamped - minV
        let snapped = (offset / step) * step
        return minV + snapped
    }

    private func clamp(_ x: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(x, min), max)
    }
}
