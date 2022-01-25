//
//  AddFillButton.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI

struct AddFillButton: View {
    @State private var didTap: Bool = false
    var initialize: () -> Bool
    var action: (_: Bool) -> Void
    
    var body: some View {
        Button {
            self.didTap = !self.didTap
            action(didTap)
        } label: {
            Image(systemName: didTap ? "plus.circle.fill" : "plus.circle")
                .font(.system(size: 20))
        }.onAppear {
            didTap = initialize()
        }
    }
}
