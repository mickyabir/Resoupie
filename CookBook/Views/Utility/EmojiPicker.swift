//
//  EmojiPicker.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import Combine
import SwiftUI

struct EmojiPickerView: View {
    var action: (String) -> Void
    
    @State private var displayEmojiWarning = false
    @State var emoji: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Emoji")
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .frame(width: 120)
                Text("Emoji Only!")
            }
            .opacity(displayEmojiWarning ? 1 : 0)
            .frame(width: 120)
            .cornerRadius(5)
            
            TextField("Emoji", text: $emoji)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onReceive(Just(emoji), perform: { _ in
                    if self.emoji != self.emoji.onlyEmoji() {
                        withAnimation {
                            displayEmojiWarning = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                displayEmojiWarning.toggle()
                            }
                        }
                        
                    }
                    self.emoji = String(self.emoji.onlyEmoji().prefix(1))
                    
                })
        }
    }
}

extension String {
    func onlyEmoji() -> String {
        return self.filter({$0.isEmoji})
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}
