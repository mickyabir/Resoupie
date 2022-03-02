//
//  NewRecipeDetail.swift
//  CookBook
//
//  Created by Michael Abir on 2/27/22.
//

import SwiftUI
import MapKit
import Combine

class RecipeDetailScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct RecipeDetailChildPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct VerticalScrollView<Content: View>: View {
    let content: (CGFloat) -> Content
    
    let offset: CGFloat
    
    @State private var _offset: CGFloat = 0
    @State private var _lastOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    init(offset: CGFloat = 0, @ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.offset = offset
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(
                    Rectangle()
                )
                .edgesIgnoringSafeArea(.all)
            
            content(_offset)
                .offset(y: _offset + offset + (contentHeight - UIScreen.main.bounds.height) / 2 - 10)
                .readSize { size in
                    DispatchQueue.main.async {
                        contentHeight = size.height
                    }
                }

        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation(.spring()) {
                        _offset = min(-offset, _lastOffset + gesture.translation.height)
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        _offset = min(0, _offset)
                        _lastOffset = _offset
                    }
                }
        )
        
    }
}

struct NewStarsRating: View {
    @ObservedObject var viewController: NewRecipeDetailViewController
    
    @State private var starNames: [String] = [String](repeating: "star", count: 5)
    @State private var starRotations: [Double] = [Double](repeating: 0, count: 5)
    @State private var starIndexAppeared: [Bool] = [Bool](repeating: false, count: 5)
    
    init(viewController: NewRecipeDetailViewController) {
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
    
    func mapPressed() {
        self.showMap = true
    }
    
    init(recipeMeta: RecipeMeta, backendController: RecipeBackendController) {
        self.recipeMeta = recipeMeta
        self.backendController = backendController
        self.rating = recipeMeta.rating
        let center = recipeMeta.recipe.coordinate()
        self.coordinateRegion = MKCoordinateRegion(center: center ?? CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
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
    
    let navbarHeight: CGFloat
    let initialOffset: CGFloat
    
    @State private var navbarOpacity: CGFloat = 0.0
    @State private var showEmoji: Bool = false
    @State private var showNavBar: Bool = false
    
    @State private var showEditRecipe: Bool = false
    
    @Environment(\.presentationMode) var presentation
    
    
    init(_ viewController: NewRecipeDetailViewController) {
        self.viewController = viewController
        
        navbarHeight = 100
        initialOffset = -navbarHeight
    }
    
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
        VStack() {
            HStack {
                Text(viewController.locationName)
                    .foregroundColor(Color.theme.lightText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.theme.lightText)
            }
            .padding(.horizontal, 30)
            
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
        }
        .padding(.vertical)
        .background(
            Rectangle()
                .foregroundColor(Color.white)
                .frame(width: UIScreen.main.bounds.width - 20)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
        .onTapGesture {
            viewController.mapPressed()
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
            
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(Color.theme.light)
                    .cornerRadius(12)
                
                HStack {
                    Spacer ()
                    Text("Fork This Recipe")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal, 20)
                .foregroundColor(Color.theme.tint)
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .onTapGesture {
                showEditRecipe = true
            }
            .shadow(color: Color.black.opacity(0.1), radius: 10)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.theme.background
                
                VerticalScrollView(offset: initialOffset) { offset in
                    VStack {
                        header(offset: offset)
                        
                        forkButtonSection
                        forkButtonSection
                        forkButtonSection
                        forkButtonSection
                        forkButtonSection
                        forkButtonSection

                        if let location = viewController.recipeMeta.recipe
                            .coordinate() {
                            mapViewSection(location)
                        }
                    }
                    .preference(key: RecipeDetailScrollPreferenceKey.self, value: offset)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .onPreferenceChange(RecipeDetailScrollPreferenceKey.self, perform: { offset in
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            self.showEmoji = offset < -120
                        }
                        
                        withAnimation(.spring()) {
                            showNavBar = offset < -120
                        }
                        
                        print(offset)
                    }
                })
                
                
                navigationBar
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarHidden(true)
    }
}

extension NewRecipeDetail {
    private var navigationBar: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .background(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: navbarHeight)
                
                
                Text(viewController.recipeMeta.recipe.emoji)
                    .font(.title)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom))
                    .opacity(showEmoji ? 1.0 : 0.0)
                
            }
            .opacity(showNavBar ? 1.0 : 0.0)
            
            HStack {
                Image(systemName: "chevron.left")
                    .font(Font.title3.weight(.semibold))
                    .foregroundColor(Color.theme.light)
                    .colorMultiply(showNavBar ? Color.theme.accent : Color.theme.light)
                    .onTapGesture {
                        presentation.wrappedValue.dismiss()
                    }
                    .padding()
                
                Spacer()
            }
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
            
        ]
        let location = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California
        
        let recipe = Recipe(image: "621c33b12cfadc340f1c20bd", name: "Spaghetti", ingredients: ingredients, steps: ["Step 1", "Step 2"], coordinate_lat: location.latitude, coordinate_long: location.longitude, emoji: "🍝", servings: 2, tags: ["vegan", "italian"], time: "25 min", specialTools: ["Tool 1"], parent_id: nil)
        
//        let recipe = Recipe(image: "621c33b12cfadc340f1c20bd", name: "Spaghetti", ingredients: ingredients, steps: ["Step 1", "Step 2"], coordinate_lat: location.latitude, coordinate_long: nil, emoji: "🍝", servings: 2, tags: ["vegan", "italian"], time: "25 min", specialTools: ["Tool 1"], parent_id: nil)

        
        let recipeMeta = RecipeMeta(id: "", author: "Micky Abir", user_id: "", recipe: recipe, rating: 4.3, favorited: 82)
        NewRecipeDetail(NewRecipeDetailViewController(recipeMeta: recipeMeta, backendController: BackendController()))
    }
}
