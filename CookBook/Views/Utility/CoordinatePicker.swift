//
//  CoordinatePicker.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI
import MapKit

struct CoordinatePicker: View {
    @State var zoom: CGFloat = 15
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.top)
                .onChange(of: region) { newRegion in
                }
            
            ZStack {
                Button {
                    
                } label: {
                    Text("Use Current Location")
                }
            }
        }
    }
}



struct CoordinatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatePicker()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
