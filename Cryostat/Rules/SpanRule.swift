import Foundation

/// The Rule for this queue: monthly limit, currency, and the default nec and disc
/// sliders written by onboarding and edited on the Rules sheet.
struct SpanRule: Codable, Equatable, Sendable {
    var monthlyLimit: Double
    var currency: String
    var defaultNec: Double
    var defaultDisc: Double
    var onboardingComplete: Bool

    static let fresh = SpanRule(
        monthlyLimit: 2_000,
        currency: "USD",
        defaultNec: 40,
        defaultDisc: 20,
        onboardingComplete: false
    )
}
