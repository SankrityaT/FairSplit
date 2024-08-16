import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome to FairShare")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Manage your expenses easily.")
                        .foregroundColor(.customBlue)
                        
                }
                    

                // FairShare branding
                Image("FairShareLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)
                
                

                Spacer()

                VStack(spacing: 15) {
                    // Sign In button
                    NavigationLink(destination: LoginView()) {
                        Text("Sign In")
                            .foregroundColor(.CustomBlue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.CustomBlue, lineWidth: 2)
                            )
                    }

                    // Create Account button
                    NavigationLink(destination: RegisterView()) {
                        Text("Create Account")
                            .foregroundColor(.CustomBlue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.CustomBlue, lineWidth: 2)
                            )
                    }
                }
                .padding(.bottom, 20)
                
                Spacer()

                HStack(spacing: 20) {
                    Image(systemName: "facebook")
                    Image(systemName: "linkedin")
                    Image(systemName: "google")
                    Image(systemName: "twitter")
                }
                .padding(.bottom, 10)
                
                Text("Sign in with another account?")
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

