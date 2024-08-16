import Foundation
import Contacts
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI
import Combine

class FirestoreService: ObservableObject {
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var friends: [Friend] = []
    @Published var users: [User] = []
    @Published var expenses: [Expense] = []
    @Published var balances: [String: Double] = [:]
    @Published private var userID: String?
    @Published var currentUser: User?
    @Published var notifications: [Notification] = []
    @Published var payments: [Payment] = []
    
    init() {
        AuthService.shared.$user
            .compactMap { $0?.id }
            .assign(to: \.userID, on: self)
            .store(in: &cancellables)
        
        $userID
            .compactMap { $0 }
            .sink { [weak self] userID in
                guard let self = self else { return }
                self.fetchCurrentUser(userID: userID)
                self.fetchFriends(for: userID) { friends in
                    self.friends = friends
                }
                self.fetchExpenses(for: userID) { expenses in
                    self.expenses = expenses
                }
                self.fetchBalances(for: userID)
            }
            .store(in: &cancellables)
        
        fetchUsers()
    }


    
    func fetchCurrentUser(userID: String) {
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                self.currentUser = try? document.data(as: User.self)
            } else if let error = error {
                print("Error fetching current user: \(error.localizedDescription)")
            }
        }
    }

    func addNotification(message: String) {
        let newNotification = Notification(message: message, date: Date())
        notifications.append(newNotification)
        db.collection("notifications").addDocument(data: [
            "message": message,
            "date": Timestamp(date: newNotification.date)
        ])
    }

    func fetchNotifications() {
        db.collection("notifications").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching notifications: \(error)")
                return
            }
            if let documents = snapshot?.documents {
                self.notifications = documents.compactMap { doc in
                    let data = doc.data()
                    guard let message = data["message"] as? String,
                          let timestamp = data["date"] as? Timestamp else {
                        return nil
                    }
                    return Notification(id: UUID(), message: message, date: timestamp.dateValue())
                }
            }
        }
    }
    
    func addExpense(_ expense: Expense, completion: @escaping (Bool) -> Void) {
        do {
            let newExpenseRef = try db.collection("expenses").addDocument(from: expense) { error in
                if let error = error {
                    print("Error adding expense: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self.fetchExpenses(for: self.userID ?? "") { _ in }
                    completion(true)
                }
            }

            for participantID in expense.participants {
                addExpenseToUser(expense, userId: participantID, expenseId: newExpenseRef.documentID) { success in
                    if !success {
                        completion(false)
                    }
                }
            }

            // Update balances
            for (friendID, amount) in expense.splitAmounts {
                if friendID != expense.paidBy {
                    let balanceAmount = friendID == userID ? -amount : amount
                    updateBalance(for: friendID, friendID: expense.paidBy, amount: balanceAmount)
                    updateBalance(for: expense.paidBy, friendID: friendID, amount: -balanceAmount)
                }
            }
        } catch {
            print("Error adding expense: \(error.localizedDescription)")
            completion(false)
        }
    }

    func fetchPayments(for userId: String, completion: @escaping ([Payment]) -> Void) {
        db.collection("payments")
            .whereField("from", isEqualTo: userId)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                let payments = documents.compactMap { queryDocumentSnapshot -> Payment? in
                    return try? queryDocumentSnapshot.data(as: Payment.self)
                }
                completion(payments)
            }
    }

    func updateBalances(for userId: String, friendId: String, amount: Double) {
        let userDocRef = db.collection("users").document(userId)
        let friendDocRef = db.collection("users").document(friendId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            let friendDocument: DocumentSnapshot

            do {
                userDocument = try transaction.getDocument(userDocRef)
                friendDocument = try transaction.getDocument(friendDocRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let userBalance = userDocument.data()?["balance"] as? Double ?? 0.0
            let friendBalance = friendDocument.data()?["balance"] as? Double ?? 0.0

            transaction.updateData(["balance": userBalance - amount], forDocument: userDocRef)
            transaction.updateData(["balance": friendBalance + amount], forDocument: friendDocRef)

            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }

    func recordPayment(from userId: String, to friendId: String, amount: Double) {
        let payment = Payment(from: userId, to: friendId, amount: amount, date: Timestamp(date: Date()))
        do {
            _ = try db.collection("payments").addDocument(from: payment)
            self.updateBalances(for: userId, friendId: friendId, amount: amount)
        } catch let error {
            print("Error adding document: \(error)")
        }
    }

    func fetchRecentActivities(for userId: String, completion: @escaping ([Expense]) -> Void) {
        db.collection("users").document(userId).collection("expenses")
            .order(by: "date", descending: true)
            .limit(to: 20)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching recent activities: \(error)")
                    completion([])
                    return
                }
                let activities = querySnapshot?.documents.compactMap { document -> Expense? in
                    try? document.data(as: Expense.self)
                } ?? []
                completion(activities)
            }
    }

    func searchExpenses(query: String, completion: @escaping ([Expense]) -> Void) {
        db.collection("expenses")
            .whereField("description", isGreaterThanOrEqualTo: query)
            .whereField("description", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    let expenses = querySnapshot.documents.compactMap { document -> Expense? in
                        try? document.data(as: Expense.self)
                    }
                    completion(expenses)
                } else {
                    print("Error searching expenses: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                }
            }
    }

    func searchFriends(query: String, completion: @escaping ([Friend]) -> Void) {
        db.collection("users")
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    let friends = querySnapshot.documents.compactMap { document -> Friend? in
                        try? document.data(as: Friend.self)
                    }
                    completion(friends)
                } else {
                    print("Error searching friends: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                }
            }
    }
    
    func searchUsers(query: String, completion: @escaping ([User]) -> Void) {
        db.collection("users")
            .whereField("email", isEqualTo: query)
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    let users = querySnapshot.documents.compactMap { document -> User? in
                        try? document.data(as: User.self)
                    }
                    completion(users)
                } else {
                    print("Error searching users: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                }
            }
    }
    
    func fetchFriends(for userID: String, completion: @escaping ([Friend]) -> Void) {
        db.collection("users").document(userID).collection("friends").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                let friends = querySnapshot.documents.compactMap { document -> Friend? in
                    try? document.data(as: Friend.self)
                }
                self.friends = friends
                completion(friends)
                print("Fetched friends: \(self.friends)")
            } else if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    func fetchFriendDetails(friendID: String, completion: @escaping (Friend?) -> Void) {
        let docRef = db.collection("users").document(friendID)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let friend = try? document.data(as: Friend.self)
                completion(friend)
            } else {
                print("Error fetching friend details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    func fetchUsers() {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.users = querySnapshot.documents.compactMap { document -> User? in
                    try? document.data(as: User.self)
                }
                print("Fetched users: \(self.users)")
            } else if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchExpenses(for userId: String, completion: @escaping ([Expense]) -> Void) {
        db.collection("users").document(userId).collection("expenses").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching expenses: \(error)")
                completion([])
                return
            }
            let expenses = snapshot?.documents.compactMap { try? $0.data(as: Expense.self) } ?? []
            self.expenses = expenses
            completion(expenses)
        }
    }
    
    func fetchBalances(for userID: String) {
        db.collection("users").document(userID).collection("balances").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.balances = querySnapshot.documents.reduce(into: [String: Double]()) { dict, document in
                    let balance = document.data()["balance"] as? Double ?? 0.0
                    dict[document.documentID] = balance
                }
                print("Fetched balances: \(self.balances)")
            } else if let error = error {
                print("Error fetching balances: \(error.localizedDescription)")
            }
        }
    }

    func updateBalance(for userID: String, friendID: String, amount: Double) {
        let balanceRef = db.collection("users").document(userID).collection("balances").document(friendID)
        balanceRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentBalance = document.data()?["balance"] as? Double ?? 0.0
                balanceRef.setData(["balance": currentBalance + amount], merge: true)
            } else {
                balanceRef.setData(["balance": amount])
            }
        }
    }

    func addFriend(friend: Friend, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let friendRef = db.collection("users").document(currentUserID).collection("friends").document(friend.id ?? "")
        let currentUserRef = db.collection("users").document(friend.id ?? "").collection("friends").document(currentUserID)

        fetchUserProfile(userID: friend.id ?? "") { friendProfile in
            guard let friendProfile = friendProfile else {
                completion(false)
                return
            }

            let updatedFriend = Friend(
                id: friend.id,
                name: friendProfile.fullName ?? friend.name,
                email: friendProfile.email ?? friend.email,
                phoneNumber: friendProfile.phoneNumber ?? friend.phoneNumber,
                profileImageUrl: friendProfile.profileImageUrl ?? friend.profileImageUrl,
                amount: friend.amount,
                isOwed: friend.isOwed
            )

            friendRef.setData([
                "id": updatedFriend.id ?? "",
                "name": updatedFriend.name,
                "email": updatedFriend.email,
                "phoneNumber": updatedFriend.phoneNumber,
                "profileImageUrl": updatedFriend.profileImageUrl ?? "",
                "amount": updatedFriend.amount,
                "isOwed": updatedFriend.isOwed
            ]) { error in
                if let error = error {
                    print("Error adding friend: \(error)")
                    completion(false)
                } else {
                    self.fetchUserProfile(userID: currentUserID) { userProfile in
                        guard let userProfile = userProfile else {
                            completion(false)
                            return
                        }

                        let currentUser = Friend(
                            id: currentUserID,
                            name: userProfile.fullName ?? "",
                            email: userProfile.email ?? "",
                            phoneNumber: userProfile.phoneNumber ?? "",
                            profileImageUrl: userProfile.profileImageUrl ?? "",
                            amount: 0.0,
                            isOwed: false
                        )

                        currentUserRef.setData([
                            "id": currentUser.id ?? "",
                            "name": currentUser.name,
                            "email": currentUser.email,
                            "phoneNumber": currentUser.phoneNumber,
                            "profileImageUrl": currentUser.profileImageUrl ?? "",
                            "amount": currentUser.amount,
                            "isOwed": currentUser.isOwed
                        ]) { error in
                            if let error = error {
                                print("Error adding friend: \(error)")
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getFriendProfileImageUrl(friendId: String, completion: @escaping (String?) -> Void) {
        let docRef = db.collection("users").document(friendId)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let profileImageUrl = document.data()?["profileImageUrl"] as? String
                completion(profileImageUrl)
            } else {
                completion(nil)
            }
        }
    }

    func addExpenseToUser(_ expense: Expense, userId: String, expenseId: String, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("users").document(userId).collection("expenses").document(expenseId).setData(from: expense) { error in
                if let error = error {
                    print("Error adding expense to user: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } catch {
            print("Error serializing expense: \(error)")
            completion(false)
        }
    }

    func checkIfRegistered(contact: CNContact, completion: @escaping (Bool) -> Void) {
        guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else {
            completion(false)
            return
        }

        db.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(!querySnapshot.isEmpty)
            } else {
                completion(false)
            }
        }
    }

    private func fetchUserProfile(userID: String, completion: @escaping (User?) -> Void) {
        let docRef = db.collection("users").document(userID)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let user = try? document.data(as: User.self)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
}
