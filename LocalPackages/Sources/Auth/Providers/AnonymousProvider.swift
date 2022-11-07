import UIKit
import FirebaseAuth

final class AnonymousProvider: NSObject {
    func signIn() async -> AuthDataResult? {
        try? await FirebaseAuth.Auth.auth().signInAnonymously()
    }
}
