//
//  LocationView.swift
//  MusicMap
//
//  Created by Josh Jeong on 10/27/24.
//

import SwiftUI
struct LocationView: View {
    @ObservedObject var data : InfoDictionary
    @State var accessToken : String
    var body: some View {
        List {
            // Create a list with all of the locations, each with a link to a DetailedView with the location
            ForEach(data.locations, id: \.self) { location in
                NavigationLink(destination: DetailedView(data: data, accessToken: accessToken, mostPlayed: data.getMostPlayed(location: location), favoriteArtist: data.getFavoriteArtist(location: location).0, artistPlayed: data.getFavoriteArtist(location: location).1, location:location)) {
                    HStack {
                        Text(location)
                    }
                }
            }
        }
        .navigationTitle("Data by Location")
    }
}
