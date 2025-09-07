//
//  FirebaseController.swift
//  CookingPlaylist
//
//  Created by Olufunmilola Obielodan on 9/7/25.
//

import FirebaseFirestore
import FirebaseFunctions

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
    
    func getPlaylist(_ genre: String, _ length: Int) {
        
        let functions = Functions.functions()
        functions.useEmulator(withHost: "localhost", port: 5001)
        
        functions.httpsCallable("addPlaylist").call(["genre": genre, "length": length]) { result, error in
            if let error = error as NSError? {
                print("error getting playlist: \(error)")
            }
            if let data = result?.data as? [String: Any],
               let genre = data["genre"] as? String,
               let length = data["length"] as? String {
                print("genre: \(genre), length \(length)")
            }
        }
    }
}
