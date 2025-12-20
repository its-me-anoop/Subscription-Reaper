//
//  SavingsPredictor.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import Foundation
import FoundationModels
#if canImport(GoogleGenerativeAI)
import GoogleGenerativeAI
#endif
import SwiftUI

@Generable
struct SmartInsight: Equatable {
    @Guide(description: "Service")
    let title: String
    
    @Guide(description: "Tip")
    let description: String
    
    @Guide(description: "Value")
    let potentialSavings: Double
    
    @Guide(description: "Score")
    let priority: Double
    
    @Guide(description: "Kind")
    let type: String
}

@Generable
struct AnalysisResult: Equatable {
    @Guide(description: "List")
    let insights: [SmartInsight]
    
    @Guide(description: "Note")
    let summary: String
    
    @Guide(description: "Total")
    let totalPotentialSavings: Double
}

class SavingsPredictor {
    static let shared = SavingsPredictor()
    
    private let foundationModelSession = LanguageModelSession()
    
    // Engine preference tracking (for UI)
    enum Engine: String {
        case gemini = "Gemini 3 Flash"
        case foundation = "Foundation Model (On-Device)"
    }
    var activeEngine: Engine = .foundation

    func analyzeSubscriptions(_ subscriptions: [Subscription], defaultCurrency: String, country: String) async -> AnalysisResult? {
        guard !subscriptions.isEmpty else { return nil }
        
        let subData = subscriptions.map { sub in
            "Name: \(sub.name), Amount: \(sub.amount) \(sub.currency), Frequency: \(sub.frequency), Category: \(sub.category)"
        }.joined(separator: "\n")
        
        let marketContext = getMarketContextFor(country: country)
        
        // 1. Try Gemini first if API key is present
        let apiKey = UserDefaults.standard.string(forKey: "geminiApiKey") ?? ""
        if !apiKey.isEmpty {
            let prompt = generateFullPrompt(subData: subData, marketContext: marketContext, country: country, defaultCurrency: defaultCurrency)
            if let result = await analyzeWithGemini(prompt: prompt, apiKey: apiKey) {
                activeEngine = .gemini
                return result
            }
        }
        
        // 2. Fallback to Apple Foundation Model (Minimalistic & Neutral to avoid refusal/limit)
        activeEngine = .foundation
        // Rephrased to be "data processing" instead of "financial advice" to avoid safety refusals
        let miniPrompt = "Here is a list of subscription data: \(subData). Please categorize these items by type (e.g., Entertainment, Utility) and identify any obvious duplicates. return the result as a structured summary."
        return await analyzeWithFoundationModel(prompt: miniPrompt)
    }
    
    private static var hasLoggedMissingModule = false
    
    private func analyzeWithGemini(prompt: String, apiKey: String) async -> AnalysisResult? {
        #if canImport(GoogleGenerativeAI)
        let model = GenerativeModel(name: "gemini-3-flash-preview", apiKey: apiKey)
        
        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text else { return nil }
            print("Gemini Raw Response: \(text)")
            return parseGeminiResponse(text)
        } catch {
            print("Gemini Analysis Failed: \(error)")
            return nil
        }
        #else
        if !Self.hasLoggedMissingModule {
            print("GoogleGenerativeAI module not available. Please add the package dependency in Xcode (File > Add Package Dependencies) with: https://github.com/google/generative-ai-swift")
            Self.hasLoggedMissingModule = true
        }
        return nil
        #endif
    }
    
    private func analyzeWithFoundationModel(prompt: String) async -> AnalysisResult? {
        do {
            let response = try await foundationModelSession.respond(
                to: prompt,
                generating: AnalysisResult.self
            )
            return response.content
        } catch {
            print("Foundation Model Analysis Failed: \(error)")
            return nil
        }
    }
    
    private func generateFullPrompt(subData: String, marketContext: String, country: String, defaultCurrency: String) -> String {
        return """
        SYSTEM: You are a financial expert. Analyze ONLY these user subscriptions:
        [START]
        \(subData)
        [END]
        
        MARKET CONTEXT FOR \(country):
        \(marketContext)
        
        INSTRUCTIONS:
        1. NO HALLUCINATIONS. Only use services in the [START]...[END] block.
        2. Group into 'Optimization', 'Duplicate', 'HighCost', or 'Lifestyle'.
        3. Provide response as VALID JSON strictly matching this schema:
        {
          "insights": [
            {
              "title": "Service Name",
              "description": "Actionable tip",
              "potentialSavings": 10.99,
              "priority": 0.9,
              "type": "Optimization"
            }
          ],
          "summary": "Brief overall summary",
          "totalPotentialSavings": 10.99
        }
        4. Do not include markdown formatting like ```json.
        """
    }
    
    private func getMarketContextFor(country: String) -> String {
        var context = "Recent Trends (Late 2025/2026):\n- Streaming services are pushing \"Ad-supported\" tiers as the new entry standard.\n- Yearly bundles (e.g. Disney+) usually save ~16% (2 months free).\n- Multi-service bundles (Apple One, Disney/Hulu/Max) are the primary way to reduce total bill.\n\n"
        
        switch country {
        case "US":
            context += """
            United States (US):
            - Netflix: Standard with Ads ($7.99), Standard ($17.99), Premium ($24.99).
            - Spotify: Individual ($11.99), Duo ($16.99), Family ($19.99), Student ($5.99).
            - Apple One: Individual ($19.95), Family ($25.95), Premier ($37.95).
            - Disney Bundle: Duo Basic ($12.99), Duo Premium ($19.99), Trio Basic ($29.99), Trio Premium ($38.99).
            - YouTube Premium: Individual ($13.99).
            """
        case "UK":
            context += """
            United Kingdom (UK):
            - Netflix: Standard with Ads (£4.99), Standard (£10.99), Premium (£17.99).
            - Spotify: Individual (£11.99), Duo (£16.99), Family (£19.99).
            - Apple One: Individual (£18.95), Family (£24.95), Premier (£36.95).
            """
        case "IN":
            context += """
            India (IN):
            - Netflix: Mobile (₹149), Basic (₹199), Standard (₹499), Premium (₹649).
            - Spotify India: Premium Individual (₹119), Duo (₹149), Family (₹179).
            - Disney+ Hotstar: Super (₹899/yr), Premium (₹1499/yr).
            - Apple One India: Individual (₹195), Family (₹365).
            """
        case "EU":
            context += """
            Europe (EU - avg):
            - Netflix: Standard with Ads (€5.99), Standard (€13.99), Premium (€19.99).
            - Spotify: Individual (€10.99), Family (€17.99).
            - Apple One: Individual (€19.95), Family (€25.95).
            """
        case "AU":
            context += """
            Australia (AU):
            - Netflix: Standard with Ads ($7.99), Standard ($18.99), Premium ($25.99).
            - Spotify: Individual ($13.99), Family ($22.99).
            - Apple One: Individual ($21.95), Premier ($42.95).
            """
        case "CA":
            context += """
            Canada (CA):
            - Netflix: Standard with Ads ($5.99), Standard ($16.49), Premium ($20.99).
            - Spotify: Individual ($10.99), Family ($16.99).
            - Apple One: Individual ($18.95), Premier ($37.95).
            """
        case "JP":
            context += """
            Japan (JP):
            - Netflix: Standard with Ads (¥790), Standard (¥1,490), Premium (¥1,980).
            - Spotify Japan: Standard (¥980), Family (¥1,580).
            - Apple One Japan: Individual (¥1,200), Family (¥1,980).
            """
        default:
            context += "Global pricing trends suggest bundle savings of ~15-20% compared to individual plans."
        }
        
        return context
    }
    
    private func parseGeminiResponse(_ text: String) -> AnalysisResult? {
        // Clean the text from markdown blocks if present
        let jsonString = text.replacingOccurrences(of: "```json", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            // Since AnalysisResult is @Model or @Generable, let's see if we can decode it normally.
            // If it's a SwiftData @Model it might need special handling, but here it's just a struct in SavingsPredictor.
            // Wait, AnalysisResult is declared as a struct at the top of this file.
            let decoder = JSONDecoder()
            return try decoder.decode(AnalysisResult.self, from: data)
        } catch {
            print("Failed to parse Gemini JSON: \(error)")
            return nil
        }
    }
}

// Ensure AnalysisResult and SmartInsight are Decodable
extension SmartInsight: Decodable {}
extension AnalysisResult: Decodable {}
