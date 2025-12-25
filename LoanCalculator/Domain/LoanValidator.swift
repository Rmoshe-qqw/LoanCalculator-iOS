final class LoanValidator {

    enum Reason: Equatable {
        case currencyNotSupported
        case amountOutOfRange
        case amountStepInvalid
        case periodNotAllowed
    }

    enum ValidationResult: Equatable {
        case valid
        case invalid(Reason)
    }

    private let rules: LoanRules

    init(rules: LoanRules) {
        self.rules = rules
    }

    func validate(_ selection: LoanSelection) -> ValidationResult {
        if !rules.isCurrencySupported(selection.currency) {
            return .invalid(.currencyNotSupported)
        }
        if !rules.isAmountInRange(selection.amount, currency: selection.currency) {
            return .invalid(.amountOutOfRange)
        }
        if !rules.isAmountStepValid(selection.amount, currency: selection.currency) {
            return .invalid(.amountStepInvalid)
        }
        if !rules.isPeriodAllowed(selection.periodDays) {
            return .invalid(.periodNotAllowed)
        }
        return .valid
    }
}
