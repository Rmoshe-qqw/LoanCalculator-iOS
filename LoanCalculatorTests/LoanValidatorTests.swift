import XCTest
@testable import LoanCalculator

@MainActor
final class LoanValidatorTests: XCTestCase {

    func test_validSelection_isValid() async {
        let rules = LoanRules(config: LoanConfig())
        let validator = LoanValidator(rules: rules)

        let res = validator.validate(LoanSelection(amount: 5_000, periodDays: 14, currency: .usd))
        XCTAssertEqual(res, .valid)
    }

    func test_amountBelowMin_isInvalid() async {
        let rules = LoanRules(config: LoanConfig())
        let validator = LoanValidator(rules: rules)

        let res = validator.validate(LoanSelection(amount: 4_999, periodDays: 14, currency: .usd))
        XCTAssertEqual(res, .invalid(.amountOutOfRange))
    }

    func test_periodNotAllowed_isInvalid() async {
        let rules = LoanRules(config: LoanConfig())
        let validator = LoanValidator(rules: rules)

        let res = validator.validate(LoanSelection(amount: 10_000, periodDays: 10, currency: .usd))
        XCTAssertEqual(res, .invalid(.periodNotAllowed))
    }

    func test_amountStepInvalid_isInvalid() async {
        let rules = LoanRules(config: LoanConfig())
        let validator = LoanValidator(rules: rules)

        let res = validator.validate(LoanSelection(amount: 10_001, periodDays: 14, currency: .usd))
        XCTAssertEqual(res, .invalid(.amountStepInvalid))
    }
}
