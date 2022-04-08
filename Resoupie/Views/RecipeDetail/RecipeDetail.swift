//
//  RecipeDetail.swift
//  Resoupie
//
//  Created by Michael Abir on 2/27/22.
//

import SwiftUI
import MapKit
import Combine

func tryIntString(d: Double) -> String {
    if floor(d) == d {
        let intD = Int(d)
        return String(intD)
    } else {
        return String(d)
    }
}

class RecipeDetailViewController: StarsRatingViewController {
    private var cancellables: Set<AnyCancellable> = Set()
    typealias Backend = RecipeBackendController
    let backendController: Backend
    var recipeMeta: RecipeMeta
    
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    @Published var favorited: Bool = false
    
    @Published var rating: Double
    @Published var forkInfo: ForkInfoModel? = nil
    @Published var showFork: Bool = false
    
    var forkViewController: RecipeDetailViewController?
    var forkRecipeMeta: RecipeMeta?
    
    var forkChildren: [RecipeMeta] = []
    
    @State var coordinateRegion: MKCoordinateRegion
    
    @Published var locationName: String = ""
    
    @Published var hasSpecialTool: [Bool]
    @Published var hasIngredient: [Bool]
    @Published var completedStep: [Bool]
    @Published var groceriesAdded = false
    
    @Published var currentServings: Int?
    
    @Published var ingredientInGroceryList: [Bool]
    
    init(_ recipeMeta: RecipeMeta, backendController: Backend) {
        self.recipeMeta = recipeMeta
        rating = recipeMeta.rating
        let center = recipeMeta.recipe.coordinate()
        coordinateRegion = MKCoordinateRegion(center: center ?? CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        hasSpecialTool = [Bool](repeating: false, count: recipeMeta.recipe.specialTools.count)
        hasIngredient = [Bool](repeating: false, count: recipeMeta.recipe.ingredientsSections.compactMap({ $0.ingredients.count }).reduce(0, +))
        completedStep = [Bool](repeating: false, count: recipeMeta.recipe.stepsSections.compactMap({ $0.steps.count }).reduce(0, +))
        favorited = false
        
        self.backendController = backendController

        
        ingredientInGroceryList =  AppStorageContainer.main.ingredientsInGroceryList(recipeMeta)
        
        let geo = CLGeocoder()
        
        if let location = recipeMeta.recipe.coordinate() {
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
        
        groceriesAdded = AppStorageContainer.main.recipeListExists(recipeMeta)
        
        checkFavorited()
        getForkInfo()
        getForkChildren()
    }
    
    func folderBadgeTapped() {
        if AppStorageContainer.main.recipeListExists(recipeMeta) {
            AppStorageContainer.main.removeRecipeList(recipeMeta)
            ingredientInGroceryList = ingredientInGroceryList.map { _ in false }
        } else {
            AppStorageContainer.main.insertListFromRecipe(recipeMeta)
            ingredientInGroceryList = ingredientInGroceryList.map { _ in true }
        }
    }
    
    func specialToolPressed(_ index: Int) {
        hasSpecialTool[index].toggle()
    }
    
    func ingredientPressed(_ index: Int) {
        hasIngredient[index].toggle()
    }
    
    func ingredientAddPressed(_ ingredient: Ingredient) {
        let ingredientIndex = recipeMeta.recipe.ingredientsSections.compactMap({ $0.ingredients }).reduce([], +).firstIndex(of: ingredient)
        ingredientInGroceryList[ingredientIndex!].toggle()
        
        if AppStorageContainer.main.ingredientInList(ingredient, recipeMeta: recipeMeta) {
            AppStorageContainer.main.removeIngredient(ingredient, recipeMeta: recipeMeta)
        } else {
            AppStorageContainer.main.insertIngredient(ingredient, recipeMeta: recipeMeta)
        }
        
        groceriesAdded = AppStorageContainer.main.recipeListExists(recipeMeta)
    }
    
    func getIngredientString(ingredient: Ingredient) -> String {
        var currentQuantity = Double(ingredient.quantity) ?? 0
        if let currentServings = currentServings {
            currentQuantity = currentQuantity / Double(recipeMeta.recipe.servings) * Double(currentServings)
        }
        return ingredient.name + " (" + (currentQuantity > 0 ? String(currentQuantity.truncate(places: 2)) : ingredient.quantity) + " " + ingredient.unit +  ")"
    }
    
    func stepPressed(_ index: Int) {
        completedStep[index].toggle()
    }
    
    func checkFavorited() {
        if favorites.firstIndex(where: {$0.id == recipeMeta.id}) != nil {
            favorited = true
        } else {
            favorited = false
        }
    }
    
    func getForkRecipe() -> RecipeMeta {
        return forkRecipeMeta ?? RecipeMeta.empty
    }
    
    func getForkInfo() {
        backendController.getForkInfo(recipe_id: recipeMeta.id)
            .receive(on: DispatchQueue.main)
            .map { forkInfoModel -> ForkInfoModel in
                self.forkInfo = forkInfoModel
                return forkInfoModel
            }
            .flatMap{ forkInfoModel in
                self.backendController.getRecipeById(recipe_id: forkInfoModel.parent_id)
            }
            .sink(receiveCompletion: { _ in
            }, receiveValue: { forkRecipe in
                self.forkRecipeMeta = forkRecipe
                self.forkViewController = RecipeDetailViewController(forkRecipe, backendController: self.backendController)
            })
            .store(in: &cancellables)
    }
    
    func getForkChildren() {
        backendController.getForkChildren(recipe_id: recipeMeta.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { children in
                self.forkChildren = children
            })
            .store(in: &cancellables)
    }
    
    func rateRecipe(_ rating: Int, continuation: @escaping (Double) -> ()) {
        backendController.rateRecipe(recipe_id: recipeMeta.id, rating: rating)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { newRating in
                self.recipeMeta.rating = newRating
                self.rating = newRating
                continuation(newRating)
            })
            .store(in: &cancellables)
    }
    
    func favoritePressed() {
        if favorited {
            unfavoriteRecipe()
        } else {
            favoriteRecipe()
        }
    }
    
    private func favoriteRecipe() {
        favorited = true
        
        if favorites.firstIndex(where: {$0.id == recipeMeta.id }) == nil {
            favorites.append(recipeMeta)
        }
        
        backendController.favoriteRecipe(recipe_id: recipeMeta.id)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                
            })
            .store(in: &cancellables)
    }
    
    private func unfavoriteRecipe() {
        favorited = false
        let index = favorites.firstIndex(where: {$0.id == recipeMeta.id })
        if let index = index {
            favorites.remove(at: index)
        }
        
        backendController.unfavoriteRecipe(recipe_id: recipeMeta.id)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                
            })
            .store(in: &cancellables)
    }
}

struct RecipeDetail: View {
    @StateObject var viewController: RecipeDetailViewController
    
    let navbarHeight: CGFloat
    let initialOffset: CGFloat
    let recipeMeta: RecipeMeta
    
    @State private var navbarOpacity: CGFloat = 0.0
    @State private var showNavBar: Bool = false
    @State private var showNavBarItems: Bool = false
    @State private var showNavBarEmoji: Bool = false
    
    @State private var presentEditRecipe: Bool = false
    
    @State private var showStepsSections: [Bool]
    @State private var showIngredientsSections: [Bool]

    @Environment(\.presentationMode) var presentation
    
    init(_ recipeMeta: RecipeMeta, backendController: BackendController) {
        self.recipeMeta = recipeMeta
        
        navbarHeight = 100
        initialOffset = -navbarHeight
        
        _showStepsSections = State(initialValue: recipeMeta.recipe.stepsSections.map({ _ in true }))
        _showIngredientsSections = State(initialValue: recipeMeta.recipe.ingredientsSections.map({ _ in true }))

        _viewController = StateObject(wrappedValue: RecipeDetailViewController(recipeMeta, backendController: backendController))
        
    }
    
    @State var scroll: CGFloat = 0
    
    @State var imageBottom: CGFloat = 1000
    @State var navbarTop: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.background
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    header(offset: scroll)
                    
                    aboutRecipeSection
                    
                    forkSection
                    
                    if let location = recipeMeta.recipe.coordinate() {
                        mapViewSection(location)
                    }
                    
                    if !recipeMeta.recipe.specialTools.isEmpty {
                        specialToolsSection
                    }
                    
                    ingredientsSection
                    
                    methodSection
                    
                    if !recipeMeta.recipe.tags.isEmpty {
                        tagSection
                    }
                }
                .readScroll { scroll in
                    self.scroll = scroll
                    
                    withAnimation {
                        self.showNavBarItems = imageBottom < navbarTop + navbarHeight * 2
                    }
                    
                    self.showNavBar = imageBottom < navbarTop + navbarHeight
                    
                    withAnimation {
                        self.showNavBarEmoji = imageBottom < navbarTop + navbarHeight
                    }
                }
                .offset(y: initialOffset)
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            GeometryReader { proxy in
                navigationBar
                
                let _ = DispatchQueue.main.async {
                    navbarTop = proxy.frame(in: .global).minY
                }
            }
        }
        .statusBar(hidden: !showNavBar)
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $presentEditRecipe) {
            NavigationView {
                EditRecipeView(recipeMeta.recipe.childOf(parent_id: recipeMeta.id), isPresented: $presentEditRecipe)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                presentEditRecipe = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
            }
        }
    }
}

extension RecipeDetail {
    @ViewBuilder
    private func header(offset: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { proxy in
                CustomAsyncImage(imageId: recipeMeta.recipe.image, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .scaleEffect(getScaleFromOffset(offset: offset), anchor: .bottom)
                let _ = DispatchQueue.main.async {
                    imageBottom = proxy.frame(in: .global).maxY
                }
            }
            .aspectRatio(1, contentMode: .fill)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(recipeMeta.recipe.name)
                        .foregroundColor(Color.white)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    
                    NavigationLink(destination: ProfileView(name: recipeMeta.author, user_id: recipeMeta.user_id)) {
                        Text(recipeMeta.author)
                            .foregroundColor(Color.white)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                
                Spacer()
                
                StarsRating(viewController: viewController)
                Text(String(recipeMeta.rating))
                    .foregroundColor(Color.theme.light)
                    .fontWeight(.semibold)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .bottom, endPoint: .top)
                    .opacity(0.9)
            )
        }
        .overlay(
            Rectangle()
                .foregroundColor(Color.clear)
                .background(.ultraThinMaterial)
                .opacity(getNavbarOpacity(offset))
        )
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(Color.clear)
                .frame(maxWidth: .infinity)
                .frame(height: navbarHeight)
                .opacity(0)
            
            Text(recipeMeta.recipe.emoji)
                .font(.title)
                .padding(.bottom, 10)
                .transition(.move(edge: .bottom))
                .opacity(showNavBarEmoji ? 1.0 : 0.0)
            
            HStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(Font.title3.weight(.medium))
                        .foregroundColor(Color.theme.light)
                        .colorMultiply(showNavBarItems ? Color.theme.accent : Color.theme.light)
                    
                    Text("Back")
                        .foregroundColor(Color.theme.light)
                        .colorMultiply(showNavBarItems ? Color.theme.accent : Color.theme.light)
                }
                .padding()
                .onTapGesture {
                    presentation.wrappedValue.dismiss()
                }
                
                Spacer()
                
                Image(systemName: viewController.favorited ? "heart.fill" : "heart")
                    .font(Font.title2.weight(.medium))
                    .foregroundColor(Color.theme.red)
                    .padding()
                    .onTapGesture {
                        viewController.favoritePressed()
                    }
            }
            
            Divider()
                .opacity(showNavBar ? 1.0 : 0.0)
        }
        .background(
            Rectangle()
                .foregroundColor(Color.clear)
                .background(.ultraThinMaterial)
                .frame(maxWidth: .infinity)
                .frame(height: navbarHeight)
                .opacity(showNavBar ? 1.0 : 0.0)
        )
    }
    
    private var specialToolsSection: some View {
        RecipeDetailSectionInset {
            VStack {
                HStack {
                    Text("Special Tools")
                        .foregroundColor(Color.theme.title3)
                        .font(.title3)
                    Spacer()
                }
                
                Divider()
                    .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        ForEach (recipeMeta.recipe.specialTools, id: \.self) { tool in
                            let index = recipeMeta.recipe.specialTools.firstIndex(of: tool)!
                            HStack {
                                Image(systemName: viewController.hasSpecialTool[index] ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(Color.theme.accent)
                                    .font(.system(size: 24))
                                
                                Text(tool)
                                    .strikethrough(viewController.hasSpecialTool[index], color: Color.theme.lightText)
                                    .foregroundColor(viewController.hasSpecialTool[index] ? Color.theme.lightText : Color.theme.text)
                                    .padding(.vertical, 5)
                            }
                            .onTapGesture {
                                viewController.specialToolPressed(index)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        RecipeDetailSectionInset {
            VStack {
                HStack {
                    Text("Ingredients")
                        .foregroundColor(Color.theme.title3)
                        .font(.title3)
                    
                    Spacer()
                    
                    VStack {
                        Text("Servings")
                            .foregroundColor(Color.theme.lightText)
                            .font(.subheadline)
                            .padding(.top, 5)
                        
                        HStack(spacing: 20) {
                            Image(systemName: "minus")
                                .font(.title2)
                                .background(
                                    Rectangle()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color.black.opacity(0.0001))
                                )
                                .foregroundColor((viewController.currentServings ?? recipeMeta.recipe.servings) > 1 ? Color.theme.accent : Color.theme.lightText)
                                .onTapGesture {
                                    if viewController.currentServings == nil {
                                        viewController.currentServings = recipeMeta.recipe.servings
                                    }
                                    
                                    if viewController.currentServings! > 1 {
                                        viewController.currentServings! -= 1
                                    }
                                }
                            
                            Text(String(viewController.currentServings ?? recipeMeta.recipe.servings))
                                .foregroundColor(Color.theme.text)
                                .font(.title2)
                            Image(systemName: "plus")
                                .foregroundColor(Color.theme.accent)
                                .font(.title2)
                                .onTapGesture {
                                    if viewController.currentServings == nil {
                                        viewController.currentServings = recipeMeta.recipe.servings
                                    }
                                    
                                    viewController.currentServings! += 1
                                }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: viewController.groceriesAdded ? "folder.fill.badge.plus" : "folder.badge.plus")
                        .foregroundColor(Color.theme.accent)
                        .font(.title2)
                        .onTapGesture {
                            withAnimation {
                                viewController.groceriesAdded.toggle()
                            }
                            
                            viewController.folderBadgeTapped()
                        }
                }
                
                Divider()
                    .padding(.bottom)
                
                ForEach(recipeMeta.recipe.ingredientsSections.indices, id: \.self) { sectionIndex in
                    let section = recipeMeta.recipe.ingredientsSections[sectionIndex]
                    
                    HStack {
                        Text(section.name)
                            .font(.headline)
                            .foregroundColor(Color.theme.headline)

                        Spacer()

                        Button {
                            withAnimation {
                                showIngredientsSections[sectionIndex].toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.theme.tint)
                                .rotationEffect(.degrees(showIngredientsSections[sectionIndex] ? 90 : 0))
                        }
                    }
                    
                    if showIngredientsSections[sectionIndex] {
                        ForEach (section.ingredients.indices, id: \.self) { index in
                            let ingredient = section.ingredients[index]
                            HStack {
                                Image(systemName: viewController.ingredientInGroceryList[index] ? "plus.circle.fill" : "plus.circle")
                                    .foregroundColor(Color.theme.accent)
                                    .font(.system(size: 24))
                                    .onTapGesture {
                                        viewController.ingredientAddPressed(ingredient)
                                    }
                                
                                var currentQuantity = Double(ingredient.quantity) ?? 0
                                if let currentServings = viewController.currentServings {
                                    let _ = (currentQuantity = currentQuantity / Double(recipeMeta.recipe.servings) * Double(currentServings))
                                }
                                
                                let doubleQuantityString = (currentQuantity > 0 ? String(currentQuantity.truncate(places: 2)) : ingredient.quantity)
                                let doubleQuantity = Double(doubleQuantityString) ?? 0
                                let finalQuantity = tryIntString(d: doubleQuantity)
                                let ingredientText = finalQuantity + " " + ingredient.unit + " " + ingredient.name
                                
                                Text(ingredientText)
                                    .strikethrough(viewController.hasIngredient[index], color: Color.theme.lightText)
                                    .foregroundColor(viewController.hasIngredient[index] ? Color.theme.lightText : Color.theme.text)
                                    .onTapGesture {
                                        viewController.ingredientPressed(index)
                                    }
                                
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
        }
    }
    
    private var methodSection: some View {
        RecipeDetailSectionInset {
            VStack {
                HStack {
                    Text("Method")
                        .foregroundColor(Color.theme.title3)
                        .font(.title3)
                    Spacer()
                }
                
                Divider()
                    .padding(.bottom)
                
                VStack(spacing: 10) {
                    ForEach(recipeMeta.recipe.stepsSections.indices, id: \.self) { sectionIndex in
                        let section = recipeMeta.recipe.stepsSections[sectionIndex]
                        
                        HStack {
                            Text(section.name)
                                .font(.headline)
                                .foregroundColor(Color.theme.headline)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    showStepsSections[sectionIndex].toggle()
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(showStepsSections[sectionIndex] ? 90 : 0))
                                    .foregroundColor(Color.theme.tint)
                            }
                        }
                        if showStepsSections[sectionIndex] {
                            ForEach(section.steps, id: \.self) { step in
                                let index = recipeMeta.recipe.stepsSections[sectionIndex].steps.firstIndex(of: step)!
                                HStack {
                                    let imageName = String(index + 1) + ".circle" + (viewController.completedStep[index] ? ".fill" : "")
                                    Image(systemName: imageName)
                                        .foregroundColor(Color.theme.accent)
                                        .font(.system(size: 24))
                                    
                                    Text(step)
                                        .strikethrough(viewController.completedStep[index], color: Color.theme.lightText)
                                        .foregroundColor(viewController.completedStep[index] ? Color.theme.lightText : Color.theme.text)
                                        .padding(.vertical, 5)
                                    
                                    Spacer()
                                }
                                .onTapGesture {
                                    viewController.stepPressed(index)
                                }
                                
                                Divider().opacity(index < section.steps.count - 1 ? 1.0 : 0.0)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var tagSection: some View {
        RecipeDetailSection {
            HStack {
                Spacer()
                
                FlexibleView(
                    data: recipeMeta.recipe.tags,
                    spacing: 15,
                    alignment: .leading
                ) { item in
                    HStack {
                        Text(verbatim: item)
                            .foregroundColor(Color.theme.text)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .frame(minHeight: 20)
                
                Spacer()
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
        }
    }
    
    private var aboutRecipeSection: some View {
        RecipeDetailSectionInset {
            VStack(spacing: 20) {
                
                VStack {
                    HStack {
                        Text("About This Recipe")
                            .foregroundColor(Color.theme.title)
                            .font(.title3)
                        Spacer()
                    }
                    
                    Divider()
                    
                    Spacer()
                    
                    HStack {
                        Text(recipeMeta.recipe.about)
                            .foregroundColor(Color.theme.lightText)
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    if let fork = viewController.forkInfo {
                        NavigationLink(destination: RecipeDetail(viewController.getForkRecipe(), backendController: BackendController())) {
                            HStack(spacing: 0) {
                                Text("Forked from \(fork.parent_author)'s \(Text(fork.parent_name).foregroundColor(Color.theme.accent))")
                                    .foregroundColor(Color.theme.lightText)
                                    .font(.footnote)
                                
                                Spacer()
                            }
                            .disabled(viewController.forkRecipeMeta == nil)
                        }
                    }
                }
            }
        }
        .foregroundColor(Color.theme.tint)
    }
    
    private var forkSection: some View {
        RecipeDetailSectionInset {
            VStack(spacing: 20) {
                
                VStack {
                    HStack {
                        Text("Forks")
                            .foregroundColor(Color.theme.title)
                            .font(.title3)
                        Spacer()
                    }
                    
                    Divider()
                    
                    Spacer()
                    
                    Group {
                        if viewController.forkChildren.isEmpty {
                            Text("Be the first to fork this recipe!")
                                .font(.body)
                                .foregroundColor(Color.theme.lightText)
                        } else {
                            let forkCount = viewController.forkChildren.count
                            let plurality = forkCount > 1 ? "s" : ""
                            let itThem = forkCount > 1 ? "them" : "it"
                            NavigationLink(destination: ForkChildren(viewController.forkChildren)) {
                                HStack(spacing: 0) {
                                    Text("This recipe has \(viewController.forkChildren.count) fork\(plurality). ")
                                        .foregroundColor(Color.theme.lightText)
                                    Text("Check \(itThem) out!")
                                        .foregroundColor(Color.theme.tint)
                                }
                                .font(.body)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    HStack {
                        Spacer ()
                        Text("Fork This Recipe")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .onTapGesture {
                        presentEditRecipe = true
                    }
                }
            }
            .foregroundColor(Color.theme.tint)
        }
    }
    
    
    private func mapView(_ location: CLLocationCoordinate2D) -> some View {
        Map(coordinateRegion: $viewController.coordinateRegion, annotationItems: [Place(id: "", emoji: recipeMeta.recipe.emoji, coordinate: location)]) { place in
            
            MapAnnotation(coordinate: place.coordinate) {
                
                PlaceAnnotationEmojiView(title: place.emoji)
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(recipeMeta.recipe.name)
    }
    
    private func mapViewSection(_ location: CLLocationCoordinate2D) -> some View {
        NavigationLink(destination: mapView(location)) {
            RecipeDetailSection {
                VStack {
                    ZStack {
                        LocationMapSnapshot(location: location, width: UIScreen.main.bounds.width - 20, height: 200) {
                            Text(recipeMeta.recipe.emoji)
                                .font(.system(size: 32))
                        }
                    }
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    HStack {
                        Text(viewController.locationName)
                            .foregroundColor(Color.theme.lightText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.theme.lightText)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func getScaleFromOffset(offset: CGFloat) -> CGFloat {
        let offset = offset + 97
        if offset > 50 {
            return 1.0 + (offset - 50) / 250
        } else if offset > 100 {
            return 1.2
        }
        
        return 1.0
    }
    
    private func getNavbarOpacity(_ offset: CGFloat) -> CGFloat {
        if imageBottom < navbarTop + navbarHeight {
            return 1.0
        } else {
            return (offset + 119) / (-175)
        }
    }
}

//struct RecipeDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        let ingredients: [Ingredient] = [
//            Ingredient(name: "Test", quantity: "1", unit: "Unit"),
//            Ingredient(name: "Test", quantity: "2", unit: "Unit"),
//            Ingredient(name: "Test", quantity: "3", unit: "Unit")
//        ]
//        let location = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California
//        
//        let steps = [
//            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
//            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
//        ]
//        
//        let recipe = Recipe(about: "", image: "621c33b12cfadc340f1c20bd", name: "Spaghetti", ingredients: ingredients, steps: steps, coordinate_lat: location.latitude, coordinate_long: location.longitude, emoji: "🍝", servings: 2, tags: ["vegan", "italian", "pasta", "easy", "t"], time: "25 min", specialTools: ["Tool 1"], parent_id: nil)
//        
//        let recipeMeta = RecipeMeta(id: "", author: "Micky Abir", user_id: "", recipe: recipe, rating: 4.3, favorited: 82)
//        RecipeDetail(recipeMeta, backendController: BackendController())
//    }
//}
