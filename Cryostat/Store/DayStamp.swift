import Foundation

/// Calendar day as YYYYMMDD, taken from `startOfDay` so a daylight-saving edge
/// still lands on the local day the mark belongs to.
enum DayStamp {
    static func yyyymmdd(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
