import XCTest
@testable import Cryostat

final class CryostatTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: CryostatApp.self), "CryostatApp")
    }

    func test_hoursClampToSpan() {
        let mid = HoursSpan.hours(price: 72, priority: 1, nec: 0, disc: 0, monthlyLimit: 720)
        XCTAssertEqual(mid ?? -1, 216, accuracy: 0.001)

        let tall = HoursSpan.hours(price: 720, priority: 1, nec: 50, disc: 0, monthlyLimit: 720)
        XCTAssertEqual(tall ?? -1, 720, accuracy: 0.001)

        let short = HoursSpan.hours(price: 10, priority: 1, nec: 0, disc: 0, monthlyLimit: 7_200)
        XCTAssertEqual(short ?? -1, 6, accuracy: 0.001)

        XCTAssertNil(HoursSpan.hours(price: 0, priority: 1, nec: 0, disc: 0, monthlyLimit: 720))
        XCTAssertNil(HoursSpan.hours(price: 10, priority: 1, nec: 0, disc: 0, monthlyLimit: 0))
        XCTAssertNil(HoursSpan.hours(price: 10, priority: 1, nec: 140, disc: 0, monthlyLimit: 720))
    }

    func test_fileEmptyPopulatedAndInvalid() throws {
        var queue = BentoQueue.empty
        XCTAssertEqual(queue.fold, .empty)
        XCTAssertThrowsError(try queue.file(label: "  ", price: 40, priority: 1, nec: 0, disc: 0, monthlyLimit: 2_000))
        XCTAssertEqual(queue.fold, .empty)

        let first = try queue.file(label: "Wool coat", price: 80, priority: 1, nec: 0, disc: 0, monthlyLimit: 2_000)
        XCTAssertEqual(queue.fold, .ticking)
        XCTAssertEqual(queue.active?.id, first.id)
        XCTAssertTrue(queue.shelf.isEmpty)

        let second = try queue.file(label: "Weekend bag", price: 400, priority: 1, nec: 0, disc: 0, monthlyLimit: 2_000)
        XCTAssertEqual(queue.fold, .ticking)
        XCTAssertEqual(queue.active?.id, first.id)
        XCTAssertEqual(queue.shelf.map(\.id), [second.id])
        XCTAssertGreaterThan(second.hoursRemaining, first.hoursRemaining)
    }

    func test_singleTickSwapLeavesShelfFrozen() throws {
        var queue = try seededQueue()
        let activeID = try XCTUnwrap(queue.active?.id)
        let activeHours = try XCTUnwrap(queue.active?.hoursRemaining)
        let shelved = queue.shelf
        let longer = try XCTUnwrap(shelved.max { $0.hoursRemaining < $1.hoursRemaining })
        let frozen = longer.hoursRemaining

        for _ in 0..<60 {
            queue.tickMinute()
        }
        XCTAssertEqual(queue.active?.id, activeID)
        XCTAssertEqual(try XCTUnwrap(queue.active?.hoursRemaining), activeHours - 1, accuracy: 0.001)
        XCTAssertEqual(queue.shelf.first { $0.id == longer.id }?.hoursRemaining ?? -1, frozen, accuracy: 0.001)
        XCTAssertEqual(queue.fold, .ticking)

        let day = DayStamp.yyyymmdd(for: Date(timeIntervalSince1970: 1_700_000_000))
        try queue.swap(to: longer.id, day: day)
        XCTAssertEqual(queue.active?.id, longer.id)
        XCTAssertEqual(queue.active?.hoursRemaining ?? -1, frozen, accuracy: 0.001)
        let parked = try XCTUnwrap(queue.shelf.first { $0.id == activeID })
        XCTAssertEqual(parked.hoursRemaining, activeHours - 1, accuracy: 0.001)
        XCTAssertEqual(queue.swapMarks.count, 1)
        XCTAssertEqual(queue.swapMarks[0].day, day)
    }

    func test_foldDonateReleaseAndPeel() throws {
        var queue = try seededQueue()
        let original = try XCTUnwrap(queue.active)
        let longer = try XCTUnwrap(queue.shelf.max { $0.hoursRemaining < $1.hoursRemaining })
        let shorter = try XCTUnwrap(queue.shelf.min { $0.hoursRemaining < $1.hoursRemaining })
        let day = 20260927

        let shortCover = try queue.donate(from: shorter.id, day: day)
        XCTAssertFalse(shortCover)
        XCTAssertEqual(queue.shortMarks.count, 1)
        XCTAssertEqual(queue.fold, .ticking)
        XCTAssertEqual(queue.shelf.count, 2)
        XCTAssertEqual(queue.active?.hoursRemaining ?? -1, original.hoursRemaining, accuracy: 0.001)

        let covered = try queue.donate(from: longer.id, day: day)
        XCTAssertTrue(covered)
        XCTAssertEqual(queue.fold, .cool)
        XCTAssertEqual(queue.active?.hoursRemaining, 0)
        XCTAssertFalse(queue.shelf.contains { $0.id == longer.id })
        XCTAssertEqual(queue.donateMarks.count, 1)

        var ticking = queue
        ticking.fold = .ticking
        if var active = ticking.active {
            active.hoursRemaining = 2
            ticking.active = active
        }
        XCTAssertThrowsError(try ticking.release(day: day))

        try queue.peel()
        XCTAssertEqual(queue.donateMarks.count, 0)
        XCTAssertEqual(queue.active?.id, original.id)
        XCTAssertEqual(queue.active?.hoursRemaining ?? -1, original.hoursRemaining, accuracy: 0.001)
        XCTAssertTrue(queue.shelf.contains { $0.id == longer.id })
        XCTAssertEqual(queue.fold, .ticking)

        try queue.swap(to: longer.id, day: day)
        let swappedActive = try XCTUnwrap(queue.active?.id)
        try queue.peel()
        XCTAssertEqual(queue.active?.id, original.id)
        XCTAssertTrue(queue.shelf.contains { $0.id == swappedActive })
        XCTAssertTrue(queue.swapMarks.isEmpty)

        queue.tickMinute()
        while queue.fold == .ticking {
            queue.tickMinute()
        }
        XCTAssertEqual(queue.fold, .cool)
        try queue.release(day: day)
        XCTAssertEqual(queue.releaseMarks.count, 1)
        XCTAssertNotEqual(queue.fold, .empty)
        XCTAssertNotNil(queue.active)

        while queue.fold != .empty {
            if queue.fold == .ticking {
                while queue.fold == .ticking {
                    queue.tickMinute()
                }
            }
            try queue.release(day: day)
        }
        XCTAssertEqual(queue.fold, .empty)
        XCTAssertNil(queue.active)
        XCTAssertTrue(queue.shelf.isEmpty)
    }

    func test_chartRoundTripAndCorruptFallback() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("cst-tests-\(UUID().uuidString)", isDirectory: true)
        let suite = "cst.tests.\(UUID().uuidString)"
        let store = try freshStore(suite: suite, directory: directory)
        let filed = try await store.file(label: "Wool coat", price: 80, priority: 1, nec: 0, disc: 0)
        await store.flush()

        let reloaded = try freshStore(suite: suite, directory: directory)
        await reloaded.open()
        let snap = await reloaded.snapshot()
        XCTAssertEqual(snap.schemaVersion, 1)
        XCTAssertEqual(snap.queue.fold, .ticking)
        XCTAssertEqual(snap.queue.active?.id, filed.id)
        XCTAssertEqual(snap.queue.active?.hoursRemaining ?? -1, filed.hoursRemaining, accuracy: 0.001)

        try await reloaded.plantUnreadableChartKeepingBackup()
        let recovered = try freshStore(suite: suite, directory: directory)
        await recovered.open()
        let after = await recovered.snapshot()
        XCTAssertEqual(after.queue.active?.id, filed.id)
        let note = await recovered.recoveryNote
        XCTAssertNotNil(note)

        await recovered.resetAllData()
        let cleared = await recovered.snapshot()
        XCTAssertEqual(cleared.queue.fold, .empty)
        let stillThere = await recovered.hasStoredPayload()
        XCTAssertFalse(stillThere)
        let fileURL = directory.appendingPathComponent("bento-chart.json")
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }

    private func freshStore(suite: String, directory: URL) throws -> BentoStore {
        guard let defaults = UserDefaults(suiteName: suite) else {
            throw BentoFault.emptyQueue
        }
        return BentoStore(defaults: defaults, directory: directory)
    }

    func test_reviewLaunchParsesScreenArgument() {
        XCTAssertEqual(ReviewLaunch.argument, "-ReviewScreen")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Cryostat", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Cryostat", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Cryostat", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Cryostat", "-ReviewScreen", "settings"]), "settings")
        XCTAssertNil(ReviewLaunch.screen(in: ["Cryostat"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Cryostat", "-ReviewScreen"]))
    }

    func test_dayStampUsesStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let date = Date(timeIntervalSince1970: 1_720_000_000)
        let stamp = DayStamp.yyyymmdd(for: date, calendar: calendar)
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let expected = (parts.year ?? 0) * 10_000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
        XCTAssertEqual(stamp, expected)
        XCTAssertGreaterThan(stamp, 20_000_000)
    }

    private func seededQueue() throws -> BentoQueue {
        var queue = BentoQueue.empty
        _ = try queue.file(label: "Wool coat", price: 80, priority: 1, nec: 0, disc: 0, monthlyLimit: 2_000)
        _ = try queue.file(label: "Weekend bag", price: 400, priority: 1, nec: 0, disc: 0, monthlyLimit: 2_000)
        _ = try queue.file(label: "Desk lamp", price: 40, priority: 1, nec: 0, disc: 0, monthlyLimit: 2_000)
        return queue
    }
}
