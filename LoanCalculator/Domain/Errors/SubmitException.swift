final class SubmitException: Error {
    let error: SubmitError
    let underlying: Error?

    init(_ error: SubmitError, underlying: Error? = nil) {
        self.error = error
        self.underlying = underlying
    }
}
