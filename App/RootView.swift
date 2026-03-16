import SwiftUI

struct RootView: View {
    @StateObject private var session = SessionViewModel()

    var body: some View {
        Group {
            if session.isSignedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .environmentObject(session)
    }
}
