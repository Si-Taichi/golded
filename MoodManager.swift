import Foundation

class MoodManager {
    
    static let shared = MoodManager()
    private let key = "moodEntries"
    
    func saveEntry(_ entry: MoodEntry) {
        var entries = loadEntries()
        entries.insert(entry, at: 0)
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadEntries() -> [MoodEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data)
        else {
            return []
        }
        return decoded
    }

    func hasAnsweredToday(for period: CheckInPeriod) -> Bool {
        let entries = loadEntries()
        
        return entries.contains { entry in
            Calendar.current.isDateInToday(entry.date) &&
            entry.period == period.rawValue
        }
    }
}
