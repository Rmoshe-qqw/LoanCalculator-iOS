import Foundation
import Combine

// MARK: - Store

@MainActor
final class LoanStore: ObservableObject {
    @Published private(set) var state: LoanState

    private let rules: LoanRules
    private let calculator: LoanCalculator
    private let validator: LoanValidator
    private let submit: (LoanSelection, LoanCalculation) async -> Result<Void, Error>
    private let dateProvider: () -> Date

    private let loadSelection: () -> SavedLoanSelection?
    private let saveSelection: (SavedLoanSelection) -> Void

    init(
        rules: LoanRules,
        calculator: LoanCalculator,
        validator: LoanValidator,
        submit: @escaping (LoanSelection, LoanCalculation) async -> Result<Void, Error>,
        dateProvider: @escaping () -> Date,
        loadSelection: @escaping () -> SavedLoanSelection?,
        saveSelection: @escaping (SavedLoanSelection) -> Void
    ) {
        self.rules = rules
        self.calculator = calculator
        self.validator = validator
        self.submit = submit
        self.dateProvider = dateProvider
        self.loadSelection = loadSelection
        self.saveSelection = saveSelection

        self.state = LoanStore.initialState(
            rules: rules,
            calculator: calculator,
            dateProvider: dateProvider,
            saved: loadSelection()
        )

        recalc()
    }

    func dispatch(_ action: LoanAction) {
        state = reduce(state: state, action: action)

        switch action {
        case .onCurrencyChanged, .onAmountChanged, .onPeriodChanged:
            persistCurrentSelection()
            recalc()

        case .onSubmitClicked:
            submitAction()

        case .onDismissMessage:
            break

        case .recalculated(_, _), .submitStarted, .submitFinished(_, _, _):
            break
        }
    }

    // MARK: - Derived calculation

    private func recalc() {
        let s = state
        let currency = s.currency
        let amountRules = rules.currencyRules(for: currency)

        let amount = rules.coerceAmount(s.amount, currency: currency)
        let period = rules.coercePeriod(s.periodDays)

        if amount != s.amount || period != s.periodDays {
            state = state.copy(amount: amount, periodDays: period)
            persistCurrentSelection()
        }

        let selection = LoanSelection(amount: amount, periodDays: period, currency: currency)
        let calculation = calculator.calculate(selection: selection, startDate: dateProvider())

        dispatch(.recalculated(calculation: calculation, amountRules: amountRules))
    }

    // MARK: - Submit

    private func submitAction() {
        let s = state
        let selection = LoanSelection(amount: s.amount, periodDays: s.periodDays, currency: s.currency)
        let calc = LoanCalculation(
            interestRatePercent: s.interestRatePercent,
            totalRepayment: s.totalRepayment,
            dueDate: s.dueDate,
            currency: s.currency
        )

        switch validator.validate(selection) {
        case .valid:
            Task { [submit] in
                await MainActor.run { self.dispatch(.submitStarted) }

                let result = await submit(selection, calc)

                await MainActor.run {
                    switch result {
                    case .success:
                        self.dispatch(.submitFinished(success: true, messageId: .submitSuccess, detail: nil))

                    case .failure(let error):
                        let messageId: UiMessageId

                        if let ex = error as? SubmitException {
                            switch ex.error {
                            case .network:
                                messageId = .submitFailedNetwork
                            case .timeout:
                                messageId = .submitFailedTimeout
                            case .http(let code):
                                messageId = .submitFailedHttp(code: code)
                            case .unknown:
                                messageId = .submitFailedUnknown
                            }
                        } else {
                            messageId = .submitFailedUnknown
                        }

                        self.dispatch(
                            .submitFinished(
                                success: false,
                                messageId: messageId,
                                detail: String(describing: error)
                            )
                        )
                    }
                }
            }

        case .invalid(let reason):
            let id: UiMessageId
            switch reason {
            case .currencyNotSupported: id = .currencyNotSupported
            case .amountOutOfRange: id = .amountOutOfRange
            case .amountStepInvalid: id = .amountStepInvalid
            case .periodNotAllowed: id = .periodNotAllowed
            }
            dispatch(.submitFinished(success: false, messageId: id, detail: nil))
        }
    }

    // MARK: - Persistence

    private func persistCurrentSelection() {
        let saved = SavedLoanSelection(
            currencyCode: state.currency.rawValue,
            amount: state.amount,
            periodDays: state.periodDays
        )
        saveSelection(saved)
    }

    private static func initialState(
        rules: LoanRules,
        calculator: LoanCalculator,
        dateProvider: () -> Date,
        saved: SavedLoanSelection?
    ) -> LoanState {
        let currencies = Array(rules.supportedCurrencies)
        let periodOptionsDays = Array(rules.allowedPeriodDays).sorted()

        // Default values
        var currency: Currency = .usd
        var amount = 10_000
        var period = 14

        // Restore if available
        if let saved = saved {
            if let restoredCurrency = Currency(rawValue: saved.currencyCode),
               rules.isCurrencySupported(restoredCurrency) {
                currency = restoredCurrency
            }
            amount = saved.amount
            period = saved.periodDays
        }

        // Coerce restored/default values
        amount = rules.coerceAmount(amount, currency: currency)
        period = rules.coercePeriod(period)

        let amountRules = rules.currencyRules(for: currency)
        let now = dateProvider()
        let selection = LoanSelection(amount: amount, periodDays: period, currency: currency)
        let calculation = calculator.calculate(selection: selection, startDate: now)

        return LoanState(
            currency: currency,
            currencies: currencies,
            periodOptionsDays: periodOptionsDays,
            amountMin: amountRules.minAmount,
            amountMax: amountRules.maxAmount,
            amountStep: amountRules.amountStep,
            amount: amount,
            periodDays: period,
            interestRatePercent: calculation.interestRatePercent,
            totalRepayment: calculation.totalRepayment,
            dueDate: calculation.dueDate,
            isLoading: false,
            message: nil
        )
    }
}
