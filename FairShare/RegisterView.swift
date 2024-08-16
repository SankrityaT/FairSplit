import SwiftUI

struct RegisterView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Spacer()

            // FairShare branding
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 10) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Please sign up to continue.")
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 40)

            // Form fields
            VStack(alignment: .leading, spacing: 20) {
                TextField("Full Name", text: $fullName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("Phone Number", text: $phoneNumber)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.bottom, 20)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
            }

            // Register button
            Button(action: {
                let defaultProfileImageUrl = "" // No profile image URL at sign up
                authService.signUp(email: email, password: password, fullName: fullName, phoneNumber: phoneNumber, profileImageUrl: defaultProfileImageUrl) { result in
                    switch result {
                    case .success:
                        self.presentationMode.wrappedValue.dismiss()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 20)

            // Login link
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                NavigationLink(destination: LoginView()) {
                    Text("Sign in")
                        .foregroundColor(.blue)
                }
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.black)
        })
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView()
                .environmentObject(AuthService())
        }
    }
}
