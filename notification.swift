import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("Permission granted")
            }
        }
    }

    func scheduleNotification(title: String, date: Date) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Don't forget 💚"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleReminder(from reminder: ReminderItem) {
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "Take a moment 💚"
        content.sound = .default
        
        let components: DateComponents
        
        switch reminder.repeats {
            
        case .none:
            components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.date
            )
            
        case .daily:
            components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: reminder.date
            )
            
        case .weekly:
            components = Calendar.current.dateComponents(
                [.weekday, .hour, .minute],
                from: reminder.date
            )
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: reminder.repeats != .none
        )
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
