//import SwiftUI
//
//struct CustomPullToRefreshView<Content: View>: View {
//    var moneyImage: UIImage
//    @Binding var isRefreshing: Bool
//    var onRefresh: () async -> Void
//    var content: () -> Content
//
//    init(moneyImage: UIImage, isRefreshing: Binding<Bool>, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async -> Void) {
//        self.moneyImage = moneyImage
//        self._isRefreshing = isRefreshing
//        self.content = content
//        self.onRefresh = onRefresh
//    }
//
//    var body: some View {
//        ScrollView {
//            GeometryReader { geo in
//                if geo.frame(in: .global).midY > 100 {
//                    if !isRefreshing {
//                        DispatchQueue.main.async {
//                            isRefreshing = true
//                            Task {
//                                await onRefresh()
//                            }
//                        }
//                    }
//                }
//                VStack {
//                    Image(uiImage: moneyImage)
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                        .rotationEffect(isRefreshing ? .degrees(360) : .degrees(0))
//                        .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
//                        .padding(.top, isRefreshing ? 20 : 0)
//                    content()
//                }
//            }
//        }
//    }
//}
