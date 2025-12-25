import Foundation

struct LoanState: Equatable {
    var currency: Currency = .usd

    var currencies: [Currency] = []
    var periodOptionsDays: [Int] = []

    var amountMin: Int = 5_000
    var amountMax: Int = 50_000
    var amountStep: Int = 500

    var amount: Int = 10_000
    var periodDays: Int = 14

    var interestRatePercent: Int = 15
    var totalRepayment: Int = 10_058
    var dueDate: Date = Date()

    var isLoading: Bool = false
    var message: UiMessage? = nil
}

extension LoanState {
    func copy(
        currency: Currency? = nil,
        currencies: [Currency]? = nil,
        periodOptionsDays: [Int]? = nil,
        amountMin: Int? = nil,
        amountMax: Int? = nil,
        amountStep: Int? = nil,
        amount: Int? = nil,
        periodDays: Int? = nil,
        interestRatePercent: Int? = nil,
        totalRepayment: Int? = nil,
        dueDate: Date? = nil,
        isLoading: Bool? = nil,
        message: UiMessage?? = nil
    ) -> LoanState {
        LoanState(
            currency: currency ?? self.currency,
            currencies: currencies ?? self.currencies,
            periodOptionsDays: periodOptionsDays ?? self.periodOptionsDays,
            amountMin: amountMin ?? self.amountMin,
            amountMax: amountMax ?? self.amountMax,
            amountStep: amountStep ?? self.amountStep,
            amount: amount ?? self.amount,
            periodDays: periodDays ?? self.periodDays,
            interestRatePercent: interestRatePercent ?? self.interestRatePercent,
            totalRepayment: totalRepayment ?? self.totalRepayment,
            dueDate: dueDate ?? self.dueDate,
            isLoading: isLoading ?? self.isLoading,
            message: message == nil ? self.message : message!
        )
    }
}
