//
//  AuthenticationView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//
import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Image("logo") // Ensure 'logo' matches the image name in Assets.xcassets
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)

                Text("FairShare")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Spacer()

                NavigationLink(destination: RegisterView()) {
                    Text("Sign up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }

                NavigationLink(destination: LoginView()) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                }

                HStack {
                    NavigationLink(destination: TermsView()) {
                        Text("Terms")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    NavigationLink(destination: ContactUsView()) {
                        Text("Contact us")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .padding(.bottom, 10)

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
