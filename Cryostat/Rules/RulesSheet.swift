import SwiftUI

/// Rules sheet. Monthly limit and the default need and discount sliders.
struct RulesSheet: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss

    @State private var limitText = ""
    @State private var nec = 40.0
    @State private var disc = 20.0
    @State private var localFault: String?
    @FocusState private var limitFocus: Bool

    var body: some View {
        NavigationStack {
            Group {
                switch deck.rulesFace {
                case .empty:
                    FailedFace(
                        title: "Set a monthly limit",
                        line: "Hours are priced against what you can spend in a month.",
                        actionTitle: "Use " + InkFormat.count(2_000),
                        action: {
                            limitText = "2000"
                            Task { await save() }
                        }
                    )
                case .failed:
                    FailedFace(
                        title: "Rules could not load",
                        line: deck.note ?? "The last saved limit is still on the device.",
                        actionTitle: "Close",
                        action: { dismiss() }
                    )
                case .ready:
                    form
                }
            }
            .background(.regularMaterial)
            .queueTitle("Rules") { dismiss() }
            .onAppear {
                limitText = InkFormat.count(deck.chart.rule.monthlyLimit)
                nec = deck.chart.rule.defaultNec
                disc = deck.chart.rule.defaultDisc
            }
        }
        .queueSheet()
    }

    private var form: some View {
        Form {
            Section {
                TextField("Monthly limit", text: $limitText)
                    .font(TypeFace.body())
                    .keyboardType(.numberPad)
                    .monospacedDigit()
                    .focused($limitFocus)
            } header: {
                Text("Limit")
                    .font(TypeFace.caption())
            } footer: {
                Text("New buys use this limit. Hours already stored stay put.")
                    .font(TypeFace.caption())
            }
            Section {
                VStack(alignment: .leading, spacing: Measure.xs) {
                    Text("Default need " + InkFormat.count(nec))
                        .font(TypeFace.body())
                    Slider(value: $nec, in: 0...100, step: 1)
                        .tint(DesignTokens.accent)
                }
                VStack(alignment: .leading, spacing: Measure.xs) {
                    Text("Default discount " + InkFormat.count(disc))
                        .font(TypeFace.body())
                    Slider(value: $disc, in: 0...100, step: 1)
                        .tint(DesignTokens.accent)
                }
            }
            if let localFault {
                Section {
                    Text(localFault)
                        .font(TypeFace.body())
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: limitText) { _, value in
            guard !value.isEmpty else { return }
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if formatter.number(from: value)?.doubleValue ?? -1 <= 0 {
                localFault = "Enter a monthly limit above zero."
            } else {
                localFault = nil
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                    Button("Done") { limitFocus = false }
                        .font(TypeFace.body())
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await save() }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity, minHeight: Measure.hit)
            }
            .buttonStyle(CommitButtonStyle())
            .padding(Measure.m)
            .background(.regularMaterial)
        }
    }

    private func save() async {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let value = formatter.number(from: limitText)?.doubleValue, value > 0 else {
            localFault = "Enter a monthly limit above zero."
            return
        }
        localFault = nil
        var rule = deck.chart.rule
        rule.monthlyLimit = value
        rule.defaultNec = nec
        rule.defaultDisc = disc
        await deck.saveRule(rule)
        dismiss()
    }
}
