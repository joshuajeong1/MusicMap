//
//  ListeningHabitsView.swift
//  MusicMap
//
//  Created by Josh Jeong on 10/27/24.
//

import SwiftUI
struct ListeningHabitsView: View {
    @ObservedObject var data : InfoDictionary
    @State var accessToken : String
    @State var artistImg : String = ""
    @State var mostPlayed : Song
    @State var favoriteArtist : String
    @State var artistPlayed : Int
    @State var favoriteLocation : String
    @State var locationPlayed : Int
    
    var body: some View {
        VStack {
            Text("Listening Habits")
                .font(.largeTitle)
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
            // If there is no data, show a message, otherwise say how many times the most played song was played
            Text(mostPlayed.getTimesPlayed() == 0 ? "No Data!" : "Played \(mostPlayed.getTimesPlayed()) times")
            // Divider shape to separate the different statistics
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
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.black)
                .padding(.horizontal)
            Text("Your Top Location:")
            Text(favoriteLocation.isEmpty ? "No Data!" : "\(favoriteLocation), with \(locationPlayed) songs played there")

        }
        .onAppear {
            // Get the artist's image when the view is loaded with the webVM
            jsonWebVM().getArtistImgByName(accessToken, name: favoriteArtist) { url in
                artistImg = url ?? ""
            }
        }
        .padding()
    }
}
