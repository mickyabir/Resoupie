//
//  LocationMapSnapshot.swift
//  Resoupie
//
//  Created by Michael Abir on 2/28/22.
//

import SwiftUI
import MapKit

struct LocationMapSnapshot<Content: View>: View {
    let location: CLLocationCoordinate2D
    
    var span: CLLocationDegrees = 0.4
    
    @State private var snapshotImage: UIImage? = nil
    let width: CGFloat
    let height: CGFloat
    
    @ViewBuilder let content: (() -> Content)
    
    var body: some View {
        Group {
            if let image = snapshotImage {
                ZStack {
                    Image(uiImage: image)
                    content()
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .onAppear {
            generateSnapshot(width: width, height: height)
        }
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true
        
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            if let snapshot = snapshotOrNil {
                self.snapshotImage = snapshot.image
            }
        }
    }
}

struct LocationMapSnapshot_Previews: PreviewProvider {
    static var previews: some View {
        let location = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962)         
        LocationMapSnapshot(location: location, width: 300, height: 300) {
            
        }
    }
}
