//
//  PlanLookupService.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import Foundation

struct StreamingSource: Identifiable {
    let id: String
    let name: String
    let logoUrl: String
    let category: String
    let defaultIcon: String
}

class PlanLookupService {
    static let shared = PlanLookupService()
    
    private let sources: [String: StreamingSource] = [
        // Entertainment / Streaming
        "netflix": StreamingSource(id: "netflix", name: "Netflix", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/f/ff/Netflix-new-icon.png", category: "Entertainment", defaultIcon: "play.tv.fill"),
        "spotify": StreamingSource(id: "spotify", name: "Spotify", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Spotify_logo_without_text.svg/1024px-Spotify_logo_without_text.svg.png", category: "Entertainment", defaultIcon: "music.note"),
        "youtube": StreamingSource(id: "youtube", name: "YouTube", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/YouTube_full-color_icon_%282017%29.svg/1024px-YouTube_full-color_icon_%282017%29.svg.png", category: "Entertainment", defaultIcon: "play.rectangle.fill"),
        "disney": StreamingSource(id: "disney", name: "Disney+", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Disney%2B_logo.svg/1024px-Disney%2B_logo.svg.png", category: "Entertainment", defaultIcon: "sparkles.tv.fill"),
        "hulu": StreamingSource(id: "hulu", name: "Hulu", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Hulu_Logo.svg/1024px-Hulu_Logo.svg.png", category: "Entertainment", defaultIcon: "play.fill"),
        "hbo": StreamingSource(id: "hbo", name: "Max", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Max_logo.svg/1024px-Max_logo.svg.png", category: "Entertainment", defaultIcon: "play.circle.fill"),
        "prime": StreamingSource(id: "prime", name: "Prime Video", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Amazon_Prime_Video_logo.svg/1024px-Amazon_Prime_Video_logo.svg.png", category: "Entertainment", defaultIcon: "play.square.fill"),
        "paramount": StreamingSource(id: "paramount", name: "Paramount+", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Paramount_Plus.svg/1024px-Paramount_Plus.svg.png", category: "Entertainment", defaultIcon: "play.circle"),
        "crunchyroll": StreamingSource(id: "crunchyroll", name: "Crunchyroll", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Crunchyroll_logo.svg/1024px-Crunchyroll_logo.svg.png", category: "Entertainment", defaultIcon: "play.tv"),
        "twitch": StreamingSource(id: "twitch", name: "Twitch", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Twitch_logo.svg/1024px-Twitch_logo.svg.png", category: "Entertainment", defaultIcon: "video.fill"),

        // AI Tools
        "chatgpt": StreamingSource(id: "chatgpt", name: "ChatGPT", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/ChatGPT_logo.svg/1024px-ChatGPT_logo.svg.png", category: "Productivity", defaultIcon: "cpu"),
        "claude": StreamingSource(id: "claude", name: "Claude AI", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Anthropic_logo.svg/1024px-Anthropic_logo.svg.png", category: "Productivity", defaultIcon: "message.and.waveform.fill"),
        "midjourney": StreamingSource(id: "midjourney", name: "Midjourney", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Midjourney_Emblem.svg/1024px-Midjourney_Emblem.svg.png", category: "Other", defaultIcon: "paintpalette.fill"),
        "perplexity": StreamingSource(id: "perplexity", name: "Perplexity", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Perplexity_AI_logo.svg/1024px-Perplexity_AI_logo.svg.png", category: "Productivity", defaultIcon: "magnifyingglass"),
        "gemini": StreamingSource(id: "gemini", name: "Google Gemini", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Google_Gemini_logo.svg/1024px-Google_Gemini_logo.svg.png", category: "Productivity", defaultIcon: "sparkles"),

        // VPNs
        "nordvpn": StreamingSource(id: "nordvpn", name: "NordVPN", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/NordVPN_logo.svg/1024px-NordVPN_logo.svg.png", category: "Utilities", defaultIcon: "lock.shield.fill"),
        "expressvpn": StreamingSource(id: "expressvpn", name: "ExpressVPN", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/ExpressVPN_logo.svg/1024px-ExpressVPN_logo.svg.png", category: "Utilities", defaultIcon: "shield.lefthalf.filled"),
        "surfshark": StreamingSource(id: "surfshark", name: "Surfshark", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Surfshark_logo.svg/1024px-Surfshark_logo.svg.png", category: "Utilities", defaultIcon: "waveform.path.ecg"),
        "proton": StreamingSource(id: "proton", name: "Proton", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Proton_Logo.svg/1024px-Proton_Logo.svg.png", category: "Utilities", defaultIcon: "lock.fill"),

        // Software & Productivity
        "microsoft365": StreamingSource(id: "microsoft365", name: "Microsoft 365", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Microsoft_Office_logo_%282012-2019%29.svg/1024px-Microsoft_Office_logo_%282012-2019%29.svg.png", category: "Productivity", defaultIcon: "doc.plaintext.fill"),
        "adobe": StreamingSource(id: "adobe", name: "Adobe Creative Cloud", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Adobe_Creative_Cloud_logo.svg/1024px-Adobe_Creative_Cloud_logo.svg.png", category: "Productivity", defaultIcon: "camera.macro"),
        "notion": StreamingSource(id: "notion", name: "Notion", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Notion_app_logo.svg/1024px-Notion_app_logo.svg.png", category: "Productivity", defaultIcon: "note.text"),
        "canva": StreamingSource(id: "canva", name: "Canva", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Canva_icon_2021.svg/1024px-Canva_icon_2021.svg.png", category: "Productivity", defaultIcon: "photo.stack.fill"),
        "dropbox": StreamingSource(id: "dropbox", name: "Dropbox", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Dropbox_Icon.svg/1024px-Dropbox_Icon.svg.png", category: "Utilities", defaultIcon: "archivebox.fill"),
        "slack": StreamingSource(id: "slack", name: "Slack", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Slack_icon_2019.svg/1024px-Slack_icon_2019.svg.png", category: "Productivity", defaultIcon: "bubble.left.and.bubble.right.fill"),
        "zoom": StreamingSource(id: "zoom", name: "Zoom", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Zoom_Communications_Logo.svg/1024px-Zoom_Communications_Logo.svg.png", category: "Productivity", defaultIcon: "video.circle.fill"),
        "apple_one": StreamingSource(id: "apple_one", name: "Apple One", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1024px-Apple_logo_black.svg.png", category: "Productivity", defaultIcon: "apple.logo"),

        // Gaming
        "playstation": StreamingSource(id: "playstation", name: "PS Plus", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Playstation_logo_colour.svg/1024px-Playstation_logo_colour.svg.png", category: "Entertainment", defaultIcon: "gamecontroller.fill"),
        "xbox": StreamingSource(id: "xbox", name: "Xbox Game Pass", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Xbox_one_logo.svg/1024px-Xbox_one_logo.svg.png", category: "Entertainment", defaultIcon: "gamecontroller"),
        "nintendo": StreamingSource(id: "nintendo", name: "Nintendo Switch Online", logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Nintendo_switch_logo.svg/1024px-Nintendo_switch_logo.svg.png", category: "Entertainment", defaultIcon: "gamecontroller.fill")
    ]
    
    private let aliases: [String: String] = [
        "yt": "youtube",
        "nf": "netflix",
        "sp": "spotify",
        "gpt": "chatgpt",
        "ps": "playstation",
        "ms": "microsoft365",
        "office": "microsoft365",
        "fb": "facebook",
        "ig": "instagram"
    ]
    
    func lookupSources(for serviceName: String) async -> [StreamingSource] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        let normalizedName = serviceName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedName.isEmpty { return [] }

        let query = aliases[normalizedName] ?? normalizedName
        var matchingSources: [StreamingSource] = []
        
        // 1. Check for exact alias/id matches
        if let exact = sources[query] {
            matchingSources.append(exact)
        }
        
        // 2. Check for partial matches in ID or Name
        for (id, source) in sources {
            if id == query { continue } // Already added
            
            if id.contains(query) || source.name.lowercased().contains(query) {
                if !matchingSources.contains(where: { $0.id == id }) {
                    matchingSources.append(source)
                }
            }
        }
        
        // 3. Limit results for better UI performance
        return Array(matchingSources.prefix(8))
    }
    
    func getSource(for id: String) -> StreamingSource? {
        return sources[id]
    }
}
