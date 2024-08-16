import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    @EnvironmentObject var authService: AuthService

    var body: some View {
        VStack {
            Spacer()
            
            Image("logo") // Assuming the image is named FairShareLogo
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Please sign in to continue.")
                    .foregroundColor(.white)
            }
            .padding(.bottom, 40)
            
            VStack(spacing: 20) {
                CustomTextField(text: $email, placeholder: "Email", iconName: "envelope")
                CustomTextField(text: $password, placeholder: "Password", isSecure: true, iconName: "lock")
                
                HStack {
                    Spacer()
                    Button(action: {
                        // Handle forgot password action
                    }) {
                        Text("Forgot Password?")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                authService.signIn(email: email, password: password) { result in
                    switch result {
                    case .success:
                        print("User successfully logged in")
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }) {
                HStack {
                    Spacer()
                    Text("Login")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding(.top, 20)
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                NavigationLink(destination: RegisterView()) {
                    Text("Sign up")
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 40)
        }
        .padding()
        .background(Color.black)
        .ignoresSafeArea(edges: .all)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
                .environmentObject(AuthService())
        }
    }
}
