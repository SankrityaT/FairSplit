import Foundation
import FirebaseFirestoreSwift

struct Expense: Identifiable, Codable {
    @DocumentID var id: String?
    var description: String
    var amount: Double
    var amountOwed: Double
    var participants: [String]
    var splitAmounts: [String: Double]
    var date: Date
    var splitOption: SplitOption?
    var paidBy: String

    init(description: String, amount: Double, amountOwed: Double, participants: [String], splitAmounts: [String: Double], date: Date, splitOption: SplitOption? = nil, paidBy: String) {
        self.description = description
        self.amount = amount
        self.amountOwed = amountOwed
        self.participants = participants
        self.splitAmounts = splitAmounts
        self.date = date
        self.splitOption = splitOption
        self.paidBy = paidBy
    }
}
