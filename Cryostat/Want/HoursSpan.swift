import Foundation

/// Family invariant. Base hours are 720 times price over the monthly limit.
/// hours = base × priority × (1.5 − nec/100) × (2 − disc/100), clamped to 6…720.
enum HoursSpan {
    static let floorHours = 6.0
    static let ceilingHours = 720.0

    static func hours(
        price: Double,
        priority: Double,
        nec: Double,
        disc: Double,
        monthlyLimit: Double
    ) -> Double? {
        guard price > 0, priority > 0, monthlyLimit > 0 else { return nil }
        guard (0...100).contains(nec), (0...100).contains(disc) else { return nil }
        let base = 720.0 * price / monthlyLimit
        let raw = base * priority * (1.5 - nec / 100.0) * (2.0 - disc / 100.0)
        return min(ceilingHours, max(floorHours, raw))
    }
}
