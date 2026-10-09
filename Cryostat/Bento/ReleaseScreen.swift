import SwiftUI

/// Release screen. Writes a ReleaseMark only when the active ring reads zero.
/// A shelved tile cannot be released.
struct ReleaseScreen: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if deck.chart.queue.active == nil {
                    EmptyCooling(action: { deck.sheet = .file })
                } else if let line = deck.faultLine, deck.chart.queue.fold == .empty {
                    FailedFace(
                        title: "Release did not run",
                        line: line,
                        actionTitle: "Close",
                        action: { dismiss() }
                    )
                } else {
                    populated
                }
            }
            .background(.regularMaterial)
            .queueTitle("Release") { dismiss() }
        }
        .queueSheet()
    }

    private var populated: some View {
        let ready = deck.chart.queue.fold == .cool
        return VStack(alignment: .leading, spacing: Measure.m) {
            if let active = deck.chart.queue.active {
                VStack(alignment: .leading, spacing: Measure.xs) {
                    Text(ready ? "Ready to release" : "Still cooling")
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
                    Text(ready
                        ? "The ring reads zero. Release marks this buy as bought."
                        : "Release stays closed until the ring reads zero. Swap a frozen tile, or wait.")
                        .font(TypeFace.body())
                        .foregroundStyle(DesignTokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(Measure.m)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background {
                    RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                                .fill(DesignTokens.accent.opacity(0.16))
                        }
                }
            }
            if let line = deck.faultLine {
                Text(line)
                    .font(TypeFace.caption())
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                Task { await deck.release() }
            } label: {
                Text("Release")
                    .frame(maxWidth: .infinity, minHeight: Measure.hit)
            }
            .buttonStyle(CommitButtonStyle(emphasis: TypeFace.release()))
            .disabled(deck.busy || !ready)
            .accessibilityHint(ready ? "Marks the cooling tile bought" : "Opens when the ring reads zero")
        }
        .padding(Measure.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.regularMaterial)
    }
}
