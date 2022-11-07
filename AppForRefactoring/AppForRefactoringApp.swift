import SwiftUI
import Auth
import ComposableArchitecture

@main
struct AppForRefactoringApp: App {
    var body: some Scene {
        WindowGroup {
            AuthView(
                store: Store(
                    initialState: AuthReducer.State(),
                    reducer: AuthReducer()
                )
            )
        }
    }
}
