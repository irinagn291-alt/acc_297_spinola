import Foundation

/// Written when a shelved want cannot cover the active shortfall. Both wants stay.
struct ShortMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var day: Int
    var order: Int
    var activeID: UUID
    var donorID: UUID
    var needed: Double
    var covered: Double

    init(
        id: UUID = UUID(),
        day: Int,
        order: Int,
        activeID: UUID,
        donorID: UUID,
        needed: Double,
        covered: Double
    ) {
        self.id = id
        self.day = day
        self.order = order
        self.activeID = activeID
        self.donorID = donorID
        self.needed = needed
        self.covered = covered
    }
}
