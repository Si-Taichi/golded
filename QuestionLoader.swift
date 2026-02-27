import Foundation

class QuestionLoader {
    
    static func loadQuestions() -> [Question] {
        
        guard let url = Bundle.main.url(forResource: "question", withExtension: "txt"),
              let rawContent = try? String(contentsOf: url, encoding: .utf8)
        else {
            print("Failed to load questions.txt")
            return []
        }
        
        let content = rawContent.replacingOccurrences(of: "\r\n", with: "\n")
        
        var questions: [Question] = []
        let blocks = content.components(separatedBy: "#QUESTION")
        
        for block in blocks {
            
            let lines = block
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: CharacterSet.newlines)
                .filter { !$0.isEmpty }
            
            guard lines.count >= 2 else { continue }
            
            let questionText = lines[0]
            var options: [QuestionOption] = []
            
            for line in lines.dropFirst() {
                let parts = line.components(separatedBy: "|")
                if parts.count == 2 {
                    options.append(
                        QuestionOption(
                            text: parts[0].trimmingCharacters(in: .whitespaces),
                            value: parts[1].trimmingCharacters(in: .whitespaces)
                        )
                    )
                }
            }
            
            if !options.isEmpty {
                questions.append(
                    Question(text: questionText, options: options)
                )
            }
        }
        
        print("Loaded \(questions.count) questions")
        return questions
    }
}   
