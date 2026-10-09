import Foundation

/// Queue ADT. Empty has no wants. Ticking has one Active want still above zero.
/// Cool has that Active want at zero, waiting for Release. Shelf wants never tick.
enum BentoFold: String, Codable, Equatable, Sendable {
    case empty
    case ticking
    case cool
}

enum BentoFault: Error, Equatable, Sendable {
    case invalidWant
    case emptyQueue
    case notOnShelf
    case releaseRefused
    case donateRefused
    case peelEmpty
    case peelBlocked
}

/// The bento fold over wants. File, Swap, Donate, tick, Release, and Peel live here
/// so a view never owns the queue rules.
struct BentoQueue: Codable, Equatable, Sendable {
    var fold: BentoFold
    var active: Want?
    var shelf: [Want]
    var swapMarks: [SwapMark]
    var donateMarks: [DonateMark]
    var releaseMarks: [ReleaseMark]
    var shortMarks: [ShortMark]
    var order: Int

    static let empty = BentoQueue(
        fold: .empty,
        active: nil,
        shelf: [],
        swapMarks: [],
        donateMarks: [],
        releaseMarks: [],
        shortMarks: [],
        order: 0
    )

    /// First File on Empty becomes Active and folds to Ticking.
    /// File while a queue exists only appends a Shelved want.
    mutating func file(
        label: String,
        price: Double,
        priority: Double,
        nec: Double,
        disc: Double,
        monthlyLimit: Double
    ) throws -> Want {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw BentoFault.invalidWant }
        guard let span = HoursSpan.hours(
            price: price,
            priority: priority,
            nec: nec,
            disc: disc,
            monthlyLimit: monthlyLimit
        ) else {
            throw BentoFault.invalidWant
        }
        let want = Want(
            label: trimmed,
            price: price,
            priority: priority,
            nec: nec,
            disc: disc,
            hoursRemaining: span
        )
        if fold == .empty || active == nil {
            active = want
            fold = want.hoursRemaining > 0 ? .ticking : .cool
        } else {
            shelf.append(want)
        }
        return want
    }

    /// Moves the tick onto a shelved want. Stored hours on both wants stay put.
    mutating func swap(to shelvedID: UUID, day: Int) throws {
        guard var current = active else { throw BentoFault.emptyQueue }
        guard let index = shelf.firstIndex(where: { $0.id == shelvedID }) else {
            throw BentoFault.notOnShelf
        }
        let incoming = shelf.remove(at: index)
        let previousID = current.id
        shelf.append(current)
        current = incoming
        active = current
        fold = current.hoursRemaining > 0 ? .ticking : .cool
        order += 1
        swapMarks.append(
            SwapMark(
                day: day,
                order: order,
                previousActiveID: previousID,
                nextActiveID: current.id
            )
        )
    }

    /// One minute on the Active want only. Shelved hours do not move.
    /// Reaching zero folds Ticking into Cool.
    mutating func tickMinute() {
        guard fold == .ticking, var current = active else { return }
        current.hoursRemaining = max(0, current.hoursRemaining - (1.0 / 60.0))
        if current.hoursRemaining <= 0.000_000_1 {
            current.hoursRemaining = 0
            fold = .cool
        }
        active = current
    }

    /// Shelved hours that cover the active shortfall burn that want, zero the
    /// active ring, and fold to Cool. A short cover writes ShortMark and keeps both.
    @discardableResult
    mutating func donate(from shelvedID: UUID, day: Int) throws -> Bool {
        guard var current = active, fold == .ticking, current.hoursRemaining > 0 else {
            throw BentoFault.donateRefused
        }
        guard let index = shelf.firstIndex(where: { $0.id == shelvedID }) else {
            throw BentoFault.notOnShelf
        }
        let donor = shelf[index]
        let needed = current.hoursRemaining
        order += 1
        if donor.hoursRemaining + 0.000_000_1 < needed {
            shortMarks.append(
                ShortMark(
                    day: day,
                    order: order,
                    activeID: current.id,
                    donorID: donor.id,
                    needed: needed,
                    covered: donor.hoursRemaining
                )
            )
            return false
        }
        shelf.remove(at: index)
        current.hoursRemaining = 0
        active = current
        fold = .cool
        donateMarks.append(
            DonateMark(
                day: day,
                order: order,
                activeID: current.id,
                hoursTaken: needed,
                donor: donor
            )
        )
        return true
    }

    /// Release only from Cool. A later shelved want becomes Active with its stored hours.
    /// An empty shelf writes Empty.
    mutating func release(day: Int) throws {
        guard fold == .cool, let current = active, current.hoursRemaining == 0 else {
            throw BentoFault.releaseRefused
        }
        order += 1
        releaseMarks.append(
            ReleaseMark(day: day, order: order, wantID: current.id, label: current.label)
        )
        if shelf.isEmpty {
            active = nil
            fold = .empty
            return
        }
        let next = shelf.removeFirst()
        active = next
        fold = next.hoursRemaining > 0 ? .ticking : .cool
    }

    /// Drops the latest SwapMark or DonateMark and restores the prior Active,
    /// including a want and the hours a donation removed.
    mutating func peel() throws {
        let latestSwap = swapMarks.max { $0.order < $1.order }
        let latestDonate = donateMarks.max { $0.order < $1.order }
        switch (latestSwap, latestDonate) {
        case (nil, nil):
            throw BentoFault.peelEmpty
        case let (mark?, nil):
            try undoSwap(mark)
        case let (nil, mark?):
            try undoDonate(mark)
        case let (swap?, donate?):
            if swap.order >= donate.order {
                try undoSwap(swap)
            } else {
                try undoDonate(donate)
            }
        }
    }

    private mutating func undoSwap(_ mark: SwapMark) throws {
        guard let current = active, current.id == mark.nextActiveID else {
            throw BentoFault.peelBlocked
        }
        guard let index = shelf.firstIndex(where: { $0.id == mark.previousActiveID }) else {
            throw BentoFault.peelBlocked
        }
        let previous = shelf.remove(at: index)
        shelf.append(current)
        active = previous
        fold = previous.hoursRemaining > 0 ? .ticking : .cool
        swapMarks.removeAll { $0.id == mark.id }
    }

    private mutating func undoDonate(_ mark: DonateMark) throws {
        guard var current = active, current.id == mark.activeID else {
            throw BentoFault.peelBlocked
        }
        current.hoursRemaining += mark.hoursTaken
        active = current
        if !shelf.contains(where: { $0.id == mark.donor.id }) {
            shelf.append(mark.donor)
        }
        fold = current.hoursRemaining > 0 ? .ticking : .cool
        donateMarks.removeAll { $0.id == mark.id }
    }
}
