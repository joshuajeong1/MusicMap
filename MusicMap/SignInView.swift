//
//  SignInView.swift
//  MusicMap
//
//  Created by Josh Jeong on 10/27/24.
//
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: SpotifyAuth
    @ObservedObject var webVM:jsonWebVM
    @Binding var isSignedIn : Bool
    @State var showAlert : Bool = false
    var body: some View {
        // Set up navigation stack to open settings menu
        NavigationStack {
            VStack {
                Image("musicmap")
                    .resizable()
                    .scaledToFit()
                    .frame(height:200)
                // Call authenticatior with Spotify logo
                Button(action: {
                    auth.authenticate()
                }) {
                    HStack {
                        Image("spotify")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Sign in with Spotify")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width:250)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .frame(width:200)
                
                // Set the binding variable to true to signal the main script to change the view
                Button(action: {
                    // Main view
                    if (auth.accessToken != nil) {
                        isSignedIn = true
                    }
                    else {
                        isSignedIn = false
                        // If there is no auth token, do not allow the user to sign in (causes fatal error)
                        // Show an alert
                        showAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Start Listening")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width:250)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                // Error message
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("You must be signed into Spotify."))
                }
                // Settings button
                NavigationLink(destination: SettingsView(isSignedIn: $isSignedIn, data: InfoDictionary())) {
                    HStack {
                        Image(systemName: "gear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width:250)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}


