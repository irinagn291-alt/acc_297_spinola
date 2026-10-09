import SwiftUI

/// Long-press companion. A shelved want that covers the active shortfall is burned.
/// A short cover writes a ShortMark and keeps both wants.
struct DonateScreen: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if deck.chart.queue.shelf.isEmpty {
                    FailedFace(
                        title: "Nothing frozen to give",
                        line: "File another buy, then donate its hours toward release.",
                        actionTitle: "Close",
                        action: { dismiss() }
                    )
                } else if let active = deck.chart.queue.active {
                    List {
                        Section {
                            Text(active.label + " still needs " + InkFormat.hours(active.hoursRemaining) + ".")
                                .font(TypeFace.body())
                                .foregroundStyle(DesignTokens.ink)
                        }
                        Section {
                            ForEach(deck.chart.queue.shelf) { donor in
                                Button {
                                    Task { await deck.donate(from: donor.id) }
                                } label: {
                                    VStack(alignment: .leading, spacing: Measure.xxs) {
                                        Text("Donate " + donor.label)
                                            .font(TypeFace.headline())
                                            .foregroundStyle(DesignTokens.ink)
                                        Text(InkFormat.hours(donor.hoursRemaining))
                                            .font(TypeFace.caption())
                                            .foregroundStyle(DesignTokens.muted)
                                            .monospacedDigit()
                                    }
                                    .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(TilePressStyle())
                                .disabled(deck.busy)
                            }
                        } footer: {
                            Text("A short gift stays on the shelf and writes a short mark.")
                                .font(TypeFace.caption())
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(.regularMaterial)
            .queueTitle("Donate hours") { dismiss() }
        }
        .queueSheet([.medium, .large])
    }
}
