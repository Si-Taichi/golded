import Foundation

struct DailyMood {
    let date: Date
    let value: Int
}

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
            let isSameDay = Calendar.current.isDateInToday(entry.date)
            return isSameDay && entry.period == period.rawValue
        }
    }
    
    func consecutiveCount(for value: String) -> Int {
        let entries = loadEntries()
            .sorted { $0.date > $1.date }   // newest first
        
        var count = 0
        
        for entry in entries {
            if entry.value == value {
                count += 1
            } else {
                break
            }
        }
        
        return count
    }
    
    func mentalStatusMessage() -> String {
        
        let badStreak = consecutiveDailyCount(for: 1)
        let goodStreak = consecutiveDailyCount(for: 3)
        
        if badStreak >= 3 {
            return "You've been feeling low for a few days 💙 It's okay to slow down and take care of yourself."
        }
        
        if goodStreak >= 3 {
            return "You've been doing great for several days 🌟 Keep it up!"
        }
        
        return "Your mental state looks balanced 😊"
    }
    
    func dailyAverages() -> [DailyMood] {
        
        let entries = loadEntries()
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        var results: [DailyMood] = []
        
        for (day, dayEntries) in grouped {
            
            let values = dayEntries.compactMap { Int($0.value) }
            guard !values.isEmpty else { continue }
            let average = Double(values.reduce(0, +)) / Double(values.count)
            let rounded = Int(average.rounded())
            
            results.append(DailyMood(date: day, value: rounded))
        }
        
        return results.sorted { $0.date > $1.date }
    }
    
    func consecutiveDailyCount(for target: Int) -> Int {
        
        let daily = dailyAverages()
        var count = 0
        
        for day in daily {
            if day.value == target {
                count += 1
            } else {
                break
            }
        }
        
        return count
    }
}
