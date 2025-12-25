import SwiftUI
import Foundation

struct LoanScreen: View {

    @StateObject private var store: LoanStore

    init(store: LoanStore) {
        _store = StateObject(wrappedValue: store)
    }

    var body: some View {
        let state = store.state

        VStack(alignment: .leading, spacing: 16) {

            Text("Loan calculator")
                .font(.title)
                .fontWeight(.regular)

            CurrencySelector(
                currencies: state.currencies,
                selected: state.currency,
                onSelect: { store.dispatch(.onCurrencyChanged($0)) }
            )

            Text("Amount: \(formatMoney(amount: state.amount, currency: state.currency))")
                .font(.title3)

            LoanSlider(
                value: Binding(
                    get: { state.amount },
                    set: { store.dispatch(.onAmountChanged($0)) }
                ),
                range: state.amountMin...state.amountMax,
                step: state.amountStep,
                activeColor: .green,
                inactiveAlpha: 0.18,
                trackHeight: 14,
                thumbSize: 22,
                thumbBorder: 2,
                minLabel: "\(formatMoney(amount: state.amountMin, currency: state.currency))",
                maxLabel: "\(formatMoney(amount: state.amountMax, currency: state.currency))"
            )

            Text("Period: \(state.periodDays) days")
                .font(.title3)

            LoanDiscreteSlider(
                value: Binding(
                    get: { state.periodDays },
                    set: { store.dispatch(.onPeriodChanged($0)) }
                ),
                options: state.periodOptionsDays,
                activeColor: .orange,
                inactiveAlpha: 0.18,
                trackHeight: 14,
                thumbSize: 22,
                thumbBorder: 2,
                minLabel: "\(state.periodOptionsDays.first ?? 7)d",
                maxLabel: "\(state.periodOptionsDays.last ?? 28)d"
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Rate: \(state.interestRatePercent)%")
                Text("Total repayment: \(formatMoney(amount: state.totalRepayment, currency: state.currency))")
                Text("Due date: \(state.dueDate.formatted(date: .abbreviated, time: .omitted))")
            }

            if state.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            } else {
                Button {
                    store.dispatch(.onSubmitClicked)
                } label: {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            messageView(state)

            Spacer()
        }
        .padding()
        .animation(.default, value: state.message != nil)
    }

    @ViewBuilder
    private func messageView(_ state: LoanState) -> some View {
        if let msg = state.message {
            HStack {
                Text(msgText(msg.id))
                    .foregroundStyle(msg.isError ? .red : .green)
                Spacer()
                Button("OK") { store.dispatch(.onDismissMessage) }
            }
            .padding(12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func msgText(_ id: UiMessageId) -> String {
        switch id {
        case .submitSuccess: return "Application submitted"
        case .submitFailedNetwork: return "Network error"
        case .submitFailedTimeout: return "Request timed out"
        case .submitFailedHttp(let code): return "Server error (\(code))"
        case .submitFailedUnknown: return "Submission failed"
        case .currencyNotSupported: return "Currency is not supported"
        case .amountOutOfRange: return "Amount is out of range"
        case .amountStepInvalid: return "Amount step is invalid"
        case .periodNotAllowed: return "Period is not allowed"
        }
    }
}

// MARK: - UI helpers

private func formatMoney(amount: Int, currency: Currency) -> String {
    let formatted = NumberFormatter.loanMoney.string(from: NSNumber(value: amount)) ?? String(amount)
    return "\(currency.symbol)\(formatted) \(currency.rawValue)"
}

private extension NumberFormatter {
    static let loanMoney: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = true
        nf.groupingSeparator = ","
        nf.decimalSeparator = "."
        nf.maximumFractionDigits = 0
        return nf
    }()
}

private extension Currency {
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        }
    }
}
