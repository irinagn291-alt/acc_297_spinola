import SwiftUI

/// Composer over Home. Writes a Want through the deck. The first file on an empty
/// queue becomes Active. Later files only join the shelf.
struct FileComposer: View {
    @EnvironmentObject private var deck: BentoDeck
    @Environment(\.dismiss) private var dismiss
    private enum Field: Hashable {
        case label
        case price
    }

    @FocusState private var focus: Field?

    @State private var label = ""
    @State private var priceText = ""
    @State private var priority = 1.0
    @State private var nec = 40.0
    @State private var disc = 20.0
    @State private var localFault: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $label)
                        .font(TypeFace.body())
                        .focused($focus, equals: .label)
                    TextField("Price", text: $priceText)
                        .font(TypeFace.body())
                        .keyboardType(.decimalPad)
                        .monospacedDigit()
                        .focused($focus, equals: .price)
                } header: {
                    Text("Buy")
                        .font(TypeFace.caption())
                }
                Section {
                    VStack(alignment: .leading, spacing: Measure.xs) {
                        Text("Priority " + InkFormat.count(priority))
                            .font(TypeFace.caption())
                            .foregroundStyle(DesignTokens.muted)
                        Slider(value: $priority, in: 1...3, step: 1)
                            .tint(DesignTokens.accent)
                    }
                    VStack(alignment: .leading, spacing: Measure.xs) {
                        Text("Need " + InkFormat.count(nec))
                            .font(TypeFace.caption())
                            .foregroundStyle(DesignTokens.muted)
                        Slider(value: $nec, in: 0...100, step: 1)
                            .tint(DesignTokens.accent)
                    }
                    VStack(alignment: .leading, spacing: Measure.xs) {
                        Text("Discount " + InkFormat.count(disc))
                            .font(TypeFace.caption())
                            .foregroundStyle(DesignTokens.muted)
                        Slider(value: $disc, in: 0...100, step: 1)
                            .tint(DesignTokens.accent)
                    }
                } header: {
                    Text("Span")
                        .font(TypeFace.caption())
                } footer: {
                    Text(preview)
                        .font(TypeFace.caption())
                        .foregroundStyle(DesignTokens.muted)
                }
                if let localFault {
                    Section {
                        Text(localFault)
                            .font(TypeFace.body())
                            .foregroundStyle(DesignTokens.ink)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.regularMaterial)
            .queueTitle("File a buy") { dismiss() }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focus = nil }
                        .font(TypeFace.body())
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { await commit() }
                } label: {
                Text("File")
                    .frame(maxWidth: .infinity, minHeight: Measure.hit)
                }
                .buttonStyle(CommitButtonStyle())
                .disabled(deck.busy || label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(Measure.m)
                .background(.regularMaterial)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: priceText) { _, value in
                guard !value.isEmpty else {
                    localFault = nil
                    return
                }
                guard let price = parsedPrice, price > 0 else {
                    localFault = "Use a number above zero."
                    return
                }
                localFault = nil
            }
            .onAppear {
                nec = deck.chart.rule.defaultNec
                disc = deck.chart.rule.defaultDisc
                focus = .label
            }
        }
        .queueSheet()
    }

    private var preview: String {
        guard let price = parsedPrice,
              let span = HoursSpan.hours(
                price: price,
                priority: priority,
                nec: nec,
                disc: disc,
                monthlyLimit: deck.chart.rule.monthlyLimit
              )
        else {
            return "Hours come from the price against your monthly limit."
        }
        return "This buy would cool for " + InkFormat.hours(span) + "."
    }

    private var parsedPrice: Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: priceText)?.doubleValue
    }

    private func commit() async {
        guard let price = parsedPrice, price > 0 else {
            localFault = "Enter a price above zero so the span can be computed."
            return
        }
        localFault = nil
        await deck.file(label: label, price: price, priority: priority, nec: nec, disc: disc)
        if let line = deck.faultLine {
            localFault = line
        }
    }
}
