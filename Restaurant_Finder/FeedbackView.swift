//
//  FeedbackView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 02.09.26.
//

import SwiftUI
import WishKit

struct FeedbackView: View {
    var body: some View {
        WishKit.FeedbackListView()
            .navigationTitle("Feature Requests")
            .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        FeedbackView()
    }
}
