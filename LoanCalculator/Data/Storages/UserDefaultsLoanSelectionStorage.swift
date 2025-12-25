import Foundation

final class UserDefaultsLoanSelectionStorage: LoanSelectionStorage {
    private let key = "loan_selection"

    func load() -> SavedLoanSelection? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SavedLoanSelection.self, from: data)
    }

    func save(_ selection: SavedLoanSelection) {
        let data = try? JSONEncoder().encode(selection)
        UserDefaults.standard.set(data, forKey: key)
    }
}
