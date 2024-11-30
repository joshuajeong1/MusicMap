//
//  Song.swift
//  MusicMap
//
//  Created by Josh Jeong on 10/27/24.
//

import Foundation


// Song object, contains important information about where a song was listened to, how many times it was played, etc
class Song : Identifiable {
    private var title : String
    private var artist : String
    private var albumImg : String
    private var timesPlayed : Int
    private var locationListened : String
    

    init(t: String, a: String, album: String, tp: Int, city : String) {
        title = t
        artist = a
        albumImg = album
        timesPlayed = tp
        locationListened = city
    }
    func getTitle() -> String {
        return title
    }
    func getArtist() -> String {
        return artist
    }
    func getAlbum() -> String {
        return albumImg
    }
    func getTimesPlayed() -> Int {
        return timesPlayed
    }
    func getLocationName() -> String {
        return locationListened
    }
    func addListen() {
        timesPlayed += 1
    }
    
}


