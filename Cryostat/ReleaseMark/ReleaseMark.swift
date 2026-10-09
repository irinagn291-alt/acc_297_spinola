import Foundation

/// Written only from Cool, when the active ring is at zero and the want is bought.
struct ReleaseMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var day: Int
    var order: Int
    var wantID: UUID
    var label: String

    init(
        id: UUID = UUID(),
        day: Int,
        order: Int,
        wantID: UUID,
        label: String
    ) {
        self.id = id
        self.day = day
        self.order = order
        self.wantID = wantID
        self.label = label
    }
}
