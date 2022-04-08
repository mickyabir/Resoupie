
//  EditRecipe.swift
//  Resoupie
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

    @Published var time: Date = Date()
    
    let backendController: BackendController
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ backendController: BackendController) {
        self.backendController = backendController
        
        Timer.publish(every: 3, tolerance: 1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] time in
                self?.time = time
            }
            .store(in: &cancellables)
    }
    
    func setLocation(_ location: CLLocationCoordinate2D?) {
        self.location = location
    }
    
    func publishRecipe(_ recipe: Recipe, image: UIImage?, recipe_id: String? = nil) -> Bool {
        if recipe.tags
            .map({ $0.isEmpty })
            .reduce(true, { current, next in
                return current && next
            }) {
            return false
        }
        
        if recipe.ingredientsSections.compactMap({ $0.ingredients }).reduce([], +)
            .map({ $0.name.isEmpty || $0.quantity.isEmpty || $0.unit.isEmpty })
            .reduce(true, { current, next in
                return current && next
            }) {
            return false
        }

        if recipe.stepsSections.compactMap({ $0.steps }).reduce([], +)
            .map({ $0.isEmpty })
            .reduce(true, { current, next in
                return current && next
            }) {
            return false
        }
        
        if recipe.name.isEmpty || recipe.time.isEmpty || recipe.emoji.isEmpty || recipe.about.isEmpty || recipe.servings == 0 {
            return false
        }
        
        var publishRecipe = recipe
        
        if let recipe_id = recipe_id {
            if let image = image {
                backendController.uploadImageToServer(image: image)
                    .receive(on: DispatchQueue.main)
                    .tryMap { image_id -> (Recipe, String) in
                        publishRecipe.image = image_id
                        return (publishRecipe, recipe_id)
                    }
                    .flatMap(backendController.editRecipe)
                    .eraseToAnyPublisher()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { success in
                        //                self.presentationMode.wrappedValue.dismiss()
                    })
                    .store(in: &cancellables)
            } else {
                backendController.editRecipe(recipe: recipe, recipe_id: recipe_id)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { success in
                        //                self.presentationMode.wrappedValue.dismiss()
                    })
                    .store(in: &cancellables)
            }
        } else if let image = image {
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
        }
        
        return true
    }
    
    func checkLocation() {
        location = location ?? coordinatePickerViewModel.chosenRegion
        
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
    
    func saveDraft(_ recipe: Recipe) {
        AppStorageContainer.main.saveRecipe(recipe)
    }
    
    func getDraft() -> Recipe {
        return AppStorageContainer.main.loadRecipe()
    }
}

struct EditRecipeView: View {
    @StateObject var viewController = EditRecipeViewController(BackendController())
    
    @State var recipe: Recipe
    
    let parent_id: String?
    
    @State var locationEnabled: Bool = false
    
    @State private var image: UIImage?
    @State private var showImageLibrary = false

    @State private var servings: Int? = nil
    @State private var emoji: String = ""

    @State var editSpecialTools: Bool = false
    @State var editIngredients: Bool = false
    @State var editMethod: Bool = false
    
    @State var newTag: String = ""
    @FocusState var tagEditorFocused: Bool
    
    @Binding var isPresented: Bool
    
    @State var showClearAlert: Bool = false
    
    @State var imageSectionWarning: Bool = false
    @State var methodSectionWarning: Bool = false
    @State var aboutSectionWarning: Bool = false
    @State var ingredientsSectionWarning: Bool = false
    @State var tagSectionWarning: Bool = false
    
    let recipe_id: String?
        
    init(_ recipeMeta: RecipeMeta = .empty, parent_id: String? = nil, isPresented: Binding<Bool>) {
        self.recipe = recipeMeta.recipe
        self.parent_id = parent_id
        self._isPresented = isPresented
        let owner = recipeMeta.user_id == AppStorageContainer.main.user_id
        self.recipe_id = recipeMeta.id.isEmpty || !owner ? nil : recipeMeta.id
    }
    
    func loadDraft() {
        if recipe == .empty {
            DispatchQueue.main.async {
                recipe = viewController.getDraft()
                servings = recipe.servings > 0 ? Int(recipe.servings) : nil
            }
        }
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
                
                clearSection
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .onChange(of: viewController.time, perform: { _ in
            viewController.saveDraft(recipe)
        })
        .background(Color.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(recipe.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if recipe.stepsSections.compactMap({ $0.steps }).reduce([], +)
                        .map({ $0.isEmpty })
                        .reduce(true, { current, next in
                            return current && next
                        }) {
                        withAnimation {
                            methodSectionWarning = true
                        }
                    } else {
                        withAnimation {
                            methodSectionWarning = false
                        }
                    }
                    
                    if recipe.name.isEmpty || recipe.time.isEmpty || recipe.emoji.isEmpty || recipe.about.isEmpty || recipe.servings == 0 {
                        withAnimation {
                            aboutSectionWarning = true
                        }
                    } else {
                        withAnimation {
                            aboutSectionWarning = false
                        }
                    }
                    
                    if recipe.ingredientsSections.compactMap({ $0.ingredients }).reduce([], +)
                        .map({ $0.name.isEmpty || $0.quantity.isEmpty || $0.unit.isEmpty })
                        .reduce(true, { current, next in
                            return current && next
                        }) {
                        withAnimation {
                            ingredientsSectionWarning = true
                        }
                    } else {
                        withAnimation {
                            ingredientsSectionWarning = false
                        }
                    }
                    
                    if recipe.tags
                        .map({ $0.isEmpty })
                        .reduce(true, { current, next in
                            return current && next
                        }) {
                        withAnimation {
                            tagSectionWarning = true
                        }
                    } else {
                        withAnimation {
                            tagSectionWarning = false
                        }
                    }
                    
                    if !locationEnabled {
                        recipe.coordinate_lat = nil
                        recipe.coordinate_long = nil
                    } else {
                        recipe.coordinate_lat = viewController.location?.latitude
                        recipe.coordinate_long = viewController.location?.longitude
                    }
                    
                    if let image = image {
                        if viewController.publishRecipe(recipe, image: image, recipe_id: recipe_id) {
                            isPresented = false
                        }
                    } else if !recipe.image.isEmpty {
                        if viewController.publishRecipe(recipe, image: nil, recipe_id: recipe_id) {
                            isPresented = false
                        }
                    } else {
                        withAnimation {
                            imageSectionWarning = true
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
            loadDraft()
            locationEnabled = recipe.coordinate() != nil
            viewController.setLocation(recipe.coordinate())
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
                .frame(minHeight: 60)
                .fixedSize(horizontal: false, vertical: true)

            
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
                
                TextField("Emoji", text: $recipe.emoji)
                    .foregroundColor(Color.theme.text)
                    .onChange(of: recipe.emoji) { _ in
                        recipe.emoji = String(recipe.emoji.onlyEmoji().prefix(1))
                    }
                
                Divider()
                
                aboutEditorSection
            }
        }
        .shadow(color: Color.theme.red.opacity(aboutSectionWarning ? 0.4 : 0.0), radius: 10)
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
                } else if !recipe.image.isEmpty {
                    CustomAsyncImage(imageId: recipe.image, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                }
                
                Button {
                    showImageLibrary = true
                } label: {
                    Text("\(Image(systemName: "camera")) \(recipe.image.isEmpty && image == nil ? "New" : "Edit") Image")
                }
                .foregroundColor(Color.theme.tint)
                .padding(.bottom)
            }
        }
        .shadow(color: Color.theme.red.opacity(imageSectionWarning ? 0.4 : 0.0), radius: 10)
        .onChange(of: image) { newValue in
            if image != nil {
                withAnimation {
                    imageSectionWarning = false
                }
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
                    ForEach(recipe.ingredientsSections.indices, id: \.self) { sectionIndex in
                        let section = recipe.ingredientsSections[sectionIndex]
                        
                        HStack {
                            if editIngredients {
                                Button {
                                    recipe.ingredientsSections.remove(at: sectionIndex)
                                } label: {
                                    Image(systemName: "rectangle.badge.minus")
                                        .foregroundColor(Color.theme.red)
                                        .font(.headline)
                                }
                            }
                            
                            TextField("Section Name", text: $recipe.ingredientsSections[sectionIndex].name)
                                .foregroundColor(Color.theme.text)
                            
                            Spacer()                            
                        }
                        
                        ForEach(section.ingredients.indices, id: \.self) { index in
                            HStack {
                                if editIngredients {
                                    Button {
                                        recipe.ingredientsSections[sectionIndex].ingredients.remove(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(Color.theme.red)
                                            .font(.title3)
                                    }
                                    .transition(.move(edge: .leading))
                                }

                                VStack {
                                    TextField("Ingredient name", text: $recipe.ingredientsSections[sectionIndex].ingredients[index].name)
                                        .foregroundColor(Color.theme.text)
                                    
                                    HStack {
                                        TextField("Quantity", text: $recipe.ingredientsSections[sectionIndex].ingredients[index].quantity)
                                            .foregroundColor(Color.theme.text)
                                            .keyboardType(.decimalPad)

                                        TextField("Unit", text: $recipe.ingredientsSections[sectionIndex].ingredients[index].unit)
                                            .foregroundColor(Color.theme.text)
                                    }
                                }
                                
                                Spacer()
                                
                                if editIngredients {
                                Button {
                                    recipe.ingredientsSections[sectionIndex].ingredients.insert(Ingredient(name: "", quantity: "", unit: ""), at: index + 1)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color.theme.tint)
                                        .font(.title3)
                                }
                                .transition(.move(edge: .trailing))
                                }
                            }
                            
                            Divider()
                        }
                        
                        HStack {
                            Spacer()
                            Button {
                                recipe.ingredientsSections[sectionIndex].ingredients.append(Ingredient(name: "", quantity: "", unit: ""))
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.theme.tint)
                                    .font(.title2)
                            }
                            Spacer()
                        }
                        
                        Divider()
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            recipe.ingredientsSections.append(IngredientsSection(name: "", ingredients: []))
                        } label: {
                            Text("Add Section")
                                .foregroundColor(Color.theme.tint)
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
            }
        }
        .shadow(color: Color.theme.red.opacity(ingredientsSectionWarning ? 0.4 : 0.0), radius: 10)
    }
    
    private func stepEditor(_ index: Int, sectionIndex: Int) -> some View {
        ZStack(alignment: .topLeading) {
            let placeHolders = [
                "First, you need to...",
                "Next, you...",
                "In this step...."
            ]

            TextEditor(text: $recipe.stepsSections[sectionIndex].steps[index])
                .foregroundColor(Color.theme.text)
                .fixedSize(horizontal: false, vertical: true)

            
            if recipe.stepsSections[sectionIndex].steps[index].isEmpty {
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
                    ForEach(recipe.stepsSections.indices, id: \.self) { sectionIndex in
                        let section = recipe.stepsSections[sectionIndex]
                        
                        HStack {
                            if editMethod {
                                Button {
                                    recipe.stepsSections.remove(at: sectionIndex)
                                } label: {
                                    Image(systemName: "rectangle.badge.minus")
                                        .foregroundColor(Color.theme.red)
                                        .font(.headline)
                                }
                            }
                            TextField("Section Name", text: $recipe.stepsSections[sectionIndex].name)
                                .foregroundColor(Color.theme.text)
                            
                            Spacer()
                        }
                        
                        ForEach(section.steps.indices, id: \.self) { index in
                            HStack {
                                if editMethod {
                                    Button {
                                        recipe.stepsSections[sectionIndex].steps.remove(at: index)
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
                                    stepEditor(index, sectionIndex: sectionIndex)
                                }
                                
                                Spacer()
                                
                                if editMethod {
                                Button {
                                    recipe.stepsSections[sectionIndex].steps.insert("", at: index + 1)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color.theme.tint)
                                        .font(.title3)
                                }
                                .transition(.move(edge: .trailing))
                                }
                            }
                            
                            Divider()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                recipe.stepsSections[sectionIndex].steps.append("")
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.theme.tint)
                                    .font(.title2)
                            }

                            Spacer()
                        }
                        
                        Divider()
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            recipe.stepsSections.append(StepsSection(name: "", steps: []))
                        } label: {
                            Text("Add Section")
                                .foregroundColor(Color.theme.tint)
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
            }
        }
        .shadow(color: Color.theme.red.opacity(methodSectionWarning ? 0.4 : 0.0), radius: 10)
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
        .shadow(color: Color.theme.red.opacity(tagSectionWarning ? 0.4 : 0.0), radius: 10)
    }
    
    private var clearSection: some View {
        RecipeDetailSectionInset {
            HStack {
                Spacer()
                
                Button {
                    showClearAlert = true

                } label: {
                    Text("Clear")
                        .foregroundColor(Color.theme.tint)
                        .font(.title3)
                }
                
                Spacer()
            }
            .alert(isPresented: $showClearAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("This can't be undone"),
                    primaryButton: .destructive(Text("Clear")) {
                        image = nil
                        locationEnabled = false
                        viewController.location = nil
                        recipe = .empty
                        viewController.saveDraft(.empty)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct EditRecipe_Previews: PreviewProvider {
    static var previews: some View {
        var recipe = RecipeMeta.empty.childOf(parent_id: "Parent!")
        let _ = (recipe.recipe.specialTools = ["Whisk", "Blender"])
        let _ = (recipe.recipe.tags = ["yummy", "easy", "italian"])
        NavigationView {
            EditRecipeView(recipe, isPresented: .constant(true))
        }
    }
}
