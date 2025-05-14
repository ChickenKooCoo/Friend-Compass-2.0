import Foundation
import FirebaseFirestore
import CoreLocation

class GroupLocationManager: ObservableObject {
    @Published var groupMembers: [DeviceLocation] = []

    private var db = Firestore.firestore()

    func listenToGroup(groupID: String) {
        db.collection("groups").document(groupID).addSnapshotListener { snapshot, _ in
            guard let data = snapshot?.data(),
                  let members = data["members"] as? [String] else { return }

            self.groupMembers = []

            for memberID in members {
                self.db.collection("devices").document(memberID).addSnapshotListener { snap, _ in
                    guard let loc = snap?.data(),
                          let lat = loc["latitude"] as? CLLocationDegrees,
                          let lon = loc["longitude"] as? CLLocationDegrees else { return }

                    DispatchQueue.main.async {
                        let newLoc = DeviceLocation(id: memberID, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        if let index = self.groupMembers.firstIndex(where: { $0.id == memberID }) {
                            self.groupMembers[index] = newLoc
                        } else {
                            self.groupMembers.append(newLoc)
                        }
                    }
                }
            }
        }
    }
}
