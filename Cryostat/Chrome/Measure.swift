import SwiftUI

/// Spacing, radii, and type for the cooling bento. Hex lives only in DesignTokens.
enum Measure {
    /// Base step is 4pt. Every gap in the bento is a multiple of this.
    static let unit: CGFloat = 4

    static var xxs: CGFloat { unit }
    static var xs: CGFloat { unit * 2 }
    static var s: CGFloat { unit * 4 }
    static var m: CGFloat { unit * 6 }
    static var l: CGFloat { unit * 8 }
    static var xl: CGFloat { unit * 10 }
    /// Minimum hit target. Not a spacing step.
    static let hit: CGFloat = 44

    /// Cards, sheets, and primary surfaces.
    static let card: CGFloat = 28
    /// Chips, badges, and small controls.
    static let chip: CGFloat = 14
}

enum TypeFace {
    static func display() -> Font { custom("Futura-Medium", 34, .largeTitle) }
    static func title() -> Font { custom("Futura-Medium", 28, .title) }
    static func headline() -> Font { custom("Futura-Medium", 20, .headline) }
    static func body() -> Font { custom("Futura-Medium", 17, .body) }
    static func caption() -> Font { custom("Futura-Medium", 13, .caption) }
    static func micro() -> Font { custom("Futura-Medium", 11, .caption2) }
    /// Reserved for the short Release label.
    static func release() -> Font { custom("Futura-Bold", 17, .headline) }

    private static func custom(_ name: String, _ size: CGFloat, _ textStyle: Font.TextStyle) -> Font {
        Font.custom(name, size: size, relativeTo: textStyle)
    }
}

enum InkFormat {
    static func hours(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = value.rounded() == value ? 0 : 1
        let text = formatter.string(from: NSNumber(value: value)) ?? "0"
        return text + " h"
    }

    static func count(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value.rounded())) ?? "0"
    }

    static func money(_ value: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? currency
    }

    static func day(_ stamp: Int) -> String {
        var parts = DateComponents()
        parts.year = stamp / 10_000
        parts.month = (stamp / 100) % 100
        parts.day = stamp % 100
        let date = Calendar.current.date(from: parts) ?? Date()
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

enum CommitTone {
    case accent
    case quiet
    case destructive
}

/// Tinted glass primary, quiet material, and a destructive variant that does not borrow accent.
struct CommitButtonStyle: ButtonStyle {
    var tone: CommitTone = .accent
    var emphasis: Font = TypeFace.headline()
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(emphasis)
            .foregroundStyle(tone == .destructive ? DesignTokens.muted : DesignTokens.ink)
            .frame(maxWidth: .infinity, minHeight: Measure.hit)
            .padding(.horizontal, Measure.s)
            .padding(.vertical, Measure.xs)
            .background {
                RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: Measure.card, style: .continuous)
                            .fill(wash.opacity(configuration.isPressed ? 0.42 : 0.22))
                    }
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.86 : 1) : 0.38)
            .scaleEffect(reduceMotion || !isEnabled ? 1 : (configuration.isPressed ? 0.98 : 1))
            .contentShape(RoundedRectangle(cornerRadius: Measure.card, style: .continuous))
            .animation(.easeOut(duration: 0.22), value: configuration.isPressed)
    }

    private var wash: Color {
        switch tone {
        case .accent: DesignTokens.accent
        case .quiet: DesignTokens.ink
        case .destructive: DesignTokens.ink
        }
    }
}

/// Card press. Scale when motion is allowed, fade when it is reduced.
struct TilePressStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? (configuration.isPressed ? 0.88 : 1) : 0.4)
            .scaleEffect(reduceMotion || !isEnabled ? 1 : (configuration.isPressed ? 0.98 : 1))
            .animation(.easeOut(duration: 0.22), value: configuration.isPressed)
    }
}

struct IconGlassStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: Measure.hit, minHeight: Measure.hit)
            .background {
                RoundedRectangle(cornerRadius: Measure.chip, style: .continuous)
                    .fill(.thinMaterial)
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.72 : 1) : 0.38)
            .scaleEffect(reduceMotion || !isEnabled ? 1 : (configuration.isPressed ? 0.96 : 1))
            .contentShape(RoundedRectangle(cornerRadius: Measure.chip, style: .continuous))
            .animation(.easeOut(duration: 0.22), value: configuration.isPressed)
    }
}

struct StaggerIn: ViewModifier {
    var index: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : Measure.xs)
            .onAppear {
                guard !shown else { return }
                if reduceMotion {
                    withAnimation(.easeOut(duration: 0.22)) {
                        shown = true
                    }
                    return
                }
                let delay = min(0.14, Double(index) * 0.05)
                withAnimation(.easeOut(duration: 0.22).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func stagger(_ index: Int) -> some View {
        modifier(StaggerIn(index: index))
    }

    /// Inline title and Close in Futura. The system navigation face stays off these sheets.
    func queueTitle(_ title: String, close: @escaping () -> Void) -> some View {
        modifier(QueueTitle(title: title, close: close))
    }

    /// Material sheet with the card radius. Detents stay per screen.
    func queueSheet(_ detents: Set<PresentationDetent> = [.large]) -> some View {
        modifier(QueueSheet(detents: detents))
    }
}

private struct QueueTitle: ViewModifier {
    var title: String
    var close: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(TypeFace.headline())
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: close) {
                        Text("Close")
                            .font(TypeFace.body())
                            .foregroundStyle(DesignTokens.ink)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .toolbarBackground(.regularMaterial, for: .navigationBar)
    }
}

private struct QueueSheet: ViewModifier {
    var detents: Set<PresentationDetent>

    func body(content: Content) -> some View {
        content
            .presentationDetents(detents)
            .presentationCornerRadius(Measure.card)
            .presentationBackground(.regularMaterial)
    }
}
