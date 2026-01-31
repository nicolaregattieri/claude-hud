import XCTest

// Note: Ensure this file is added to a Test Target in Xcode to run.
// @testable import ClaudeUsageMonitor 

class TimeFormatterTests: XCTestCase {
    
    // Mocking TimeFormatter here since we can't compile the main module in this script context easily
    // In a real test target, remove this struct and import the main module.
    
    func testTimeAgo() {
        let now = Date(timeIntervalSince1970: 1600000000) // Fixed reference time
        
        // 30 seconds ago
        let secondsAgo = now.addingTimeInterval(-30)
        let resultSec = TimeFormatter.timeAgo(from: secondsAgo, relativeTo: now)
        XCTAssertEqual(resultSec, "30 secs")
        
        // 5 minutes ago
        let minutesAgo = now.addingTimeInterval(-300)
        let resultMin = TimeFormatter.timeAgo(from: minutesAgo, relativeTo: now)
        XCTAssertEqual(resultMin, "5 mins")
        
        // 2 hours ago
        let hoursAgo = now.addingTimeInterval(-7200)
        let resultHr = TimeFormatter.timeAgo(from: hoursAgo, relativeTo: now)
        XCTAssertEqual(resultHr, "2 hrs")
    }
    
    func testTimeUntil() {
        let now = Date(timeIntervalSince1970: 1600000000)
        
        // In 30 seconds
        let inSeconds = now.addingTimeInterval(30)
        let resultSec = TimeFormatter.timeUntil(from: inSeconds, relativeTo: now)
        XCTAssertEqual(resultSec, "30 secs")
        
        // In 2 hours
        let inHours = now.addingTimeInterval(7200)
        let resultHr = TimeFormatter.timeUntil(from: inHours, relativeTo: now)
        XCTAssertEqual(resultHr, "2 hrs")
        
        // In 25 hours (1 day 1 hour)
        let inDayHour = now.addingTimeInterval(90000)
        let resultDay = TimeFormatter.timeUntil(from: inDayHour, relativeTo: now)
        XCTAssertEqual(resultDay, "1d 1h")
    }
}
