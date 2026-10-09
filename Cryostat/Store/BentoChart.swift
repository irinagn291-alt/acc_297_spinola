import Foundation

/// One Chart root. Schema 1 holds the fold, the Active want, the shelf,
/// the span rule, and every mark. A failed decode never throws to the caller.
struct BentoChart: Codable, Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var queue: BentoQueue
    var rule: SpanRule

    static let empty = BentoChart(
        schemaVersion: currentSchema,
        queue: .empty,
        rule: .fresh
    )

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case fold
        case active
        case shelf
        case rule
        case swapMarks
        case donateMarks
        case releaseMarks
        case shortMarks
        case order
    }

    init(schemaVersion: Int, queue: BentoQueue, rule: SpanRule) {
        self.schemaVersion = schemaVersion
        self.queue = queue
        self.rule = rule
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            let fold = try container.decode(BentoFold.self, forKey: .fold)
            let active = try container.decodeIfPresent(Want.self, forKey: .active)
            let shelf = try container.decode([Want].self, forKey: .shelf)
            rule = try container.decode(SpanRule.self, forKey: .rule)
            queue = BentoQueue(
                fold: fold,
                active: active,
                shelf: shelf,
                swapMarks: try container.decode([SwapMark].self, forKey: .swapMarks),
                donateMarks: try container.decode([DonateMark].self, forKey: .donateMarks),
                releaseMarks: try container.decode([ReleaseMark].self, forKey: .releaseMarks),
                shortMarks: try container.decode([ShortMark].self, forKey: .shortMarks),
                order: try container.decode(Int.self, forKey: .order)
            )
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown chart schema \(version)."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(queue.fold, forKey: .fold)
        try container.encodeIfPresent(queue.active, forKey: .active)
        try container.encode(queue.shelf, forKey: .shelf)
        try container.encode(rule, forKey: .rule)
        try container.encode(queue.swapMarks, forKey: .swapMarks)
        try container.encode(queue.donateMarks, forKey: .donateMarks)
        try container.encode(queue.releaseMarks, forKey: .releaseMarks)
        try container.encode(queue.shortMarks, forKey: .shortMarks)
        try container.encode(queue.order, forKey: .order)
    }
}
