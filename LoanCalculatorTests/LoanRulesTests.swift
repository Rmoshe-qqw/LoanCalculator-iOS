import XCTest
@testable import LoanCalculator

@MainActor
final class LoanRulesTests: XCTestCase {

    func test_currencySupported() async {
        let rules = LoanRules(config: LoanConfig())
        XCTAssertTrue(rules.isCurrencySupported(.usd))
        XCTAssertTrue(rules.isCurrencySupported(.eur))
    }

    func test_coerceAmount_clampsAndSnapsToStep() async {
        let rules = LoanRules(config: LoanConfig())

        // below min -> clamp to min
        XCTAssertEqual(rules.coerceAmount(1, currency: .usd), 5_000)

        // above max -> clamp to max snapped to step (should already fit)
        XCTAssertEqual(rules.coerceAmount(999_999, currency: .usd), 50_000)

        // snap down to nearest step from min
        // min=5000 step=500: 5251 -> 5000, 5499 -> 5000, 5500 -> 5500
        XCTAssertEqual(rules.coerceAmount(5_251, currency: .usd), 5_000)
        XCTAssertEqual(rules.coerceAmount(5_499, currency: .usd), 5_000)
        XCTAssertEqual(rules.coerceAmount(5_500, currency: .usd), 5_500)
    }

    func test_coercePeriod_picksNearestAllowed() async {
        let rules = LoanRules(config: LoanConfig()) // allowed 7,14,21,28

        XCTAssertEqual(rules.coercePeriod(6), 7)
        XCTAssertEqual(rules.coercePeriod(8), 7)
        XCTAssertEqual(rules.coercePeriod(13), 14)
        XCTAssertEqual(rules.coercePeriod(20), 21)
        XCTAssertEqual(rules.coercePeriod(27), 28)
    }

    func test_validationHelpers() async {
        let rules = LoanRules(config: LoanConfig())

        XCTAssertTrue(rules.isAmountInRange(10_000, currency: .usd))
        XCTAssertFalse(rules.isAmountInRange(4_999, currency: .usd))

        XCTAssertTrue(rules.isAmountStepValid(10_000, currency: .usd))
        XCTAssertFalse(rules.isAmountStepValid(10_001, currency: .usd))

        XCTAssertTrue(rules.isPeriodAllowed(14))
        XCTAssertFalse(rules.isPeriodAllowed(10))
    }
}
