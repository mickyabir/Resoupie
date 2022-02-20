//
//  World.swift
//  CookBook
//
//  Created by Michael Abir on 1/20/22.
//

import SwiftUI
import MapKit

struct Place: Identifiable {
    var id: String
    var emoji: String
    var coordinate: CLLocationCoordinate2D
}

struct PlaceAnnotationEmojiView: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 40))
    }
}

class WorldViewModel: ObservableObject {
    @Published var recipes: [RecipeMeta] = []
    
    func loadRecipes() {
//        let backendController = RecipeBackendController()
//        let _ = backendController.loadAllRecipes { allRecipes in
//            self.recipes = allRecipes
//        }
    }
    
    func fetchRecipes(region: MKCoordinateRegion) {
        loadRecipes()
        
        recipes = recipes
            .filter({
                $0.recipe.coordinate != nil
            })
        
        for recipe_i in recipes {
            for recipe_j in recipes {
                if recipe_i == recipe_j {
                    continue
                }
                
                if abs(recipe_i.recipe.coordinate!.latitude - recipe_j.recipe.coordinate!.latitude) < region.span.latitudeDelta * 0.02 && abs(recipe_i.recipe.coordinate!.longitude - recipe_j.recipe.coordinate!.longitude) < region.span.longitudeDelta * 0.02 {
                    if recipe_i.favorited >= recipe_j.favorited {
                        if let index = recipes.firstIndex(of: recipe_j) {
                            recipes.remove(at: index)
                        }
                    } else {
                        if let index = recipes.firstIndex(of: recipe_i) {
                            recipes.remove(at: index)
                        }
                    }
                }
            }
            
            recipes = recipes.filter({
                $0.recipe.coordinate!.latitude > region.center.latitude - region.span.latitudeDelta &&
                $0.recipe.coordinate!.latitude < region.center.latitude + region.span.latitudeDelta &&
                $0.recipe.coordinate!.longitude > region.center.longitude - region.span.longitudeDelta &&
                $0.recipe.coordinate!.longitude < region.center.longitude + region.span.longitudeDelta
            })
        }
    }
}

struct WorldView: View {
    @State var zoom: CGFloat = 15
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    @ObservedObject var viewModel = WorldViewModel()
    
    @State var displayRecipe = false
    @State var chosenRecipeIndex = 0
    
    
    var body: some View {
        let places = viewModel.recipes.filter {
            $0.recipe.coordinate != nil
        } .map {
            Place(id: $0.id, emoji: $0.recipe.emoji, coordinate: $0.recipe.coordinate!)
        }
        
        Map(coordinateRegion: $region, annotationItems: places) { place in
            MapAnnotation(coordinate: place.coordinate) {
                Button {
                    if let index = viewModel.recipes.firstIndex(where: { $0.id == place.id }) {
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
            viewModel.fetchRecipes(region: newRegion)
        }
        .onAppear {
            viewModel.fetchRecipes(region: region)
        }
        .sheet(isPresented: $displayRecipe, onDismiss: {
//            self.chosenRecipe = nil
        }, content: {
//            RecipeDetail(recipeMeta: viewModel.recipes[chosenRecipeIndex], image: Image())
        })
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta && lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
    }
}

struct World_Previews: PreviewProvider {
    static var previews: some View {
        WorldView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
