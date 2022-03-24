//
//  World.swift
//  Resoupie
//
//  Created by Michael Abir on 1/20/22.
//

import SwiftUI
import MapKit
import Combine

class WorldViewController: ObservableObject {
    @Published var recipes: [RecipeMeta] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    let backendController: RecipeBackendController
    
    init(_ backendController: RecipeBackendController) {
        self.backendController = backendController
    }
    
    func fetchRecipes(region: MKCoordinateRegion) {
        backendController.getRecipesWorld(position: region.center, latDelta: region.span.latitudeDelta, longDelta: region.span.longitudeDelta)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.recipes = recipes
            })
            .store(in: &cancellables)
    }
}

struct WorldView: View {
    @StateObject var locationManager = LocationManager()
    
    @State var zoom: CGFloat = 15
    
    //    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 55, longitudeDelta: 60))
    
    @ObservedObject var viewController: WorldViewController
    
    @State var displayRecipe = false
    @State var chosenRecipeIndex: Int? = nil
    
    @State var lastRegion: MKCoordinateRegion?
    
    @State var firstTimeLocation: Bool = true
    
    var body: some View {
        let places = viewController.recipes.map { Place(id: $0.id, emoji: $0.recipe.emoji, coordinate: $0.recipe.coordinate()!) }
        
        NavigationView {
            ZStack(alignment: .bottom) {
                NavigationLink(destination: RecipeDetail(chosenRecipeIndex != nil && chosenRecipeIndex! < viewController.recipes.count ? viewController.recipes[chosenRecipeIndex!] : RecipeMeta.empty, backendController: BackendController()), isActive: $displayRecipe) {
                    EmptyView()
                }
                .opacity(0)
                .frame(width: 0, height: 0)
                
                Map(coordinateRegion: $region, annotationItems: places) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Button {
                            if let index = viewController.recipes.firstIndex(where: { $0.id == place.id }) {
                                chosenRecipeIndex = index
                                displayRecipe = true
                            }
                        } label: {
                            PlaceAnnotationEmojiView(title: place.emoji)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .onChange(of: region) { newRegion in
                    //            viewController.fetchRecipes(region: newRegion)
                }
                
                Button {
                    viewController.fetchRecipes(region: region)
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .frame(width: 140, height: 40)
                            .cornerRadius(10)
                        Text("Search Here")
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 8)
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .onAppear {
            if firstTimeLocation {
                locationManager.requestLocation()
                if let location = locationManager.location {
                    firstTimeLocation = false

                    DispatchQueue.main.async {
                        withAnimation {
                            region.center = location
                            region.span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
                            viewController.fetchRecipes(region: region)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
