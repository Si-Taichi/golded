import Foundation

struct HealthEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    
    var bloodSugar: String?
    var bloodPressure: String?
    
    var cholesterol: String?
    var hdl: String?
    var ldl: String?
    var triglyceride: String?
    
    var bmi: Double
}

