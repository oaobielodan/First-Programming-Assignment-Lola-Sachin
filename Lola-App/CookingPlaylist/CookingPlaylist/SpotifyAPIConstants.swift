//
//  SpotifyAPIConstants.swift
//  CookingPlaylist
//
//  Created by Olufunmilola Obielodan on 9/5/25.
//

enum SpotifyAPIConstants {
    static let apiHost = "api.sspotify.com"
    static let authorizeHost = "accounts.spotify.com"
    static let clientId = "abc6f3a92343420385f92f1140556465"
    static let redirectURI = "cookingplaylist://callback"
    static let responseType = "token"
    static let scopes = "user-library-read user-personalized"
    static var authParams = [
        "response_type": responseType,
        "client_id": clientId,
        "redirect_uri": redirectURI,
        "scope": scopes
    ]
}
