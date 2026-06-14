import SwiftUI

struct RootView: View {
    @StateObject private var session = SessionViewModel()

    var body: some View {
        Group {
            if session.isSignedIn {
                if session.isCheckingProfile {
                    ProgressView("Loading profile...")
                } else if session.isOnboarded {
                    MainTabView()
                } else {
                    ProfileSetupView()
                }
            } else {
                AuthView()
            }
        }
        .environmentObject(session)
    }
}
