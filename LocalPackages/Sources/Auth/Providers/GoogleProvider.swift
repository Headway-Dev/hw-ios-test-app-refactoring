import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

final class GoogleProvider: NSObject {
    func signIn() async -> AuthDataResult? {
        guard let presentingViewController = await (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return nil
        }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return nil
        }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        let user = await createUser(config: signInConfig,
                                    controller: presentingViewController)
        let credential =
        GoogleAuthProvider.credential(withIDToken: user?.authentication.idToken ?? "",
                                      accessToken: user?.authentication.accessToken ?? "")
        if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
            return try? await currentUser.link(with: credential)
        }
        return try? await FirebaseAuth.Auth.auth().signIn(with: credential)
    }
    
    private func createUser(config: GIDConfiguration, controller: UIViewController) async -> GIDGoogleUser? {
        try? await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(with: config,
                                                presenting: controller,
                                                callback: { (user, error) in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    } else {
                        return continuation.resume(returning: user)
                    }
                })
            }
        }
    }
}
