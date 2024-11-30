
//
//  Location.swift
//  MusicMap
//
//  Created by Josh Jeong on 11/27/24.
//

import Foundation
import MapKit
import SwiftUI

// Location struct for markers
struct Location : Identifiable {
    let id = UUID()
    var name : String
    var coordinate : CLLocationCoordinate2D
}

