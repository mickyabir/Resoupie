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
            CustomTextField("Emoji", text: $emoji)
                .alert("Emoji only!", isPresented: $displayEmojiWarning) {
                    Button("OK", role: .cancel) {}
                }
                .onReceive(Just(emoji), perform: { _ in
                    if self.emoji != self.emoji.onlyEmoji() {
                        withAnimation {
                            displayEmojiWarning = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
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
