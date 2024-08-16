import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isImagePickerPresented = false
    @State private var profileImage: UIImage?
    @State private var userEmail: String = ""
    @State private var userName: String = ""
    @State private var userPhone: String = ""
    @State private var userTimeZone: String = ""
    @State private var userCurrency: String = ""
    @State private var userLanguage: String = ""
    @State private var profileImageURL: URL?
    @State private var isEditProfilePresented = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("User Info").foregroundColor(lightPurple)) {
                    HStack {
                        VStack {
                            if let profileImageURL = profileImageURL {
                                AsyncImage(url: profileImageURL) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            isImagePickerPresented = true
                                        }
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        isImagePickerPresented = true
                                    }
                                    .foregroundColor(lightPurple)
                            }
                        }
                        .padding(.trailing, 16)

                        VStack(alignment: .leading) {
                            Text(userName)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(lightPurple)
                            .onTapGesture {
                                isEditProfilePresented = true
                            }
                    }
                    .padding()
                    .background(darkPurple)
                    .cornerRadius(10)
                }

                Section(header: Text("Settings").foregroundColor(lightPurple)) {
                    NavigationLink(destination: NotificationsView()) {
                        Text("Notifications")
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: PasscodeView()) {
                        Text("Passcode")
                            .foregroundColor(.white)
                    }
                }

                Section(header: Text("Feedback").foregroundColor(lightPurple)) {
                    NavigationLink(destination: RateFairShareView()) {
                        Text("Rate FairShare")
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: ContactUsView()) {
                        Text("Contact us")
                            .foregroundColor(.white)
                    }
                }

                Button(action: {
                    authService.signOut()
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(darkBackground.edgesIgnoringSafeArea(.all))
            .navigationTitle("Account")
            .onAppear {
                loadUserData()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView(isPresented: $isImagePickerPresented, selectedImage: $profileImage, onImagePicked: { image in
                    self.uploadProfileImage(image)
                })
            }
            .sheet(isPresented: $isEditProfilePresented) {
                EditProfileView(userFullName: $userName, userEmail: $userEmail, userPhoneNumber: $userPhone, userTimeZone: $userTimeZone, userCurrency: $userCurrency, userLanguage: $userLanguage)
            }
        }
    }

    private func loadUserData() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? ""
            profileImageURL = user.photoURL
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(user.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    userName = data?["fullName"] as? String ?? ""
                    userPhone = data?["phoneNumber"] as? String ?? ""
                    userTimeZone = data?["timeZone"] as? String ?? ""
                    userCurrency = data?["currency"] as? String ?? "USD"
                    userLanguage = data?["language"] as? String ?? "English"
                    if let profileImageUrl = data?["profileImageUrl"] as? String {
                        self.profileImageURL = URL(string: profileImageUrl)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error fetching download URL: \(error.localizedDescription)")
                        return
                    }
                    if let profileImageUrl = url?.absoluteString {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.photoURL = URL(string: profileImageUrl)
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("Error updating profile image URL: \(error.localizedDescription)")
                            } else {
                                DispatchQueue.main.async {
                                    self.profileImageURL = URL(string: profileImageUrl)
                                    self.authService.user?.profileImageUrl = profileImageUrl
                                }
                            }
                        }
                        // Save image locally
                        let fileURL = getDocumentsDirectory().appendingPathComponent("\(user.uid).jpg")
                        try? imageData.write(to: fileURL)

                        // Update profile image URL in Firestore
                        let docRef = Firestore.firestore().collection("users").document(user.uid)
                        docRef.updateData(["profileImageUrl": profileImageUrl]) { error in
                            if let error = error {
                                print("Error updating profile image URL in Firestore: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AuthService())
    }
}
