//
//  MapView.swift
//  MusicMap
//
//  Created by Josh Jeong on 10/27/24.
//

import SwiftUI
import MapKit


struct MapView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var data : InfoDictionary

    // state property that represents the current map region
    @State private var cameraPosition : MapCameraPosition = .automatic
    // state property that stores marker locations in current map region
    @State var markers : [Location] = [Location] ()
    var body: some View {
        
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                // Map object, marker on the city
                // Iterates over the markers in the array and adds them to the map
                ForEach(markers, id: \.id) { marker in
                    Marker(marker.name, coordinate: marker.coordinate)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // This button changes the markers to song markers
                    data.getSongMarkers() { markers in
                        cameraPosition = .region(data.getRegion(markers: markers))
                        self.markers = markers
                    }
                })
                {
                    Text("Sort by Songs")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                    // This button changes the markers to artist markers
                    Button(action: {
                        data.getArtistMarkers() { markers in
                            cameraPosition = .region(data.getRegion(markers: markers))
                            self.markers = markers
                        }
                    })
                    {
                        Text("Sort by Artist")
                    }
            }
        }
        .onAppear {
            // Sets the camera position to the region when the map appears and gets the markers from the InfoRepository
            // Defaults to song markers
            data.getSongMarkers() { markers in
                cameraPosition = .region(data.getRegion(markers: markers))
                self.markers = markers
            }
        }
    }
}

