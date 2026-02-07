import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func checkAndNotify(metric: String, percentage: Double, lastNotified: inout [String: Int]) {
        let threshold: Int
        if percentage >= 90 {
            threshold = 90
        } else if percentage >= 80 {
            threshold = 80
        } else {
            // Reset tracking when usage drops below 80
            lastNotified.removeValue(forKey: metric)
            return
        }

        // Only notify once per threshold per metric
        if lastNotified[metric] == threshold { return }
        lastNotified[metric] = threshold

        let content = UNMutableNotificationContent()
        content.title = "Claude Usage Alert"
        content.body = "\(metric) usage is at \(Int(percentage))%"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(metric)-\(threshold)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // Show notifications even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
