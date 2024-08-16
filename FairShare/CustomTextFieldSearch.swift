import SwiftUI

struct CustomTextFieldSearch: View {
    @Binding var text: String
    var placeholder: String
    var iconName: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(hex: "#9370DB")) // Custom purple color
                    .padding(.leading, 10)
            }
            TextField("", text: $text)
                .foregroundColor(.white)
                .padding(.leading, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

struct CustomTextFieldSearch_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextFieldSearch(text: .constant(""), placeholder: "Search", iconName: "magnifyingglass")
    }
}
