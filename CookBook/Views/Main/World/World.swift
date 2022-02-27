//
//  World.swift
//  CookBook
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
    @State var zoom: CGFloat = 15
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    @ObservedObject var viewController: WorldViewController
    
    @State var displayRecipe = false
    @State var chosenRecipeIndex = 0
    
    @State var lastRegion: MKCoordinateRegion?
    
    var body: some View {
        let places = viewController.recipes.map { Place(id: $0.id, emoji: $0.recipe.emoji, coordinate: $0.recipe.coordinate()!) }
        
        ZStack(alignment: .bottom) {
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
            .onAppear {
                viewController.fetchRecipes(region: region)
            }
            .popover(isPresented: $displayRecipe,content: {
                NavigationView {
                    RecipeDetail(viewController: RecipeDetailViewController(recipeMeta: viewController.recipes[chosenRecipeIndex], backendController: viewController.backendController))
                        .navigationBarItems(leading:
                                                Button(action: {
                            displayRecipe = false
                        }) {
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.theme.accent)
                        })
                }
                
            })
            
            Button {
                viewController.fetchRecipes(region: region)
            } label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.white)
                        .frame(width: 120, height: 40)
                        .cornerRadius(10)
                    Text("Search Here")
                }
            }
            .padding(.bottom)
        }
    }
}
