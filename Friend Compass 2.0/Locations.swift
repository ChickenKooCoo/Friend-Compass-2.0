import SwiftUI
import MapKit
import CoreLocation

struct LocationView: View {
    @StateObject var locationManager = MyLocationManager()
    
    
    var body: some View {
            VStack {
                Map {
                    UserAnnotation()
                }

                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: 150, height: 150)

                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(locationManager.directionToTarget))
                }
                .padding()

                Text("Heading: \(locationManager.currentHeading, specifier: "%.1f")°")
            }
        }
    }


class MyLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    var locationManager = CLLocationManager()
    
    @Published var targetLocation = CLLocation(latitude: 36.1069, longitude: -112.1129)
    @Published var currentLocation: CLLocation?
    @Published var currentHeading: CLLocationDirection = 0
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
                currentLocation = location
                print("Updated Location: \(location.coordinate)")
            } else {
                print("No location available")
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
    }

    extension Double {
        var radians: Double { self * .pi / 180 }
        var degrees: Double { self * 180 / .pi }
    }

