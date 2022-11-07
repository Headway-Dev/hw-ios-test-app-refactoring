import SwiftUI
import ComposableArchitecture

public struct AuthView: View {
    var store: StoreOf<AuthReducer>
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    public init(store: StoreOf<AuthReducer>) {
        self.store = store
    }
    
    @State var presentEmailAuth = false
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                NavigationView {
                    ZStack {
                        VStack {
                            VStack {
                                ZStack {
                                    HStack {
                                        Button("Skip") {
                                            viewStore.send(.anonymous)
                                            mode.wrappedValue.dismiss()
                                        }
                                        .disabled(viewStore.isActivity)
                                        .frame(width: 48.0, height: 32.0)
                                        .font(.system(size: 12.0).bold())
                                        .cornerRadius(6.0)
                                        .padding(EdgeInsets(top: 12.0, leading: 0.0, bottom: 0.0, trailing: 16.0))
                                    }
                                    .frame(width: proxy.size.width, height: 32.0, alignment: .trailing)
                                    .padding(.bottom, (proxy.size.width - proxy.safeAreaInsets.top) - 68.0)
                                }
                                .frame(height: (proxy.size.width - proxy.safeAreaInsets.top) + 16.0, alignment: .bottom)
                                Spacer(minLength: 16.0)
                                Text("Title")
                                    .font(.headline)
                                    .frame(width: proxy.size.width - 48.0, height: 32.0, alignment: .top)
                                Text("Subtitle")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .frame(width: proxy.size.width - 48.0, height: 48.0, alignment: .top)
                            }
                            .frame(height: (proxy.size.width - proxy.safeAreaInsets.top) + 64.0)
                            Spacer(minLength: 16.0)
                            VStack {
                                VStack {
                                    Button {
                                        viewStore.send(.apple)
                                    } label: {
                                        Image(systemName: "applelogo")
                                            .resizable()
                                            .frame(width: 24.0, height: 24.0)
                                    }
                                    .disabled(viewStore.isActivity)
                                    .frame(width: proxy.size.width - 32.0)
                                    .padding(.bottom, 8.0)
                                    
                                    Button {
                                        viewStore.send(.google)
                                    } label: {
                                        Image(systemName: "g.circle")
                                            .resizable()
                                            .frame(width: 24.0, height: 24.0)
                                    }
                                    .disabled(viewStore.isActivity)
                                    .frame(width: 56.0, height: 56.0)
                                    .cornerRadius(8.0)
                                    .cornerRadius(8.0)
                                    .padding(.trailing, 8.0)
                                }
                            }
                            .frame(height: 128.0)
                            .padding(.bottom, 8.0)
                            
                            Text(.init("Privacy policy"))
                                .frame(width: proxy.size.width)
                                .font(.system(size: 12.0))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 8.0)
                        }
                        if viewStore.isActivity {
                            ProgressView()
                        }
                    }
                    .onChange(of: viewStore.isPresented) { isPresented in
                        if !isPresented {
                            self.mode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(
            store: Store(
                initialState: AuthReducer.State(),
                reducer: AuthReducer()
            )
        )
    }
}
