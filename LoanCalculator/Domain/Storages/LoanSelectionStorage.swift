protocol LoanSelectionStorage {
    func load() -> SavedLoanSelection?
    func save(_ selection: SavedLoanSelection)
}
