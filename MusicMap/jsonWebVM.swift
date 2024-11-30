//
//  jsonWebVM.swift
//  MusicMap
//
//  Created by Josh Jeong on 11/20/24.
//


import Foundation
import SwiftUI

// Set up structs for JSON
struct SearchResult : Decodable {
    let artists : ArtistList
}
struct ArtistList : Decodable {
    let items : [SearchArtist]
}

struct CurrentlyPlaying : Decodable {
    let progress_ms : Int
    let item : ItemStruct
    let is_playing : Bool
}

struct ItemStruct : Decodable {
    let album : Album
    let artists : [Artist]
    let name : String
    let duration_ms : Int
}
struct Album : Decodable {
    let images : [ImageStruct]
}
struct ImageStruct : Decodable {
    let url: String
}
struct Artist : Decodable {
    let name : String
}

struct SearchArtist : Decodable {
    let images : [ImageStruct]
}

struct CurrentlyPlayingSong {
    var name : String
    var artist : String
    var albumImg : String
    var isPlaying : Bool
    var progress : String
    init(_ name : String, _ artist : String, _ albumImg : String, _ isPlaying : Bool, _ progress : String) {
        self.name = name
        self.artist = artist
        self.albumImg = albumImg
        self.isPlaying = isPlaying
        self.progress = progress
    }
}


// Taken from Prof Balasooriya's example code
class jsonWebVM : ObservableObject
{
    // Calls the Spotify API to skip forwards or backwards
    func skip(_ accessToken : String, _ destination : String) {
        let urlAsString = "https://api.spotify.com/v1/me/player/" + destination
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
        })
        jsonQuery.resume()
    }
    // Calls the Spotify API to pause the player
    func pause(_ accessToken : String) {
        let urlAsString = "https://api.spotify.com/v1/me/player/pause"
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
        })
        jsonQuery.resume()
    }
    // Calls the Spotify API to resume the player
    func resume(_ accessToken : String) {
        let urlAsString = "https://api.spotify.com/v1/me/player/play"
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
        })
        jsonQuery.resume()
    }
        
    // Formats time in ms as "00:00"
    func formatTime(_ ms : Int) -> String {
        let seconds : Int = ms / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // Gets an image of the artist by calling the Spotify Search API
    func getArtistImgByName(_ accessToken : String, name : String, completion: @escaping (String?) -> Void) {
        let urlAsString = "https://api.spotify.com/v1/search?offset=0&limit=1&query=\(name)&type=artist&locale=en-US"
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                completion(nil)
                print(error!.localizedDescription)
            }
            
            do {
                let decodedData = try JSONDecoder().decode(SearchResult.self, from: data!)
                DispatchQueue.main.async {
                    completion(decodedData.artists.items[0].images[0].url)
                }
                
            } catch {
                completion(nil)
                print("error: \(error)")
            }
        })
        jsonQuery.resume()
    }
    
    // Calls Spotify's currently playing endpoint to get the currently playing song
    func getCurrentlyPlaying(_ accessToken : String, completion: @escaping (CurrentlyPlayingSong?) -> Void) {
        let urlAsString = "https://api.spotify.com/v1/me/player/currently-playing"
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                completion(nil)
                print(error!.localizedDescription)
            }
            
            do {
                let decodedData = try JSONDecoder().decode(CurrentlyPlaying.self, from: data!)
                DispatchQueue.main.async {
                    // Return a CurrentlyPlayingSong object
                    let progress = self.formatTime(decodedData.progress_ms) + " /  " + self.formatTime(decodedData.item.duration_ms)
                    let isPlaying = decodedData.is_playing
                    let item = decodedData.item
                    let albumImg = item.album.images[0].url
                    let artist = item.artists[0].name
                    let name = item.name
                    completion(CurrentlyPlayingSong(name, artist, albumImg, isPlaying, progress))
                    
                }
                
            } catch {
                completion(nil)
                print("error: \(error)")
            }
        })
        jsonQuery.resume()
    }
    
}
