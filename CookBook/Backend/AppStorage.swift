//
//  AppStorage.swift
//  CookBook
//
//  Created by Michael Abir on 2/27/22.
//

import Foundation
import SwiftUI

class AppStorageContainer {
    static var main = AppStorageContainer()
    
    @AppStorage("uesrname") var username: String = ""
}
