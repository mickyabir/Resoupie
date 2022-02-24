//
//  RecipeDetail.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI
import Combine

class RecipeDetailViewController: ObservableObject {
    private var cancellables: Set<AnyCancellable> = Set()
    let backendController: RecipeBackendController
    @Published var recipeMeta: RecipeMeta
    @Published var stars: [Int] = []
    @Published var halfStar: Bool = false
    @Published var emptyStars: [Int] = []
    @Published var forkInfo: ForkInfoModel?
    @Published var showFork: Bool = false
    var forkViewController: RecipeDetailViewController?
    var forkRecipeMeta: RecipeMeta? 
        
    init(recipeMeta: RecipeMeta, backendController: RecipeBackendController) {
        self.recipeMeta = recipeMeta
        self.backendController = backendController
        self.stars = Array(0..<Int(floor(recipeMeta.rating)))
        self.halfStar = recipeMeta.rating.truncatingRemainder(dividingBy: 1) > 0.3
        let emptyCount = 5 - Int(floor(recipeMeta.rating)) - (self.halfStar ? 1 : 0)
        self.emptyStars = Array(0..<emptyCount)
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
    
    func rateRecipe(_ rating: Int) {
        backendController.rateRecipe(recipe_id: recipeMeta.id, rating: rating)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { newRating in
                self.recipeMeta.rating = newRating
                self.stars = Array(0..<Int(floor(newRating)))
                self.halfStar = newRating.truncatingRemainder(dividingBy: 1) > 0.3
                let emptyCount = 5 - Int(floor(newRating)) - (self.halfStar ? 1 : 0)
                self.emptyStars = Array(0..<emptyCount)

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
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.background
            
            List {
                VStack(spacing: 10) {
                    if let fork = viewController.forkInfo {
                        if viewController.showFork {
                            NavigationLink(destination: RecipeDetail(viewController: viewController.forkViewController!), isActive: $viewController.showFork) {
                                EmptyView()
                            }
                            .frame(width: 0, height: 0)
                            .opacity(0)
                        }
                        HStack(spacing: 0) {
                            Text("Forked from " + fork.parent_author + "'s ")
                                .foregroundColor(Color.lightText)
                            Text(fork.parent_name)
                                .foregroundColor(Color.orange)
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
                    
                    HStack {
                        Spacer()
                        
                        ForEach(viewController.stars, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.yellow)
                                .onTapGesture {
                                    let rating = index + 1
                                    viewController.rateRecipe(rating)
                                }
                        }
                        
                        if viewController.halfStar {
                            Image(systemName: "star.leadinghalf.filled")
                                .foregroundColor(Color.yellow)
                                .onTapGesture {
                                    let rating = viewController.stars.count + 1
                                    viewController.rateRecipe(rating)
                                }
                        }
                        
                        ForEach(viewController.emptyStars, id: \.self) { index in
                            Image(systemName: "star")
                                .foregroundColor(Color.yellow)
                                .onTapGesture {
                                    let rating = viewController.stars.count + (viewController.halfStar ? 1 : 0) + index + 1
                                    viewController.rateRecipe(rating)
                                }
                        }
                        
                        Text(String(viewController.recipeMeta.rating))
                            .foregroundColor(Color.lightText)
                        
                        Spacer()
                    }
                    let editRecipeViewController: EditRecipeViewController = EditRecipeViewController(viewController.backendController as! RecipeBackendController & ImageBackendController, recipe: viewController.recipeMeta.recipe, parent_id: viewController.recipeMeta.id)
                    
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
                            .cornerRadius(10)
                            .frame(width: 180, height: 40)
                        
                        Text("Fork This Recipe")
                            .foregroundColor(Color.orange)
                            .font(.title3)
                    }
                    .onTapGesture {
                        showEditRecipe = true
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                if !viewController.recipeMeta.recipe.specialTools.isEmpty {
                    Section(header: HStack {
                        Text("Special Tools").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)
                    }) {
                        ForEach(viewController.recipeMeta.recipe.specialTools.indices, id: \.self) { index in
                            Text(viewController.recipeMeta.recipe.specialTools[index])
                                .foregroundColor(Color.text)
                        }
                    }
                    .textCase(nil)
                }
                
                Section(header:
                            HStack {
                    Text("Ingredients")
                        .foregroundColor(Color.title)
                        .font(.title2).fontWeight(.semibold)
                    
                    Spacer()
                    
                    VStack {
                        Text("Servings")
                            .foregroundColor(Color.lightText)
                            .font(.system(size: 14))
                            .font(.title2).fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "minus")
                                .foregroundColor((currentServings ?? viewController.recipeMeta.recipe.servings) > 1 ? Color.orange : Color.lightText)
                                .onTapGesture {
                                    if currentServings == nil {
                                        currentServings = viewController.recipeMeta.recipe.servings
                                    }
                                    
                                    if currentServings! > 1 {
                                        currentServings! -= 1
                                    }
                                    
                                }
                            
                            Text(String(currentServings ?? viewController.recipeMeta.recipe.servings))
                                .foregroundColor(Color.lightText)
                                .font(.title2).fontWeight(.semibold)
                            
                            Image(systemName: "plus")
                                .foregroundColor(Color.orange)
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
                        .foregroundColor(Color.orange)
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
                                        let ingredientString = ingredient.name + " (" + (currentQuantity > 0 ? String(currentQuantity) : ingredient.quantity) + " " + ingredient.unit +  ")"
                                        groceries[0].items.append(GroceryListItem(id: viewController.recipeMeta.id + "_" + ingredient.id, ingredient: ingredientString, check: false))
                                    } else if index != nil {
                                        for listIndex in 0..<groceries.count {
                                            if let itemIndex = groceries[listIndex].items.firstIndex(where: { $0.id == viewController.recipeMeta.id + "_" + ingredient.id }) {
                                                groceries[listIndex].items.remove(at: itemIndex)
                                            }
                                        }
                                    }
                                }
                                .foregroundColor(Color.orange)
                                .font(.system(size: 18))
                            
                            var currentQuantity = Double(ingredient.quantity) ?? 0
                            if let currentServings = currentServings {
                                let _ = (currentQuantity = currentQuantity / Double(viewController.recipeMeta.recipe.servings) * Double(currentServings))
                            }
                            let ingredientText = (currentQuantity > 0 ? String(currentQuantity) : ingredient.quantity) + " " + ingredient.unit + " " + ingredient.name
                            Text(ingredientText)
                                .foregroundColor(Color.text)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .textCase(nil)
                
                Section(header: Text("Method").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)) {
                    ForEach (viewController.recipeMeta.recipe.steps, id: \.self) { step in
                        let index = viewController.recipeMeta.recipe.steps.firstIndex(of: step)!
                        HStack {
                            Image(systemName: String(index + 1) + ".circle.fill")
                                .foregroundColor(Color.orange)
                                .font(.system(size: 24))
                            
                            Text(step)
                                .foregroundColor(Color.text)
                                .padding(.vertical, 5)
                        }
                    }
                }
                .textCase(nil)
                
                if !viewController.recipeMeta.recipe.tags.isEmpty {
                    Section(header: Text("Tags").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)) {
                        FlexibleView(
                            data: viewController.recipeMeta.recipe.tags,
                            spacing: 15,
                            alignment: .leading
                        ) { item in
                            HStack {
                                Text(verbatim: item)
                                    .foregroundColor(Color.text)
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
                        Text(viewController.recipeMeta.recipe.name).font(.headline).foregroundColor(Color.navbarTitle)
                        Text(viewController.recipeMeta.author).font(.subheadline).foregroundColor(Color.lightText)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
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
            })
            
            Group {
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
        .accentColor(Color.orange)
    }
}
