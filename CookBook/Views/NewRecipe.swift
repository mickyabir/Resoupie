//
//  NewRecipe.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI
import PhotosUI
import Combine

struct NewRecipeRow<Content: View>: View {
    let content: Content
    let heading: String?
    
    init(_ heading: String? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.heading = heading
    }
    var body: some View {
        VStack(spacing: 20) {
            if heading != nil {
                Text(heading!)
                    .font(.title2)
            }
            content
        }
        .frame(minHeight: 100)
    }
}

struct NewRecipeRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.orange)
            .frame(height: 1)
            .edgesIgnoringSafeArea(.horizontal)
        
    }
}

class NewRecipeViewController: ObservableObject {
    typealias NewRecipeBackendController = RecipeBackendController & ImageBackendController

    @Published var name: String = ""
    @Published var emoji: String = ""
    @Published var ingredients: [Ingredient] = []
    @Published var steps: [String] = []
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var image: UIImage?
    @Published var servings: String = ""
    @Published var tags: [String] = []
    @Published var time: String = ""
    @Published var specialTools: [String] = []
    @Published var showEmptyRecipeWarning = false
    
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    let backendController: NewRecipeBackendController
    
    init(_ backendController: NewRecipeBackendController) {
        self.backendController = backendController
    }
    
    func publishRecipe() {
        if name == "" || ingredients.isEmpty || steps.isEmpty {
            showEmptyRecipeWarning = true
            return
        }
        
        if let image = image {
            backendController.uploadImageToServer(image: image)
                .tryMap { image_id -> Recipe in
                    return Recipe(image: image_id, name: self.name, author: "author", ingredients: self.ingredients, steps: self.steps, coordinate: self.coordinate, emoji: self.emoji, servings: Int(self.servings) ?? 0, tags: self.tags, time: self.time, specialTools: self.specialTools)
                }
                .flatMap(backendController.uploadRecipeToServer)
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { success in
                })
                .store(in: &cancellables)
        }
    }
}

struct NewRecipeView: View {
    @State private var inputImage: UIImage?
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false
    
    private let coordinatePickerViewModel = CoordinatePickerViewModel()
    
    @ObservedObject var viewController: NewRecipeViewController
    
    @State private var editMode = EditMode.inactive
    
    @State var specialTools: [String] = [""]
    @State var steps: [String] = [""]
    @State var ingredients: [Ingredient] = [Ingredient(id: "0", name: "", quantity: "", unit: "")]
    @Environment(\.presentationMode) var presentationMode
    
    @State var coordinatePickerActive = false
    @State var locationEnabled = false
    
    @State var country: String?
    @State var locality: String?
    @State var tags: [String] = []
    @State var currentTag: String = ""
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("About").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)) {
                    TextField("Recipe name", text: $viewController.name)
                        .foregroundColor(Color.text)
                    
                    //                    HStack {
                    TextField("Servings", text: $viewController.servings)
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.text)
                    
                    TextField("Time", text: $viewController.time)
                        .foregroundColor(Color.text)
                    
                    EmojiPickerView() { emoji in
                        viewController.emoji = emoji
                    }
                    //                    }
                }
                .textCase(nil)
                
                Section(header: HStack {
                    Text("Location").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)
                    Toggle("", isOn: $locationEnabled.animation())
                }) {
                    if locationEnabled {
                        NavigationLink(destination: CoordinatePicker(viewModel: coordinatePickerViewModel), isActive: $coordinatePickerActive) {
                            HStack {
                                Spacer()
                                
                                if let country = coordinatePickerViewModel.country {
                                    if let locality = coordinatePickerViewModel.locality {
                                        Text(locality + ", " + country)
                                            .foregroundColor(Color.orange)
                                    } else {
                                        Text(country)
                                            .foregroundColor(Color.orange)
                                    }
                                } else {
                                    Text("Choose Location")
                                        .foregroundColor(Color.orange)
                                }
                                
                                Spacer()
                                
                            }
                            .onTapGesture {
                                coordinatePickerActive = true
                            }
                        }
                    }
                }
                .textCase(nil)
                
                Section(header: Text("Image").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)) {
                    if viewController.image != nil {
                        Image(uiImage: viewController.image!)
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text((viewController.image == nil ? "Add" : "Edit") + " Image")
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                showImageLibrary = true
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
                
                Section(header: Text("Tags").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)) {
                    FlexibleView(
                        data: tags,
                        spacing: 15,
                        alignment: .leading
                    ) { item in
                        HStack {
                            Text(verbatim: item)
                                .foregroundColor(Color.text)
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(Color.lightText)
                                .onTapGesture {
                                    tags.removeAll(where: { $0 == item })
                                }
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    .frame(minHeight: 20)
                    
                    TextField("New Tag", text: $currentTag)
                        .submitLabel(.next)
                        .onSubmit {
                            let componentTags = currentTag
                                .lowercased()
                                .components(separatedBy: " ")
                                .filter({ tags.firstIndex(of: $0) == nil })
                                .filter({ !$0.isEmpty })
                            tags += componentTags
                            currentTag = ""
                        }
                }
                .textCase(nil)
                
                
                Section(header: HStack {
                    Text("Special Tools").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.orange)
                            .font(.system(size: 16))
                    }
                }) {
                    ForEach(specialTools.indices, id: \.self) { index in
                        HStack {
                            TextField("Tool " + String(index + 1), text: $specialTools[index])
                                .foregroundColor(Color.text)
                        }
                    }
                    .onMove { sourceSet, destination in
                        specialTools.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        specialTools.remove(atOffsets: index)
                    }
                    
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                withAnimation {
                                    specialTools.append("")
                                }
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
                
                Section(header: HStack {
                    Text("Ingredients").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.orange)
                            .font(.system(size: 16))
                    }
                }) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        VStack {
                            TextField("Ingredient " + String(index + 1), text: $ingredients[index].name)
                                .foregroundColor(Color.text)
                            
                            HStack {
                                TextField("Quantity", text: $ingredients[index].quantity)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(Color.text)
                                
                                TextField("Unit", text: $ingredients[index].unit)
                                    .foregroundColor(Color.text)
                            }
                        }
                    }
                    .onMove { sourceSet, destination in
                        ingredients.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        ingredients.remove(atOffsets: index)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                withAnimation {
                                    ingredients.append(Ingredient(id: String(ingredients.count), name: "", quantity: "", unit: ""))
                                }
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
                
                Section(header: HStack {
                    Text("Method").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.orange)
                            .font(.system(size: 16))
                    }
                }) {
                    ForEach(steps.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: String(index + 1) + ".circle")
                                .foregroundColor(Color.orange)
                                .font(.system(size: 24))
                            
                            ZStack(alignment: .leading) {
                                TextEditor(text: $steps[index])
                                    .foregroundColor(Color.text)
                                    .onChange(of: steps[index]) { _ in
                                        if !steps[index].filter({ $0.isNewline }).isEmpty {
                                            steps[index] = steps[index].trimmingCharacters(in: .newlines)
                                            let resign = #selector(UIResponder.resignFirstResponder)
                                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                                        }
                                    }
                                
                                Text("Step " + String(index + 1))
                                    .foregroundColor(Color(UIColor.systemGray3))
                                    .opacity(steps[index] == "" ? 1.0 : 0.0)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .onMove { sourceSet, destination in
                        steps.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        steps.remove(atOffsets: index)
                    }
                    
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.orange)
                            .onTapGesture {
                                withAnimation {
                                    steps.append("")
                                }
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
            }
            .onAppear {
                viewController.coordinate = coordinatePickerViewModel.chosenRegion
            }
            .onChange(of: inputImage) { _ in
                guard let inputImage = inputImage else { return }
                viewController.image = inputImage
            }
            .alert(isPresented: $viewController.showEmptyRecipeWarning) {
                Alert(
                    title: Text("Please fill out the full recipe!"),
                    dismissButton: .none
                )
            }
            .navigationTitle(viewController.name != "" ? viewController.name : "New Recipe")
            .sheet(isPresented: $showImageLibrary) {
                PhotoPicker(image: $inputImage)
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(Color.orange)
            }, trailing: Button(action: {
                viewController.ingredients = ingredients
                viewController.steps = steps
                viewController.tags = tags
                viewController.specialTools = specialTools.filter({ !$0.isEmpty })
                
                viewController.publishRecipe()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Publish")
                    .foregroundColor(Color.orange)
            })
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            let resign = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        }
                        .foregroundColor(Color.orange)
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            _FlexibleView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

struct _FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body : some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
