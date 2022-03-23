//
//  String.swift
//  Resoupie
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

extension String {
    func onlyEmoji() -> String {
        return self.filter({$0.isEmoji})
    }
}
