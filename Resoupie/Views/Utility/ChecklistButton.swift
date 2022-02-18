//
//  ChecklistButton.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI

struct ChecklistButton: View {
    @State private var didTap: Bool = false
    var initialize: () -> Bool
    var action: (_: Bool) -> Void
    
    var body: some View {
        Image(systemName: didTap ? "checkmark.circle.fill" : "circle")
            .frame(width: 22, height: 22)
            .foregroundColor(Color.orange)
            .font(.system(size: 22))
            .onTapGesture {
                self.didTap = !self.didTap
                action(didTap)
            }
            .onAppear {
                didTap = initialize()
            }
    }
}
