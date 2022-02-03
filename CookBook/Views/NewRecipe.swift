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
    }
}

struct NewRecipeRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.orange)
            .frame(height: 1)
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
    @Published var image: UIImage?
    @Published var servings: String = ""
    
    @Published var showEmptyRecipeWarning = false
    
    func publishRecipe() {
        if name == "" || ingredients.isEmpty || steps.isEmpty {
            showEmptyRecipeWarning = true
            return
        }
        
        let imageUploader = ImageBackendController()
        
        var imageIdString: String = ""
        
        if let image = image {
            imageUploader.uploadImageToServer(image: image) { [self] imageId in
                guard let imageId = imageId else { return }
                imageIdString = imageId.uuidString
                let recipe = Recipe(id: uuid, image: imageIdString, name: name, author: "author", rating: 0, ingredients: ingredients, steps: steps, coordinate: self.coordinate, emoji: emoji, favorited: 0, servings: Int(servings) ?? 0)
                
                let recipeUploader = RecipeBackendController()
                recipeUploader.uploadRecipeToServer(recipe: recipe) { result in
                    print(result)
                }
                print(imageId)
                
                recipeUploader.loadAllRecipes { recipes in
                    print(recipes)
                }
            }
        }
    }
}

struct NewRecipeView: View {
    @EnvironmentObject var presentNewRecipe: PresentNewRecipe
    
    @State private var inputImage: UIImage?
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false
    
    private let coordinatePickerViewModel = CoordinatePickerViewModel()
    private let textEditorListViewController = TextEditorListViewController()
    private let ingredientsViewController = IngredientListEditorViewController()
    
    @ObservedObject var viewController = NewRecipeViewController()
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    NewRecipeRow {
                        CustomTextField("Recipe name", text: $viewController.name)
                        
                        HStack {
                            CustomTextField("Servings", text: $viewController.servings)
                                .keyboardType(.numberPad)
                                .frame(width: 150)
                            
                            EmojiPickerView() { emoji in
                                viewController.emoji = emoji
                            }
                        }
                        
                        if viewController.image != nil {
                            Image(uiImage: viewController.image!)
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
                    
                    NewRecipeRowDivider()
                    
                    
                    Group {
                        NewRecipeRow("Ingredients") {
                            IngredientListEditorView(viewController: ingredientsViewController)
                                .padding()
                        }
                        
                        NewRecipeRowDivider()
                        
                        NewRecipeRow("Method") {
                            TextEditorListView(viewController: textEditorListViewController)
                        }
                    }
                    
                    NewRecipeRowDivider()
                    
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
                viewController.image = inputImage
            }
            .alert(isPresented: $viewController.showEmptyRecipeWarning) {
                Alert(
                    title: Text("Please fill out the full recipe!"),
                    dismissButton: .none
                )
            }
            .navigationTitle(viewController.name != "" ? viewController.name : "New Recipe")
            .sheet(isPresented: $showImageLibrary) {
                PhotoPicker(image: $inputImage)
            }
            .navigationBarItems(leading:
                                    Button(action: {
                presentNewRecipe.showNewRecipe = false
            }) {
                Text("Cancel")
                    .foregroundColor(Color.orange)
            })
            .navigationBarItems(trailing:
                                    Button(action: {
                viewController.ingredients = ingredientsViewController.ingredientsList
                
                viewController.steps = textEditorListViewController.listItemsText
                
                viewController.publishRecipe()
                presentNewRecipe.showNewRecipe = false
            }) {
                Text("Publish")
                    .foregroundColor(Color.orange)
            })
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
