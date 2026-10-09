import SwiftUI

/// Active queue role. The one tile whose hours decrement while the fold is Ticking.
/// A tap opens donate while cooling, or release when the ring reads zero.
struct ActiveTile: View {
    @EnvironmentObject private var deck: BentoDeck
    @ScaledMetric(relativeTo: .headline) private var ringSide = 72
    var want: Want
    var fold: BentoFold
    var currency: String

    var body: some View {
        Button {
            deck.sheet = fold == .cool ? .release : .donate
        } label: {
            tile
        }
        .buttonStyle(TilePressStyle())
        .disabled(deck.busy)
        .contextMenu {
            ForEach(deck.chart.queue.shelf) { donor in
                Button("Donate " + donor.label) {
                    Task { await deck.donate(from: donor.id) }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(want.label + ", " + InkFormat.hours(want.hoursRemaining) + " cooling")
        .accessibilityHint("Opens donate, or long press a frozen tile")
    }

    private var tile: some View {
        VStack(alignment: .leading, spacing: Measure.s) {
            HStack {
                Text(fold == .cool ? "Ready to release" : "Cooling now")
                    .font(TypeFace.caption())
                    .foregroundStyle(DesignTokens.accent)
                Spacer()
                Text(InkFormat.money(want.price, currency: currency))
                    .font(TypeFace.caption())
                    .foregroundStyle(DesignTokens.muted)
                    .monospacedDigit()
            }
            Text(want.label)
                .font(TypeFace.headline())
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Measure.xs)
            HStack(alignment: .center, spacing: Measure.s) {
                ring
                Text(InkFormat.hours(want.hoursRemaining))
                    .font(TypeFace.display())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer(minLength: 0)
            }
            Text("Long press to donate frozen hours.")
                .font(TypeFace.micro())
                .foregroundStyle(DesignTokens.muted)
        }
        .padding(Measure.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    Image("cst_CardBackdrop")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.28)
                        .clipShape(RoundedRectangle(cornerRadius: Measure.card, style: .continuous))
                        .allowsHitTesting(false)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                        .fill(DesignTokens.accent.opacity(0.16))
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: Measure.card, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: Measure.card, style: .continuous))
    }

    private var ring: some View {
        let fraction = min(1, want.hoursRemaining / HoursSpan.ceilingHours)
        return ZStack {
            Circle()
                .stroke(DesignTokens.muted.opacity(0.35), lineWidth: Measure.xs)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(DesignTokens.accent, style: StrokeStyle(lineWidth: Measure.xs, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image("cst_ControlFace")
                .resizable()
                .scaledToFit()
                .padding(Measure.xs)
        }
        .frame(width: ringSide, height: ringSide)
        .accessibilityHidden(true)
    }
}
