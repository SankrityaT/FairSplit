import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Friend: Identifiable, Codable,Equatable  {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var email: String
    var phoneNumber: String
    var profileImageUrl: String?
    var amount: Double
    var isOwed: Bool
    
    static func ==(lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id
    }
}
