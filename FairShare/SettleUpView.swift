import SwiftUI
import CoreHaptics

struct SettleUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var firestoreService: FirestoreService
    var friend: Friend

    @State private var amount: String = ""
    @State private var engine: CHHapticEngine?
    @State private var showConfirmation: Bool = false

    var body: some View {
        VStack {
            headerView
            formView
            Spacer()
            if showConfirmation {
                confirmationView
            } else {
                sliderView
            }
        }
        .onAppear(perform: prepareHaptics)
    }

    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .padding()
                    .background(Circle().fill(Color(hex: "#FFC857")))
            }
            Spacer()
        }
    }

    private var formView: some View {
        VStack {
            HStack {
                if let userProfileImageUrl = authService.user?.profileImageUrl, let url = URL(string: userProfileImageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }

                Image(systemName: "arrow.right")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                if let friendProfileImageUrl = friend.profileImageUrl, let url = URL(string: friendProfileImageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
            }
            .padding()

            Text("You paid \(friend.name)")
                .font(.headline)
                .padding()

            CustomNumpad(amount: $amount)
                .padding()

            Spacer()
        }
        .padding()
    }

    private var sliderView: some View {
        VStack {
            Spacer()
            ZStack {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 50)
                HStack {
                    Circle()
                        .fill(Color(hex: "#9370DB"))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        )
                        .gesture(
                            DragGesture(minimumDistance: 50)
                                .onEnded { value in
                                    if value.translation.width > 100 {
                                        playHaptics()
                                        recordPayment()
                                        showConfirmation = true
                                    }
                                }
                        )
                    Spacer()
                }
            }
            Spacer()
        }
    }

    private var confirmationView: some View {
        ZStack {
            VStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                Text("Payment Recorded!")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    presentationMode.wrappedValue.dismiss()
                    firestoreService.fetchExpenses(for: authService.user?.id ?? "") { _ in }
                    firestoreService.fetchFriends(for: authService.user?.id ?? "") { _ in }
                    firestoreService.fetchRecentActivities(for: authService.user?.id ?? "") { _ in }
                }
            }
        }
    }

    private func playHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)

            let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
            let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
            let parameterCurve = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, end], relativeTime: 0)

            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0.1)
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [parameterCurve])

            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    private func recordPayment() {
        guard let amount = Double(amount), let userId = authService.user?.id, let friendId = friend.id else {
            return
        }

        firestoreService.recordPayment(from: userId, to: friendId, amount: amount)
        firestoreService.updateBalances(for: userId, friendId: friendId, amount: amount)
        firestoreService.addNotification(message: "\(authService.user?.fullName ?? "You") paid \(friend.name) \(amount)")
    }
}

struct CustomNumpad: View {
    @Binding var amount: String

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<3) { row in
                HStack(spacing: 10) {
                    ForEach(1...3, id: \.self) { number in
                        Button(action: {
                            amount.append("\(number + row * 3)")
                        }) {
                            Text("\(number + row * 3)")
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .background(Color(hex: "#9370DB").opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                    }
                }
            }
            HStack(spacing: 10) {
                Button(action: {
                    amount.append(".")
                }) {
                    Text(".")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .background(Color(hex: "#9370DB").opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(40)
                }
                Button(action: {
                    amount.append("0")
                }) {
                    Text("0")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .background(Color(hex: "#9370DB").opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(40)
                }
                Button(action: {
                    amount = String(amount.dropLast())
                }) {
                    Text("⌫")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .background(Color(hex: "#9370DB").opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(40)
                }
            }
        }
    }
}


struct SettleUpView_Previews: PreviewProvider {
    static var previews: some View {
        SettleUpView(friend: Friend(id: "123", name: "Mohan Anna", email: "mohan@example.com", phoneNumber: "1234567890", profileImageUrl: "https://example.com/profile.jpg", amount: 0.0, isOwed: false))
            .environmentObject(AuthService())
            .environmentObject(FirestoreService())
    }
}
