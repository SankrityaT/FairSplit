//
//  ExpenseHeaderView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//

import SwiftUI

struct ExpenseHeaderView: View {
    var totalAmountOwed: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overall, you owe")
                .font(.headline)
                .foregroundColor(.primary)
            Text("$\(totalAmountOwed, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(totalAmountOwed > 0 ? .red : .green)
        }
        .padding()
    }
}

struct ExpenseHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseHeaderView(totalAmountOwed: 25.68)
    }
}
