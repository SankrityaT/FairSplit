//import SwiftUI
//
//struct VerifyFriendsView: View {
//    @ObservedObject var firestoreService: FirestoreService
//    @Binding var selectedUsers: [User]
//    @Binding var isPresented: Bool
//
//    var body: some View {
//        VStack {
//            Text("Verify contact info")
//                .font(.headline)
//                .padding()
//
//            List {
//                ForEach(selectedUsers) { user in
//                    HStack {
//                        if let profileImage = user.profileImage {
//                            Image(uiImage: profileImage)
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .clipShape(Circle())
//                        } else {
//                            Image(systemName: "person.circle.fill")
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .clipShape(Circle())
//                        }
//                        VStack(alignment: .leading) {
//                            Text(user.fullName ?? "")
//                            Text(user.phoneNumber ?? "")
//                        }
//                        Spacer()
//                        Button(action: {
//                            if let index = selectedUsers.firstIndex(where: { $0.id == user.id }) {
//                                selectedUsers.remove(at: index)
//                            }
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(.red)
//                        }
//                    }
//                }
//            }
//
//            Button("Finish") {
//                for user in selectedUsers {
//                    let friend = Friend(
//                        id: user.id ?? UUID().uuidString,
//                        name: user.fullName ?? "",
//                        email: user.email ?? "",
//                        phoneNumber: user.phoneNumber ?? "",
//                        amount: 0.0,
//                        isOwed: false,
//                        profileImageUrl: user.profileImageUrl ?? ""
//                    )
//                    firestoreService.addFriend(friend) { success in
//                        if success {
//                            print("Friend added successfully")
//                        } else {
//                            print("Failed to add friend")
//                        }
//                    }
//                }
//                isPresented = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    // Navigate back to MainDashboardView
//                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                       let window = windowScene.windows.first {
//                        window.rootViewController = UIHostingController(rootView: MainDashboardView(firestoreService: firestoreService).environmentObject(AuthService()))
//                        window.makeKeyAndVisible()
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//struct VerifyFriendsView_Previews: PreviewProvider {
//    static var previews: some View {
//        VerifyFriendsView(firestoreService: FirestoreService(), selectedUsers: .constant([]), isPresented: .constant(true))
//    }
//}
