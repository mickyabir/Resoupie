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
    var chosenRegion: CLLocationCoordinate2D?
    var region: MKCoordinateRegion?
    @Published var country: String?
    @Published var locality: String?
    @Published var subLocality: String?

    var locations: [PinLocation] = []
    
    func selectCurrentRegion(continuation: @escaping () -> ()) {
        let latDelta = Double.random(in: -0.03 ..< 0.03)
        let longDelta = Double.random(in: -0.03 ..< 0.03)
        
        let latitude = region!.center.latitude
        let longitude = region!.center.longitude
        
        chosenRegion = CLLocationCoordinate2D(latitude: latitude + latDelta, longitude: longitude + longDelta)
        
        locations = [PinLocation(coordinate: chosenRegion!)]
        
        if let region = chosenRegion {
            let loc: CLLocation = CLLocation(latitude: region.latitude, longitude: region.longitude)
            let ceo: CLGeocoder = CLGeocoder()
            let _ = ceo.reverseGeocodeLocation(loc, completionHandler:
                                                {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    self.country = pm.country
                    self.locality = pm.locality
                    self.subLocality = pm.subLocality
                }
                
                continuation()
            })
        }
    }
}

struct CoordinatePicker: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var zoom: CGFloat = 15
    
    @ObservedObject var viewModel: CoordinatePickerViewModel
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: viewModel.locations) { place in
                MapPin(coordinate: place.coordinate, tint: Color.red)
            }
            .onChange(of: region) { newRegion in
                viewModel.region = region
            }
            
            VStack {
                SearchAreaButton(text: "Use This Approximate Location") {
                    viewModel.selectCurrentRegion() {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                .offset(y: 280)
                .opacity(1)
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
