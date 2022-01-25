//
//  NewRecipe.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI
import PhotosUI

// For reference: delete later
//struct Recipe: Hashable, Codable, Identifiable {
//    var id: UUID
//    var image: String
//    var name: String
//    var author: String
//    var rating: Double
//    var ingredients: [Ingredient]
//    var steps: [String]
//    var coordinate: CLLocationCoordinate2D?
//    var emoji: String
//    var favorited: Int
//}

struct TextFieldListView: View {
    @State private var steps: [String] = [""]
    
    var body: some View {
        VStack {
            ForEach(steps, id: \.self) { step in
                let index = steps.firstIndex(of: step)!
                TextField("", text: $steps[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            Button {
                steps.append(String(steps.count + 1))
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct NewRecipeView: View {
    @State var name: String = ""
    @State var emoji: String = ""
    @State var uuid = UUID()
    @State var ingredients: [Ingredient] = []
    @State var steps: [String] = [""]
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Recipe name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button() {
                    showImageLibrary = true
                } label: {
                    Text("Add Image")
                }
                
                Divider()
                
                TextFieldListView()
                
                
                Divider()
                
                EmojiPickerView() { emoji in
                    self.emoji = emoji
                }
                
            }
            .navigationTitle("New Recipe")
            .sheet(isPresented: $showImageLibrary) {
                PhotoPicker() { didSelectItems in
                    showImageLibrary = false
                }
            }
        }
        .onTapGesture {
            let resign = #selector(UIResponder.resignFirstResponder)
            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
            
        }
    }
}

struct NewRecipe_Previews: PreviewProvider {
    static var previews: some View {
        NewRecipeView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
