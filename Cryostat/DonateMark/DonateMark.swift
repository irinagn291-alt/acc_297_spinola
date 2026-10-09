import Foundation

/// Written when a shelved want covers the active shortfall.
/// The donor is kept so Peel can put that want and those hours back.
struct DonateMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var day: Int
    var order: Int
    var activeID: UUID
    var hoursTaken: Double
    var donor: Want

    init(
        id: UUID = UUID(),
        day: Int,
        order: Int,
        activeID: UUID,
        hoursTaken: Double,
        donor: Want
    ) {
        self.id = id
        self.day = day
        self.order = order
        self.activeID = activeID
        self.hoursTaken = hoursTaken
        self.donor = donor
    }
}
