//
//  NewRecipeDetail.swift
//  CookBook
//
//  Created by Michael Abir on 2/27/22.
//

import SwiftUI
import MapKit
import Combine

class NewRecipeDetailViewController: StarsRatingViewController {
    private var cancellables: Set<AnyCancellable> = Set()
    let backendController: RecipeBackendController
    @Published var rating: Double
    @Published var recipeMeta: RecipeMeta
    @Published var forkInfo: ForkInfoModel?
    @Published var showFork: Bool = false
    var forkViewController: RecipeDetailViewController?
    var forkRecipeMeta: RecipeMeta?
    
    @State var coordinateRegion: MKCoordinateRegion
    @Published var showMap: Bool = false
    
    @Published var locationName: String = ""
    
    @Published var hasSpecialTool: [Bool]
    @Published var completedStep: [Bool]

    func mapPressed() {
        self.showMap = true
    }
    
    func specialToolPressed(_ index: Int) {
        hasSpecialTool[index].toggle()
    }
    
    func stepPressed(_ index: Int) {
        completedStep[index].toggle()
    }
    
    init(recipeMeta: RecipeMeta, backendController: RecipeBackendController) {
        self.recipeMeta = recipeMeta
        self.backendController = backendController
        self.rating = recipeMeta.rating
        let center = recipeMeta.recipe.coordinate()
        self.coordinateRegion = MKCoordinateRegion(center: center ?? CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        hasSpecialTool = [Bool](repeating: false, count: recipeMeta.recipe.specialTools.count)
        completedStep = [Bool](repeating: false, count: recipeMeta.recipe.steps.count)

        
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
    }
    
    func getForkInfo() {
        backendController.getForkInfo(recipe_id: recipeMeta.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { forkInfo in
                self.forkInfo = forkInfo
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
    
    func favoriteRecipe() {
        backendController.favoriteRecipe(recipe_id: recipeMeta.id)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                
            })
            .store(in: &cancellables)
    }
    
    func unfavoriteRecipe() {
        backendController.unfavoriteRecipe(recipe_id: recipeMeta.id)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                
            })
            .store(in: &cancellables)
    }
    
    func presentFork() {
        if let forkInfo = forkInfo {
            backendController.getRecipeById(recipe_id: forkInfo.parent_id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { forkRecipe in
                    self.forkRecipeMeta = forkRecipe
                    self.forkViewController = RecipeDetailViewController(recipeMeta: forkRecipe, backendController: self.backendController)
                    self.showFork = true
                })
                .store(in: &cancellables)
            
        }
    }
}

struct NewRecipeDetail: View {
    @ObservedObject var viewController: NewRecipeDetailViewController
    
    @AppStorage("groceryLists") var groceries: [GroceryList] = []
    
    let navbarHeight: CGFloat
    let initialOffset: CGFloat
    
    @State private var navbarOpacity: CGFloat = 0.0
    @State private var showNavBar: Bool = false
    @State private var showEditRecipe: Bool = false
    @State var currentServings: Int?
    
    @State var groceriesAdded = false
    
    @Environment(\.presentationMode) var presentation
    
    init(_ viewController: NewRecipeDetailViewController) {
        self.viewController = viewController
        
        navbarHeight = 100
        initialOffset = -navbarHeight
    }
    
    @State var scroll: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.background
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    header(offset: scroll)
                    
                    forkButtonSection
                    
                    if let location = viewController.recipeMeta.recipe
                        .coordinate() {
                        mapViewSection(location)
                            .padding(.top)
                    }
                    
                    if !viewController.recipeMeta.recipe.specialTools.isEmpty {
                        specialToolsSection
                    }
                    
                    ingredientsSection
                    
                    methodSection
                    
                    if !viewController.recipeMeta.recipe.tags.isEmpty {
                        tagSection
                    }
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .opacity(0.0)
                }
                .readScroll { scroll in
                    self.scroll = scroll + 97
                    self.showNavBar = self.scroll <= -197 - 15
                }
                .offset(y: -100)
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            navigationBar
        }
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            groceriesAdded = groceries.firstIndex(where: { $0.id == viewController.recipeMeta.id }) != nil
        }
    }
}

extension NewRecipeDetail {
    @ViewBuilder
    private func header(offset: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            CustomAsyncImage(imageId: viewController.recipeMeta.recipe.image, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .scaleEffect(getScaleFromOffset(offset: offset), anchor: .bottom)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(viewController.recipeMeta.recipe.name)
                        .foregroundColor(Color.white)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(viewController.recipeMeta.author)
                        .foregroundColor(Color.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding()
                
                Spacer()
                
                NewStarsRating(viewController: viewController)
                Text(String(viewController.recipeMeta.rating))
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
                .background(.ultraThinMaterial)
                .opacity(getNavbarOpacity(offset: offset))
        )
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .background(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: navbarHeight)
                
                
                Text(viewController.recipeMeta.recipe.emoji)
                    .font(.title)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom))
                    .opacity(showNavBar ? 1.0 : 0.0)
                
            }
            .opacity(showNavBar ? 1.0 : 0.0)
            
            HStack {
                Image(systemName: "chevron.left")
                    .font(Font.title3.weight(.medium))
                    .foregroundColor(Color.theme.light)
                    .colorMultiply(showNavBar ? Color.theme.accent : Color.theme.light)
                
                Text("Back")
                    .foregroundColor(Color.theme.light)
                    .colorMultiply(showNavBar ? Color.theme.accent : Color.theme.light)
                
                Spacer()
            }
            .padding()
            .onTapGesture {
                presentation.wrappedValue.dismiss()
            }
            
            Divider()
                .opacity(showNavBar ? 1.0 : 0.0)
        }
    }
    
    private func getIngredientString(ingredient: Ingredient) -> String {
        var currentQuantity = Double(ingredient.quantity) ?? 0
        if let currentServings = currentServings {
            currentQuantity = currentQuantity / Double(viewController.recipeMeta.recipe.servings) * Double(currentServings)
        }
        return ingredient.name + " (" + (currentQuantity > 0 ? String(currentQuantity.truncate(places: 2)) : ingredient.quantity) + " " + ingredient.unit +  ")"
    }
    
    private var specialToolsSection: some View {
        RecipeDetailSection {
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
                    VStack {
                        ForEach (viewController.recipeMeta.recipe.specialTools, id: \.self) { tool in
                            let index = viewController.recipeMeta.recipe.specialTools.firstIndex(of: tool)!
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
            .padding(.horizontal, 30)
            .padding(.vertical)
        }
    }
    
    private var ingredientsSection: some View {
        RecipeDetailSection {
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
                                .foregroundColor((currentServings ?? viewController.recipeMeta.recipe.servings) > 1 ? Color.theme.accent : Color.theme.lightText)
                                .onTapGesture {
                                    if currentServings == nil {
                                        currentServings = viewController.recipeMeta.recipe.servings
                                    }
                                    
                                    if currentServings! > 1 {
                                        currentServings! -= 1
                                    }
                                }
                            
                            Text(String(currentServings ?? viewController.recipeMeta.recipe.servings))
                                .foregroundColor(Color.theme.text)
                                .font(.title2)
                            Image(systemName: "plus")
                                .foregroundColor(Color.theme.accent)
                                .font(.title2)
                                .onTapGesture {
                                    if currentServings == nil {
                                        currentServings = viewController.recipeMeta.recipe.servings
                                    }
                                    
                                    currentServings! += 1
                                }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: groceriesAdded ? "folder.fill.badge.plus" : "folder.badge.plus")
                        .foregroundColor(Color.theme.accent)
                        .font(.title2)
                        .onTapGesture {
                            withAnimation {
                                groceriesAdded.toggle()
                            }
                            
                            if groceriesAdded {
                                groceries.append(GroceryList(id: viewController.recipeMeta.id, name: viewController.recipeMeta.recipe.name, items: []))
                                groceries[groceries.count - 1].items = viewController.recipeMeta.recipe.ingredients.map {
                                    return GroceryListItem(id: viewController.recipeMeta.id + "_" + $0.id, ingredient: getIngredientString(ingredient: $0), check: false)
                                }
                            } else {
                                groceries.removeAll(where: { $0.id == viewController.recipeMeta.id })
                            }
                            
                        }
                }
                
                Divider()
                
                ForEach (viewController.recipeMeta.recipe.ingredients) { ingredient in
                    let index = groceries.reduce([], { $0 + $1.items }).firstIndex(where: { $0.id == (viewController.recipeMeta.id + "_" + ingredient.id) })
                    
                    HStack {
                        Image(systemName: index != nil ? "plus.circle.fill" : "plus.circle")
                            .foregroundColor(Color.theme.accent)
                            .font(.system(size: 24))
                        
                        var currentQuantity = Double(ingredient.quantity) ?? 0
                        if let currentServings = currentServings {
                            let _ = (currentQuantity = currentQuantity / Double(viewController.recipeMeta.recipe.servings) * Double(currentServings))
                        }
                        let ingredientText = (currentQuantity > 0 ? String(currentQuantity.truncate(places: 2)) : ingredient.quantity) + " " + ingredient.unit + " " + ingredient.name
                        Text(ingredientText)
                            .foregroundColor(Color.theme.text)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        if index == nil {
                            groceries[0].items.append(GroceryListItem(id: viewController.recipeMeta.id + "_" + ingredient.id, ingredient: getIngredientString(ingredient: ingredient), check: false))
                        } else if index != nil {
                            for listIndex in 0..<groceries.count {
                                if let itemIndex = groceries[listIndex].items.firstIndex(where: { $0.id == viewController.recipeMeta.id + "_" + ingredient.id }) {
                                    groceries[listIndex].items.remove(at: itemIndex)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding(.bottom)
            .padding(.horizontal, 30)
        }
    }
    
    private var methodSection: some View {
        RecipeDetailSection {
            VStack {
                HStack {
                    Text("Method")
                        .foregroundColor(Color.theme.title3)
                        .font(.title3)
                    Spacer()
                }
                
                Divider()
                    .padding(.bottom)
                
                HStack {
                    VStack {
                        ForEach (viewController.recipeMeta.recipe.steps, id: \.self) { step in
                            let index = viewController.recipeMeta.recipe.steps.firstIndex(of: step)!
                            HStack {
                                Image(systemName: String(index + 1) + ".circle" + (viewController.completedStep[index] ? ".fill" : ""))
                                    .foregroundColor(Color.theme.accent)
                                    .font(.system(size: 24))
                                
                                Text(step)
                                    .strikethrough(viewController.completedStep[index], color: Color.theme.lightText)
                                    .foregroundColor(viewController.completedStep[index] ? Color.theme.lightText : Color.theme.text)
                                    .padding(.vertical, 5)
                            }
                            .onTapGesture {
                                viewController.stepPressed(index)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical)
        }
    }
    
    private var tagSection: some View {
        RecipeDetailSection {
            HStack {
                Spacer()
                
                FlexibleView(
                    data: viewController.recipeMeta.recipe.tags,
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
    
    private var forkButtonSection: some View {
        let editRecipeViewController: EditRecipeViewController = EditRecipeViewController(viewController.backendController as! RecipeBackendController & ImageBackendController, recipe: viewController.recipeMeta.recipe, parent_id: viewController.recipeMeta.id)
        
        return Group {
            NavigationLink(destination: EditRecipeView(viewController: editRecipeViewController), isActive: $showEditRecipe) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            
            RecipeDetailSection {
                HStack {
                    Spacer ()
                    Image(systemName: "fork.knife")
                    Text("Fork This Recipe")
                        .font(.title3)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal, 30)
            }
            .foregroundColor(Color.theme.tint)
            .onTapGesture {
                showEditRecipe = true
            }
        }
    }
    
    
    private func mapView(_ location: CLLocationCoordinate2D) -> some View {
        Map(coordinateRegion: $viewController.coordinateRegion, annotationItems: [Place(id: "", emoji: viewController.recipeMeta.recipe.emoji, coordinate: location)]) { place in
            
            MapAnnotation(coordinate: place.coordinate) {
                
                PlaceAnnotationEmojiView(title: place.emoji)
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewController.recipeMeta.recipe.name)
    }
    
    private func mapViewSection(_ location: CLLocationCoordinate2D) -> some View {
        RecipeDetailSection {
            VStack {
                ZStack {
                    NavigationLink(destination: mapView(location), isActive: $viewController.showMap) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    
                    LocationMapSnapshot(location: location, width: UIScreen.main.bounds.width - 20, height: 200) {
                        Text(viewController.recipeMeta.recipe.emoji)
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
        .onTapGesture {
            viewController.mapPressed()
        }
    }
    
    private func getScaleFromOffset(offset: CGFloat) -> CGFloat {
        if offset > 50 {
            return 1.0 + (offset - 50) / 250
        } else if offset > 100 {
            return 1.2
        }
        
        return 1.0
    }
    
    private func getNavbarOpacity(offset: CGFloat) -> CGFloat {
        if offset < -80 && offset >= -200 {
            return -(offset + 80) / 110
        } else if offset < -200 {
            return 1.0
        }
        
        return 0.0
    }
}

struct NewRecipeDetail_Previews: PreviewProvider {
    static var previews: some View {
        let ingredients: [Ingredient] = [
            Ingredient(id: "0", name: "Test", quantity: "1", unit: "Unit"),
            Ingredient(id: "1", name: "Test", quantity: "2", unit: "Unit"),
            Ingredient(id: "2", name: "Test", quantity: "3", unit: "Unit")
        ]
        let location = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California
        
        let recipe = Recipe(image: "621c33b12cfadc340f1c20bd", name: "Spaghetti", ingredients: ingredients, steps: ["Step 1", "Step 2"], coordinate_lat: location.latitude, coordinate_long: location.longitude, emoji: "🍝", servings: 2, tags: ["vegan", "italian", "pasta", "easy", "t"], time: "25 min", specialTools: ["Tool 1"], parent_id: nil)
        
        let recipeMeta = RecipeMeta(id: "", author: "Micky Abir", user_id: "", recipe: recipe, rating: 4.3, favorited: 82)
        NewRecipeDetail(NewRecipeDetailViewController(recipeMeta: recipeMeta, backendController: BackendController()))
    }
}
