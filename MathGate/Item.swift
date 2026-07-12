//
//  Item.swift
//  Integate
//
//  Created by Levi Monte on 6/23/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
