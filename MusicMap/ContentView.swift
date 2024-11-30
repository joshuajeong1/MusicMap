//
//  ContentView.swift
//  MusicMap
//
//  Created by Josh Jeong on 11/25/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // State and environment variables
    @StateObject var data : InfoDictionary = InfoDictionary()
    @EnvironmentObject var locationDataManager : LocationDataManager
    @EnvironmentObject var auth: SpotifyAuth
    @ObservedObject var webVM:jsonWebVM
    @Binding var isSignedIn : Bool
    @State var currentlyPlaying : CurrentlyPlayingSong
    @State var isUpdating : Bool = true
    @State var pauseButton : Image = Image(systemName: "pause")
    // Constant notPlaying to use whenever a song is not playing
    private let notPlaying : CurrentlyPlayingSong = CurrentlyPlayingSong("No Song Playing", "N/A", "", true, "00:00 / 00:00")
    var body: some View {
        NavigationStack {
            VStack {
                Text("Music Map")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Text("Now Playing")
                    .fontWeight(.bold)
                // Get the albumImg of the currently playing song, show a failure message/ProgressView if needed
                AsyncImage(url: URL(string: currentlyPlaying.albumImg)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    case .failure:
                        Text("Failed to load image")
                            .foregroundColor(.red)
                    default:
                        ProgressView()
                    }
                }
                // Show the name, artist, and progress bar
                Text(currentlyPlaying.name)
                Text(currentlyPlaying.artist)
                Text(currentlyPlaying.progress)
                // This HStack contains the three playback control buttons
                HStack {
                    // Skip previous button
                    Button(action: {
                        print("Skipping to previous")
                        webVM.skip(auth.accessToken!, "previous")
                    }) {
                        Image(systemName: "backward")
                            .font(.system(size: 20))
                    }
                    .padding(10)
                    
                    // Pause/resume button, changes based on the state variable
                    Button(action: {
                        if(currentlyPlaying.isPlaying) {
                            print("Pausing")
                            webVM.pause(auth.accessToken!)
                        }
                        else {
                            print("Resuming")
                            webVM.resume(auth.accessToken!)
                        }
                    }) {
                        pauseButton
                            .font(.system(size: 20))
                    }
                    .padding(10)
                    
                    // Skip to next button
                    Button(action: {
                        print("Skipping to next")
                        webVM.skip(auth.accessToken!, "next")
                    }) {
                        Image(systemName: "forward")
                            .font(.system(size: 20))
                    }
                    .padding(10)
                    
                }
                
                // Opens the map view
                NavigationLink(destination: MapView(data: data)) {
                    HStack {
                        Image(systemName: "map")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Map")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width:250)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .frame(width:200)
                
                // Opens the listening habits view, sends a lot of data (was having synchronization issues and this solved it)
                NavigationLink(destination: ListeningHabitsView(data: data, accessToken: auth.accessToken!, mostPlayed: data.getMostPlayed(location: "unsorted"), favoriteArtist: data.getFavoriteArtist(location: "unsorted").0, artistPlayed: data.getFavoriteArtist(location: "unsorted").1, favoriteLocation: data.getFavoriteLocation().0, locationPlayed: data.getFavoriteLocation().1)) {
                    HStack {
                        Image(systemName: "headphones")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Listening Habits")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width:250)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .frame(width:200)
                
                // Opens the location view
                NavigationLink(destination: LocationView(data:data, accessToken: auth.accessToken!)) {
                    HStack {
                        Image(systemName: "mappin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Location View")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width:250)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .frame(width:200)
            }
            // When the view is opened, get the currently playing song from the webVM
            .onAppear {
                webVM.getCurrentlyPlaying(auth.accessToken!) { currentSong in
                    // Start updating the currently playing song
                    if(currentSong == nil) {
                        isUpdating = true
                        startUpdating()
                        
                    }
                    else {
                        if (currentlyPlaying.isPlaying) {
                            pauseButton = Image(systemName: "pause")
                        }
                        else {
                            pauseButton = Image(systemName: "play")
                        }
                        isUpdating = true
                        startUpdating()
                    }
                }
            }
            // When the view disappears, stop updating the view
            .onDisappear {
                isUpdating = false
            }
            .toolbar {
                // Settings button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:SettingsView(isSignedIn: $isSignedIn, data: data)) {
                        Image(systemName:"gear")
                    }
                }
            }
        }
    }
    private func startUpdating() {
        // Start a timer that repeats once per second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // While isUpdating is true, get the currently playing song
            if isUpdating {
                webVM.getCurrentlyPlaying(auth.accessToken!) { currentSong in
                    // If the song is not nil and is a new song from what it was before, add a listing to the data manager
                    if(currentSong != nil) {
                        if(currentSong!.name != currentlyPlaying.name) {
                            print("Song has changed, adding listing")
                            locationDataManager.getCurrentCity() { city in
                                if(city != "") {
                                    data.addToStorage(currentSong!.name, currentSong!.artist, currentSong!.albumImg, city, 1)
                                }
                            }
                        }
                    }
                    // If the song is nil, set it to notPlaying
                    currentlyPlaying = currentSong ?? notPlaying
                    // Set the pause button to be pause or play depending on if the song is paused or not
                    if (currentlyPlaying.isPlaying) {
                        pauseButton = Image(systemName: "pause")
                    }
                    else {
                        pauseButton = Image(systemName: "play")
                    }
                }
            } 
            // When isUpdating is no longer true, invalidate the timer
            else {
                timer.invalidate() // Stop the timer when inactive
            }
        }
    }
}



