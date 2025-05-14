import FirebaseAuth
import Foundation

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    @Published var userID: String?

    init() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("Auth error: \(error.localizedDescription)")
                } else {
                    self.userID = result?.user.uid
                }
            }
        } else {
            self.userID = Auth.auth().currentUser?.uid
        }
    }
}
