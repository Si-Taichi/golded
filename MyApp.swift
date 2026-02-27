import SwiftUI

@main
struct MyApp: App {
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView().preferredColorScheme(selectedTheme.colorScheme)
            } else {
                OnboardingView()
            }
        }
    }
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var currentStep = 0
    var body: some View {
        VStack {
            Spacer()
            if currentStep == 0 {
                WelcomeStep()
            }
            if currentStep == 1 {
                NameStep()
            }
            if currentStep == 2 {
                AgeStep()
            }
            if currentStep == 3 {
                HWStep()
            }
            if currentStep == 4 {
                GenderStep()
            }
            Spacer()
            Button(action: nextStep) {
                Text(currentStep == 4 ? "Finish" : "Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .padding()
        .animation(.easeInOut, value: currentStep)
        .onAppear {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .notDetermined {
                    NotificationManager.shared.requestPermission()
                }
            }
        }
    }
    
    func nextStep() {
        if currentStep < 4 {
            currentStep += 1
        }
        else {
            hasCompletedOnboarding = true
        }
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.largeTitle)
            
            Text("Let’s personalize your experience.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

struct NameStep: View {
    
    @AppStorage("userName") var name = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Please tell me your name")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            TextField("Enter your name", text: $name)
                .padding()
                .frame(maxWidth: 300)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

struct AgeStep: View {
    
    @AppStorage("userAge") var selectedAge = 45
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Age")
                .font(.title)
            
            Stepper("Age: \(selectedAge)", value: $selectedAge, in: 35...65)
                .padding()
        }
    }
}

struct HWStep: View {
    @AppStorage("userHeight") var height = 170
    @AppStorage("userWeight") var weight = 65
    var body: some View {
        VStack(spacing: 16) {
            Text("Your weight and height").font(.title)
            Stepper("Weight : \(weight)", value: $weight, in: 40...120).padding()
            Stepper("Height : \(height)", value: $height, in: 120...200).padding()
        }
    }
}

struct GenderStep: View {
    
    @AppStorage("userGender") private var storedGender: String = Gender.male.rawValue
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Select Your Gender")
                .font(.title2)
            
            Picker("Gender", selection: $storedGender) {
                ForEach(Gender.allCases) { gender in
                    Text(gender.rawValue)
                        .tag(gender.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}

struct OptionButton: View {
    let title: String
    @Binding var selected: String
    var body: some View {
        Button(action: {
            selected = title
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selected == title ? Color.green.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
    }
}
