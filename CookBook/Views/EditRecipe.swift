//
//  EditRecipe.swift
//  CookBook
//
//  Created by Michael Abir on 2/23/22.
//

import SwiftUI
import PhotosUI
import Combine

class EditRecipeViewController: ObservableObject {
    typealias EditRecipeBackendController = RecipeBackendController & ImageBackendController

    var emoji: String = ""
    var servings: String = ""

    @Published var image: UIImage?
    @Published var showEmptyRecipeWarning = false
    @Published var coordinatePickerActive = false
    
    @Published var coordinatePickerViewModel = CoordinatePickerViewModel()
    
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    @Published var recipe: Recipe
    
    let backendController: EditRecipeBackendController
    
    init(_ backendController: EditRecipeBackendController, recipe: Recipe? = nil, parent_id: String? = nil, image: UIImage? = nil) {
        self.backendController = backendController
        
        if let recipe = recipe {
            self.recipe = recipe
            self.emoji = recipe.emoji
            self.servings = String(recipe.servings)
            self.recipe.parent_id = parent_id
        } else {
            self.recipe = Recipe(image: "", name: "", ingredients: [Ingredient(id: "0", name: "", quantity: "", unit: "")], steps: [""], coordinate: nil, emoji: "", servings: 0, tags: [], time: "", specialTools: [], parent_id: nil)
        }
    }
    
    func reset() {
        self.recipe = Recipe(image: "", name: "", ingredients: [], steps: [], coordinate: nil, emoji: "", servings: 0, tags: [], time: "", specialTools: [], parent_id: nil)

        emoji = ""
        servings = ""
        showEmptyRecipeWarning = false
    }
    
    func publishRecipe() {
        if recipe.name == "" || recipe.ingredients.isEmpty || recipe.steps.isEmpty {
            showEmptyRecipeWarning = true
            return
        }
        
        recipe.specialTools = recipe.specialTools.filter({ !$0.isEmpty })
        recipe.servings = Int(servings) ?? 0
        
        if let image = image {
            backendController.uploadImageToServer(image: image)
                .receive(on: DispatchQueue.main)
                .tryMap { image_id -> Recipe in
                    self.recipe.image = image_id
                    return self.recipe
                }
                .flatMap(backendController.uploadRecipeToServer)
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { success in
                    self.reset()
                })
                .store(in: &cancellables)
        }
    }
}

struct EditRecipeView: View {
    @State private var inputImage: UIImage?
    @State private var recipeImage: UIImage?
    @State private var showImageLibrary = false
        
    @ObservedObject var viewController: EditRecipeViewController
    
    @State private var editMode = EditMode.inactive
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var locationEnabled = false
    
    @State var country: String?
    @State var locality: String?
    @State var currentTag: String = ""
    
    @State var displayEmojiWarning: Bool = false

    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("About").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)) {
                    TextField("Recipe name", text: $viewController.recipe.name)
                        .foregroundColor(Color.theme.text)
                    
                    TextField("Servings", text: $viewController.servings)
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.text)
                    
                    TextField("Time", text: $viewController.recipe.time)
                        .foregroundColor(Color.theme.text)
                    
                    TextField("Emoji", text: $viewController.emoji)
                        .alert("Emoji only!", isPresented: $displayEmojiWarning) {
                            Button("OK", role: .cancel) {}
                        }
                        .onReceive(Just(viewController.emoji), perform: { _ in
                            if self.viewController.emoji != self.viewController.emoji.onlyEmoji() {
                                withAnimation {
                                    displayEmojiWarning = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                                    withAnimation {
                                        displayEmojiWarning.toggle()
                                    }
                                }
                                
                            }
                            self.viewController.emoji = String(self.viewController.emoji.onlyEmoji().prefix(1))
                        })
                }
                .textCase(nil)
                
                Section(header: HStack {
                    Text("Location").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)
                    Toggle("", isOn: $locationEnabled.animation())
                }) {
                    if locationEnabled {
                        NavigationLink(destination: CoordinatePicker(viewModel: viewController.coordinatePickerViewModel), isActive: $viewController.coordinatePickerActive) {
                            HStack {
                                Spacer()
                                
                                if let country = viewController.coordinatePickerViewModel.country {
                                    if let locality = viewController.coordinatePickerViewModel.locality {
                                        Text(locality + ", " + country)
                                            .foregroundColor(Color.theme.accent)
                                    } else {
                                        Text(country)
                                            .foregroundColor(Color.theme.accent)
                                    }
                                } else {
                                    Text("Choose Location")
                                        .foregroundColor(Color.theme.accent)
                                }
                                
                                Spacer()
                                
                            }
                            .onTapGesture {
                                viewController.coordinatePickerActive = true
                            }
                        }
                    }
                }
                .textCase(nil)
                
                Section(header: Text("Image").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)) {
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
                            .foregroundColor(Color.theme.accent)
                            .onTapGesture {
                                showImageLibrary = true
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
                
                Section(header: Text("Tags").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)) {
                    FlexibleView(
                        data: viewController.recipe.tags,
                        spacing: 15,
                        alignment: .leading
                    ) { item in
                        HStack {
                            Text(verbatim: item)
                                .foregroundColor(Color.theme.text)
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(Color.theme.lightText)
                                .onTapGesture {
                                    viewController.recipe.tags.removeAll(where: { $0 == item })
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
                                .filter({ viewController.recipe.tags.firstIndex(of: $0) == nil })
                                .filter({ !$0.isEmpty })
                            viewController.recipe.tags += componentTags
                            currentTag = ""
                        }
                }
                .textCase(nil)
                
                
                Section(header: HStack {
                    Text("Special Tools").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.theme.accent)
                            .font(.system(size: 16))
                    }
                }) {
                    ForEach(viewController.recipe.specialTools.indices, id: \.self) { index in
                        HStack {
                            TextField("Tool " + String(index + 1), text: $viewController.recipe.specialTools[index])
                                .foregroundColor(Color.theme.text)
                        }
                    }
                    .onMove { sourceSet, destination in
                        viewController.recipe.specialTools.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        viewController.recipe.specialTools.remove(atOffsets: index)
                    }
                    
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.theme.accent)
                            .onTapGesture {
                                withAnimation {
                                    viewController.recipe.specialTools.append("")
                                }
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
                
                Section(header: HStack {
                    Text("Ingredients").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.theme.accent)
                            .font(.system(size: 16))
                    }
                }) {
                    ForEach(viewController.recipe.ingredients.indices, id: \.self) { index in
                        VStack {
                            TextField("Ingredient " + String(index + 1), text: $viewController.recipe.ingredients[index].name)
                                .foregroundColor(Color.theme.text)
                            
                            HStack {
                                TextField("Quantity", text: $viewController.recipe.ingredients[index].quantity)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(Color.theme.text)
                                
                                TextField("Unit", text: $viewController.recipe.ingredients[index].unit)
                                    .foregroundColor(Color.theme.text)
                            }
                        }
                    }
                    .onMove { sourceSet, destination in
                        viewController.recipe.ingredients.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        viewController.recipe.ingredients.remove(atOffsets: index)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.theme.accent)
                            .onTapGesture {
                                withAnimation {
                                    viewController.recipe.ingredients.append(Ingredient(id: String(viewController.recipe.ingredients.count), name: "", quantity: "", unit: ""))
                                }
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
                
                Section(header: HStack {
                    Text("Method").foregroundColor(Color.theme.title).font(.title2).fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(Color.theme.accent)
                            .font(.system(size: 16))
                    }
                }) {
                    ForEach(viewController.recipe.steps.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: String(index + 1) + ".circle")
                                .foregroundColor(Color.theme.accent)
                                .font(.system(size: 24))
                            
                            ZStack(alignment: .leading) {
                                TextEditor(text: $viewController.recipe.steps[index])
                                    .foregroundColor(Color.theme.text)
                                    .onChange(of: viewController.recipe.steps[index]) { _ in
                                        if !viewController.recipe.steps[index].filter({ $0.isNewline }).isEmpty {
                                            viewController.recipe.steps[index] = viewController.recipe.steps[index].trimmingCharacters(in: .newlines)
                                            let resign = #selector(UIResponder.resignFirstResponder)
                                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                                        }
                                    }
                                
                                Text("Step " + String(index + 1))
                                    .foregroundColor(Color(UIColor.systemGray3))
                                    .opacity(viewController.recipe.steps[index] == "" ? 1.0 : 0.0)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .onMove { sourceSet, destination in
                        viewController.recipe.steps.move(fromOffsets: sourceSet, toOffset: destination)
                    }
                    .onDelete { index in
                        viewController.recipe.steps.remove(atOffsets: index)
                    }
                    
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundColor(Color.theme.accent)
                            .onTapGesture {
                                withAnimation {
                                    viewController.recipe.steps.append("")
                                }
                            }
                        
                        Spacer()
                    }
                }
                .textCase(nil)
            }
            .onAppear {
                viewController.recipe.coordinate = viewController.coordinatePickerViewModel.chosenRegion
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
            .navigationTitle(viewController.recipe.name != "" ? viewController.recipe.name : "New Recipe")
            .sheet(isPresented: $showImageLibrary) {
                PhotoPicker(image: $inputImage)
            }
            .navigationBarItems(trailing: Button(action: {
                viewController.publishRecipe()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Publish")
                    .foregroundColor(Color.theme.accent)
            })
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            let resign = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        }
                        .foregroundColor(Color.theme.accent)
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
