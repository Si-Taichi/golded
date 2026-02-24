import Foundation

class ReminderManager {
    
    static let shared = ReminderManager()
    private let key = "savedReminders"
    
    func save(_ reminders: [ReminderItem]) {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() -> [ReminderItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ReminderItem].self, from: data)
        else { return [] }
        
        return decoded
    }
}
