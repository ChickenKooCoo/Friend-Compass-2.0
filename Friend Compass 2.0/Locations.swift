import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore
import Foundation

struct LocationView: View {
    @ObservedObject var locationManager: MyLocationManager
    var targets: [DeviceLocation]
    

    var body: some View {
        VStack {
            ForEach(targets) { target in
                VStack(spacing: 2) {
                    Text("To: \(target.id.prefix(6))")
                        .font(.caption)
                        .foregroundColor(.white)
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(locationManager.direction(to: target.coordinate)))
                        .foregroundColor(.white)
                }
                .padding(5)
            }
        }
    }
}

class MyLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let db = Firestore.firestore()

    var locationManager = CLLocationManager()
    @Published var targetLocation = CLLocation(latitude: 36.1069, longitude: -112.1129)
    @Published var currentLocation: CLLocation?
    @Published var currentHeading: CLLocationDirection = 0

    @Published var latitudeString: String = "36.1069" {
        didSet {
            updateTargetLocation()
        }
    }

    @Published var longitudeString: String = "-112.1129" {
        didSet {
            updateTargetLocation()
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func updateTargetLocation() {
        if let lat = Double(latitudeString), let lon = Double(longitudeString) {
            targetLocation = CLLocation(latitude: lat, longitude: lon)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            print("Updated Location: \(location.coordinate)")

            // Upload to Firestore
            db.collection("devices").document("myDeviceID").setData([
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ])
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading.trueHeading
    }

    var bearingToTarget: Double {
        guard let currentLocation = currentLocation else { return 0 }

        let lat1 = currentLocation.coordinate.latitude.radians
        let lon1 = currentLocation.coordinate.longitude.radians
        let lat2 = targetLocation.coordinate.latitude.radians
        let lon2 = targetLocation.coordinate.longitude.radians

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x).degrees

        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    var directionToTarget: Double {
        (bearingToTarget - currentHeading + 360).truncatingRemainder(dividingBy: 360)
    }

    func direction(to coordinate: CLLocationCoordinate2D) -> Double {
        guard let currentLocation = currentLocation else { return 0 }

        let lat1 = currentLocation.coordinate.latitude.radians
        let lon1 = currentLocation.coordinate.longitude.radians
        let lat2 = coordinate.latitude.radians
        let lon2 = coordinate.longitude.radians

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x).degrees
        return (bearing - currentHeading + 360).truncatingRemainder(dividingBy: 360)
    }
}
class RemoteLocationManager: ObservableObject {
    @Published var devices: [DeviceLocation] = []

    private var db = Firestore.firestore()

    init() {
        listenForUpdates()
    }

    func listenForUpdates() {
        db.collection("devices").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            self.devices = documents.compactMap { doc in
                let data = doc.data()
                guard let lat = data["latitude"] as? CLLocationDegrees,
                      let lon = data["longitude"] as? CLLocationDegrees else { return nil }
                return DeviceLocation(id: doc.documentID, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }
    }
}

struct DeviceLocation: Identifiable {
    let id: String
    var coordinate: CLLocationCoordinate2D  
}

extension Double {
    var radians: Double { self * .pi / 180 }
    var degrees: Double { self * 180 / .pi }
}
