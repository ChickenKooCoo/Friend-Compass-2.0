import SwiftUI
import MapKit

struct ContentView: View {
    @State var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            distance: 80000000,
            heading: 0,
            pitch: 0
        )
    )
    @State private var compassScale: CGFloat = 0.2
    var holeRadius: CGFloat {
        50
    }
    @State private var rotation: Angle = .degrees(0)


    var body: some View {
        ZStack {
            // 🌍 World Map
            Map(position: $position) {
                UserAnnotation()
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .mapStyle(.standard(pointsOfInterest: .all))
            .mapControls {
                MapCompass()
                MapScaleView()
                MapUserLocationButton()
            }
            .ignoresSafeArea()

            // 🔙 Back Button
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            compassScale = 0.2
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

            // 🧭 Compass Hole Overlay
            Color.clear
                .overlay(
                    ZStack {
                        Color.black
                        Image("compass")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1)
                        // 🧭 Circular Text around the hole
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

            


            // 📍 Arrow (Custom View)
            LocationView()

            // ⭕ Button to enlarge the hole
            if compassScale < 1.0 {
                Button(action: {
                    withAnimation {
                        compassScale = 2.5
                    }
                }) {
                    Color.clear
                        .clipShape(Circle())
                        .scaleEffect(0.7)
                }
                .frame(width: 100, height: 100)
            }
        }
    }
}

// 🔠 Circular Text View
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
