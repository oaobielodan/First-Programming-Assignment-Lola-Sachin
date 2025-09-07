//
//  FirebaseController.swift
//  CookingPlaylist
//
//  Created by Olufunmilola Obielodan on 9/7/25.
//

import FirebaseFirestore

class FirebaseController {
    static let shared = FirebaseController()
    
    func saveRecipeToFirestore(_ fileName: String, _ recipeURL: URL, _ title: String, _ recipeText: String) {
        let db = Firestore.firestore()
        db.collection("user-recipes").addDocument(data: [
            "fileName": fileName,
            "recipeURL": recipeURL.absoluteString,
            "title": title,
            "text": recipeText,
            "createdAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("error writing recipe: \(error)")
            } else {
                print("recipe saved to Firestore")
            }
        }
    }
}

