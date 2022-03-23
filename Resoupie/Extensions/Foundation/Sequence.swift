//
//  Sequence.swift
//  Resoupie
//
//  Created by Michael Abir on 3/21/22.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
