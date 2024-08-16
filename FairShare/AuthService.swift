import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var user: User?
    private var db = Firestore.firestore()
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.fetchUserData(userId: user.uid)
            } else {
                self?.user = nil
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                self?.fetchUserData(userId: user.uid, completion: completion)
            }
        }
    }
    
    func signUp(email: String, password: String, fullName: String, phoneNumber: String?, profileImageUrl: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                let newUser = User(id: user.uid, fullName: fullName, email: email, phoneNumber: phoneNumber ?? "", profileImageUrl: profileImageUrl)
                self?.saveUserData(user: newUser, completion: completion)
            }
        }
    }

    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func fetchUserData(userId: String, completion: ((Result<User, Error>) -> Void)? = nil) {
        let docRef = db.collection("users").document(userId)
        docRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion?(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = try? document.data(as: User.self) else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data is malformed."])
                print("User data is malformed.")
                completion?(.failure(error))
                return
            }
            
            self?.user = data
            completion?(.success(data))
            self?.loadProfileImageLocally(userId: userId)
        }
    }
    
    private func saveUserData(user: User, completion: ((Result<User, Error>) -> Void)? = nil) {
        do {
            try db.collection("users").document(user.id ?? "").setData(from: user) { error in
                if let error = error {
                    completion?(.failure(error))
                } else {
                    self.user = user
                    completion?(.success(user))
                }
            }
        } catch {
            completion?(.failure(error))
        }
    }
    
    func saveProfileImageLocally(image: UIImage, userId: String) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(userId).jpg")
            try? data.write(to: filename)
        }
    }
    
    func loadProfileImageLocally(userId: String) -> UIImage? {
        let filename = getDocumentsDirectory().appendingPathComponent("\(userId).jpg")
        return UIImage(contentsOfFile: filename.path)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
