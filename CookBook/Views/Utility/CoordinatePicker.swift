//
//  CoordinatePicker.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI
import MapKit

struct PinLocation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

class CoordinatePickerViewModel: ObservableObject {
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var chosenRegion: CLLocationCoordinate2D?
    
    var locations: [PinLocation] = []
    
    func selectCurrentRegion() {
        let latDelta = Double.random(in: -0.02 ..< 0.02)
        let longDelta = Double.random(in: -0.02 ..< 0.02)

        let latitude = region.center.latitude
        let longitude = region.center.longitude
        
        chosenRegion = CLLocationCoordinate2D(latitude: latitude + latDelta, longitude: longitude + longDelta)
        
        locations = [PinLocation(coordinate: chosenRegion!)]
    }
}

struct CoordinatePicker: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var zoom: CGFloat = 15
    
    @ObservedObject var viewModel: CoordinatePickerViewModel
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, annotationItems: viewModel.locations) { place in
                MapPin(coordinate: place.coordinate, tint: Color.red)
            }
            .onChange(of: viewModel.region) { newRegion in
            }
            
            VStack {
                SearchAreaButton(text: "Use This Approximate Location") {
                    viewModel.selectCurrentRegion()
                    self.presentationMode.wrappedValue.dismiss()
                }
                .offset(y: 280)
                .opacity(0.85)
            }
        }
        .navigationBarTitle("Location", displayMode: .inline)
    }
}



struct CoordinatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatePicker(viewModel: CoordinatePickerViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
