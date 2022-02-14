//
//  NewRecipe.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI
import PhotosUI

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
                let recipe = Recipe(id: uuid, image: imageIdString, name: name, author: "author", ingredients: ingredients, steps: steps, coordinate: self.coordinate, emoji: emoji, servings: Int(servings) ?? 0)
                
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
    @State private var inputImage: UIImage?
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false
    
    private let coordinatePickerViewModel = CoordinatePickerViewModel()
    
    @ObservedObject var viewController = NewRecipeViewController()
    
    @State private var editMode = EditMode.inactive
    
    @State var steps: [String] = [""]
    @State var ingredients: [Ingredient] = [Ingredient(id: "0", name: "", quantity: "", unit: "")]
    @Environment(\.presentationMode) var presentationMode
    
    @State var coordinatePickerActive = false
    @State var locationEnabled = false
    
    @State var country: String?
    @State var locality: String?
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            List {
                Section(header: Text("About").foregroundColor(Color.title)) {
                    TextField("Recipe name", text: $viewController.name)
                        .foregroundColor(Color.text)
                    
                    HStack {
                        TextField("Servings", text: $viewController.servings)
                            .keyboardType(.numberPad)
                            .foregroundColor(Color.text)
                        
                        EmojiPickerView() { emoji in
                            viewController.emoji = emoji
                        }
                    }
                }
                
                Section(header: Text("")) {
                    if viewController.image != nil {
                        Image(uiImage: viewController.image!)
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text((viewController.image == nil ? "Add" : "Edit") + " Image")
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                showImageLibrary = true
                            }
                        
                        Spacer()
                    }
                }
                
                Section(header: HStack {
                    Text("Location").foregroundColor(Color.title)
                    Toggle("", isOn: $locationEnabled)
                }) {
                    if locationEnabled {
                        NavigationLink(destination: CoordinatePicker(viewModel: coordinatePickerViewModel), isActive: $coordinatePickerActive) {
                            HStack {
                                Spacer()
                                                               
                                if let country = coordinatePickerViewModel.country, let locality = coordinatePickerViewModel.locality {
                                    Text(locality + ", " + country)
                                        .foregroundColor(Color.orange)
                                } else {
                                    Text("Choose Location")
                                        .foregroundColor(Color.orange)
                                }
                                
                                Spacer()
                                
                            }
                            .onTapGesture {
                                coordinatePickerActive = true
                            }
                        }
                    }
                }
                
                
                Section(header: HStack {
                    Text("Ingredients").foregroundColor(Color.title)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.orange)
                    }
                }) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        VStack {
                            TextField("Ingredient " + String(index + 1), text: $ingredients[index].name)
                                .foregroundColor(Color.text)
                            
                            HStack {
                                TextField("Quantity", text: $ingredients[index].quantity)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(Color.text)
                                
                                TextField("Unit", text: $ingredients[index].unit)
                                    .foregroundColor(Color.text)
                            }
                        }
                    }
                    .onMove { sourceSet, destination in
                        ingredients.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        ingredients.remove(atOffsets: index)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                withAnimation {
                                    ingredients.append(Ingredient(id: String(ingredients.count), name: "", quantity: "", unit: ""))
                                }
                            }
                        
                        Spacer()
                    }
                }
                
                
                Section(header: HStack {
                    Text("Method").foregroundColor(Color.title)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.orange)
                    }
                }) {
                    ForEach(steps.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: String(index + 1) + ".circle")
                                .foregroundColor(Color.orange)
                                .font(.system(size: 24))
                            
                            ZStack(alignment: .leading) {
                                TextEditor(text: $steps[index])
                                    .foregroundColor(Color.text)
                                
                                Text("Step " + String(index + 1))
                                    .foregroundColor(Color(UIColor.systemGray3))
                                    .opacity(steps[index] == "" ? 1.0 : 0.0)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .onMove { sourceSet, destination in
                        steps.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        steps.remove(atOffsets: index)
                    }

                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                withAnimation {
                                    steps.append("")
                                }
                            }
                        
                        Spacer()
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
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(Color.orange)
            }, trailing: Button(action: {
                viewController.ingredients = ingredients

                viewController.steps = steps

                viewController.publishRecipe()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Publish")
                    .foregroundColor(Color.orange)
            })
            .environment(\.editMode, $editMode)
        }
    }
}
