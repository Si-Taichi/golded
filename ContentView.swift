import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            MindView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Mind")
                }
            HealthView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Health")
                }
            RemindersView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Reminders")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(.green)
    }
}

struct DashboardView: View {
    
    @AppStorage("userName") var name = ""
    
    @State private var moodEntries: [MoodEntry] = []
    @State private var questions: [Question] = []
    @State private var showThankYou = false
    @State private var currentPeriod: CheckInPeriod?
    @State private var shouldShowQuestion = false
    @State private var currentQuestionIndex = 0
    @State private var hasAnswered = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                
                Text("Welcome Back, \(name)")
                    .font(.title)
                
                if shouldShowQuestion, let period = currentPeriod {
                    
                    Text(titleForPeriod(period))
                        .font(.headline)
                    
                    if questions.indices.contains(currentQuestionIndex) {
                        let question = questions[currentQuestionIndex]
                        
                        VStack(spacing: 12) {
                            Text(question.text)
                            
                            ForEach(question.options) { option in
                                Button {
                                    saveMood(option.value, question: question.text, period: period)
                                } label: {
                                    Text(option.text)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.15))
                                        .cornerRadius(12)
                                }
                                .disabled(hasAnswered)
                            }
                        }
                    }
                }
                else {
                    Text("You've completed your check-in for this period 💚")
                        .foregroundColor(.gray)
                }
                
                if showThankYou {
                    Text("Thanks for sharing 💚")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.4), value: currentQuestionIndex)
            .padding()
            .navigationTitle("Home")
            .onAppear {
                moodEntries = MoodManager.shared.loadEntries()
                currentPeriod = CheckInPeriod.current()
                questions = QuestionLoader.loadQuestions()
                
                if let period = currentPeriod {
                    shouldShowQuestion = !MoodManager.shared.hasAnsweredToday(for: period)
                }
            }
        }
    }
    
    func saveMood(_ value: String, question: String, period: CheckInPeriod) {
        
        guard !MoodManager.shared.hasAnsweredToday(for: period) else {
            return
        }
        
        let entry = MoodEntry(
            date: Date(),
            period: period.rawValue,
            question: question,
            value: value
        )
        
        MoodManager.shared.saveEntry(entry)
        
        withAnimation {
            shouldShowQuestion = false
            hasAnswered = true
        }
    }
    
    func titleForPeriod(_ period: CheckInPeriod) -> String {
        switch period {
        case .morning:
            return "It's going be a great morning, don't you think? ☀️"
        case .afternoon:
            return "Good Afternoon, isn't it? 🌤"
        case .evening:
            return "It's evening, why don't relax a littl? 🌙"
        }
    }
}

struct MoodButton: View {
    
    var text: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(12)
        }
    }
}

struct MindView: View {
    var body: some View {
        NavigationView {
            VStack {
                MentalStatusCard(
                    message: MoodManager.shared.mentalStatusMessage()
                )
                ActivityCard(
                    title: "Breathing Exercise",
                    description: "Slow breathing to calm yourself and your body.",
                    buttonTitle: "Go Now",
                    preview: MiniBreathingPreview(),
                    destination: BreathingView()
                )
                
                ActivityCard(
                    title: "Grounding",
                    description: "Check out your surroundings.",
                    buttonTitle: "Go now",
                    preview: GroundingPreview(),
                    destination: GroundingView()

                )
                
                ActivityCard(
                    title: "Tiny Win Today",
                    description: "What's the thing you're the most proud of today?",
                    buttonTitle: "Try Now",
                    preview: TinyWinsPreview(),
                    destination: TinyWinsView()

                )
            }
            .navigationTitle("Mind")
        }
    }
}

struct MentalStatusCard: View {
    
    var message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Mental Status")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.08))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct ActivityCard<Preview: View, Destination: View>: View {
    
    var title: String
    var description: String
    var buttonTitle: String
    var preview: Preview
    var destination: Destination
    
    var body: some View {
        HStack(spacing: 15) {
            
            preview
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                NavigationLink(destination: destination) {
                    Text(buttonTitle)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct HealthView: View {
    
    @State private var entries: [HealthEntry] = []
    @State private var showAddEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                VStack {
                    
                    if let result = healthResult {
                        HealthStatusView(result: result)
                            .padding(.horizontal)
                    } else {
                        Text("No health data available.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    if entries.isEmpty {
                        Text("No health records yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(entries) { entry in
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    if let sugar = entry.bloodSugar {
                                        Text("Blood Sugar: \(sugar)")
                                    }
                                    
                                    if let pressure = entry.bloodPressure {
                                        Text("Blood Pressure: \(pressure)")
                                    }
                                    
                                    if let cholesterol = entry.cholesterol {
                                        Text("Total Cholesterol: \(cholesterol)")
                                    }
                                    
                                    if let hdl = entry.hdl {
                                        Text("HDL: \(hdl)")
                                    }
                                    
                                    if let ldl = entry.ldl {
                                        Text("LDL: \(ldl)")
                                    }
                                    
                                    if let triglyceride = entry.triglyceride {
                                        Text("Triglyceride: \(triglyceride)")
                                    }
                                    
                                    Text("BMI: \(String(format: "%.1f", entry.bmi))")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Floating Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button {
                            showAddEntry = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(Color.blue)
                                        .shadow(color: .black.opacity(0.2), radius: 5)
                                )
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Health")
            .onAppear {
                entries = HealthEntryManager.shared.loadEntries()
            }
            .sheet(isPresented: $showAddEntry) {
                AddHealthEntryView {
                    entries = HealthEntryManager.shared.loadEntries()
                }
            }
        }
    }
    
    var healthResult: HealthResult? {
        
        guard let latest = entries.sorted(by: { $0.date > $1.date }).first else {
            return nil
        }
        
        let cholesterol = Double(latest.cholesterol ?? "")
        let hdl = Double(latest.hdl ?? "")
        let ldl = Double(latest.ldl ?? "")
        let triglyceride = Double(latest.triglyceride ?? "")
        
        var systolic: Double?
        var diastolic: Double?
        
        if let bp = latest.bloodPressure {
            let parts = bp.split(separator: "/")
            if parts.count == 2 {
                systolic = Double(parts[0])
                diastolic = Double(parts[1])
            }
        }
        
        return HealthEvaluator.evaluate(
            gender: .male,
            cholesterol: cholesterol,
            hdl: hdl,
            ldl: ldl,
            triglyceride: triglyceride,
            systolic: systolic,
            diastolic: diastolic
        )
    }
}

struct HealthStatusView: View {
    
    @State private var showPopup = false
    
    let result: HealthResult
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Your Health Status")
                .font(.headline)
            
            Text(result.overallStatus.rawValue)
                .font(.largeTitle)
                .bold()
                .foregroundColor(statusColor)
            
            Button {
                showPopup = true
            } label: {
                Text("More Info")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .sheet(isPresented: $showPopup) {
                HealthDetailPopup(result: result)
            }
            
        }
        .padding()
        .sheet(isPresented: $showPopup) {
            HealthDetailPopup(result: result)
        }
    }
    
    var statusColor: Color {
        switch result.overallStatus {
        case .healthy:
            return .green
        case .inRisk:
            return .orange
        case .danger:
            return .red
        }
    }
}

struct HealthDetailPopup: View {
    
    let result: HealthResult
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                if result.overallStatus == .healthy {
                    
                    Text("🎉 Keep up the good work!")
                        .font(.title2)
                        .bold()
                    
                    Text("All your health markers are within healthy range.")
                    
                } else {
                    
                    Text("⚠ Areas That Need Attention")
                        .font(.title2)
                        .bold()
                    
                    ForEach(result.triggeredIssues, id: \.self) { issue in
                        
                        if let issueData = result.individualResults[issue] {
                            
                            VStack(alignment: .leading) {
                                
                                Text("\(issue): \(issueData.level.rawValue)")
                                    .bold()
                                
                                Text(issueData.advice)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Health Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddHealthEntryView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("userHeight") var height = 170
    @AppStorage("userWeight") var weight = 65
    
    @State private var bloodSugar = ""
    @State private var bloodPressure = ""
    @State private var cholesterol = ""
    @State private var hdl = ""
    @State private var ldl = ""
    @State private var triglyceride = ""
    @State private var showAlert = false
    
    var onSave: () -> Void
    
    var bmi: Double {
        guard height > 0 else { return 0 }
        let heightInMeters = Double(height) / 100
        return Double(weight) / (heightInMeters * heightInMeters)
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Health Data")) {
                    
                    TextField("Blood Sugar (mg/dL)", text: $bloodSugar)
                        .keyboardType(.decimalPad)
                    
                    TextField("Blood Pressure (e.g. 120/80)", text: $bloodPressure)
                    
                    TextField("Total cholesterol (mg/dL)", text: $cholesterol)
                        .keyboardType(.decimalPad)
                    
                    TextField("HDL (mg/dL)", text: $hdl)
                        .keyboardType(.decimalPad)
                    
                    TextField("LDL (mg/dL)", text: $ldl)
                        .keyboardType(.decimalPad)
                    
                    TextField("Triglyceride (mg/dL)", text: $triglyceride)
                        .keyboardType(.decimalPad)
                    
                    
                    
                    HStack {
                        Text("BMI")
                        Spacer()
                        Text(String(format: "%.1f", bmi))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
            .alert("Please fill at least one field.", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func saveEntry() {
        
        if bloodSugar.isEmpty && bloodPressure.isEmpty && cholesterol.isEmpty && hdl.isEmpty && ldl.isEmpty && triglyceride.isEmpty {
            showAlert = true
            return
        }
        
        let entry = HealthEntry(
            date: Date(),
            bloodSugar: bloodSugar.isEmpty ? nil : bloodSugar,
            bloodPressure: bloodPressure.isEmpty ? nil : bloodPressure,
            cholesterol: cholesterol.isEmpty ? nil : cholesterol,
            hdl: hdl.isEmpty ? nil : hdl,
            ldl: ldl.isEmpty ? nil : ldl,
            triglyceride: triglyceride.isEmpty ? nil : triglyceride,
            bmi: bmi
        )
        
        HealthEntryManager.shared.saveEntry(entry)
        onSave()
        dismiss()
    }
}

struct RemindersView: View {
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                
                ForEach(GenerationType.allCases) { generation in
                    NavigationLink(destination: GenerationReminderView(generation: generation)) {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(generation.color.opacity(0.8))
                                .frame(height: 120)
                            
                            Text(generation.rawValue)
                                .opacity(0.7)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Reminders")
        }
    }
}

struct GenerationReminderView: View {
    
    let generation: GenerationType
    
    @State private var reminders: [ReminderItem] = []
    @State private var showAddReminder = false
    
    var body: some View {
        ZStack {

            VStack {
                
                if reminders.isEmpty {
                    Text("No reminders for \(generation.rawValue).")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(reminders) { reminder in
                            VStack(alignment: .leading) {
                                Text(reminder.title)
                                    .font(.headline)
                                
                                Text(reminder.date.formatted())
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(reminder.repeats.rawValue)
                                    .font(.caption2)
                            }
                        }
                        .onDelete(perform: deleteReminder)
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button {
                        showAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.blue)
                                    .shadow(color: .black.opacity(0.2), radius: 5)
                            )
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(generation.rawValue)
        .onAppear {
            reminders = ReminderManager.shared.load(for: generation)
        }
        .sheet(isPresented: $showAddReminder) {
            AddReminderView(generation: generation) {
                reminders = ReminderManager.shared.load(for: generation)
            }
        }
    }
    
    func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
        ReminderManager.shared.save(reminders, for: generation)
    }
}

struct AddReminderView: View {
    
    let generation: GenerationType
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var date = Date()
    @State private var repeatOption: RepeatOption = .none
    
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Details")) {
                    TextField("Reminder title", text: $title)
                    DatePicker("Date & Time", selection: $date)
                }
                
                Section(header: Text("Repeat")) {
                    Picker("Repeat", selection: $repeatOption) {
                        ForEach(RepeatOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("New Reminder")
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReminder()
                    }
                }
            }
        }
    }
    
    func saveReminder() {
        
        let newReminder = ReminderItem(
            id: UUID(),
            title: title,
            date: date,
            repeats: repeatOption,
            generation: generation
        )
        
        var reminders = ReminderManager.shared.load()
        reminders.append(newReminder)
        ReminderManager.shared.save(reminders)
        
        NotificationManager.shared.scheduleReminder(from: newReminder)
        
        onSave()
        dismiss()
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("App Settings")
                    .font(.title)
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}
