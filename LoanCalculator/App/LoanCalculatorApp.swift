import SwiftUI

@main
struct LoanCalculatorApp: App {

    private let graph = AppGraph()

    var body: some Scene {
        WindowGroup {
            LoanScreen(store: graph.makeLoanStore())
        }
    }
}
