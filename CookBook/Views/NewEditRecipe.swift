
//  NewEditRecipe.swift
//  CookBook
//
//  Created by Michael Abir on 3/4/22.
//

import SwiftUI
import MapKit
import Combine

class NewEditRecipeViewController: ObservableObject {
    @Environment(\.presentationMode) var presentationMode
    
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
    
    func publishRecipe(_ recipe: Recipe, image: UIImage) {
        if recipe.name == "" || recipe.ingredients.isEmpty || recipe.steps.isEmpty {
            return
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
                self.presentationMode.wrappedValue.dismiss()
            })
            .store(in: &cancellables)
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

struct NewEditRecipeView: View {
    @StateObject var viewController = NewEditRecipeViewController(BackendController())
    
    let recipe: Recipe
    let parent_id: String?
    
    @State var title: String = ""
    @State var servings: Int?
    @State var time: String = ""
    @State var emoji: String = ""
    @State var about: String = ""
    
    @State var image: UIImage?
    @State var locationEnabled: Bool = false
    
    init(_ recipe: Recipe?, parent_id: String? = nil) {
        self.recipe = recipe ?? Recipe.empty
        self.parent_id = parent_id
        
        if let recipe = recipe {
            title = recipe.name
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                RecipeDetailSectionInset {
                    VStack(spacing: 20) {
                        HStack {
                            Text("About This Recipe")
                                .foregroundColor(Color.theme.title)
                                .font(.title3)
                            Spacer()
                        }
                        
                        Divider()
                        
                        TextField("Name", text: $title)
                            .foregroundColor(Color.theme.text)
                        
                        TextField("Servings", value: $servings, formatter: NumberFormatter())
                            .foregroundColor(Color.theme.text)
                            .keyboardType(.numberPad)
                        
                        TextField("Time", text: $time)
                            .foregroundColor(Color.theme.text)
                            .keyboardType(.numberPad)
                        
                        TextField("Emoji", text: $emoji)
                            .foregroundColor(Color.theme.text)
                            .keyboardType(.numberPad)
                        
                        Divider()
                        
                        aboutEditorSection
                    }
                }
                
                locationSection
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(Color.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let image = image {
                        viewController.publishRecipe(recipe, image: image)
                    }
                } label: {
                    Text("Publish")
                }
            }
        }
        .onAppear {
            viewController.checkLocation()
        }
    }
}

extension NewEditRecipeView {
    private var aboutEditorSection: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $about)
            
            if about.isEmpty {
                Text("What makes this recipe special")
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 9)
                    .allowsHitTesting(false)
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
                
                NavigationLink(destination: CoordinatePicker(viewModel: viewController.coordinatePickerViewModel)) {
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
                                Text("Choose Location")
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
}

struct NewEditRecipe_Previews: PreviewProvider {
    static var previews: some View {
        let recipe = Recipe.empty.childOf(parent_id: "Parent!")
        NavigationView {
            NewEditRecipeView(recipe)
        }
    }
}
