import SpotifyiOS
import SwiftUI
import Combine

class SpotifyAuth: NSObject, ObservableObject, SPTSessionManagerDelegate {
    // Store accessToken here, used throughout app
    var accessToken: String?
    // Client ID taken from Spotify
    private let clientID = "28a9580ea16e49fbbfba21ae382b0c76"
    private let redirectURI = URL(string: "musicmap://spotify-login-callback")!
    // Create SPTConfiguration using these values
    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        return config
    }()
    
    // Create session manager using this configuration
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    // Initiate a session with the needed permissions
    func authenticate() {
        sessionManager.initiateSession(with: [.userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying], options: .default, campaign: "login")
    }
    
    // Methods called based on how the authentication did
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Authentication failed.")
    }
    
    // Necessary method to make sure the class conforms to SPTSessionManagerDelegate
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        self.accessToken = session.accessToken
    }
    
    // Print the access token when newly acquired
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        self.accessToken = session.accessToken
        print("Access token: " + accessToken!)
    }
}

