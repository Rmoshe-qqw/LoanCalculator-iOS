import Foundation

final class AppGraph {

    lazy var rules = LoanRules(config: LoanConfig())
    lazy var calculator = LoanCalculator(rules: rules)
    lazy var validator = LoanValidator(rules: rules)

    lazy var api: LoanAPI = LoanAPIImpl()
    lazy var repository: LoanRepository = LoanRepositoryImpl(api: api)

    private let storage: LoanSelectionStorage = UserDefaultsLoanSelectionStorage()

    lazy var submit: (LoanSelection, LoanCalculation) async -> Result<Void, Error> = { [repository] selection, calc in
        await repository.submit(selection: selection, calculation: calc)
    }

    func makeLoanStore() -> LoanStore {
        LoanStore(
            rules: rules,
            calculator: calculator,
            validator: validator,
            submit: submit,
            dateProvider: { Date() },
            loadSelection: { [storage] in storage.load() },
            saveSelection: { [storage] in storage.save($0) }
        )
    }
}
