import Foundation

enum HealthLevel: String {
    case healthy = "Healthy"
    case inRisk = "In Risk"
    case danger = "Danger"
}

struct HealthIssue {
    let level: HealthLevel
    let advice: String
}

struct HealthResult {
    let overallStatus: HealthLevel
    let individualResults: [String: HealthIssue]
    let triggeredIssues: [String]
}

class HealthEvaluator {
    
    static func evaluate(
        gender: Gender,
        cholesterol: Double?,
        hdl: Double?,
        ldl: Double?,
        triglyceride: Double?,
        systolic: Double?,
        diastolic: Double?
    ) -> HealthResult {
        
        var riskScore = 0
        var results: [String: HealthIssue] = [:]
        var issues: [String] = []
        var checkedItems = 0
        
        func check(_ level: HealthLevel, key: String) {
            let adviceText = advice(for: key, level: level)
            results[key] = HealthIssue(level: level, advice: adviceText)
            checkedItems += 1
            
            if level == .inRisk { riskScore += 1 }
            if level == .danger { riskScore += 2 }
            if level != .healthy { issues.append(key) }
        }
        
        // MARK: - Cholesterol
        if let cholesterol = cholesterol {
            if cholesterol < 200 {
                check(.healthy, key: "Cholesterol")
            } else if cholesterol <= 240 {
                check(.inRisk, key: "Cholesterol")
            } else {
                check(.danger, key: "Cholesterol")
            }
        }
        
        // MARK: - HDL
        if let hdl = hdl {
            if gender == .male {
                if hdl > 50 {
                    check(.healthy, key: "HDL")
                } else if hdl >= 40 {
                    check(.inRisk, key: "HDL")
                } else {
                    check(.danger, key: "HDL")
                }
            } else {
                if hdl >= 50 {
                    check(.healthy, key: "HDL")
                } else if hdl >= 40 {
                    check(.inRisk, key: "HDL")
                } else {
                    check(.danger, key: "HDL")
                }
            }
        }
        
        // MARK: - LDL
        if let ldl = ldl {
            if ldl < 130 {
                check(.healthy, key: "LDL")
            } else if ldl <= 160 {
                check(.inRisk, key: "LDL")
            } else {
                check(.danger, key: "LDL")
            }
        }
        
        // MARK: - Triglyceride
        if let triglyceride = triglyceride {
            if triglyceride < 150 {
                check(.healthy, key: "Triglyceride")
            } else if triglyceride <= 200 {
                check(.inRisk, key: "Triglyceride")
            } else {
                check(.danger, key: "Triglyceride")
            }
        }
        
        // MARK: - Systolic
        if let systolic = systolic {
            if systolic < 130 {
                check(.healthy, key: "Systolic")
            } else if systolic <= 139 {
                check(.inRisk, key: "Systolic")
            } else {
                check(.danger, key: "Systolic")
            }
        }
        
        // MARK: - Diastolic
        if let diastolic = diastolic {
            if diastolic < 85 {
                check(.healthy, key: "Diastolic")
            } else if diastolic <= 89 {
                check(.inRisk, key: "Diastolic")
            } else {
                check(.danger, key: "Diastolic")
            }
        }
        
        // If nothing entered
        if checkedItems == 0 {
            return HealthResult(
                overallStatus: .healthy,
                individualResults: [:],
                triggeredIssues: []
            )
        }
        
        let overall: HealthLevel
        
        if riskScore == 0 {
            overall = .healthy
        } else if riskScore <= 2 {
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
    
    // MARK: - Advice Generator
    private static func advice(for key: String, level: HealthLevel) -> String {
        
        switch key {
            
        case "Cholesterol":
            if level == .inRisk {
                return "Try reducing saturated fats, increasing fiber, and exercising regularly."
            } else if level == .danger {
                return "High cholesterol increases heart disease risk. Please consult a doctor."
            }
            
        case "HDL":
            if level == .inRisk {
                return "Increase aerobic exercise and include healthy fats like nuts and olive oil."
            } else if level == .danger {
                return "Low HDL significantly raises heart risk. Lifestyle change is strongly recommended."
            }
            
        case "LDL":
            if level == .inRisk {
                return "Limit processed foods and reduce red meat consumption."
            } else if level == .danger {
                return "High LDL may require medical treatment. Seek professional advice."
            }
            
        case "Triglyceride":
            if level == .inRisk {
                return "Reduce sugar intake and refined carbohydrates."
            } else if level == .danger {
                return "Very high triglycerides can be dangerous. Please consult a physician."
            }
            
        case "Systolic":
            if level == .inRisk {
                return "Monitor blood pressure and reduce sodium intake."
            } else if level == .danger {
                return "High systolic pressure may indicate hypertension. Medical evaluation advised."
            }
            
        case "Diastolic":
            if level == .inRisk {
                return "Improve stress management and physical activity."
            } else if level == .danger {
                return "High diastolic pressure requires medical consultation."
            }
            
        default:
            break
        }
        
        return ""
    }
}
