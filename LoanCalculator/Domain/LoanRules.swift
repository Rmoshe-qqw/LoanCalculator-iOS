import Foundation

final class LoanRules {

    private let config: LoanConfig

    init(config: LoanConfig = LoanConfig()) {
        self.config = config
    }

    // MARK: - Public accessors

    var interestRatePercent: Int {
        config.interestRatePercent
    }

    var allowedPeriodDays: Set<Int> {
        config.allowedPeriodDays
    }

    var supportedCurrencies: Set<Currency> {
        Set(config.currencyRules.keys)
    }

    // MARK: - Currency rules

    func currencyRules(for currency: Currency) -> CurrencyRules {
        guard let rules = config.currencyRules[currency] else {
            fatalError(
                "Currency \(currency.rawValue) is not supported. " +
                "Supported: \(supportedCurrencies.map(\.rawValue).joined(separator: ", "))"
            )
        }
        return rules
    }

    func isCurrencySupported(_ currency: Currency) -> Bool {
        supportedCurrencies.contains(currency)
    }

    // MARK: - Amount validation

    func isAmountInRange(_ amount: Int, currency: Currency) -> Bool {
        let rules = currencyRules(for: currency)
        return (rules.minAmount...rules.maxAmount).contains(amount)
    }

    func isAmountStepValid(_ amount: Int, currency: Currency) -> Bool {
        let rules = currencyRules(for: currency)
        return ((amount - rules.minAmount) % rules.amountStep) == 0
    }

    // MARK: - Period validation

    func isPeriodAllowed(_ periodDays: Int) -> Bool {
        allowedPeriodDays.contains(periodDays)
    }

    // MARK: - Coercion

    /// Coerce any incoming amount to the closest valid value within rules.
    func coerceAmount(_ amount: Int, currency: Currency) -> Int {
        let rules = currencyRules(for: currency)

        let clamped = min(max(amount, rules.minAmount), rules.maxAmount)
        let offset = clamped - rules.minAmount
        let snapped = (offset / rules.amountStep) * rules.amountStep

        return rules.minAmount + snapped
    }

    /// Coerce any incoming period to the closest allowed value.
    func coercePeriod(_ periodDays: Int) -> Int {
        if allowedPeriodDays.contains(periodDays) {
            return periodDays
        }

        return allowedPeriodDays.min(by: {
            abs($0 - periodDays) < abs($1 - periodDays)
        })!
    }
}
