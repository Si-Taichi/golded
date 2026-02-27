import Foundation
import SwiftUI

enum GenerationType: String, CaseIterable, Identifiable, Codable {
    case kids = "Kids"
    case you = "You"
    case elders = "Elders"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .elders:
            return Color.yellow.opacity(0.7)
        case .you:
            return Color.green.opacity(0.7)
        case .kids:
            return Color.yellow.opacity(0.7)
        }
    }
}

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
    
    func load(for generation: GenerationType) -> [ReminderItem] {
        let all = load()
        return all.filter { $0.generation == generation }
    }

    func save(_ reminders: [ReminderItem], for generation: GenerationType) {
        var all = load()
        all.removeAll { $0.generation == generation }
        all.append(contentsOf: reminders)
        save(all)
    }
}
