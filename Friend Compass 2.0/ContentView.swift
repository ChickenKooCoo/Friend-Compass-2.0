import SwiftUI
import MapKit
import Firebase

struct ContentView: View {

    @StateObject var remoteLocationManager = RemoteLocationManager()
    @ObservedObject var friendManager = FriendLocationManager()
    @ObservedObject var locationManager = MyLocationManager()
    
    @StateObject var groupManager = GroupLocationManager()
    @State private var selectedGroupID: String? = nil

    @State var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            distance: 90000000,
            heading: 0,
            pitch: 0
        )
    )
    var holeRadius: CGFloat {
        50
    }
    @State private var rotation: Angle = .degrees(0)
    
    @StateObject var authManager = AuthManager.shared
    
    @State private var compassScale: CGFloat = 0.2
    @State private var mapScale: CGFloat = 0.2
    
    
    var body: some View {
        ZStack {
            // World Map
            Map(position: $position) {
                if let coordinate = locationManager.currentLocation?.coordinate {
                    Annotation("Hi", coordinate: coordinate) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                }
                
                ForEach(remoteLocationManager.devices) { device in
                    Annotation("Hi 2", coordinate: device.coordinate) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .mapStyle(.standard(pointsOfInterest: .all))
            .mapControls {
                MapScaleView()
                MapUserLocationButton()
                MapCompass()
            }
            .ignoresSafeArea()
            .scaleEffect(mapScale)
            
            // Back Button
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 2)) {
                            compassScale = 0.2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut(duration: 1)) {
                                mapScale = 0.3
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.leading, 20)
                Spacer()
            }
            
            // Compass Hole with Circular Text
            Color.clear
                .overlay(
                    ZStack {
                        Color.black
                        Image("compass")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1)
                        
                        CircularText(
                            text: "  Tap here for world map.  ",
                            radius: holeRadius,
                            font: .system(size: 14, weight: .bold)
                        )
                        .rotationEffect(rotation)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                                rotation = .degrees(-360)
                            }
                        }
                        .allowsHitTesting(false)
                        .foregroundColor(.white)
                    }
                        .mask(
                            ZStack {
                                Rectangle()
                                Circle()
                                    .scaleEffect(compassScale)
                                    .blendMode(.destinationOut)
                            }
                                .compositingGroup()
                        )
                )
                .allowsHitTesting(false)
            
            // Compass arrow
            LocationView(locationManager: locationManager, targets: remoteLocationManager.devices)
            
            // Button to enlarge hole
            if compassScale < 1.0 {
                Button(action: {
                    withAnimation {
                        compassScale = 2.5
                    }
                    withAnimation(.linear(duration: 0.1)) {
                        mapScale = 1
                    }
                }) {
                    Color.clear
                        .clipShape(Circle())
                        .scaleEffect(0.7)
                }
                .frame(width: 100, height: 100)
            }
            
        }
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - User Location Info
                if let myLocation = locationManager.currentLocation {
                    Text("My Location: \(myLocation.coordinate.latitude), \(myLocation.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundColor(.blue)
                } else {
                    Text("My Location: Unavailable")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // MARK: - Groups Debug Info
                Text("Groups")
                    .font(.headline)
                ForEach(groupManager.groups) { group in
                    Button(action: {
                        selectedGroupID = group.id
                    }) {
                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.headline)
                            Text("Members: \(group.members.count)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                // MARK: - Friends Debug Info
                Text("Friends")
                    .font(.headline)
                ForEach(friendManager.friends) { friend in
                    VStack(alignment: .leading) {
                        Text("Friend: \(friend.name)")
                            .font(.subheadline)
                        if let location = friend.location {
                            Text("Location: \(location.latitude), \(location.longitude)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("Location: Unavailable")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity,maxHeight: 130)
    }
}

struct CircularText: View {
    let text: String
    let radius: CGFloat
    let font: Font

    var body: some View {
        ZStack {
            ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                let angle = Double(index) / Double(text.count) * 360.0
                let radians = Angle(degrees: angle).radians

                Text(String(char))
                    .font(font)
                    .foregroundColor(.white)
                    .overlay(
                        Text(String(char))
                            .font(font)
                            .foregroundColor(.black)
                            .offset(x: 1, y: 1)
                    )
                    .rotationEffect(Angle(degrees: angle + 90))
                    .position(
                        x: cos(radians) * radius + radius,
                        y: sin(radians) * radius + radius
                    )
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

// 📍 Sample Location Setup
struct Locations {
    static let prospectLocation = CLLocationCoordinate2D(
        latitude: 42.0791,
        longitude: -87.94954
    )

    static let prospectPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: Locations.prospectLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    static let prospectAngled = MapCameraPosition.camera(
        MapCamera(
            centerCoordinate: Locations.prospectLocation,
            distance: 500,
            heading: 260.0,
            pitch: 60.0
        )
    )
}

#Preview {
    ContentView()
}
