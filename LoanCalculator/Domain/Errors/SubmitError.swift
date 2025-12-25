enum SubmitError: Equatable {
    case network
    case timeout
    case http(code: Int)
    case unknown
}
