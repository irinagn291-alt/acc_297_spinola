import SwiftUI

/// Chronological timeline of swap, donate, release, and short marks.
struct ReviewTimeline: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch deck.reviewFace {
                case .empty:
                    EmptyReview()
                case .failed:
                    FailedFace(
                        title: "The timeline could not be read",
                        line: deck.note ?? "The marks will return when the chart loads.",
                        actionTitle: "Close",
                        action: { dismiss() }
                    )
                case .ready:
                    List(deck.marks) { line in
                        markRow(line)
                            .listRowBackground(DesignTokens.surface)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(.regularMaterial)
            .queueTitle("Review") { dismiss() }
        }
        .queueSheet()
    }

    private func markRow(_ line: MarkLine) -> some View {
        VStack(alignment: .leading, spacing: Measure.xxs) {
            Text(title(line))
                .font(TypeFace.headline())
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(detail(line))
                .font(TypeFace.caption())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Text(InkFormat.day(line.day))
                .font(TypeFace.micro())
                .foregroundStyle(DesignTokens.muted)
        }
        .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
        .padding(.vertical, Measure.xs)
    }

    private func title(_ line: MarkLine) -> String {
        switch line {
        case .swap: "Swap"
        case .donate: "Donate"
        case .release: "Release"
        case .short: "Short"
        }
    }

    private func detail(_ line: MarkLine) -> String {
        let queue = deck.chart.queue
        switch line {
        case .swap(let mark):
            let from = name(mark.previousActiveID, queue: queue)
            let to = name(mark.nextActiveID, queue: queue)
            return "Tick moved from \(from) to \(to)."
        case .donate(let mark):
            return "\(mark.donor.label) gave \(InkFormat.hours(mark.hoursTaken))."
        case .release(let mark):
            return "\(mark.label) was marked bought."
        case .short(let mark):
            return "Covered " + InkFormat.hours(mark.covered) + " of " + InkFormat.hours(mark.needed) + ". Both tiles stayed."
        }
    }

    private func name(_ id: UUID, queue: BentoQueue) -> String {
        if queue.active?.id == id { return queue.active?.label ?? "Buy" }
        if let match = queue.shelf.first(where: { $0.id == id }) { return match.label }
        if let mark = queue.releaseMarks.first(where: { $0.wantID == id }) { return mark.label }
        if let mark = queue.donateMarks.first(where: { $0.donor.id == id }) { return mark.donor.label }
        return "Buy"
    }
}

struct EmptyReview: View {
    @EnvironmentObject private var deck: BentoDeck

    var body: some View {
        VStack(alignment: .leading, spacing: Measure.m) {
            Spacer(minLength: Measure.l)
            Image("cst_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Measure.xl * 6, maxHeight: Measure.xl * 6)
                .padding(Measure.s)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                        .fill(DesignTokens.surface)
                }
                .accessibilityHidden(true)
            Text("No marks yet")
                .font(TypeFace.title())
                .foregroundStyle(DesignTokens.ink)
            Text("Swap, donate, or release a buy and the timeline fills in.")
                .font(TypeFace.body())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Measure.l)
            Button {
                deck.sheet = .file
            } label: {
                Text("File")
                    .frame(maxWidth: .infinity, minHeight: Measure.hit)
            }
            .buttonStyle(CommitButtonStyle())
        }
        .padding(Measure.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
