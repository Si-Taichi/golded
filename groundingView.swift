import SwiftUI
import Foundation

enum GroundingStep: Int, CaseIterable {
    case see = 0
    case feel
    case hear
    case smell
    case taste
    
    var title: String {
        switch self {
        case .see: return "5 things you see"
        case .feel: return "4 things you feel"
        case .hear: return "3 things you hear"
        case .smell: return "2 things you smell"
        case .taste: return "1 thing you taste"
        }
    }
    
    var count: Int {
        switch self {
        case .see: return 5
        case .feel: return 4
        case .hear: return 3
        case .smell: return 2
        case .taste: return 1
        }
    }
}

struct GroundingPreview: View {
    
    @State private var currentNumber = 5
    @State private var nextNumber = 4
    
    @State private var currentOffset: CGFloat = 0
    @State private var nextOffset: CGFloat = 120
    
    @State private var animating = false
    
    private func startLoop() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            animateTransition()
        }
    }
    
    private func animateTransition() {
        
        guard !animating else { return }
        animating = true
        
        nextNumber = currentNumber > 1 ? currentNumber - 1 : 5
        nextOffset = 120
        
        // Slide left + slide in
        withAnimation(.easeInOut(duration: 0.4)) {
            currentOffset = -120
            nextOffset = -10   // slight overshoot past center
        }
        
        // Settle to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.2)) {
                nextOffset = 0
            }
        }
        
        // Reset for next cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            currentNumber = nextNumber
            currentOffset = 0
            nextOffset = 120
            animating = false
        }
    }
    
    var body: some View {
        ZStack {
            
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 80, height: 80)
            
            ZStack {
                
                Text("\(currentNumber)")
                    .font(.title)
                    .bold()
                    .offset(x: currentOffset)
                
                Text("\(nextNumber)")
                    .font(.title)
                    .bold()
                    .offset(x: nextOffset)
            }
            .frame(width: 80, height: 80)
            .mask(
                Circle()
                    .frame(width: 80, height: 80)
            )
        }
        .onAppear {
            startLoop()
        }
    }
}

struct GroundingHistoryView: View {
    
    @ObservedObject var store: GroundingStore
    
    var body: some View {
        List {
            ForEach(store.sessions) { session in
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("See: \(session.see.joined(separator: ", "))")
                    Text("Feel: \(session.feel.joined(separator: ", "))")
                    Text("Hear: \(session.hear.joined(separator: ", "))")
                    Text("Smell: \(session.feel.joined(separator: ", "))")
                    Text("Taste: \(session.hear.joined(separator: ", "))")
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("History")
    }
}

struct GroundingView: View {
    
    @StateObject private var store = GroundingStore()
    
    @State private var currentStep: GroundingStep = .see
    @State private var inputs: [String] = []
    @State private var allInputs: [GroundingStep: [String]] = [:]
    @State private var textFieldValue = ""
    @State private var finished = false
    
    private func addInput() {
        guard !textFieldValue.isEmpty else { return }
        if inputs.count < currentStep.count {
            inputs.append(textFieldValue)
            textFieldValue = ""
        }
    }
    
    private func goToNextStep() {
        
        allInputs[currentStep] = inputs
        
        if let next = GroundingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
            inputs = []
        } else {
            saveSession()
            finished = true
        }
    }
    
    private func saveSession() {
        let session = GroundingSession(
            date: Date(),
            see: allInputs[.see] ?? [],
            feel: allInputs[.feel] ?? [],
            hear: allInputs[.hear] ?? [],
            smell: allInputs[.smell] ?? [],
            taste: allInputs[.taste] ?? []
        )
        
        store.addSession(session)
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Text("You’re grounded 🌿")
                .font(.title2)
            
            Text("Take a breath and notice how you feel.")
                .foregroundColor(.gray)
            
            NavigationLink("View History") {
                GroundingHistoryView(store: store)
            }
        }
    }
    
    private var stepView: some View {
        VStack(spacing: 20) {
            
            Text(currentStep.title)
                .font(.title3)
                .multilineTextAlignment(.center)
            
            ProgressView(value: Double(currentStep.rawValue),
                         total: Double(GroundingStep.allCases.count - 1))
            
            TextField("Type one item...", text: $textFieldValue)
                .textFieldStyle(.roundedBorder)
            
            Button("Add") {
                addInput()
            }
            .buttonStyle(.borderedProminent)
            
            VStack(alignment: .leading) {
                ForEach(inputs, id: \.self) { item in
                    Text("• \(item)")
                }
            }
            
            Button("Next") {
                goToNextStep()
            }
            .disabled(inputs.count < currentStep.count)
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            
            if finished {
                completionView
            } else {
                stepView
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Grounding")
    }
}
