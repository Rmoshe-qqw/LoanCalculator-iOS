struct SubmitLoanRequest: Encodable {
    let amount: Int
    let period: Int
    let totalRepayment: Int
}
