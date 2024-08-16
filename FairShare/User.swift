import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var fullName: String?
    var email: String?
    var phoneNumber: String?
    var profileImageUrl: String?
}
