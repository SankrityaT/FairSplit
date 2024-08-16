import SwiftUI

enum SplitOption: String, Codable, Identifiable, CaseIterable {
    var id: String { self.rawValue }
    
    case paidByYouAndSplitEqually
    case youAreOwedFullAmount
    case friendPaidAndSplitEqually
    case friendPaidFullAmount

    func title(friendName: String) -> String {
        switch self {
        case .paidByYouAndSplitEqually:
            return "Paid by You and Split Equally"
        case .youAreOwedFullAmount:
            return "You are Owed Full Amount"
        case .friendPaidAndSplitEqually:
            return "\(friendName) Paid and Split Equally"
        case .friendPaidFullAmount:
            return "\(friendName) Paid Full Amount"
        }
    }

    func subtitle(friendName: String, amount: Double) -> String {
        switch self {
        case .paidByYouAndSplitEqually:
            return "\(friendName) owes you $\(amount / 2.0)"
        case .youAreOwedFullAmount:
            return "\(friendName) owes you $\(amount)"
        case .friendPaidAndSplitEqually:
            return "You owe \(friendName) $\(amount / 2.0)"
        case .friendPaidFullAmount:
            return "You owe \(friendName) $\(amount)"
        }
    }

    var subtitleColor: Color {
        switch self {
        case .paidByYouAndSplitEqually, .youAreOwedFullAmount:
            return .green
        case .friendPaidAndSplitEqually, .friendPaidFullAmount:
            return .red
        }
    }

    func paidBy(for userID: String, friends: [Friend]) -> String {
        switch self {
        case .paidByYouAndSplitEqually, .youAreOwedFullAmount:
            return userID
        case .friendPaidAndSplitEqually, .friendPaidFullAmount:
            return friends.first?.id ?? userID
        }
    }
}
