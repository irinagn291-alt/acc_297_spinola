import Foundation

/// A filed impulse. Hours stay on the want so a swap can move the tick
/// without recomputing the span, and a shelved want stays frozen.
struct Want: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var label: String
    var price: Double
    var priority: Double
    var nec: Double
    var disc: Double
    var hoursRemaining: Double

    init(
        id: UUID = UUID(),
        label: String,
        price: Double,
        priority: Double,
        nec: Double,
        disc: Double,
        hoursRemaining: Double
    ) {
        self.id = id
        self.label = label
        self.price = price
        self.priority = priority
        self.nec = nec
        self.disc = disc
        self.hoursRemaining = hoursRemaining
    }
}
