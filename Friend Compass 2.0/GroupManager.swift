import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreLocation



//struct Group: Identifiable, Codable {
//    var id: String
//    var name: String
//    var members: [String]
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case members
//    }
//}

import Foundation
import FirebaseFirestore
import CoreLocation
import SwiftUI

struct DeviceLocation: Identifiable {
    var id: String
    var coordinate: CLLocationCoordinate2D
}

class GroupLocationManager: ObservableObject {
    @Published var groupMembers: [DeviceLocation] = []
    @Published var groups: [Group] = []
    @Published var expandedGroupID: String?
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

    func renameGroup(_ groupID: String, to newName: String) {
        db.collection("groups").document(groupID).updateData(["name": newName])
    }

    func addMember(_ memberID: String, to groupID: String) {
        let color = randomColorHex()
        db.collection("groups").document(groupID).updateData([
            "members": FieldValue.arrayUnion([memberID])
        ])
        db.collection("users").document(memberID).setData(["colorHex": color], merge: true)
    }

    func removeMember(_ memberID: String, from groupID: String) {
        db.collection("groups").document(groupID).updateData([
            "members": FieldValue.arrayRemove([memberID])
        ])
    }

    func toggleGroupExpansion(groupID: String) {
        expandedGroupID = (expandedGroupID == groupID) ? nil : groupID
        if let groupID = expandedGroupID {
            listenToGroup(groupID: groupID)
        }
    }

    private func randomColorHex() -> String {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}


//class GroupLocationManager: ObservableObject {
//
//    @Published var groups: [Group] = []
//    @Published var expandedGroupID: String?
//    private var db = Firestore.firestore()
//
//    
//    func renameGroup(_ groupID: String, to newName: String) {
//        db.collection("groups").document(groupID).updateData([
//            "name": newName
//        ])
//    }
//    
//    func addMember(_ memberID: String, to groupID: String) {
//        db.collection("groups").document(groupID).updateData([
//            "members": FieldValue.arrayUnion([memberID])
//        ])
//    }
//
//    func removeMember(_ memberID: String, from groupID: String) {
//        db.collection("groups").document(groupID).updateData([
//            "members": FieldValue.arrayRemove([memberID])
//        ])
//    }
//
//    func toggleGroupExpansion(groupID: String) {
//        expandedGroupID = (expandedGroupID == groupID) ? nil : groupID
//    }
//    
//    func fetchGroups() {
//        guard let userID = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("groups")
//            .whereField("owner", isEqualTo: userID)
//            .addSnapshotListener { snapshot, _ in
//                self.groups = snapshot?.documents.compactMap { doc in
//                    try? doc.data(as: Group.self)
//                } ?? []
//            }
//    }
//
//    func fetchGroups(for userID: String) {
//        db.collection("groups").whereField("members", arrayContains: userID).addSnapshotListener { snapshot, error in
//            guard let documents = snapshot?.documents else { return }
//            self.groups = documents.compactMap { doc -> Group? in
//                try? doc.data(as: Group.self)
//            }
//        }
//    }
//
//    func addGroup(name: String, members: [String]) {
//        let newGroup = Group(id: UUID().uuidString, name: name, members: members)
//        do {
//            try db.collection("groups").document(newGroup.id!).setData(from: newGroup)
//        } catch {
//            print("Error writing group to Firestore: \(error)")
//        }
//    }
//    
//    @Published var groupMembers: [DeviceLocation] = []
//
//
//    func listenToGroup(groupID: String) {
//        db.collection("groups").document(groupID).addSnapshotListener { snapshot, _ in
//            guard let data = snapshot?.data(),
//                  let members = data["members"] as? [String] else { return }
//
//            self.groupMembers = []
//
//            for memberID in members {
//                self.db.collection("devices").document(memberID).addSnapshotListener { snap, _ in
//                    guard let loc = snap?.data(),
//                          let lat = loc["latitude"] as? CLLocationDegrees,
//                          let lon = loc["longitude"] as? CLLocationDegrees else { return }
//
//                    DispatchQueue.main.async {
//                        let newLoc = DeviceLocation(id: memberID, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
//                        if let index = self.groupMembers.firstIndex(where: { $0.id == memberID }) {
//                            self.groupMembers[index] = newLoc
//                        } else {
//                            self.groupMembers.append(newLoc)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

//struct Group: Identifiable {
//    let id: UUID
//    var name: String
//    var members: [String]
//}
