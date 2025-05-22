import Foundation

struct PromptBuilder {
    static func loadPromptTemplate() -> String {
        guard let url = Bundle.main.url(forResource: "DevotionalPrompt", withExtension: "txt"),
              let prompt = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("DevotionalPrompt.txt not found or unreadable in bundle.")
        }
        return prompt
    }

    static func buildPrompt(bookDisplay: String, chapter: String, verse: String, verseText: String, today: String) -> String {
        return loadPromptTemplate()
            .replacingOccurrences(of: "{bookDisplay}", with: bookDisplay)
            .replacingOccurrences(of: "{chapter}", with: chapter)
            .replacingOccurrences(of: "{verse}", with: verse)
            .replacingOccurrences(of: "{verseText}", with: verseText)
            .replacingOccurrences(of: "{today}", with: today)
    }
}
