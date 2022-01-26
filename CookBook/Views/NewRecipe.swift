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

struct NewRecipeRow<Content: View>: View {
    let content: Content
    let heading: String?
    
    init(_ heading: String? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.heading = heading
    }
    var body: some View {
        VStack(spacing: 20) {
            if heading != nil {
                Text(heading!)
                    .font(.title2)
            }
            content
        }
        .frame(minHeight: 100)
        
        Rectangle()
            .fill(Color.orange)
            .frame(height: 5)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

class NewRecipeViewController: ObservableObject {
    @Published var name: String = ""
    @Published var uuid = UUID()
    @Published var emoji: String = ""
    @Published var ingredients: [Ingredient] = []
    @Published var steps: [String] = [] // might need to add one? not sure
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var image: Image?
    @Published var servings: String = ""
    
    @Published var showEmptyRecipeWarning = false
    
    func publishRecipe() {
        // Send recipe to backend
        if name == "" || ingredients.isEmpty || steps.isEmpty {
            showEmptyRecipeWarning = true
            return
        }
        
        let _ = Recipe(id: uuid, image: "image", name: name, author: "author", rating: 0, ingredients: ingredients, steps: steps, coordinate: coordinate, emoji: emoji, favorited: 0, servings: Int(servings) ?? 0)
        
        
        
        
    }
    
}

struct NewRecipeView: View {
    @State private var inputImage: UIImage?
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false
    
    private let coordinatePickerViewModel = CoordinatePickerViewModel()
    private let textEditorListViewController = TextEditorListViewController()
    private let ingredientsViewController = IngredientListEditorViewController()
    
    @ObservedObject var viewController = NewRecipeViewController()
    
    var body: some View {
        ScrollView {
            VStack {
                NewRecipeRow {
                    CustomTextField("Recipe name", text: $viewController.name)
                    CustomTextField("Servings", text: $viewController.servings)
                        .keyboardType(.numberPad)
                    
                    if viewController.image != nil {
                        viewController.image!
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .cornerRadius(10)
                            .padding(10)
                    }
                    
                    Button() {
                        showImageLibrary = true
                    } label: {
                        if viewController.image == nil {
                            Text("Add Image")
                        } else {
                            Text("Edit Image")
                        }
                    }
                }
                
                NewRecipeRow("Location") {
                    HStack {
                        NavigationLink {
                            CoordinatePicker(viewModel: coordinatePickerViewModel)
                        } label: {
                            Text("Choose Location (Optional)")
                        }
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                            .opacity(viewController.coordinate != nil ? 1 : 0)
                    }
                }
                
                Group {
                    NewRecipeRow("Ingredients") {
                        IngredientListEditorView(viewController: ingredientsViewController)
                            .padding()
                    }
                    
                    NewRecipeRow("Method") {
                        TextEditorListView(viewController: textEditorListViewController)
                    }
                }
                
                NewRecipeRow("Emoji") {
                    EmojiPickerView() { emoji in
                        viewController.emoji = emoji
                    }
                }
            }
        }
        .onTapGesture {
            let resign = #selector(UIResponder.resignFirstResponder)
            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
            
        }
        .onAppear {
            viewController.coordinate = coordinatePickerViewModel.chosenRegion
        }
        .onChange(of: inputImage) { _ in
            guard let inputImage = inputImage else { return }
            viewController.image = Image(uiImage: inputImage)
        }
        .alert(isPresented: $viewController.showEmptyRecipeWarning) {
            Alert(
                title: Text("Please fill out the full recipe!"),
                dismissButton: .none
            )
        }
        //        .navigationTitle("New Recipe")
        .navigationTitle(viewController.name != "" ? viewController.name : "New Recipe")
        .sheet(isPresented: $showImageLibrary) {
            PhotoPicker(image: $inputImage)
            
        }
        .navigationBarItems(trailing:
                                Button(action: {
            
            //            if !ingredientsViewController.isEmpty {
            //                var ingredients: [Ingredient] = []
            //                for index in ingredientsViewController.listItems {
            //                    if ingredientsViewController.rowIsEmpty(index: index) {
            //                        continue
            //                    }
            //                    ingredients.append(Ingredient(id: String(index), name: ingredientsViewController.ingredients[index], quantity: ingredientsViewController.quantities[index], unit: ingredientsViewController.units[index]))
            //                }
            //                viewController.ingredients = ingredients
            //            }
            
            viewController.ingredients = ingredientsViewController.ingredientsList
            
            viewController.steps = textEditorListViewController.listItemsText
            
            viewController.publishRecipe()
        }) {
            Text("Publish")
        })
    }
}

struct NewRecipe_Previews: PreviewProvider {
    static var previews: some View {
        NewRecipeView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
