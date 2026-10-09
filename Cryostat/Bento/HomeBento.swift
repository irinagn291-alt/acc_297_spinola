import SwiftUI

/// Home is the cooling mechanic: one Active tile ticks, shelved tiles stay frozen.
/// Swap is a tap on a shelved cell. File, Donate, Release, and Peel stay on this bento.
struct HomeBento: View {
    @EnvironmentObject private var deck: BentoDeck

    var body: some View {
        ZStack {
            switch deck.homeFace {
            case .empty:
                EmptyCooling(action: { deck.sheet = .file })
            case .failed:
                FailedFace(
                    title: "The shelf could not be read",
                    line: deck.faultLine ?? deck.note ?? "Start again from an empty bento.",
                    actionTitle: "File a buy",
                    action: {
                        deck.clearFault()
                        deck.sheet = .file
                    }
                )
            case .ready:
                populated
            }
            if deck.celebrate {
                Image("cst_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Measure.hit * 2, height: Measure.hit * 2)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
        .sheet(item: $deck.sheet) { sheet in
            sheetBody(sheet)
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: Measure.s) {
            header
            if let line = deck.faultLine ?? deck.note {
                Text(line)
                    .font(TypeFace.caption())
                    .foregroundStyle(DesignTokens.ink)
                    .padding(Measure.s)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: Measure.chip, style: .continuous)
                            .fill(.thinMaterial)
                    }
                    .accessibilityLabel(line)
            }
            bento
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            actions
        }
        .padding(Measure.m)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Measure.s) {
            Image("cst_HeaderDecor")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: Measure.l + Measure.s)
                .clipShape(RoundedRectangle(cornerRadius: Measure.chip, style: .continuous))
                .accessibilityHidden(true)
            HStack(alignment: .center, spacing: Measure.s) {
                VStack(alignment: .leading, spacing: Measure.xxs) {
                    Text("One clock is cooling")
                        .font(TypeFace.title())
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Tap a frozen tile to swap the tick.")
                        .font(TypeFace.body())
                        .foregroundStyle(DesignTokens.muted)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: Measure.s)
                iconButton("slider.horizontal.3", "Rules") { deck.sheet = .rules }
                iconButton("gearshape", "Settings") { deck.sheet = .settings }
            }
        }
        .stagger(0)
    }

    private func iconButton(_ symbol: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(TypeFace.headline())
                .foregroundStyle(DesignTokens.ink)
                .frame(width: Measure.hit, height: Measure.hit)
        }
        .buttonStyle(IconGlassStyle())
        .accessibilityLabel(label)
    }

    private var bento: some View {
        GeometryReader { proxy in
            let shelf = deck.chart.queue.shelf
            let pairCount = max(shelf.count, 1)
            let rows = Int(ceil(Double(pairCount) / 2.0))
            let gap = Measure.s
            let heroShare: CGFloat = shelf.isEmpty ? 1 : 0.46
            let heroFloor = Measure.hit * 4
            let rowFloor = Measure.hit * 3.2
            let shelfBlock = shelf.isEmpty ? 0 : rowFloor * CGFloat(rows) + gap * CGFloat(max(rows - 1, 0))
            let heroHeight = shelf.isEmpty
                ? max(heroFloor, proxy.size.height)
                : max(heroFloor, min(proxy.size.height * heroShare, max(heroFloor, proxy.size.height - shelfBlock - gap)))
            let rowHeight = shelf.isEmpty ? 0 : rowFloor
            ScrollView {
                VStack(spacing: gap) {
                    if let active = deck.chart.queue.active {
                        ActiveTile(want: active, fold: deck.chart.queue.fold, currency: deck.chart.rule.currency)
                            .frame(minHeight: heroHeight)
                            .stagger(1)
                    }
                    shelfRows(shelf, rowHeight: rowHeight)
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    private func shelfRows(_ shelf: [Want], rowHeight: CGFloat) -> some View {
        let pairs = ShelfPair.rows(in: shelf)
        ForEach(Array(pairs.enumerated()), id: \.element.id) { row, pair in
            HStack(spacing: Measure.s) {
                ShelvedTile(want: pair.leading) {
                    Task { await deck.swap(to: pair.leading.id) }
                }
                .frame(maxWidth: .infinity)
                .disabled(deck.busy)
                if let trailing = pair.trailing {
                    ShelvedTile(want: trailing) {
                        Task { await deck.swap(to: trailing.id) }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(deck.busy)
                }
            }
            .frame(minHeight: rowHeight)
            .stagger(row + 2)
        }
    }

    private var actions: some View {
        VStack(spacing: Measure.xs) {
            HStack(alignment: .center, spacing: Measure.s) {
                Button {
                    deck.sheet = .review
                } label: {
                    HStack(spacing: Measure.s) {
                        VStack(alignment: .leading, spacing: Measure.xxs) {
                            Text("Marks")
                                .font(TypeFace.caption())
                                .foregroundStyle(DesignTokens.accent)
                            Text(markLine)
                                .font(TypeFace.body())
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: Measure.s)
                        Image(systemName: "chevron.right")
                            .font(TypeFace.caption())
                            .foregroundStyle(DesignTokens.muted)
                            .accessibilityHidden(true)
                    }
                    .padding(Measure.s)
                    .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                            .fill(.regularMaterial)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: Measure.card, style: .continuous))
                }
                .buttonStyle(TilePressStyle())
                .accessibilityHint("Opens the mark timeline")
                Button {
                    deck.sheet = .twist
                } label: {
                    Image(systemName: "timer")
                        .font(TypeFace.headline())
                        .foregroundStyle(DesignTokens.ink)
                        .frame(width: Measure.hit, height: Measure.hit)
                }
                .buttonStyle(IconGlassStyle())
                .accessibilityLabel("Single tick")
            }
            if deck.chart.queue.fold == .cool {
                Button {
                    Task { await deck.release() }
                } label: {
                    Text("Release")
                        .frame(maxWidth: .infinity, minHeight: Measure.hit)
                }
                .buttonStyle(CommitButtonStyle(emphasis: TypeFace.release()))
                .disabled(deck.busy)
                .accessibilityHint("Marks the cooling tile bought")
            }
            Button {
                deck.sheet = .file
            } label: {
                Text("File")
                    .frame(maxWidth: .infinity, minHeight: Measure.hit)
            }
            .buttonStyle(CommitButtonStyle(tone: deck.chart.queue.fold == .cool ? .quiet : .accent))
            .disabled(deck.busy)
            .accessibilityHint("Files a new buy")
            HStack(spacing: Measure.xs) {
                Button {
                    deck.sheet = .donate
                } label: {
                    Text("Donate")
                        .frame(maxWidth: .infinity, minHeight: Measure.hit)
                }
                .buttonStyle(CommitButtonStyle(tone: .quiet))
                .disabled(deck.busy || deck.chart.queue.shelf.isEmpty || deck.chart.queue.fold != .ticking)
                .accessibilityHint("Gives frozen hours to the cooling tile")
                Button {
                    Task { await deck.peel() }
                } label: {
                    Text("Peel")
                        .frame(maxWidth: .infinity, minHeight: Measure.hit)
                }
                .buttonStyle(CommitButtonStyle(tone: .quiet))
                .disabled(deck.busy || (deck.chart.queue.swapMarks.isEmpty && deck.chart.queue.donateMarks.isEmpty))
                .accessibilityHint("Restores the previous cooling tile")
            }
        }
        .stagger(4)
    }

    private var markLine: String {
        if deck.marks.isEmpty {
            return "Swap writes the first mark."
        }
        return InkFormat.count(Double(deck.marks.count)) + " marks on the timeline."
    }

    @ViewBuilder
    private func sheetBody(_ sheet: BentoDeck.Sheet) -> some View {
        switch sheet {
        case .review:
            ReviewTimeline()
        case .rules:
            RulesSheet()
        case .settings:
            SettingsSheet()
        case .file:
            FileComposer()
        case .donate:
            DonateScreen()
        case .swap:
            SwapScreen()
        case .release:
            ReleaseScreen()
        case .twist:
            TickSheet()
        case .onboard:
            OnboardFlow()
        }
    }
}

/// One shelf row. Identity is the want ids, so a swap does not reuse a row index.
private struct ShelfPair: Identifiable {
    let leading: Want
    let trailing: Want?

    var id: String {
        if let trailing {
            return leading.id.uuidString + trailing.id.uuidString
        }
        return leading.id.uuidString
    }

    static func rows(in shelf: [Want]) -> [ShelfPair] {
        stride(from: 0, to: shelf.count, by: 2).map { index in
            let trailing = index + 1 < shelf.count ? shelf[index + 1] : nil
            return ShelfPair(leading: shelf[index], trailing: trailing)
        }
    }
}

struct EmptyCooling: View {
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Measure.m) {
            Spacer(minLength: Measure.l)
            Image("cst_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Measure.xl * 7, maxHeight: Measure.xl * 7)
                .padding(Measure.s)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                        .fill(DesignTokens.surface)
                }
                .accessibilityHidden(true)
            Text("Nothing is cooling")
                .font(TypeFace.title())
                .foregroundStyle(DesignTokens.ink)
            Text("File a buy. The span starts.")
                .font(TypeFace.body())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Measure.l)
            Button(action: action) {
                Text("File")
                    .frame(maxWidth: .infinity, minHeight: Measure.hit)
            }
            .buttonStyle(CommitButtonStyle())
        }
        .padding(Measure.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct FailedFace: View {
    var title: String
    var line: String
    var actionTitle: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Measure.m) {
            Spacer(minLength: Measure.l)
            Text(title)
                .font(TypeFace.title())
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(TypeFace.body())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Measure.l)
            Button(action: action) {
                Text(actionTitle)
                    .frame(maxWidth: .infinity, minHeight: Measure.hit)
            }
            .buttonStyle(CommitButtonStyle())
        }
        .padding(Measure.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
