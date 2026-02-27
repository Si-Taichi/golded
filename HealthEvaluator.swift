import Foundation

enum Gender {
    case male
    case female
}

enum HealthLevel: String {
    case healthy = "Healthy"
    case inRisk = "In Risk"
    case danger = "Danger"
}

struct HealthResult {
    let overallStatus: HealthLevel
    let individualResults: [String: HealthLevel]
    let triggeredIssues: [String]
}

class HealthEvaluator {
    
    static func evaluate(
        gender: Gender,
        cholesterol: Double,
        hdl: Double,
        ldl: Double,
        triglyceride: Double,
        systolic: Double,
        diastolic: Double
    ) -> HealthResult {
        
        var riskScore = 0
        var results: [String: HealthLevel] = [:]
        var issues: [String] = []
        
        func check(_ level: HealthLevel, key: String) {
            results[key] = level
            if level == .inRisk { riskScore += 1 }
            if level == .danger { riskScore += 2 }
            if level != .healthy { issues.append(key) }
        }
        
        // Cholesterol
        if cholesterol < 200 {
            check(.healthy, key: "Cholesterol")
        } else if cholesterol <= 240 {
            check(.inRisk, key: "Cholesterol")
        } else {
            check(.danger, key: "Cholesterol")
        }
        
        // HDL
        if gender == .male {
            if hdl > 50 {
                check(.healthy, key: "HDL")
            } else if hdl >= 40 {
                check(.inRisk, key: "HDL")
            } else {
                check(.danger, key: "HDL")
            }
        } else {
            if hdl >= 40 {
                check(.healthy, key: "HDL")
            } else {
                check(.danger, key: "HDL")
            }
        }
        
        // LDL
        if ldl < 130 {
            check(.healthy, key: "LDL")
        } else if ldl <= 160 {
            check(.inRisk, key: "LDL")
        } else {
            check(.danger, key: "LDL")
        }
        
        // Triglyceride
        if triglyceride < 150 {
            check(.healthy, key: "Triglyceride")
        } else if triglyceride <= 200 {
            check(.inRisk, key: "Triglyceride")
        } else {
            check(.danger, key: "Triglyceride")
        }
        
        // Systolic
        if systolic < 130 {
            check(.healthy, key: "Systolic")
        } else if systolic <= 139 {
            check(.inRisk, key: "Systolic")
        } else {
            check(.danger, key: "Systolic")
        }
        
        // Diastolic
        if diastolic < 85 {
            check(.healthy, key: "Diastolic")
        } else if diastolic <= 89 {
            check(.inRisk, key: "Diastolic")
        } else {
            check(.danger, key: "Diastolic")
        }
        
        let overall: HealthLevel
        
        if riskScore == 0 {
            overall = .healthy
        } else if riskScore <= 3 {
            overall = .inRisk
        } else {
            overall = .danger
        }
        
        return HealthResult(
            overallStatus: overall,
            individualResults: results,
            triggeredIssues: issues
        )
    }
}
