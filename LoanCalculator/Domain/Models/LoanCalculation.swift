import Foundation

struct LoanCalculation: Equatable {
    let interestRatePercent: Int
    let totalRepayment: Int
    let dueDate: Date
    let currency: Currency
}
