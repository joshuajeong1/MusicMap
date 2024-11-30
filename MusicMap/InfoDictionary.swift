//
//  InfoDictionary.swift
//  MusicMap
//
//  Created by Josh Jeong on 10/27/24.
//

import Foundation
import MapKit
import CoreData

class InfoDictionary : ObservableObject
{
    // Dictionary that stores records of all songs
    @Published var infoRepository : [Song] = [Song] ()
    @Published var locations : [String] = [String] ()
    private var artistIds : [String:String] = [:]
    let context = PersistenceController.shared.container.viewContext

    init() {
        // On init, put the data from the database into the infoRepository
        let request = NSFetchRequest<Track>(entityName: "Track")
        var songData : [Track] = []
        do {
            songData = try context.fetch(request)
        }
        catch {
            print("Error with fetch request")
        }

        for song in songData {
            add(song.name!, song.artist!, song.albumImg!, song.location!, Int(song.timesListened))
        }
    }
    
    // returns the repository
    func getRepository() -> [Song] {
        return self.infoRepository
    }
    // Clears the repository and clears the database
    func clear() {
        infoRepository.removeAll()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print("Error clearing song data from database")
        }
    }
    
    // Helper method to get the region for the MapView
    func getRegion(markers : [Location]) -> MKCoordinateRegion {
        if(markers.isEmpty) {
            // Returns default value at Tempe if no markers exist
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400), span:MKCoordinateSpan(latitudeDelta:0.2, longitudeDelta: 0.2)
            )
        }
        // Gets the mininum and maximum lat and lon values
        var minLat = markers[0].coordinate.latitude
        var maxLat = markers[0].coordinate.latitude
        var minLon = markers[0].coordinate.longitude
        var maxLon = markers[0].coordinate.longitude
        for marker in markers {
            if(marker.coordinate.latitude <= minLat) {
                minLat = marker.coordinate.latitude
            }
            if(marker.coordinate.latitude >= maxLat) {
                maxLat = marker.coordinate.latitude
            }
            if(marker.coordinate.longitude <= minLon) {
                minLon = marker.coordinate.longitude
            }
            if(marker.coordinate.longitude >= maxLon) {
                maxLon = marker.coordinate.longitude
            }
        }
        // Averages these values, and puts the center of the map at that point
        let averageLat = (minLat + maxLat) / 2
        let averageLon = (minLon + maxLon) / 2
        let center = CLLocationCoordinate2D(latitude: averageLat, longitude: averageLon)
        let latDelta = maxLat - minLat + 0.2
        let lonDelta = maxLon - minLon + 0.2
        // Span contains all of the locations, with an extra 0.2
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        return MKCoordinateRegion(center: center, span: span)
    }
    // Returns the coordinates of a city by name with CLGeocoder
    func getCoordinate(city : String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        CLGeocoder().geocodeAddressString(city) { placemarks, error in
            if let error = error {
                completion(nil)
                return
            }
            
            if let location = placemarks?.first?.location  {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    // Returns all coordinates of the cities in the locations array
    func getCoordinates(completion: @escaping ([CLLocationCoordinate2D?]) -> Void) {
        var coords : [CLLocationCoordinate2D?] = [CLLocationCoordinate2D] ()
        // Uses group to make sure that all of the getCoordinate calls happen before completing
        let group = DispatchGroup()
        
        for city in locations {
            group.enter()
            getCoordinate(city: city) { coord in
                coords.append(coord)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(coords)
        }
    }
    
    func addToStorage(_ title : String, _ artist : String, _ albumImg : String, _ location : String, _ timesPlayed : Int) {
        // If an entry of the same name and location already exists, add 1 to the timesListened field
        // Do this both locally and on the database
        if(exists(name: title, location: location)) {
            let request : NSFetchRequest<Track> = Track.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@ AND location == %@", title, location)
            do {
                let result = try context.fetch(request)
                if let track = result.first {
                    track.timesListened += 1
                }
                try context.save()
            }
            catch {
                print("Error updating times played entry")
            }
            
            
            for song in infoRepository {
                if(song.getTitle() == title && song.getLocationName() == location) {
                    song.addListen()
                }
            }
            return
        }
        
        // Otherwise, create a new entry in the database
        let newSong = Track(context: context)
        
        newSong.name = title
        newSong.artist = artist
        newSong.albumImg = albumImg
        newSong.location = location
        newSong.timesListened = Int64(timesPlayed)
        do {
            try context.save()
        }
        catch {
            print("Error saving new activity")
        }
        // And add to the local repository
        add(title, artist, albumImg, location, timesPlayed)
        
    }
    
    func add(_ title : String, _ artist : String, _ albumImg : String, _ location : String, _ timesPlayed : Int)
    {
        // If the location is new, add it to the locations array
        let song = Song(t:title, a: artist, album: albumImg, tp: timesPlayed, city: location)
        if(!self.locations.contains(location) && location != "") {
            self.locations.append(location)
        }
        print("Adding song with location \(song.getLocationName())")
        self.infoRepository.append(song)
        
    }
    // Helper method to check if a song is in the repository already
    func exists(name : String, location : String) -> Bool {
        for song in self.infoRepository {
            if (song.getTitle() == name && song.getLocationName() == location) {
                return true
            }
        }
        return false
    }
    // Returns the Song object of the most listened to song, sorted by location
    func getMostPlayed(location : String) -> Song {
        // Sorts by location unless the location field is "unsorted"
        var sortedInfoRepo : [Song] = infoRepository
        if(location != "unsorted") {
            sortedInfoRepo = [Song] ()
            for song in infoRepository {
                if(song.getLocationName() == location) {
                    sortedInfoRepo.append(song)
                }
            }
        }
        // Get a dictionary that associates song titles with Song objects, simplifies the next method
        var songData : [String : Song] = [:]
        for song in sortedInfoRepo {
            if songData[song.getTitle()] == nil {
                songData[song.getTitle()] = song
            }
        }
        
        // Get a dictionary that stores the number of times a song was played with the name
        var playcounts : [String:Int] = [:]
        for song in sortedInfoRepo {
            playcounts[song.getTitle(), default:0] += song.getTimesPlayed()
        }
        
        var song = Song(t: "", a: "", album: "", tp: 0, city: "")
        // Return the song with the biggest playcount
        if let (songName, playcount) =  playcounts.max(by:{$0.value < $1.value}) {
            song = Song(t: songName, a: songData[songName]!.getArtist(), album: songData[songName]!.getAlbum(), tp: playcount, city: "")
        }
        // If there are no values, return a blank Song object
        return song
    }
    // Returns the artist with the most plays based on location
    func getFavoriteArtist(location : String) -> (String, Int) {
        // Same sorting method from the getMostPlayed method
        var sortedInfoRepo : [Song] = infoRepository
        if(location != "unsorted") {
            sortedInfoRepo = [Song] ()
            for song in infoRepository {
                if(song.getLocationName() == location) {
                    sortedInfoRepo.append(song)
                }
            }
        }
        // Similar logic to getMostPlayed method, returns the name and listen count of the most played artist in a tuple
        var timesAppeared : [String: Int] = [:]
        for song in sortedInfoRepo {
            timesAppeared[song.getArtist(), default: 0] += song.getTimesPlayed()
        }
        let (favoriteArtist, listenCount) = timesAppeared.max(by:{$0.value < $1.value}) ?? ("", 0)
        return (favoriteArtist, listenCount)
    }
    // Returns the location that appears the most
    func getFavoriteLocation() -> (String, Int) {
        var timesAppeared : [String: Int] = [:]
        for song in infoRepository {
            timesAppeared[song.getLocationName(), default: 0] += song.getTimesPlayed()
        }
        let (favoriteLocation, listenCount) = timesAppeared.max(by:{$0.value < $1.value}) ?? ("", 0)
        return (favoriteLocation, listenCount)
    }
    
    // Returns a list of markers, one per location with titles containing the songs that were most played in that city
    func getSongMarkers(completion: @escaping ([Location]) -> Void) {
        getCoordinates() { coords in
            var markers : [Location] = [Location] ()
            var i = 0
            for coord in coords {
                let song = self.getMostPlayed(location: self.locations[i])
                i += 1
                markers.append(Location(name: song.getTitle(), coordinate: coord!))
            }
            completion(markers)
        }
    }
    // Returns a list of markers, one per location with titles containing the artists that were most played in that city
    func getArtistMarkers(completion: @escaping ([Location]) -> Void) {
        getCoordinates() { coords in
            var markers : [Location] = [Location] ()
            var i = 0
            for coord in coords {
                let artist = self.getFavoriteArtist(location: self.locations[i]).0
                i += 1
                markers.append(Location(name: artist, coordinate: coord!))
            }
            completion(markers)
        }
    }
}

