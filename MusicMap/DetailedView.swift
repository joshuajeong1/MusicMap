//
//  DetailedView.swift
//  MusicMap
//
//  Created by Josh Jeong on 11/28/24.
//


// This method is mostly a copy of ListeningHabitsView
// It is missing the Favorite Location field, which is not needed for this view

import Foundation
import SwiftUI
struct DetailedView : View {
    @ObservedObject var data : InfoDictionary
    @State var accessToken : String
    @State var artistImg : String = ""
    @State var mostPlayed : Song
    @State var favoriteArtist : String
    @State var artistPlayed : Int
    @State var location : String
    var body: some View {
        VStack {
            Text("Listening Habits - \(location)")
                .bold()
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.black)
                .padding(.horizontal)
            Text("Your Top Song:")
            AsyncImage(url: URL(string: mostPlayed.getAlbum())) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                case .failure:
                    Text("Failed to load image")
                        .foregroundColor(.red)
                default:
                    ProgressView()
                }
            }
            Text(mostPlayed.getTitle())
            Text(mostPlayed.getArtist())
            Text(mostPlayed.getTimesPlayed() == 0 ? "No Data!" : "Played \(mostPlayed.getTimesPlayed()) times")
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.black)
                .padding(.horizontal)
            Text("Your Top Artist:")
            AsyncImage(url: URL(string: artistImg)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                case .failure:
                    Text("Failed to load image")
                        .foregroundColor(.red)
                default:
                    ProgressView()
                }
            }
            Text(favoriteArtist.isEmpty ? "No Data!" : "\(favoriteArtist), listened to \(artistPlayed) times")

        }
        .onAppear {
            jsonWebVM().getArtistImgByName(accessToken, name: favoriteArtist) { url in
                artistImg = url ?? ""
            }
        }
        .padding()
    }
}
