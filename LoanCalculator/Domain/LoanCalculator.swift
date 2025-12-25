import Foundation

final class LoanCalculator {
    private let rules: LoanRules

    init(rules: LoanRules) {
        self.rules = rules
    }

    func calculate(selection: LoanSelection, startDate: Date) -> LoanCalculation {
        let annualRate = Double(rules.interestRatePercent) / 100.0
        let daysFactor = Double(selection.periodDays) / 365.0

        let interest = Double(selection.amount) * annualRate * daysFactor
        let total = Int((Double(selection.amount) + interest).rounded())

        let dueDate = Calendar.current.date(byAdding: .day, value: selection.periodDays, to: startDate) ?? startDate

        return LoanCalculation(
            interestRatePercent: rules.interestRatePercent,
            totalRepayment: total,
            dueDate: dueDate,
            currency: selection.currency
        )
    }
}
