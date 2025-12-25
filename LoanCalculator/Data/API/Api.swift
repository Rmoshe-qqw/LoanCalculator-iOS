import Foundation

enum LoanAPIError: Error, Equatable {
    case invalidResponse
    case httpStatus(code: Int)
}

protocol LoanAPI {
    func submit(_ body: SubmitLoanRequest) async throws
}

final class LoanAPIImpl: LoanAPI {
    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func submit(_ body: SubmitLoanRequest) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("posts"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw LoanAPIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw LoanAPIError.httpStatus(code: http.statusCode)
        }
    }
}
