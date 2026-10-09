import SwiftUI

/// Root chrome. The active bento never leaves. Review, Rules, and Settings
/// arrive as sheets. Launch keys are read once after onboarding.
struct ContentView: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            if deck.ready {
                if deck.chart.rule.onboardingComplete {
                    ZStack {
                        ParticleField()
                            .ignoresSafeArea()
                        HomeBento()
                    }
                } else {
                    OnboardFlow()
                }
            }
        }
        .task { await deck.boot() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                Task { await deck.leaveActive() }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BentoDeck())
}
