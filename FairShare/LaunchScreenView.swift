import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(hex: "#1C1C1E") // Use your color palette for background
                .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen

            VStack {
                Spacer()
                Image("illustration") // Ensure this is the correct name of your image
                    .resizable()
                    .scaledToFit()
                    .frame(width:500, height: 500) // Adjust the size as needed
                    .padding(.bottom,90)
            }
            
            VStack{
                Text("FairShare")
                    .font(.largeTitle)
                    .foregroundColor(Color(hex: "#9370DB"))
                    .padding(.top,200)
                Spacer()
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}

