import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserManager: ObservableObject {
    @Published var userID: String = ""
    private var db = Firestore.firestore()

    init() {
        signInAnonymously()
    }

    func signInAnonymously() {
        if let currentUser = Auth.auth().currentUser {
            self.userID = currentUser.uid
        } else {
            Auth.auth().signInAnonymously { result, error in
                if let user = result?.user {
                    self.userID = user.uid
                    self.createUserProfileIfNeeded()
                }
            }
        }
    }

    private func createUserProfileIfNeeded() {
        db.collection("users").document(userID).getDocument { doc, _ in
            if doc?.exists == false {
                self.db.collection("users").document(self.userID).setData([
                    "friends": [],
                    "groups": []
                ])
            }
        }
    }

    func sendFriendRequest(to otherUserID: String) {
        db.collection("friend_requests").document(otherUserID).collection("requests").document(userID).setData([
            "from": userID,
            "timestamp": FieldValue.serverTimestamp()
        ])
    }

    func acceptFriendRequest(from otherUserID: String) {
        let userRef = db.collection("users").document(userID)
        let otherRef = db.collection("users").document(otherUserID)

        userRef.updateData(["friends": FieldValue.arrayUnion([otherUserID])])
        otherRef.updateData(["friends": FieldValue.arrayUnion([userID])])

        db.collection("friend_requests").document(userID).collection("requests").document(otherUserID).delete()
    }

    func deleteFriend(_ otherUserID: String) {
        let userRef = db.collection("users").document(userID)
        let otherRef = db.collection("users").document(otherUserID)

        userRef.updateData(["friends": FieldValue.arrayRemove([otherUserID])])
        otherRef.updateData(["friends": FieldValue.arrayRemove([userID])])
    }

    func createGroup(name: String, members: [String]) {
        let groupRef = db.collection("groups").document()
        groupRef.setData([
            "name": name,
            "members": members + [userID]
        ])
    }

    func deleteGroup(groupID: String) {
        db.collection("groups").document(groupID).delete()
    }
}
