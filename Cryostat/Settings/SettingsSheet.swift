import SwiftUI

/// Settings holds currency, the contact link, a fresh onboarding pass, and reset.
struct SettingsSheet: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var currency = "USD"

    private let choices = ["USD", "EUR", "GBP", "JPY"]

    var body: some View {
        NavigationStack {
            Group {
                switch deck.settingsFace {
                case .empty:
                    FailedFace(
                        title: "Pick a currency",
                        line: "Prices on the bento use this code.",
                        actionTitle: "Use USD",
                        action: {
                            currency = "USD"
                            Task { await saveCurrency() }
                        }
                    )
                case .failed:
                    FailedFace(
                        title: "Settings could not load",
                        line: deck.note ?? "Try again after the chart recovers.",
                        actionTitle: "Close",
                        action: { dismiss() }
                    )
                case .ready:
                    form
                }
            }
            .background(.regularMaterial)
            .queueTitle("Settings") { dismiss() }
            .onAppear { currency = deck.chart.rule.currency }
            .confirmationDialog(
                "Reset the shelf?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset the shelf", role: .destructive) {
                    Task { await deck.resetAll() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Buys and marks on this device are removed.")
            }
        }
        .queueSheet()
    }

    private var form: some View {
        Form {
            Section {
                Picker("Currency", selection: $currency) {
                    ForEach(choices, id: \.self) { code in
                        Text(code).tag(code)
                    }
                }
                .font(TypeFace.body())
                .onChange(of: currency) { _, _ in
                    Task { await saveCurrency() }
                }
            }
            Section {
                if let contact = URL(string: "https://cryostat-bento.pro/contact-us") {
                    Link(destination: contact) {
                        Text("Contact")
                            .font(TypeFace.body())
                            .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                }
                Button("Show the intro again") {
                    Task { await deck.rerunOnboarding() }
                }
                .font(TypeFace.body())
                .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
                Button("Reset the shelf") {
                    confirmReset = true
                }
                .font(TypeFace.body())
                .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
                .buttonStyle(CommitButtonStyle(tone: .destructive))
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func saveCurrency() async {
        var rule = deck.chart.rule
        rule.currency = currency
        await deck.saveRule(rule)
    }
}
