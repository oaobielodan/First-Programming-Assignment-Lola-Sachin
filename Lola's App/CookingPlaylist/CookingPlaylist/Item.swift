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
    var recipeName: String
    var documentContent: String
    var cookingTime: String
    
    init(timestamp: Date, recipeURL: URL, recipeName: String, documentContent: String, cookingTime: String = "Unknown") {
        self.timestamp = timestamp
        self.recipeURL = recipeURL
        self.recipeName = recipeName
        self.documentContent = documentContent
        self.cookingTime = cookingTime
    }
}
