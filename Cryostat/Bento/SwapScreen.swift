import SwiftUI

/// Swap screen. A tap writes a SwapMark and moves the tick.
/// Stored hours on both tiles stay as they are.
struct SwapScreen: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if deck.chart.queue.active == nil {
                    EmptyCooling(action: { deck.sheet = .file })
                } else if deck.chart.queue.shelf.isEmpty {
                    FailedFace(
                        title: "Nothing is frozen",
                        line: "File another buy. Then tap it to move the tick.",
                        actionTitle: "File",
                        action: { deck.sheet = .file }
                    )
                } else {
                    populated
                }
            }
            .background(.regularMaterial)
            .queueTitle("Swap") { dismiss() }
        }
        .queueSheet()
    }

    private var populated: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Measure.s) {
                if let active = deck.chart.queue.active {
                    VStack(alignment: .leading, spacing: Measure.xs) {
                        Text("Cooling now")
                            .font(TypeFace.caption())
                            .foregroundStyle(DesignTokens.accent)
                        Text(active.label)
                            .font(TypeFace.headline())
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(InkFormat.hours(active.hoursRemaining))
                            .font(TypeFace.display())
                            .foregroundStyle(DesignTokens.ink)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(Measure.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                            .fill(.regularMaterial)
                    }
                }
                Text("Tap a frozen row. Both spans stay as they are.")
                    .font(TypeFace.body())
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                if let line = deck.faultLine {
                    Text(line)
                        .font(TypeFace.caption())
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(deck.chart.queue.shelf) { item in
                    Button {
                        Task { await deck.swap(to: item.id) }
                    } label: {
                        HStack(alignment: .center, spacing: Measure.s) {
                            VStack(alignment: .leading, spacing: Measure.xxs) {
                                Text("Frozen")
                                    .font(TypeFace.micro())
                                    .foregroundStyle(DesignTokens.muted)
                                Text(item.label)
                                    .font(TypeFace.headline())
                                    .foregroundStyle(DesignTokens.ink)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer(minLength: Measure.s)
                            Text(InkFormat.hours(item.hoursRemaining))
                                .font(TypeFace.title())
                                .foregroundStyle(DesignTokens.ink)
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .padding(Measure.s)
                        .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                                .fill(.thinMaterial)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: Measure.card, style: .continuous))
                    }
                    .buttonStyle(TilePressStyle())
                    .disabled(deck.busy)
                    .accessibilityLabel(item.label + ", frozen at " + InkFormat.hours(item.hoursRemaining))
                    .accessibilityHint("Swaps the cooling tick onto this tile")
                }
            }
            .padding(Measure.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
