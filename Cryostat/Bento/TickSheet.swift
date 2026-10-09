import SwiftUI

/// Twist screen for the single tick. Home already runs the swap. This sheet
/// states which want is moving and which hours are frozen.
struct TickSheet: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Measure.m) {
                    Image("cst_TwistHero")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: Measure.xl * 6, maxHeight: Measure.xl * 6)
                        .padding(Measure.s)
                        .background {
                            RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                                .fill(DesignTokens.surface)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                    Text("One tick")
                        .font(TypeFace.title())
                        .foregroundStyle(DesignTokens.ink)
                    Text("Only the active tile loses a minute. Frozen tiles keep the hours they already stored. Swap moves the tick. It does not restart either span.")
                        .font(TypeFace.body())
                        .foregroundStyle(DesignTokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    if let active = deck.chart.queue.active {
                        VStack(alignment: .leading, spacing: Measure.xs) {
                            Text("Active")
                                .font(TypeFace.caption())
                                .foregroundStyle(DesignTokens.accent)
                            Text(active.label)
                                .font(TypeFace.headline())
                                .foregroundStyle(DesignTokens.ink)
                            Text(InkFormat.hours(active.hoursRemaining))
                                .font(TypeFace.title())
                                .foregroundStyle(DesignTokens.ink)
                                .monospacedDigit()
                        }
                        .padding(Measure.m)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                                .fill(.regularMaterial)
                        }
                    } else {
                        Text("Nothing is cooling")
                            .font(TypeFace.headline())
                            .foregroundStyle(DesignTokens.ink)
                    }
                    ForEach(deck.chart.queue.shelf) { want in
                        HStack {
                            Text(want.label)
                                .font(TypeFace.body())
                                .foregroundStyle(DesignTokens.ink)
                            Spacer()
                            Text(InkFormat.hours(want.hoursRemaining))
                                .font(TypeFace.body())
                                .foregroundStyle(DesignTokens.muted)
                                .monospacedDigit()
                        }
                        .frame(minHeight: Measure.hit)
                    }
                }
                .padding(Measure.l)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.regularMaterial)
            .queueTitle("Single tick") { dismiss() }
            .safeAreaInset(edge: .bottom) {
                Button {
                    dismiss()
                } label: {
                    Text("Back to the bento")
                        .frame(maxWidth: .infinity, minHeight: Measure.hit)
                }
                .buttonStyle(CommitButtonStyle())
                .padding(Measure.m)
                .background(.regularMaterial)
            }
        }
        .queueSheet()
    }
}
