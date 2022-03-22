
//  EditRecipe.swift
//  CookBook
//
//  Created by Michael Abir on 3/4/22.
//

import SwiftUI
import MapKit
import Combine

class EditRecipeViewController: ObservableObject {
    @ObservedObject var coordinatePickerViewModel = CoordinatePickerViewModel()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var locationName: String = ""
    
    @Published var coordinateRegion = MKCoordinateRegion()
    @Published var mapMarker = [Place(id: "", emoji: "", coordinate: CLLocationCoordinate2D())]

    let backendController: BackendController
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ backendController: BackendController) {
        self.backendController = backendController
    }
    
    func publishRecipe(_ recipe: Recipe, image: UIImage) -> Bool {
        if recipe.name == "" || recipe.ingredients.isEmpty || recipe.steps.isEmpty {
            return false
        }
                
        var publishRecipe = recipe
        backendController.uploadImageToServer(image: image)
            .receive(on: DispatchQueue.main)
            .tryMap { image_id -> Recipe in
                publishRecipe.image = image_id
                return publishRecipe
            }
            .flatMap(backendController.uploadRecipeToServer)
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
//                self.presentationMode.wrappedValue.dismiss()
            })
            .store(in: &cancellables)
        
        return true
    }
    
    func checkLocation() {
        location = coordinatePickerViewModel.chosenRegion
        
        if let location = location {
            coordinateRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
            mapMarker[0] = Place(id: "", emoji: "", coordinate: location)
            let geo = CLGeocoder()
            geo.reverseGeocodeLocationCombine(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
                .receive(on: DispatchQueue.main)
                .sink { country, locality in
                    if let country = country {
                        self.locationName = country
                        
                        if let locality = locality {
                            self.locationName = locality + ", " + country
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
}

struct EditRecipeView: View {
    @StateObject var viewController = EditRecipeViewController(BackendController())
    
    @State var recipe: Recipe
    let parent_id: String?
    
    @State var locationEnabled: Bool = false
    
    @State private var image: UIImage?
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false

    @State private var servings: Int? = nil
    @State private var emoji: String = ""

    @State var editSpecialTools: Bool = false
    @State var editIngredients: Bool = false
    @State var editMethod: Bool = false
    
    @State var newTag: String = ""
    @FocusState var tagEditorFocused: Bool
    
    @Binding var isPresented: Bool
    
    init(_ recipe: Recipe = .empty, parent_id: String? = nil, isPresented: Binding<Bool>) {
        self.recipe = recipe
        self.parent_id = parent_id
        self._isPresented = isPresented
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                aboutSection
                
                imageSection
                
                locationSection
                
                tagSection
                
                specialToolsSection
                
                ingredientsSection
                
                methodSection
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(Color.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(recipe.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let image = image {
                        if !locationEnabled {
                            recipe.coordinate_lat = nil
                            recipe.coordinate_long = nil
                        } else {
                            recipe.coordinate_lat = viewController.location?.latitude
                            recipe.coordinate_long = viewController.location?.longitude
                        }
                        if viewController.publishRecipe(recipe, image: image) {
                            isPresented = false
                        }
                        
                    }
                } label: {
                    Text("Publish")
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        let resign = #selector(UIResponder.resignFirstResponder)
                        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                    }
                }
            }
        }
        .sheet(isPresented: $showImageLibrary) {
            PhotoPicker(image: $image)
        }
        .onAppear {
            viewController.checkLocation()
            servings = recipe.servings > 0 ? recipe.servings : nil
        }
    }
}

extension EditRecipeView {
    private var aboutEditorSection: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $recipe.about)
                .foregroundColor(Color.theme.text)
                .frame(height: 40)
            
            if recipe.about.isEmpty {
                Text("What makes this recipe special")
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 9)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var aboutSection: some View {
        RecipeDetailSectionInset {
            VStack(spacing: 20) {
                HStack {
                    Text("About This Recipe")
                        .foregroundColor(Color.theme.title)
                        .font(.title3)
                    Spacer()
                }
                
                Divider()
                
                TextField("Name", text: $recipe.name)
                    .foregroundColor(Color.theme.text)
                
                TextField("Servings", value: $servings, formatter: NumberFormatter())
                    .foregroundColor(Color.theme.text)
                    .keyboardType(.numberPad)
                    .onChange(of: servings) { newServings in
                        recipe.servings = newServings ?? 0
                    }
                
                TextField("Time", text: $recipe.time)
                    .foregroundColor(Color.theme.text)
                
                EmojiTextField(text: $recipe.emoji, placeholder: "Emoji")
                    .foregroundColor(Color.theme.text)
                    .onChange(of: recipe.emoji) { _ in
                        recipe.emoji = String(recipe.emoji.onlyEmoji().prefix(1))
                    }
                
                Divider()
                
                aboutEditorSection
            }
        }
    }
    
    private var imageSection: some View {
        RecipeDetailSection {
            VStack(spacing: 20) {
                HStack {
                    Text("Image")
                        .foregroundColor(Color.theme.title)
                        .font(.title3)
                    
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal, 30)
                
                Divider()
                    .padding(.horizontal, 30)
                
                if let image = image {
                    VStack {
                        Image(uiImage: image.cropsToSquare())
                            .resizable()
                            .scaledToFit()
                            .clipped()
                    }
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                }

                Button {
                    showImageLibrary = true
                } label: {
                    Text("\(Image(systemName: "camera")) \(image == nil ? "New" : "Edit") Image")
                }
                .foregroundColor(Color.theme.tint)
                .padding(.bottom)
            }
        }
    }
    
    private var locationSection: some View {
        RecipeDetailSection {
            VStack {
                HStack {
                    Text("Location")
                        .foregroundColor(Color.theme.title)
                        .font(.title3)
                    
                    Spacer()
                    
                    Toggle("", isOn: $locationEnabled)
                }
                .padding(.horizontal, 30)
                
                NavigationLink(destination: CoordinatePicker(viewController.coordinatePickerViewModel)) {
                    if locationEnabled {
                        if let _ = viewController.location {
                            VStack {
                                ZStack {
                                    Map(coordinateRegion: $viewController.coordinateRegion, annotationItems: viewController.mapMarker) { place in
                                        MapMarker(coordinate: place.coordinate)
                                        
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 200)
                                    .allowsHitTesting(false)
                                }
                                
                                HStack {
                                    Text(viewController.locationName)
                                        .foregroundColor(Color.theme.lightText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.theme.lightText)
                                }
                                .padding(.horizontal, 30)
                            }
                        } else {
                            Divider()
                            
                            HStack {
                                Spacer()
                                Text("\(Image(systemName: "mappin")) Choose Location")
                                    .foregroundColor(Color.theme.accent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.theme.accent)
                            }
                            .padding(.top)
                            .padding(.horizontal, 30)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var specialToolsSection: some View {
        RecipeDetailSectionInset {
            VStack(spacing: 20) {
                HStack {
                    Text("Special Tools")
                        .foregroundColor(Color.theme.title)
                        .font(.title3)
                    
                    Spacer()
                    
                    Button {
                        if editSpecialTools {
                            withAnimation(.easeOut(duration: 0.1)) {
                                editSpecialTools.toggle()
                            }
                        } else {
                            withAnimation(.spring()) {
                                editSpecialTools.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: editSpecialTools ? "checkmark" : "pencil")
                            .foregroundColor(Color.theme.lightText)
                            .font(.title3)
                    }
                }
                
                Divider()
                
                VStack(spacing: 20) {
                    ForEach(recipe.specialTools.indices, id: \.self) { index in
                        HStack {
                            if editSpecialTools {
                                Button {
                                    recipe.specialTools.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.theme.red)
                                        .font(.title3)
                                }
                                .transition(.move(edge: .leading))
                            }
                            TextField("Tool", text: $recipe.specialTools[index])
                                .foregroundColor(Color.theme.text)
                            
                            Spacer()
                            
                            if editSpecialTools {
                            Button {
                                recipe.specialTools.insert("", at: index + 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.theme.tint)
                                    .font(.title3)
                            }
                            .transition(.move(edge: .trailing))
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            recipe.specialTools.append("")
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(Color.theme.tint)
                                .font(.title2)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        RecipeDetailSectionInset {
            VStack(spacing: 20) {
                HStack {
                    Text("Ingredients")
                        .foregroundColor(Color.theme.title)
                        .font(.title3)
                    
                    Spacer()
                    
                    Button {
                        if editIngredients {
                            withAnimation(.easeOut(duration: 0.1)) {
                                editIngredients.toggle()
                            }
                        } else {
                            withAnimation(.spring()) {
                                editIngredients.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: editIngredients ? "checkmark" : "pencil")
                            .foregroundColor(Color.theme.lightText)
                            .font(.title3)
                    }
                }
                
                Divider()
                
                VStack(spacing: 20) {
                    ForEach(recipe.ingredients.indices, id: \.self) { index in
                        HStack {
                            if editIngredients {
                                Button {
                                    recipe.ingredients.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.theme.red)
                                        .font(.title3)
                                }
                                .transition(.move(edge: .leading))
                            }

                            VStack {
                                TextField("Ingredient name", text: $recipe.ingredients[index].name)
                                    .foregroundColor(Color.theme.text)
                                
                                HStack {
                                    TextField("Quantity", text: $recipe.ingredients[index].quantity)
                                        .foregroundColor(Color.theme.text)
                                        .keyboardType(.decimalPad)

                                    TextField("Unit", text: $recipe.ingredients[index].unit)
                                        .foregroundColor(Color.theme.text)
                                }
                            }
                            
                            Spacer()
                            
                            if editIngredients {
                            Button {
                                recipe.ingredients.insert(Ingredient(name: "", quantity: "", unit: ""), at: index + 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.theme.tint)
                                    .font(.title3)
                            }
                            .transition(.move(edge: .trailing))
                            }
                        }
                        
                        if index < recipe.ingredients.count - 1 {
                            Divider()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            recipe.ingredients.append(Ingredient(name: "", quantity: "", unit: ""))
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(Color.theme.tint)
                                .font(.title2)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func stepEditor(_ index: Int) -> some View {
        ZStack(alignment: .topLeading) {
            let placeHolders = [
                "First, you need to...",
                "Next, you...",
                "In this step...."
            ]

            TextEditor(text: $recipe.steps[index])
                .foregroundColor(Color.theme.text)
                .frame(height: 40)
            
            if recipe.steps[index].isEmpty {
                Text("\(placeHolders[min(index, placeHolders.count - 1)])")
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 9)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var methodSection: some View {
        RecipeDetailSectionInset {
            VStack(spacing: 20) {
                HStack {
                    Text("Method")
                        .foregroundColor(Color.theme.title)
                        .font(.title3)
                    
                    Spacer()
                    
                    Button {
                        if editMethod {
                            withAnimation(.easeOut(duration: 0.1)) {
                                editMethod.toggle()
                            }
                        } else {
                            withAnimation(.spring()) {
                                editMethod.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: editMethod ? "checkmark" : "pencil")
                            .foregroundColor(Color.theme.lightText)
                            .font(.title3)
                    }
                }
                
                Divider()
                
                VStack(spacing: 20) {
                    ForEach(recipe.steps.indices, id: \.self) { index in
                        HStack {
                            if editMethod {
                                Button {
                                    recipe.steps.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.theme.red)
                                        .font(.title3)
                                }
                                .transition(.move(edge: .leading))
                            }

                            HStack {
                                Image(systemName: "\(min(index + 1, 50) ).circle.fill")
                                    .foregroundColor(Color.theme.lightText)
                                    .font(.title3)
                                stepEditor(index)
                            }
                            
                            Spacer()
                            
                            if editMethod {
                            Button {
                                recipe.steps.insert("", at: index + 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.theme.tint)
                                    .font(.title3)
                            }
                            .transition(.move(edge: .trailing))
                            }
                        }
                        
                        if index < recipe.steps.count - 1 {
                            Divider()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            recipe.steps.append("")
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(Color.theme.tint)
                                .font(.title2)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var tagSection: some View {
        RecipeDetailSectionInset {
            VStack {
                HStack {
                    Text("Tags")
                        .foregroundColor(Color.theme.title)
                        .font(.title3)
                    
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                if !recipe.tags.isEmpty {
                    FlexibleView(
                        data: recipe.tags,
                        spacing: 8,
                        alignment: .leading
                    ) { item in
                        HStack {
                            Text(verbatim: item)
                                .foregroundColor(Color.theme.text)
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(Color.theme.lightText)
                                .onTapGesture {
                                    recipe.tags.removeAll(where: { $0 == item })
                                }
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    .frame(minHeight: 20)
                    
                    Divider()
                        .padding(.vertical, 10)
                }
                
                TextField("New Tag", text: $newTag)
                    .foregroundColor(Color.theme.text)
                    .focused($tagEditorFocused)
                    .submitLabel(.next)
                    .onSubmit {
                        let componentTags = newTag
                            .lowercased()
                            .components(separatedBy: " ")
                            .filter({ recipe.tags.firstIndex(of: $0) == nil })
                            .filter({ !$0.isEmpty })
                            .map({ String($0.prefix(20)) })
                        recipe.tags += componentTags
                        recipe.tags = Array(recipe.tags[0..<min(5, recipe.tags.count)])
                        newTag = ""
                        tagEditorFocused = true
                    }

            }
        }
    }
}

struct EditRecipe_Previews: PreviewProvider {
    static var previews: some View {
        var recipe = Recipe.empty.childOf(parent_id: "Parent!")
        let _ = (recipe.specialTools = ["Whisk", "Blender"])
        let _ = (recipe.tags = ["yummy", "easy", "italian"])
        NavigationView {
            EditRecipeView(recipe, isPresented: .constant(true))
        }
    }
}
