//
//  LoadingView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5, anchor: .center)
                .padding()

            Text("Please wait")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
