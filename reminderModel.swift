import Foundation

struct ReminderItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: Date
    let repeats: RepeatOption
    let generation: GenerationType
}

enum RepeatOption: String, Codable, CaseIterable {
    case none = "One Time"
    case daily = "Daily"
    case weekly = "Weekly"
}
