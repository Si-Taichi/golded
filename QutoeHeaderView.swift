import SwiftUI

struct QuoteHeaderView: View {
    
    private let quotes = [
        "Small steps every day.",
        "Your well-being matters.",
        "Breathe. Reset. Continue.",
        "Progress, not perfection.",
        "You are doing better than you think.",
        "Take it one moment at a time."
    ]
    
    private var todaysQuote: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[day % quotes.count]
    }
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.25),
                            Color.green.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 150)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 10) {
                
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.green)
                
                Text(todaysQuote)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
        }
        .padding(.horizontal)
    }
}
