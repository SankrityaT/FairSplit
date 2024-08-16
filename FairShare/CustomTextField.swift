import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    var iconName: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                HStack {
                    Image(systemName: iconName)
                        .foregroundColor(.customBlue)
                    Text(placeholder)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                }
            }
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.customBlue)
                if isSecure {
                    SecureField("", text: $text)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                } else {
                    TextField("", text: $text)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}
