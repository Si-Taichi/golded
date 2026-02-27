import SwiftUI

class TinyWinsStore: ObservableObject {
    
    @Published var wins: [TinyWin] = []
    private let key = "tinyWins"
    
    init() {
        load()
    }
    
    func addWin(text: String) {
        let newWin = TinyWin(text: text, date: Date())
        wins.insert(newWin, at: 0)
        save()
    }
    
    func deleteWin(at offsets: IndexSet) {
        wins.remove(atOffsets: offsets)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(wins) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([TinyWin].self, from: data) {
            wins = decoded
        }
    }
}
