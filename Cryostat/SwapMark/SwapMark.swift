import Foundation

/// Written when the tick moves from one want to a shelved want.
/// Hours on both wants stay as they were.
struct SwapMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var day: Int
    var order: Int
    var previousActiveID: UUID
    var nextActiveID: UUID

    init(
        id: UUID = UUID(),
        day: Int,
        order: Int,
        previousActiveID: UUID,
        nextActiveID: UUID
    ) {
        self.id = id
        self.day = day
        self.order = order
        self.previousActiveID = previousActiveID
        self.nextActiveID = nextActiveID
    }
}
