//
//  MusicMapApp.swift
//  MusicMap
//
//  Created by Josh Jeong on 11/25/24.
//

import SwiftUI

@main
struct MusicMapApp: App {
    @State private var isSignedIn = false
    let persistenceController = PersistenceController.shared
    @StateObject var auth = SpotifyAuth()
    @StateObject var locationDataManager = LocationDataManager()
    var body: some Scene {
        WindowGroup {
            // Show the main view if signed in, otherwise load the sign in view
            if isSignedIn {
                ContentView(webVM: jsonWebVM(), isSignedIn: $isSignedIn, currentlyPlaying: CurrentlyPlayingSong("No Song Playing", "N/A", "", true, "00:00 / 00:00"))
                    .environmentObject(auth)
                    .environmentObject(locationDataManager)
            }
            else {
                SignInView(webVM:jsonWebVM(), isSignedIn: $isSignedIn)
                    .environmentObject(auth)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
