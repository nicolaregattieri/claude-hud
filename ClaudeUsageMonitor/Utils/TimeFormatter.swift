import Foundation

struct TimeFormatter {
    static func timeAgo(from date: Date, relativeTo now: Date = Date()) -> String {
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            let seconds = max(0, Int(interval))
            return "\(seconds) sec\(seconds == 1 ? "" : "s")"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min\(minutes == 1 ? "" : "s")"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hr\(hours == 1 ? "" : "s")"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s")"
        }
    }

    static func timeUntil(from date: Date, relativeTo now: Date = Date()) -> String {
        let interval = date.timeIntervalSince(now)

        if interval <= 0 {
            return "now"
        } else if interval < 60 {
            let seconds = Int(interval)
            return "\(seconds) sec\(seconds == 1 ? "" : "s")"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min\(minutes == 1 ? "" : "s")"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            }
            return "\(hours) hr\(hours == 1 ? "" : "s")"
        } else {
            let days = Int(interval / 86400)
            let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
            if hours > 0 && days < 7 {
                return "\(days)d \(hours)h"
            }
            return "\(days)d"
        }
    }
}
