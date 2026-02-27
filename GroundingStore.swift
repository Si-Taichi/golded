import Foundation
import SwiftUI

struct GroundingSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    
    var see: [String]
    var feel: [String]
    var hear: [String]
    var smell: [String]
    var taste: [String]
}

class GroundingStore: ObservableObject {
    
    @Published var sessions: [GroundingSession] = []
    
    private let key = "groundingSessions"
    
    init() {
        load()
    }
    
    func addSession(_ session: GroundingSession) {
        sessions.insert(session, at: 0)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([GroundingSession].self, from: data) {
            sessions = decoded
        }
    }
}
