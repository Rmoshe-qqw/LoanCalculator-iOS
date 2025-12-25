import Foundation

final class LoanRepositoryImpl: LoanRepository {

    private let api: LoanAPI

    init(api: LoanAPI) {
        self.api = api
    }

    func submit(selection: LoanSelection, calculation: LoanCalculation) async -> Result<Void, Error> {
        let body = SubmitLoanRequest(
            amount: selection.amount,
            period: selection.periodDays,
            totalRepayment: calculation.totalRepayment
        )

        do {
            try await api.submit(body)
            return .success(())
        } catch {
            return .failure(mapToSubmitException(error))
        }
    }

    private func mapToSubmitException(_ error: Error) -> Error {
        if let apiError = error as? LoanAPIError {
            switch apiError {
            case .invalidResponse:
                return SubmitException(.unknown, underlying: error)
            case .httpStatus(let code):
                return SubmitException(.http(code: code), underlying: error)
            }
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return SubmitException(.timeout, underlying: error)
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
                return SubmitException(.network, underlying: error)
            default:
                return SubmitException(.unknown, underlying: error)
            }
        }

        return SubmitException(.unknown, underlying: error)
    }
}
