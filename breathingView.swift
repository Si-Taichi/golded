import SwiftUI

struct MiniBreathingPreview: View {
    
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.3))
            .frame(width: 50, height: 50)
            .scaleEffect(animate ? 1.2 : 0.8)
            .animation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

struct BreathingView: View {
    
    enum Phase {
        case countdown
        case breathing
        case finished
    }
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var phase: Phase = .countdown
    @State private var countdown = 3
    @State private var timeRemaining = 60
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isActive = false
    
    @State private var isBreathingIn = true
    @State private var animate = false
    
    let inhaleDuration: Double = 4
    let exhaleDuration: Double = 4
    
    var body: some View {
        VStack(spacing: 40) {
            
            if phase == .countdown {
                
                Text("Starting in")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("\(countdown)")
                    .font(.system(size: 60, weight: .bold))
            }
            
            if phase == .breathing {
                
                Text(isBreathingIn ? "Breathe In" : "Breathe Out")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .frame(height: 30)
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(animate ? 1.0 : 0.55)
                        .animation(
                            .easeInOut(duration: isBreathingIn ? inhaleDuration : exhaleDuration),
                            value: animate
                        )
                }
                .frame(width: 220, height: 220)
                
                Text("\(timeRemaining)s")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
            }
            
            if phase == .finished {
                
                Text("Great Job 🌿")
                    .font(.title2)
                
                Text("You completed 1 minute of breathing.")
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .onReceive(timer) { _ in
            guard isActive else { return }

            switch phase {
                
            case .countdown:
                if countdown > 1 {
                    countdown -= 1
                } else {
                    phase = .breathing
                    startBreathing()
                }
                
            case .breathing:
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    phase = .finished
                    isActive = false
                }
                
            case .finished:
                break
            }
        }
        .padding()
        .navigationTitle("Breathing")
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            isActive = false
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue != .active {
                isActive = false
            }
        }
    }
    func startCountdown() {
        countdown = 3
        phase = .countdown
        isActive = true
    }
    
    func startBreathing() {
        timeRemaining = 60
        isBreathingIn = true
        animate = true
        
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            animate.toggle()
        }
        
        startBreathingCycle()
    }
    
    func startBreathingCycle() {
        guard phase == .breathing else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            if phase == .breathing {
                isBreathingIn.toggle()
                animate.toggle()
                startBreathingCycle()
            }
        }
    }
}
