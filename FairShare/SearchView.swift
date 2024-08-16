import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var mockUsers = [
        User(id: "1", fullName: "John Doe", email: "john@example.com", phoneNumber: "1234567890"),
        User(id: "2", fullName: "Jane Smith", email: "jane@example.com", phoneNumber: "0987654321"),
        User(id: "3", fullName: "Bob Johnson", email: "bob@example.com", phoneNumber: "1122334455")
    ]
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search")
            List {
                ForEach(mockUsers.filter {
                    self.searchText.isEmpty ? true : ($0.fullName?.contains(self.searchText) ?? false)
                }) { user in
                    Text(user.fullName ?? "")
                }
            }
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}
