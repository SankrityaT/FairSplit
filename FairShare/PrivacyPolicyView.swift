//
//  PrivacyPolicyView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy")
            .font(.title)
            .navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
