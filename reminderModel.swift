import Foundation

struct ReminderItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var repeats: RepeatOption
}

enum RepeatOption: String, Codable, CaseIterable {
    case none = "One Time"
    case daily = "Daily"
    case weekly = "Weekly"
}
