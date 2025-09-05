//
//  SpotifyAPIController.swift
//  CookingPlaylist
//
//  Created by Olufunmilola Obielodan on 9/5/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

class SpotifyAPIController: NSObject {
    static let shared = SpotifyAPIController()
    private var authSession: ASWebAuthenticationSession?
    
    func getAuthURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyAPIConstants.authorizeHost
        components.path = "/authorize"
        
        components.queryItems = SpotifyAPIConstants.authParams.map({URLQueryItem(name: $0, value: $1)})
        
        return components.url
    }
    
    func startAuthSession() {
        guard let authURL = getAuthURL() else { return }
        
        let authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "cookingplaylist") { callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else { return }
            
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            let token = queryItems?.filter({ $0.name == "token" }).first?.value
            print(token)
        }
        authSession.start()
    }
}

extension SpotifyAPIController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // get the first window of the active scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        // fallback
        return ASPresentationAnchor()
    }
}
