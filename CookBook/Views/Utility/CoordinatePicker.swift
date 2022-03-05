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
    @Published var chosenRegion: CLLocationCoordinate2D?
    var region: MKCoordinateRegion?
    @Published var country: String?
    @Published var locality: String?
    @Published var subLocality: String?

    var locations: [PinLocation] = []
    
    func selectCurrentRegion(continuation: @escaping () -> ()) {
        let latDelta = Double.random(in: -region!.span.latitudeDelta/4..<region!.span.latitudeDelta/4)
        let longDelta = Double.random(in: -region!.span.longitudeDelta/8..<region!.span.longitudeDelta/8)
        
        let latitude = region!.center.latitude
        let longitude = region!.center.longitude
        
        chosenRegion = CLLocationCoordinate2D(latitude: latitude + latDelta, longitude: longitude + longDelta)
        
        locations = [PinLocation(coordinate: chosenRegion!)]
        
        if let region = chosenRegion {
            let loc: CLLocation = CLLocation(latitude: region.latitude, longitude: region.longitude)
            let ceo: CLGeocoder = CLGeocoder()
            let _ = ceo.reverseGeocodeLocation(loc, completionHandler:
                                                {(placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if let placemarks = placemarks {
                    let pm = placemarks as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks[0]
                        self.country = pm.country
                        self.locality = pm.locality
                        self.subLocality = pm.subLocality
                    }
                }
                
                continuation()
            })
        }
    }
}

struct RegionLocation: Identifiable {
    var id: UUID
}

struct CoordinatePicker: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var zoom: CGFloat = 15
    
    @ObservedObject var viewModel: CoordinatePickerViewModel
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: viewModel.locations) { place in
                MapMarker(coordinate: place.coordinate)
            }
            .onChange(of: region) { newRegion in
                viewModel.region = region
            }
            .onTapGesture {
                
            }

            Circle()
                .strokeBorder(Color.white, lineWidth: 4)
                .background(Circle().foregroundColor(Color.blue).opacity(0.1))
                .frame(width: 300, height: 300)
                .allowsHitTesting(false)
        }
        .navigationBarTitle("Location", displayMode: .inline)
        .toolbar {
            Button {
                viewModel.selectCurrentRegion() {
                    self.presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Select")
            }
        }
    }
}
