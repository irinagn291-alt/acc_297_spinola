import Foundation

/// The only seam between the queue and storage. Memory is the source of truth.
/// UserDefaults key `cst.bento.v1` and an atomic Application Support file are
/// projections. A failed write leaves the in-memory chart in place.
actor BentoStore {
    static let storageKey = "cst.bento.v1"
    static let demoKey = "cst.demo.v1"
    static let debounceNanoseconds: UInt64 = 400_000_000

    private let defaults: UserDefaults
    private let directory: URL
    private var chart: BentoChart
    private var saveTask: Task<Void, Never>?
    private var didOpen = false
    private(set) var recoveryNote: String?

    init(defaults: UserDefaults = .standard, directory: URL? = nil) {
        self.defaults = defaults
        self.directory = directory ?? Self.defaultDirectory()
        self.chart = .empty
    }

    func open() async {
        guard !didOpen else { return }
        didOpen = true
        let loaded = Self.readChart(defaults: defaults, directory: directory)
        chart = loaded.chart
        recoveryNote = loaded.note
    }

    func snapshot() -> BentoChart {
        chart
    }

    func file(
        label: String,
        price: Double,
        priority: Double,
        nec: Double? = nil,
        disc: Double? = nil
    ) async throws -> Want {
        await open()
        let want = try chart.queue.file(
            label: label,
            price: price,
            priority: priority,
            nec: nec ?? chart.rule.defaultNec,
            disc: disc ?? chart.rule.defaultDisc,
            monthlyLimit: chart.rule.monthlyLimit
        )
        scheduleSave(immediate: false)
        return want
    }

    func swap(to shelvedID: UUID, on date: Date = Date()) async throws {
        await open()
        try chart.queue.swap(to: shelvedID, day: DayStamp.yyyymmdd(for: date))
        scheduleSave(immediate: false)
    }

    func tickMinute() async {
        await open()
        chart.queue.tickMinute()
        scheduleSave(immediate: false)
    }

    /// Donate and Release flush immediately so a force-quit keeps the destructive mark.
    @discardableResult
    func donate(from shelvedID: UUID, on date: Date = Date()) async throws -> Bool {
        await open()
        let covered = try chart.queue.donate(from: shelvedID, day: DayStamp.yyyymmdd(for: date))
        if covered {
            await flush()
        } else {
            scheduleSave(immediate: false)
        }
        return covered
    }

    func release(on date: Date = Date()) async throws {
        await open()
        try chart.queue.release(day: DayStamp.yyyymmdd(for: date))
        await flush()
    }

    func peel() async throws {
        await open()
        try chart.queue.peel()
        scheduleSave(immediate: false)
    }

    func updateRule(_ rule: SpanRule) async {
        await open()
        chart.rule = rule
        scheduleSave(immediate: false)
    }

    /// Scene left `.active`. Pending edits hit disk before suspension.
    func sceneDidLeaveActive() async {
        await open()
        await flush()
    }

    func resetAllData() async {
        await open()
        saveTask?.cancel()
        saveTask = nil
        chart = .empty
        recoveryNote = nil
        defaults.removeObject(forKey: Self.storageKey)
        let fileURL = Self.chartURL(in: directory)
        let backupURL = Self.backupURL(in: directory)
        let manager = FileManager.default
        if manager.fileExists(atPath: fileURL.path) {
            do {
                try manager.removeItem(at: fileURL)
            } catch {
                recoveryNote = "Reset could not remove the chart file."
            }
        }
        if manager.fileExists(atPath: backupURL.path) {
            do {
                try manager.removeItem(at: backupURL)
            } catch {
                recoveryNote = "Reset could not remove the chart backup."
            }
        }
    }

    /// Test seam: the primary file and the defaults blob are unreadable, and the
    /// backup still holds the last good chart.
    func plantUnreadableChartKeepingBackup() throws {
        let fileURL = Self.chartURL(in: directory)
        let backupURL = Self.backupURL(in: directory)
        let good = try Data(contentsOf: fileURL)
        try good.write(to: backupURL, options: .atomic)
        try Data("not-json".utf8).write(to: fileURL, options: .atomic)
        defaults.set(Data("also-bad".utf8), forKey: Self.storageKey)
    }

    func hasStoredPayload() -> Bool {
        defaults.data(forKey: Self.storageKey) != nil
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        await writeProjection()
    }

    /// Simulator only, once. Seats one Active want and two Shelved wants,
    /// one longer than Active, and marks onboarding complete. Never calls on device.
    func seedDemoIfNeeded() async {
        #if targetEnvironment(simulator)
        await open()
        guard defaults.bool(forKey: Self.demoKey) == false else { return }
        guard chart.queue.fold == .empty else {
            defaults.set(true, forKey: Self.demoKey)
            return
        }
        chart.rule = SpanRule(
            monthlyLimit: 2_000,
            currency: "USD",
            defaultNec: 0,
            defaultDisc: 0,
            onboardingComplete: true
        )
        do {
            _ = try chart.queue.file(
                label: "Wool coat",
                price: 80,
                priority: 1,
                nec: 0,
                disc: 0,
                monthlyLimit: chart.rule.monthlyLimit
            )
            _ = try chart.queue.file(
                label: "Weekend bag",
                price: 400,
                priority: 1,
                nec: 0,
                disc: 0,
                monthlyLimit: chart.rule.monthlyLimit
            )
            _ = try chart.queue.file(
                label: "Desk lamp",
                price: 40,
                priority: 1,
                nec: 0,
                disc: 0,
                monthlyLimit: chart.rule.monthlyLimit
            )
        } catch {
            recoveryNote = "Demo shelf could not be filed."
            return
        }
        defaults.set(true, forKey: Self.demoKey)
        await flush()
        #endif
    }

    private func scheduleSave(immediate: Bool) {
        saveTask?.cancel()
        let delay = immediate ? 0 : Self.debounceNanoseconds
        saveTask = Task { [delay] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
                guard !Task.isCancelled else { return }
            }
            await writeProjection()
        }
    }

    private func writeProjection() async {
        let payload: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            payload = try encoder.encode(chart)
        } catch {
            recoveryNote = "The chart could not be encoded."
            return
        }
        defaults.set(payload, forKey: Self.storageKey)
        do {
            try Self.writeAtomically(payload, directory: directory)
        } catch {
            recoveryNote = "The chart file could not be saved. The in-memory shelf is unchanged."
        }
    }

    private static func defaultDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("Spinola", isDirectory: true)
    }

    private static func chartURL(in directory: URL) -> URL {
        directory.appendingPathComponent("bento-chart.json")
    }

    private static func backupURL(in directory: URL) -> URL {
        directory.appendingPathComponent("bento-chart.json.backup")
    }

    private static func writeAtomically(_ data: Data, directory: URL) throws {
        let manager = FileManager.default
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileURL = chartURL(in: directory)
        let backupURL = backupURL(in: directory)
        if manager.fileExists(atPath: fileURL.path) {
            if manager.fileExists(atPath: backupURL.path) {
                try manager.removeItem(at: backupURL)
            }
            try manager.copyItem(at: fileURL, to: backupURL)
        }
        try data.write(to: fileURL, options: .atomic)
    }

    private static func readChart(
        defaults: UserDefaults,
        directory: URL
    ) -> (chart: BentoChart, note: String?) {
        let fileURL = chartURL(in: directory)
        let backupURL = backupURL(in: directory)
        if let data = loadData(at: fileURL), let chart = decode(data) {
            return (chart, nil)
        }
        let filePresent = FileManager.default.fileExists(atPath: fileURL.path)
        if let data = loadData(at: backupURL), let chart = decode(data) {
            return (chart, "The saved chart was unreadable. The last good copy is back.")
        }
        if let data = defaults.data(forKey: storageKey), let chart = decode(data) {
            return (chart, filePresent ? "The saved chart was unreadable. The last good copy is back." : nil)
        }
        if filePresent || defaults.data(forKey: storageKey) != nil {
            return (.empty, "The saved chart was unreadable. Starting from an empty shelf.")
        }
        return (.empty, nil)
    }

    private static func loadData(at url: URL) -> Data? {
        let present = FileManager.default.fileExists(atPath: url.path)
        guard present else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }

    private static func decode(_ data: Data) -> BentoChart? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try? decoder.decode(BentoChart.self, from: data)
    }
}
