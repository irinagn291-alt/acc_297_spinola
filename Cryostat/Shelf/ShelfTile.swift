import SwiftUI

/// Shelf queue role. A frozen tile keeps its stored hours.
/// A tap writes a SwapMark and moves the tick onto this want.
struct ShelvedTile: View {
    var want: Want
    var swap: () -> Void

    var body: some View {
        Button(action: swap) {
            VStack(alignment: .leading, spacing: Measure.xs) {
                Text("Frozen")
                    .font(TypeFace.caption())
                    .foregroundStyle(DesignTokens.muted)
                Text(want.label)
                    .font(TypeFace.headline())
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(InkFormat.hours(want.hoursRemaining))
                    .font(TypeFace.headline())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .layoutPriority(1)
                Text("Swap the tick")
                    .font(TypeFace.caption())
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(1)
            }
            .padding(Measure.s)
            .frame(maxWidth: .infinity, minHeight: Measure.hit * 3, maxHeight: .infinity, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                    .fill(.thinMaterial)
            }
            .contentShape(RoundedRectangle(cornerRadius: Measure.card, style: .continuous))
        }
        .buttonStyle(TilePressStyle())
        .accessibilityLabel(want.label + ", frozen at " + InkFormat.hours(want.hoursRemaining))
        .accessibilityHint("Swaps the cooling tick onto this tile")
    }
}
