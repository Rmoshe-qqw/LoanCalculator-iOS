protocol LoanRepository {
    func submit(selection: LoanSelection, calculation: LoanCalculation) async -> Result<Void, Error>
}
