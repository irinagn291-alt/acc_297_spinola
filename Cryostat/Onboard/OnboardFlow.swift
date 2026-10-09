import SwiftUI

/// Three full pages. Continue sits full width at the bottom and writes the
/// monthly limit plus default need and discount. Skip keeps sensible defaults.
struct OnboardFlow: View {
    @EnvironmentObject private var deck: BentoDeck
    @State private var page = 0
    @State private var limitText = InkFormat.count(2_000)
    @State private var nec = 40.0
    @State private var disc = 20.0
    @State private var fault: String?
    @FocusState private var limitFocus: Bool

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            ScrollView {
                Group {
                    switch page {
                    case 0: pageOne
                    case 1: pageTwo
                    default: pageThree
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Measure.l)
                .animation(.easeOut(duration: 0.22), value: page)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: Measure.xs) {
                    if let fault {
                        Text(fault)
                            .font(TypeFace.caption())
                            .foregroundStyle(DesignTokens.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Button {
                        Task { await advance() }
                    } label: {
                        Text(page == 2 ? "Continue" : "Next")
                            .frame(maxWidth: .infinity, minHeight: Measure.hit)
                    }
                    .buttonStyle(CommitButtonStyle())
                    Button {
                        Task { await skip() }
                    } label: {
                        Text("Skip")
                            .frame(maxWidth: .infinity, minHeight: Measure.hit)
                    }
                    .buttonStyle(CommitButtonStyle(tone: .quiet))
                }
                .padding(Measure.l)
                .background(DesignTokens.bg)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { limitFocus = false }
            }
        }
    }

    private var pageOne: some View {
        VStack(alignment: .leading, spacing: Measure.m) {
            art("cst_Onboarding1")
            Text("One clock cools at a time")
                .font(TypeFace.title())
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("File the things you might buy. Only one clock runs. The rest stay frozen until you swap the tick.")
                .font(TypeFace.body())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private var pageTwo: some View {
        VStack(alignment: .leading, spacing: Measure.m) {
            art("cst_Onboarding2")
            Text("Swap the tick")
                .font(TypeFace.title())
                .foregroundStyle(DesignTokens.ink)
            Text("Tap a frozen tile to move the clock. Stored hours on both tiles stay as they are.")
                .font(TypeFace.body())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private var pageThree: some View {
        VStack(alignment: .leading, spacing: Measure.s) {
            art("cst_Onboarding3")
            Text("Your monthly limit")
                .font(TypeFace.title())
                .foregroundStyle(DesignTokens.ink)
            TextField("Monthly limit", text: $limitText)
                .font(TypeFace.body())
                .keyboardType(.numberPad)
                .monospacedDigit()
                .focused($limitFocus)
                .padding(Measure.s)
                .background {
                    RoundedRectangle(cornerRadius: Measure.chip, style: .continuous)
                        .fill(.thinMaterial)
                }
            Text("Need " + InkFormat.count(nec))
                .font(TypeFace.caption())
                .foregroundStyle(DesignTokens.muted)
            Slider(value: $nec, in: 0...100, step: 1)
                .tint(DesignTokens.accent)
            Text("Discount " + InkFormat.count(disc))
                .font(TypeFace.caption())
                .foregroundStyle(DesignTokens.muted)
            Slider(value: $disc, in: 0...100, step: 1)
                .tint(DesignTokens.accent)
            Spacer(minLength: 0)
        }
    }

    private func art(_ name: String) -> some View {
        Image(name)
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
    }

    private func advance() async {
        if page < 2 {
            page += 1
            return
        }
        await commit(skipping: false)
    }

    private func skip() async {
        limitText = InkFormat.count(2_000)
        nec = 40
        disc = 20
        await commit(skipping: true)
    }

    private func commit(skipping: Bool) async {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let parsed = formatter.number(from: limitText)?.doubleValue
        let limit = parsed ?? (skipping ? 2000 : nil)
        guard let limit, limit > 0 else {
            fault = "Enter a monthly limit above zero, or skip to keep the default."
            return
        }
        fault = nil
        var rule = deck.chart.rule
        rule.monthlyLimit = limit
        rule.defaultNec = nec
        rule.defaultDisc = disc
        rule.currency = rule.currency.isEmpty ? "USD" : rule.currency
        await deck.finishOnboarding(rule)
    }
}
