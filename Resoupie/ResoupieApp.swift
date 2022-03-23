//
//  ResoupieApp.swift
//  Resoupie
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI
import Combine

class InitialAppLoading: ObservableObject {
    let backendController: BackendController
    private var cancellables = Set<AnyCancellable>()
    
    init(_ backendController: BackendController) {
        self.backendController = backendController
    }
    
    func loadApp() {
        backendController.getCurrentUser()
            .sink { _ in
            } receiveValue: { user in
                AppStorageContainer.main.user_id = user.user_id
                AppStorageContainer.main.username = user.username
            }
            .store(in: &cancellables)
    }
}

@main
struct ResoupieApp: App {
    @StateObject var initialAppLoading = InitialAppLoading(BackendController())
    
    var body: some Scene {
        WindowGroup {
            let backendController = BackendController()
            ContentView()
                .preferredColorScheme(.light)
                .setTheme(LightTheme.self)
                .tint(Color.orange)
                .environmentObject(backendController)
                .onAppear {
                    initialAppLoading.loadApp()
                }
        }
    }
}
