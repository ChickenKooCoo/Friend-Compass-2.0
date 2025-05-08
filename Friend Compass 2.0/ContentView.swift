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

    var body: some View {
        LocationView()
        
        ZStack {
            //world map
            Map(position: $position)
                .mapStyle(.hybrid(elevation: .realistic))
                .mapStyle(.standard(pointsOfInterest: .all))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                    MapUserLocationButton()
                }
                .ignoresSafeArea()
            //back button
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            compassScale = 0.1
                            
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
            //compass image
            Color.clear
                .overlay(
                    ZStack {
                        Color.black
                        Image("compass")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1)
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
            
            
            //button -> enlarges hole
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
//            Circle()
//                .frame(width: 100, height: 100)
//                .shadow(color: .red, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
        }
//        Image("shadow")
//            .resizable()
//            .scaledToFit()
//            .scaleEffect(1)
        
        
        
        
        VStack {
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct Locations {  //2nd
    static let prospectLocation = CLLocationCoordinate2D(        //lines 74-93 were a stretch to add a second button
        
        latitude: 42.0791, longitude: -87.94954
        
    )
    static let prospectPosition = MapCameraPosition.region(
        
        MKCoordinateRegion(
            
            center: Locations.prospectLocation,
            
            span: MKCoordinateSpan(
                
                latitudeDelta: 0.01, longitudeDelta: 0.01
                
            )
            
        ))
    static let prospectAngled = MapCameraPosition.camera(
        
        MapCamera(
            
            centerCoordinate: Locations.prospectLocation,
            
            distance: 500,
            
            heading: 260.0,
            
            pitch: 60.0
        )
    )
}
