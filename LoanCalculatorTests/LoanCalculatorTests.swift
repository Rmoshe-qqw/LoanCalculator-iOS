import XCTest
@testable import LoanCalculator
    
@MainActor
final class LoanCalculatorTests: XCTestCase {

    func test_calculate_dueDateIsStartPlusPeriod() async {
        let rules = LoanRules(config: LoanConfig())
        let calculator = LoanCalculator(rules: rules)

        let start = isoDate("2025-12-22T00:00:00Z")
        let selection = LoanSelection(amount: 10_000, periodDays: 14, currency: .usd)

        let result = calculator.calculate(selection: selection, startDate: start)

        let expectedDue = start.addingTimeInterval(days(14))

        // Compare with tolerance to avoid DST/rounding issues.
        XCTAssertEqual(
            result.dueDate.timeIntervalSince1970,
            expectedDue.timeIntervalSince1970,
            accuracy: 0.5
        )
        XCTAssertEqual(result.interestRatePercent, rules.interestRatePercent)
        XCTAssertEqual(result.currency, .usd)
    }

    func test_totalRepayment_growsWithPeriod() async {
        let rules = LoanRules(config: LoanConfig())
        let calculator = LoanCalculator(rules: rules)

        let start = isoDate("2025-12-22T00:00:00Z")
        let s14 = LoanSelection(amount: 10_000, periodDays: 14, currency: .usd)
        let s28 = LoanSelection(amount: 10_000, periodDays: 28, currency: .usd)

        let r14 = calculator.calculate(selection: s14, startDate: start)
        let r28 = calculator.calculate(selection: s28, startDate: start)

        XCTAssertTrue(r28.totalRepayment > r14.totalRepayment)
    }

    func test_totalRepayment_matchesFormula() async {
        let rules = LoanRules(config: LoanConfig())
        let calculator = LoanCalculator(rules: rules)

        let start = isoDate("2025-12-22T00:00:00Z")
        let sel = LoanSelection(amount: 10_000, periodDays: 14, currency: .usd)
        let result = calculator.calculate(selection: sel, startDate: start)

        // expected: amount * (1 + r * days / 365)
        let r = Double(rules.interestRatePercent) / 100.0
        let expected = Int((Double(sel.amount) * (1.0 + r * Double(sel.periodDays) / 365.0)).rounded())

        XCTAssertEqual(result.totalRepayment, expected)
    }

    // MARK: - Helpers

    private func days(_ n: Int) -> TimeInterval {
        TimeInterval(n) * 24 * 60 * 60
    }

    private func isoDate(_ string: String) -> Date {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        guard let date = f.date(from: string) else {
            XCTFail("Failed to parse ISO date: \(string)")
            return Date(timeIntervalSince1970: 0)
        }
        return date
    }
}
