struct LoanConfig {
    let interestRatePercent: Int
    let allowedPeriodDays: Set<Int>
    let currencyRules: [Currency: CurrencyRules]

    init(
        interestRatePercent: Int = 15,
        allowedPeriodDays: Set<Int> = [7, 14, 21, 28],
        currencyRules: [Currency: CurrencyRules] = [
            .usd: CurrencyRules(
                minAmount: 5_000,
                maxAmount: 50_000,
                amountStep: 500
            ),
            .eur: CurrencyRules(
                minAmount: 5_000,
                maxAmount: 50_000,
                amountStep: 500
            ),
        ]
    ) {
        self.interestRatePercent = interestRatePercent
        self.allowedPeriodDays = allowedPeriodDays
        self.currencyRules = currencyRules
    }
}

struct CurrencyRules: Equatable {
    let minAmount: Int
    let maxAmount: Int
    let amountStep: Int
}
