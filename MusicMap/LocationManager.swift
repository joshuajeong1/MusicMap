//
//  LocationManager.swift
//  MusicMap
//
//  Created by Josh Jeong on 11/28/24.
//

// Taken from Prof. Balasooriya's sample code
import Foundation
import CoreLocation

class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    // Taken from Prof Balasooriya's code
    func getCurrentCity(completion: @escaping (String) -> Void) {
        let lon = self.locationManager.location?.coordinate.longitude ?? 0
        let lat = self.locationManager.location?.coordinate.latitude ?? 0
        let geoCoder = CLGeocoder();
        let latAsString = lat
        let latVal = Double(latAsString)
    
        let lngAsString = lon
        let lngVal = Double(lngAsString)
            // Create Location
        let location = CLLocation(latitude: latVal, longitude: lngVal)

            // Geocode Location
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                // Process Response
                //self.processResponse(withPlacemarks: placemarks, error: error)
                  
            if let error = error {
                completion("Error Geocoding")
                print("Unable to Reverse Geocode Location (\(error))")
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    completion(placemark.locality!)
                    
                } else {
                    completion("")
                    let noLocation = "No Matching Addresses Found"
                    print(noLocation)
                }
            }
        }
        completion("")
        
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            // Insert code here of what should happen when Location services are authorized
            authorizationStatus = .authorizedWhenInUse
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            manager.startUpdatingLocation()
            break
            
        case .restricted:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .restricted
            break
            
        case .denied:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .denied
            break
            
        case .notDetermined:        // Authorization not determined yet.
            authorizationStatus = .notDetermined
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        print(userLocation.coordinate.latitude)
        print(userLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    
}
