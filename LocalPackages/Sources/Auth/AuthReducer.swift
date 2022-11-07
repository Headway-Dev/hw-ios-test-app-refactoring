import Foundation
import ComposableArchitecture

public struct AuthReducer: ReducerProtocol {
    public struct Failed: Equatable, Error {}
    
    public struct State: Equatable {
        public var isAuthorized = false
        public var isPresented = true
        public var isActivity = false
        
        public init(isAuthorized: Bool = false) {
            self.isAuthorized = isAuthorized
        }
    }
    
    public enum Action: Equatable {
        case anonymous
        case apple
        case google
        case email(String, String, String)
        case logout
        case finished(Bool)
    }
    
    public init() {}
    
    private let authClient = AuthClient.shared
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .anonymous:
            return .task {
                .finished(try await self.authClient.anonymous())
            }
            
        case .apple:
            state.isActivity = true
            return .task {
                .finished(try await self.authClient.apple())
            }
        case .google:
            state.isActivity = true
            return .task {
                .finished(try await self.authClient.google())
            }
        case .email:
            break
            
        case .logout:
            break
            
        case .finished(let authState):
            state.isAuthorized = authState
            if authState {
                state.isPresented = false
            }
            state.isActivity = false
            return .none
        }
        
        return .none
    }
}
