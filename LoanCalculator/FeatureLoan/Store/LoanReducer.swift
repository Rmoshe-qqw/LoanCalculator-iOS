
func reduce(state: LoanState, action: LoanAction) -> LoanState {
    var s = state

    switch action {
    case .onCurrencyChanged(let c):
        s.currency = c
        s.message = nil

    case .onAmountChanged(let a):
        s.amount = a
        s.message = nil

    case .onPeriodChanged(let p):
        s.periodDays = p
        s.message = nil

    case .onSubmitClicked:
        break

    case .onDismissMessage:
        s.message = nil

    case .recalculated(let calc, let amountRules):
        s.amountMin = amountRules.minAmount
        s.amountMax = amountRules.maxAmount
        s.amountStep = amountRules.amountStep
        s.interestRatePercent = calc.interestRatePercent
        s.totalRepayment = calc.totalRepayment
        s.dueDate = calc.dueDate

    case .submitStarted:
        s.isLoading = true
        s.message = nil

    case .submitFinished(let success, let messageId, let detail):
        s.isLoading = false
        s.message = UiMessage(id: messageId, isError: !success, detail: detail)
    }

    return s
}
