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

struct NewRecipeView: View {
    @State var name: String = ""
    @State var emoji: String = ""
    @State var uuid = UUID()
    @State var ingredients: [Ingredient] = []
    @State var steps: [String] = [""]
    @State var coordinate: CLLocationCoordinate2D?
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false
    
    private let coordinatePickerViewModel = CoordinatePickerViewModel()

    
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

                HStack {
                    NavigationLink {
                        CoordinatePicker(viewModel: coordinatePickerViewModel)
                    } label: {
                        Text("Choose Location (Optional)")
                    }
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                        .opacity(coordinate != nil ? 1 : 0)
                }
                
                Divider()
                
                Text("Method")
                
                TextEditorListView()
                
                
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
        .onAppear {
            coordinate = coordinatePickerViewModel.chosenRegion
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
