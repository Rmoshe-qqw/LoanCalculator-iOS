enum LoanAction: Equatable {
    case onCurrencyChanged(Currency)
    case onAmountChanged(Int)
    case onPeriodChanged(Int)
    case onSubmitClicked
    case onDismissMessage

    case recalculated(calculation: LoanCalculation, amountRules: CurrencyRules)
    case submitStarted
    case submitFinished(success: Bool, messageId: UiMessageId, detail: String?)
}
