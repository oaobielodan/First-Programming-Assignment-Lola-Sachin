//
//  Item.swift
//  CookingPlaylist
//
//  Created by Olufunmilola Obielodan on 9/4/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var recipeURL: URL
    var documentContent: String
    
    init(timestamp: Date, recipeURL: URL, documentContent: String) {
        self.timestamp = timestamp
        self.recipeURL = recipeURL
        self.documentContent = documentContent
    }
}
