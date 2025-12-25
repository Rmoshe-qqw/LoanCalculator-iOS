enum UiMessageId: Equatable {
    // submit
    case submitSuccess
    case submitFailedNetwork
    case submitFailedTimeout
    case submitFailedHttp(code: Int)
    case submitFailedUnknown

    // validation
    case currencyNotSupported
    case amountOutOfRange
    case amountStepInvalid
    case periodNotAllowed
}

struct UiMessage: Equatable {
    let id: UiMessageId
    let isError: Bool
    let detail: String?

    init(id: UiMessageId, isError: Bool, detail: String? = nil) {
        self.id = id
        self.isError = isError
        self.detail = detail
    }
}
