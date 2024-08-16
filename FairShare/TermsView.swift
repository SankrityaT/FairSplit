//
//  TermsView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        Text("Terms and Conditions")
            .font(.title)
            .navigationBarTitle("Terms", displayMode: .inline)
    }
}

struct TermsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsView()
    }
}
