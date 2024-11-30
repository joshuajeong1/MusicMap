//
//  SettingsView.swift
//  MusicMap
//
//  Created by Josh Jeong on 11/28/24.
//

import Foundation
import SwiftUI

struct SettingsView : View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isSignedIn : Bool
    @State var data : InfoDictionary
    var body : some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            // Clear the data and clear the locations array
            Button(action: {
                data.clear()
                data.locations = [String] ()
            }) {
                HStack {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("Clear Data")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(width:250)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
            }
            
            // Return to the sign in window
            Button(action: {
                isSignedIn = false
                dismiss()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("Return to Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(width:250)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
            }
            
            
        }
    }
}
