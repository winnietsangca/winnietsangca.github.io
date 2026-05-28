import UserNotifications
import Foundation

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestPermission() async {
        try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleGearAlert(for racket: Racket) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [racket.name + "_restring"])

        guard racket.warningSoon || racket.needsRestring else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to restring 🎾"
        content.body  = "\(racket.name) — \(racket.hoursDetail) and \(racket.monthsDetail)"
        content.sound = .default

        // Fire now (alert was triggered by a session update)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: racket.name + "_restring",
            content: content,
            trigger: trigger)
        center.add(request)
    }

    func scheduleGearAlert(for shoe: Shoe) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [shoe.name + "_shoes"])

        guard shoe.warningSoon || shoe.needsReplacement else { return }

        let content = UNMutableNotificationContent()
        content.title = "Replace your shoes 👟"
        content.body  = "\(shoe.name) — \(shoe.wornDetail)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: shoe.name + "_shoes",
            content: content,
            trigger: trigger)
        center.add(request)
    }
}
