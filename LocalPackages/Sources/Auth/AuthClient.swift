
import FirebaseFirestore
import FirebaseAuth

struct AuthClient {
    static let shared = AuthClient()
    
    func anonymous() async throws -> Bool {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            return true
        }
        guard let result = await AnonymousProvider().signIn() else {
            return false
        }
        return await Self.createUser(authResult: result, name: "Anonymous")
    }
    
    func google() async throws -> Bool {
        let provider = GoogleProvider()
        guard let result = await provider.signIn() else {
            return false
        }
        return await Self.createUser(authResult: result)
    }
    
    func apple() async throws -> Bool {
        let provider = AppleProvider()
        guard let result = await provider.signIn() else {
            return false
        }
        return await Self.createUser(authResult: result)
    }
}

extension AuthClient {
    static fileprivate func createUser(authResult: AuthDataResult, name: String = "") async -> Bool {
        if await Self.existUser(authResult: authResult) {
            return true
        }
        // Hidden logic
        return true
    }
    
    static private func existUser(authResult: AuthDataResult) async -> Bool {
        await withCheckedContinuation { continuation in
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(authResult.user.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let name = authResult.user.displayName, !name.isEmpty {
                        document.reference.updateData(["name" : name])
                    }
                    return continuation.resume(returning: true)
                } else {
                    return continuation.resume(returning: false)
                }
            }
        }
    }
}
