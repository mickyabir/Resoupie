//
//  RecipeDetail.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI
import Combine

protocol StarsRatingViewController: ObservableObject {
    var rating: Double { get }
    func rateRecipe(_ rating: Int, continuation: @escaping (Double) -> ())
}

struct StarsRating: View {
    @ObservedObject var viewController: RecipeDetailViewController
    
    @State private var starNames: [String] = [String](repeating: "star", count: 5)
    @State private var starRotations: [Double] = [Double](repeating: 0, count: 5)
    @State private var starIndexAppeared: [Bool] = [Bool](repeating: false, count: 5)

    init(viewController: RecipeDetailViewController) {
        self.viewController = viewController
    }
    
    func rateRecipe(_ rating: Int) {
        viewController.rateRecipe(rating) { newRating in
            let halfStar = newRating.truncatingRemainder(dividingBy: 1) > 0.3
            for index in 0..<5 {
                if index < Int(floor(viewController.rating)) {
                    starNames[index] = "star.fill"
                } else if index == Int(floor(viewController.rating)) && halfStar {
                    starNames[index] = "star.leadinghalf.fill"
                } else {
                    starNames[index] = "star"
                }

                starRotations[index] = 0
            }
        }
    }
    
    var body: some View {
        let halfStar = viewController.rating.truncatingRemainder(dividingBy: 1) > 0.3

        ForEach(0..<5) { index in
            if index < Int(floor(viewController.rating)) {
                Image(systemName: starNames[index])
                    .foregroundColor(Color.yellow)
                    .rotation3DEffect(.degrees(starRotations[index]), axis: (x: 0, y: 1, z: 0))
                    .onTapGesture {
                        rateRecipe(index + 1)
                    }
                    .onAppear {
                        if !starIndexAppeared[index] {
                            starIndexAppeared[index] = true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 + Double(index) * 0.2) {
                                withAnimation(.linear(duration: 1.0)) {
                                    starRotations[index] = 180
                                }
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                    withAnimation(.linear(duration: 0.5)) {
                                        starNames[index] = "star.fill"
                                    }
                                }
                            }
                        }
                    }
            } else if index == Int(floor(viewController.rating)) && halfStar {
                Image(systemName: starNames[index])
                    .foregroundColor(Color.yellow)
                    .rotation3DEffect(.degrees(starRotations[index]), axis: (x: 0, y: 1, z: 0))
                    .onTapGesture {
                        rateRecipe(index + 1)
                    }
                    .onAppear {
                        if !starIndexAppeared[index] {
                            starIndexAppeared[index] = true
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 + Double(index) * 0.2) {
                                withAnimation(.linear(duration: 1.0)) {
                                    starRotations[index] = 360
                                }
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                    withAnimation(.linear(duration: 0.5)) {
                                        starNames[index] = "star.leadinghalf.fill"
                                    }
                                }
                            }
                        }
                    }

            } else {
                Image(systemName: "star")
                    .foregroundColor(Color.yellow)
                    .onTapGesture {
                        rateRecipe(index + 1)
                    }
                    .onAppear {
                        if !starIndexAppeared[index] {
                            starIndexAppeared[index] = true
                        }
                    }
            }
        }
    }
}

class RecipeDetailViewController: StarsRatingViewController {
    private var cancellables: Set<AnyCancellable> = Set()
    let backendController: RecipeBackendController
    @Published var rating: Double
    @Published var recipeMeta: RecipeMeta
    @Published var forkInfo: ForkInfoModel?
    @Published var showFork: Bool = false
    var forkViewController: RecipeDetailViewController?
    var forkRecipeMeta: RecipeMeta?
    
    init(recipeMeta: RecipeMeta, backendController: RecipeBackendController) {
        self.recipeMeta = recipeMeta
        self.backendController = backendController
        self.rating = recipeMeta.rating
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

struct RecipeDetail: View {
    @State private var favorited: Bool = false
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    @AppStorage("groceryLists") var groceries: [GroceryList] = []
    
    @State var groceriesAdded = false
    
    @State var showLargeImage = false
    
    @State var currentServings: Int?
    @State var xOff: CGFloat = 0.0
    @State var yOff: CGFloat = 0.0
    @State var lastXOff: CGFloat = 0.0
    @State var lastYOff: CGFloat = 0.0
    @State var scale: CGFloat = 1.0
    @State var lastScaleValue: CGFloat = 1.0
    
    @ObservedObject var viewController: RecipeDetailViewController
    
    @State var showEditRecipe: Bool = false
    
    @State var showAuthorProfile: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationLink(destination: ProfileView(viewController: ProfileViewController(viewController.backendController, name: viewController.recipeMeta.author, user_id: viewController.recipeMeta.user_id)), isActive: $showAuthorProfile) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            .onTapGesture {
            }

            
            Color.theme.background
            
            List {
                VStack(spacing: 10) {
                    if let fork = viewController.forkInfo {
                        NavigationLink(destination: RecipeDetail(viewController: viewController.forkViewController ?? viewController), isActive: $viewController.showFork) {
                            EmptyView()
                        }
                        .frame(width: 0, height: 0)
                        .opacity(0)
                        
                        HStack(spacing: 0) {
                            Image(systemName: "fork.knife")
                                .foregroundColor(Color.theme.lightText)
                            Text(" from " + fork.parent_author + "'s ")
                                .foregroundColor(Color.theme.lightText)
                            Text(fork.parent_name)
                                .foregroundColor(Color.theme.accent)
                        }
                        .padding(.bottom)
                        .onTapGesture {
                            viewController.presentFork()
                        }
                    }
                    
                    CustomAsyncImage(imageId: viewController.recipeMeta.recipe.image, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.width - 40)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                showLargeImage = true
                            }
                        }
                    
                    starsRating
                    
                    forkRecipeButton
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                if !viewController.recipeMeta.recipe.specialTools.isEmpty {
                    specialToolsSection
                }
                
                ingredientSection
                
                methodSection
                
                if !viewController.recipeMeta.recipe.tags.isEmpty {
                    tagsSection
                }
            }
            .onAppear {
                if favorites.firstIndex(where: {$0.id == viewController.recipeMeta.id}) != nil {
                    favorited = true
                } else {
                    favorited = false
                }
                
                groceriesAdded = groceries.firstIndex(where: { $0.id == viewController.recipeMeta.id }) != nil
                
                viewController.getForkInfo()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(viewController.recipeMeta.recipe.name).font(.headline).foregroundColor(Color.theme.navbarTitle)
                        Text(viewController.recipeMeta.author).font(.subheadline).foregroundColor(Color.theme.lightText)
                            .onTapGesture {
                                showAuthorProfile = true
                            }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        favorited.toggle()
                        
                        if favorited {
                            if favorites.firstIndex(where: {$0.id == viewController.recipeMeta.id }) == nil {
                                favorites.append(viewController.recipeMeta)
                            }
                            viewController.favoriteRecipe()
                        } else {
                            if let offset = favorites.firstIndex(where: {$0.id == viewController.recipeMeta.id}) {
                                favorites.remove(at: offset)
                            }
                            viewController.unfavoriteRecipe()
                        }
                    }) {
                        Image(systemName: favorited ? "heart.fill" : "heart")
                            .foregroundColor(Color.red)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
            expandImage
            
        }
    }
}

extension RecipeDetail {
    private var forkRecipeButton: some View {
        let editRecipeViewController: EditRecipeViewController = EditRecipeViewController(viewController.backendController as! RecipeBackendController & ImageBackendController, recipe: viewController.recipeMeta.recipe, parent_id: viewController.recipeMeta.id)
        
        return Group {
            NavigationLink(destination: EditRecipeView(viewController: editRecipeViewController), isActive: $showEditRecipe) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            .onTapGesture {
            }
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
                    .frame(width: 190, height: 40)
                
                HStack {
                    Text("Fork This Recipe")
                    Image(systemName: "fork.knife")
                }
                .foregroundColor(Color.theme.accent)
                .font(.headline)

            }
            .padding(.bottom)
            .onTapGesture {
                showEditRecipe = true
            }
        }
    }
    private var expandImage: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(showLargeImage ? 0.7 : 0.0)
            
            CustomAsyncImage(imageId: viewController.recipeMeta.recipe.image, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                .opacity(showLargeImage ? 1.0 : 0.0)
                .offset(x: xOff / self.scale, y: 60 + yOff / self.scale)
                .scaleEffect(self.scale)
                .gesture(MagnificationGesture().onChanged { val in
                    let delta = val / self.lastScaleValue
                    self.lastScaleValue = val
                    let newScale = max(1, self.scale * delta)
                    self.scale = newScale
                }.onEnded { val in
                    self.lastScaleValue = 1.0
                })
                .simultaneousGesture(DragGesture().onChanged { val in
                    self.xOff = val.translation.width + self.lastXOff
                    self.yOff = val.translation.height + self.lastYOff
                }.onEnded { _ in
                    self.lastXOff = self.xOff
                    self.lastYOff = self.yOff
                })
        }
        .onTapGesture {
            withAnimation {
                showLargeImage = false
                xOff = 0
                yOff = 0
                lastXOff = 0
                lastYOff = 0
                scale = 1.0
            }
        }
    }
    private var starsRating: some View {
        HStack {
            Spacer()
            
            StarsRating(viewController: viewController)
            
            Text(String(viewController.recipeMeta.rating))
                .foregroundColor(Color.theme.lightText)
            
            Spacer()
        }
    }
    private var specialToolsSection: some View {
        Section(header: HStack {
            Text("Special Tools").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)
        }) {
            ForEach(viewController.recipeMeta.recipe.specialTools.indices, id: \.self) { index in
                Text(viewController.recipeMeta.recipe.specialTools[index])
                    .foregroundColor(Color.theme.text)
            }
        }
        .textCase(nil)
    }
    private var ingredientSection: some View {
        Section(header:
                    HStack {
            Text("Ingredients")
                .foregroundColor(Color.theme.title)
                .font(.title2).fontWeight(.semibold)
            
            Spacer()
            
            VStack {
                Text("Servings")
                    .foregroundColor(Color.theme.lightText)
                    .font(.system(size: 14))
                    .font(.title2).fontWeight(.semibold)
                
                HStack {
                    Image(systemName: "minus")
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
                        .foregroundColor(Color.theme.lightText)
                        .font(.title2).fontWeight(.semibold)
                    
                    Image(systemName: "plus")
                        .foregroundColor(Color.theme.accent)
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
                .font(.title2)
                .padding(.trailing, 20)
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    withAnimation {
                        groceriesAdded.toggle()
                    }
                    
                    if groceriesAdded {
                        groceries.append(GroceryList(id: viewController.recipeMeta.id, name: viewController.recipeMeta.recipe.name, items: []))
                        groceries[groceries.count - 1].items = viewController.recipeMeta.recipe.ingredients.map { GroceryListItem(id: viewController.recipeMeta.id + "_" + $0.id, ingredient: $0.name + " (" + $0.quantity + " " + $0.unit +  ")", check: false)}
                    } else {
                        groceries.removeAll(where: { $0.id == viewController.recipeMeta.id })
                    }
                    
                }
        }) {
            ForEach (viewController.recipeMeta.recipe.ingredients) { ingredient in
                HStack {
                    let index = groceries.reduce([], { $0 + $1.items }).firstIndex(where: { $0.id == (viewController.recipeMeta.id + "_" + ingredient.id) })
                    
                    Image(systemName: index != nil ? "plus.circle.fill" : "plus.circle")
                        .onTapGesture {
                            if index == nil {
                                var currentQuantity = Double(ingredient.quantity) ?? 0
                                if let currentServings = currentServings {
                                    currentQuantity = currentQuantity / Double(viewController.recipeMeta.recipe.servings) * Double(currentServings)
                                }
                                let ingredientString = ingredient.name + " (" + (currentQuantity > 0 ? String(currentQuantity.truncate(places: 2)) : ingredient.quantity) + " " + ingredient.unit +  ")"
                                groceries[0].items.append(GroceryListItem(id: viewController.recipeMeta.id + "_" + ingredient.id, ingredient: ingredientString, check: false))
                            } else if index != nil {
                                for listIndex in 0..<groceries.count {
                                    if let itemIndex = groceries[listIndex].items.firstIndex(where: { $0.id == viewController.recipeMeta.id + "_" + ingredient.id }) {
                                        groceries[listIndex].items.remove(at: itemIndex)
                                    }
                                }
                            }
                        }
                        .foregroundColor(Color.theme.accent)
                        .font(.system(size: 18))
                    
                    var currentQuantity = Double(ingredient.quantity) ?? 0
                    if let currentServings = currentServings {
                        let _ = (currentQuantity = currentQuantity / Double(viewController.recipeMeta.recipe.servings) * Double(currentServings))
                    }
                    let ingredientText = (currentQuantity > 0 ? String(currentQuantity.truncate(places: 2)) : ingredient.quantity) + " " + ingredient.unit + " " + ingredient.name
                    Text(ingredientText)
                        .foregroundColor(Color.theme.text)
                }
                .padding(.vertical, 5)
            }
        }
        .textCase(nil)
    }
    
    private var methodSection: some View {
        Section(header: Text("Method").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)) {
            ForEach (viewController.recipeMeta.recipe.steps, id: \.self) { step in
                let index = viewController.recipeMeta.recipe.steps.firstIndex(of: step)!
                HStack {
                    Image(systemName: String(index + 1) + ".circle.fill")
                        .foregroundColor(Color.theme.accent)
                        .font(.system(size: 24))
                    
                    Text(step)
                        .foregroundColor(Color.theme.text)
                        .padding(.vertical, 5)
                }
            }
        }
        .textCase(nil)
    }
    private var tagsSection: some View {
        Section(header: Text("Tags").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)) {
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
        }
        .textCase(nil)
    }
}
