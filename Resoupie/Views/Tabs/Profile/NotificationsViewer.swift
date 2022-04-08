//
//  NotificationsViewer.swift
//  Resoupie
//
//  Created by Michael Abir on 4/8/22.
//

import SwiftUI

struct NotificationsViewer: View {
    let notifications: Notifications
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(notifications.new_notifications.indices, id: \.self) { index in
                    let notification = notifications.new_notifications[index]
                    
                    RectangleSectionInset {
                        HStack {
                            Text(notification)
                                .foregroundColor(Color.theme.text)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                }
                ForEach(notifications.notifications.indices, id: \.self) { index in
                    let notification = notifications.notifications[index]
                    
                    RectangleSectionInset {
                        HStack {
                            Text(notification)
                                .foregroundColor(Color.theme.lightText)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top)
        }
        .background(Color.theme.background)
    }
}

struct NotificationsViewer_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsViewer(notifications: Notifications(new_notifications: [], notifications: []))
    }
}
