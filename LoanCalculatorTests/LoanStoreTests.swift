import XCTest
@testable import LoanCalculator

@MainActor
final class LoanStoreTests: XCTestCase {

    func test_currencyChange_recalculatesAndPersists() async {
        let rules = LoanRules(config: LoanConfig())
        let calculator = LoanCalculator(rules: rules)
        let validator = LoanValidator(rules: rules)

        var saved: SavedLoanSelection?
        let store = LoanStore(
            rules: rules,
            calculator: calculator,
            validator: validator,
            submit: { _, _ in .success(()) },
            dateProvider: { self.fixedDateUTC(2025, 12, 22) },
            loadSelection: { nil },
            saveSelection: { saved = $0 }
        )

        store.dispatch(.onCurrencyChanged(.eur))

        XCTAssertEqual(store.state.currency, .eur)
        XCTAssertEqual(saved?.currencyCode, Currency.eur.rawValue)
    }

    func test_submit_success_setsSuccessMessage() async {
        let rules = LoanRules(config: LoanConfig())
        let calculator = LoanCalculator(rules: rules)
        let validator = LoanValidator(rules: rules)

        let store = LoanStore(
            rules: rules,
            calculator: calculator,
            validator: validator,
            submit: { _, _ in .success(()) },
            dateProvider: { self.fixedDateUTC(2025, 12, 22) },
            loadSelection: { nil },
            saveSelection: { _ in }
        )

        store.dispatch(.onSubmitClicked)

        // wait until loading finishes
        await waitUntil(timeout: 1.5) { !store.state.isLoading && store.state.message != nil }

        XCTAssertEqual(store.state.message?.id, .submitSuccess)
        XCTAssertEqual(store.state.message?.isError, false)
    }

    func test_submit_httpFailure_setsTypedError() async {
        let rules = LoanRules(config: LoanConfig())
        let calculator = LoanCalculator(rules: rules)
        let validator = LoanValidator(rules: rules)

        let store = LoanStore(
            rules: rules,
            calculator: calculator,
            validator: validator,
            submit: { _, _ in
                .failure(SubmitException(.http(code: 500)))
            },
            dateProvider: { self.fixedDateUTC(2025, 12, 22) },
            loadSelection: { nil },
            saveSelection: { _ in }
        )

        store.dispatch(.onSubmitClicked)

        await waitUntil(timeout: 1.5) { !store.state.isLoading && store.state.message != nil }

        XCTAssertEqual(store.state.message?.id, .submitFailedHttp(code: 500))
        XCTAssertEqual(store.state.message?.isError, true)
    }

    // MARK: - helpers

    private func fixedDateUTC(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal.date(from: DateComponents(year: y, month: m, day: d))!
    }

    private func waitUntil(timeout: TimeInterval, condition: @escaping () -> Bool) async {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            let ok = condition()
            if ok { return }
            try? await Task.sleep(nanoseconds: 30_000_000)
        }
        XCTFail("Condition not met within \(timeout)s")
    }
}
