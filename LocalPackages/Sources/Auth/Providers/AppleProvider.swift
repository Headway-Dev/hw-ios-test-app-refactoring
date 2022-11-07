import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseCore
import FirebaseAuth

final class AppleProvider: NSObject {
    let providerDelegate = AppleProviderDelegate()
    
    func signIn() async -> AuthDataResult? {
        try? await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                request.nonce = self.providerDelegate.setNonse()
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self.providerDelegate
                authorizationController.presentationContextProvider = self.providerDelegate
                self.providerDelegate.completion = { authDataResult, error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    } else {
                        return continuation.resume(returning: authDataResult)
                    }
                }
                authorizationController.performRequests()
            }
        }
    }
}

final class AppleProviderDelegate: NSObject {
    var completion: ((AuthDataResult?, Error?) -> Void)?
    private var currentNonce: String?
    
    func setNonse() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
    
    // MARK: - Helpers
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
 
extension AppleProviderDelegate: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
                currentUser.link(with: credential) { [weak self] (authResult, error) in
                    guard let self = self else {
                        return
                    }
                    if self.completion != nil {
                        self.completion?(authResult, error)
                    }
                }
            } else {
                FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    guard let self = self else {
                        return
                    }
                    if self.completion != nil {
                        self.completion?(authResult, error)
                    }
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
        if completion != nil {
            completion?(nil, error)
        }
    }
}
// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleProviderDelegate: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.delegate!.window!!
    }
}
