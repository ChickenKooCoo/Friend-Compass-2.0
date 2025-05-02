import SwiftUI
import MapKit
import CoreLocation

struct LocationView: View {
    var locationManager = MyLocationManager()
    var body: some View {
        Map() {
            UserAnnotation()
        }
        .onAppear() {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "university"
            let location = CLLocationCoordinate2D(latitude: 36.0544, longitude: -112.1401)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            request.region = MKCoordinateRegion(center: location, span: span)
            
            Task {
                let search = MKLocalSearch(request: request)
                let response = try? await search.start()
                print(response?.mapItems ?? "None Found")
            }
            
        }
    }
}

class MyLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locations.first?.coordinate {
            print(coordinate)
        }
        else {
            print("No location available")
        }
    }
}
