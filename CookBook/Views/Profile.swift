//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        Text("Profile")
        
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
