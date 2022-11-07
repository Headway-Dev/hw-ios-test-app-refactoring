import UIKit
import FirebaseCore
import FirebaseAuth

final class EmailProvider: NSObject {
    func signUp(email: String, password: String) async -> AuthDataResult? {
        if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
            let credential =
            EmailAuthProvider.credential(withEmail: email,
                                         password: password)
            return try? await currentUser.link(with: credential)
        }
        return try? await FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                                              password: password)
    }
    
    func signIn(email: String, password: String) async -> AuthDataResult? {
        return try? await FirebaseAuth.Auth.auth().signIn(withEmail: email,
                                                          password: password)
    }
}

