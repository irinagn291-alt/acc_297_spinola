import Foundation
import UIKit

/// Presentation seam. Views ask the deck to File, Swap, Donate, Release, and Peel.
/// The queue rules stay on BentoQueue. This type only mirrors the chart and sheets.
@MainActor
final class BentoDeck: ObservableObject {
    enum Sheet: String, Identifiable {
        case review
        case rules
        case settings
        case file
        case donate
        case swap
        case release
        case twist
        case onboard

        var id: String { rawValue }
    }

    enum Face {
        case empty
        case ready
        case failed
    }

    @Published private(set) var chart: BentoChart = .empty
    @Published private(set) var ready = false
    @Published private(set) var note: String?
    @Published private(set) var faultLine: String?
    @Published var sheet: Sheet?
    @Published var celebrate = false
    @Published private(set) var busy = false

    private let store: BentoStore
    private var launchApplied = false
    private var ticker: Task<Void, Never>?

    init(store: BentoStore = BentoStore()) {
        self.store = store
    }

    func boot() async {
        await store.seedDemoIfNeeded()
        await reload()
        applyLaunchIfReady()
        ready = true
        startTicker()
    }

    func reload() async {
        let snapshot = await store.snapshot()
        chart = snapshot
        note = await store.recoveryNote
    }

    func leaveActive() async {
        await store.sceneDidLeaveActive()
    }

    var homeFace: Face {
        if chart.queue.active == nil {
            if faultLine != nil || note != nil { return .failed }
            return .empty
        }
        return .ready
    }

    var reviewFace: Face {
        if note != nil, marks.isEmpty { return .failed }
        if marks.isEmpty { return .empty }
        return .ready
    }

    var rulesFace: Face {
        if note != nil, chart.rule.monthlyLimit <= 0 { return .failed }
        if chart.rule.monthlyLimit <= 0 { return .empty }
        return .ready
    }

    var settingsFace: Face {
        if note != nil, chart.rule.currency.isEmpty { return .failed }
        if chart.rule.currency.trimmingCharacters(in: .whitespaces).isEmpty { return .empty }
        return .ready
    }

    var marks: [MarkLine] {
        var lines: [MarkLine] = []
        lines += chart.queue.swapMarks.map { MarkLine.swap($0) }
        lines += chart.queue.donateMarks.map { MarkLine.donate($0) }
        lines += chart.queue.releaseMarks.map { MarkLine.release($0) }
        lines += chart.queue.shortMarks.map { MarkLine.short($0) }
        return lines.sorted { $0.order < $1.order }
    }

    func file(label: String, price: Double, priority: Double, nec: Double, disc: Double) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            _ = try await store.file(label: label, price: price, priority: priority, nec: nec, disc: disc)
            await reload()
            faultLine = nil
            sheet = nil
            pulse()
        } catch let fault as BentoFault {
            faultLine = fault.spoken
        } catch {
            faultLine = "That buy could not be filed. Try a name and a price above zero."
        }
    }

    func swap(to id: UUID) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            try await store.swap(to: id)
            await reload()
            faultLine = nil
            pulse()
        } catch let fault as BentoFault {
            faultLine = fault.spoken
        } catch {
            faultLine = "The tick stayed where it was. Tap a frozen tile again."
        }
    }

    func donate(from id: UUID) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            let covered = try await store.donate(from: id)
            await reload()
            faultLine = covered ? nil : "Those frozen hours do not cover the active ring. Both tiles stayed."
            sheet = nil
            if covered { pulse() }
        } catch let fault as BentoFault {
            faultLine = fault.spoken
        } catch {
            faultLine = "Donate did not run. The shelf is unchanged."
        }
    }

    func release() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            try await store.release()
            await reload()
            faultLine = nil
            pulse()
        } catch let fault as BentoFault {
            faultLine = fault.spoken
        } catch {
            faultLine = "Release waits until the active ring reads zero."
        }
    }

    func peel() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            try await store.peel()
            await reload()
            faultLine = nil
            pulse()
        } catch let fault as BentoFault {
            faultLine = fault.spoken
        } catch {
            faultLine = "Nothing to peel. Swap or donate first."
        }
    }

    func saveRule(_ rule: SpanRule) async {
        await store.updateRule(rule)
        await reload()
        faultLine = nil
    }

    func finishOnboarding(_ rule: SpanRule) async {
        var next = rule
        next.onboardingComplete = true
        await saveRule(next)
        applyLaunchIfReady()
    }

    func rerunOnboarding() async {
        var rule = chart.rule
        rule.onboardingComplete = false
        await saveRule(rule)
        sheet = nil
    }

    func resetAll() async {
        await store.resetAllData()
        await reload()
        faultLine = nil
        sheet = nil
    }

    func clearFault() {
        faultLine = nil
    }

    private func applyLaunchIfReady() {
        guard chart.rule.onboardingComplete, !launchApplied else { return }
        launchApplied = true
        switch ReviewLaunch.screen {
        case "today", "home":
            sheet = nil
        case "log", "review":
            sheet = .review
        case "goals", "rules":
            sheet = .rules
        case "settings":
            sheet = .settings
        case "file":
            sheet = .file
        case "swap":
            sheet = .swap
        case "donate":
            sheet = .donate
        case "release":
            sheet = .release
        case "twist":
            sheet = .twist
        default:
            break
        }
    }

    private func startTicker() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                guard !Task.isCancelled, let self else { return }
                await self.store.tickMinute()
                await self.reload()
            }
        }
    }

    private func pulse() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        celebrate = true
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 900_000_000)
            self?.celebrate = false
        }
    }
}

enum MarkLine: Identifiable {
    case swap(SwapMark)
    case donate(DonateMark)
    case release(ReleaseMark)
    case short(ShortMark)

    var id: String {
        switch self {
        case .swap(let mark): "swap-\(mark.id.uuidString)"
        case .donate(let mark): "donate-\(mark.id.uuidString)"
        case .release(let mark): "release-\(mark.id.uuidString)"
        case .short(let mark): "short-\(mark.id.uuidString)"
        }
    }

    var order: Int {
        switch self {
        case .swap(let mark): mark.order
        case .donate(let mark): mark.order
        case .release(let mark): mark.order
        case .short(let mark): mark.order
        }
    }

    var day: Int {
        switch self {
        case .swap(let mark): mark.day
        case .donate(let mark): mark.day
        case .release(let mark): mark.day
        case .short(let mark): mark.day
        }
    }
}

extension BentoFault {
    var spoken: String {
        switch self {
        case .invalidWant:
            "That needs a name and a price the monthly limit can span."
        case .emptyQueue:
            "Nothing is cooling yet. File a buy first."
        case .notOnShelf:
            "That tile is not frozen on the shelf."
        case .releaseRefused:
            "Release only when the active ring reads zero."
        case .donateRefused:
            "Donate runs while a clock is still cooling."
        case .peelEmpty:
            "No swap or donate to peel."
        case .peelBlocked:
            "Peel can only restore the latest swap or donate."
        }
    }
}
