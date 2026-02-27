import SwiftUI

struct TinyWinsPreview: View {
    
    @State private var offset: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.3))
                .frame(height: 20)
                .offset(y: offset)
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.45))
                .frame(height: 20)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                offset = -5
            }
        }
    }
}

struct TinyWinCard: View {
    
    let win: TinyWin
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(win.text)
                .font(.body)
            
            Text(win.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.08))
        )
        .padding(.vertical, 4)
    }
}

struct TinyWinsView: View {
    
    @StateObject private var store = TinyWinsStore()
    @State private var winText = ""
    @State private var showCelebration = false
    
    private func saveWin() {
        guard !winText.isEmpty else { return }
        
        store.addWin(text: winText)
        winText = ""
        
        showCelebration = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showCelebration = false
        }
    }
    
    private var celebrationView: some View {
        Group {
            if showCelebration {
                Text("🌟 Nice Job!")
                    .font(.title2)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .transition(.scale)
            }
        }
        .animation(.easeInOut, value: showCelebration)
    }
    
    var body: some View {
        VStack(spacing: 25) {
            
            Text("What’s one thing you’re proud of today?")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            TextField("Write your tiny win...", text: $winText)
                .textFieldStyle(.roundedBorder)
            
            Button("Save Win") {
                saveWin()
            }
            .buttonStyle(.borderedProminent)
            
            Divider()
            
            if store.wins.isEmpty {
                Text("Your tiny wins will appear here 🌿")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(store.wins) { win in
                        TinyWinCard(win: win)
                    }
                    .onDelete(perform: store.deleteWin)
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle("Tiny Wins")
        .overlay(celebrationView)
    }
}
