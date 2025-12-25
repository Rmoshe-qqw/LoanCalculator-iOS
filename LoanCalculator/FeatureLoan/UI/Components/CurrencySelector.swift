import SwiftUI

struct CurrencySelector: View {
    let currencies: [Currency]
    let selected: Currency
    let onSelect: (Currency) -> Void

    private let selectedFill = Color(red: 0.86, green: 0.90, blue: 0.98)
    private let border = Color.black.opacity(0.45)

    var body: some View {
        HStack(spacing: 16) {
            ForEach(currencies, id: \.self) { c in
                Button {
                    onSelect(c)
                } label: {
                    Text(c.rawValue)
                        .font(.headline)
                        .frame(minWidth: 64)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(c == selected ? selectedFill : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(border, lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(Color.black.opacity(0.8))
                .accessibilityLabel("Currency \(c.rawValue)")
                .accessibilityAddTraits(c == selected ? .isSelected : [])
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}
