import Foundation

struct UltimateGuitarImporter {
    enum ImportError: LocalizedError {
        case invalidURL
        case unsupportedHost
        case downloadFailed
        case parseFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Please enter a valid URL."
            case .unsupportedHost:
                return "Only ultimate-guitar.com URLs are supported right now."
            case .downloadFailed:
                return "Could not download tab content from Ultimate Guitar."
            case .parseFailed:
                return "Could not parse tab content from this page."
            }
        }
    }
    
    static func importSong(from urlString: String) async throws -> Song {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw ImportError.invalidURL
        }
        
        guard let host = url.host()?.lowercased(), host.contains("ultimate-guitar.com") else {
            throw ImportError.unsupportedHost
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ImportError.downloadFailed
        }
        
        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw ImportError.downloadFailed
        }
        
        guard let song = parseSong(fromHTML: html, sourceURL: url) else {
            throw ImportError.parseFailed
        }
        
        return song
    }
    
    private static func parseSong(fromHTML html: String, sourceURL: URL) -> Song? {
        let title = parseTitle(fromHTML: html) ?? parseSongTitle(from: sourceURL) ?? "Imported Song"
        let artist = parseArtist(from: sourceURL)
        let plainText = extractTabContent(fromHTML: html) ?? htmlToText(html)
        let lines = plainText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var sections: [Section] = []
        var currentSectionName = "Song"
        var currentPhrases: [Phrase] = []
        var phrasePosition = 0
        var sectionPosition = 0
        
        var idx = 0
        while idx < lines.count {
            let line = lines[idx]
            
            if let sectionName = parseSectionHeader(line) {
                if !currentPhrases.isEmpty {
                    let section = Section(id: UUID(), name: currentSectionName, phrases: currentPhrases, position: sectionPosition)
                    sections.append(section)
                    currentPhrases = []
                    sectionPosition += 1
                    phrasePosition = 0
                }
                currentSectionName = sectionName
                idx += 1
                continue
            }
            
            if let chordSteps = parseChordLine(line), !chordSteps.isEmpty {
                var lyricText = ""
                if idx + 1 < lines.count {
                    let nextLine = lines[idx + 1]
                    if parseSectionHeader(nextLine) == nil && parseChordLine(nextLine) == nil {
                        lyricText = nextLine
                        idx += 1
                    }
                }
                
                let sequence = ChordSequence(
                    id: UUID(),
                    sequence: chordSteps.enumerated().map { offset, item in
                        ChordSequenceStep(id: UUID(), chord: item.chord, step: item.step > 0 ? item.step : offset)
                    }
                )
                
                let phrase = Phrase(id: UUID(), chordSequence: sequence, position: phrasePosition, repeats: 1)
                phrase.lyric = Lyric(id: UUID(), text: lyricText)
                currentPhrases.append(phrase)
                phrasePosition += 1
            }
            
            idx += 1
        }
        
        if !currentPhrases.isEmpty {
            let section = Section(id: UUID(), name: currentSectionName, phrases: currentPhrases, position: sectionPosition)
            sections.append(section)
        }
        
        guard !sections.isEmpty else { return nil }
        return Song(id: UUID(), title: title, sections: sections, artist: artist)
    }
    
    private static func parseSectionHeader(_ line: String) -> String? {
        guard line.hasPrefix("[") && line.hasSuffix("]") else { return nil }
        let inner = line.dropFirst().dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        return inner.isEmpty ? nil : inner
    }
    
    private static func parseChordLine(_ line: String) -> [(chord: Chord, step: Int)]? {
        let cleaned = line.replacingOccurrences(of: "|", with: " ")
        let rawTokens = cleaned.split(whereSeparator: \.isWhitespace).map(String.init)
        guard !rawTokens.isEmpty else { return nil }
        
        var parsed: [(Chord, Int)] = []
        var searchStart = cleaned.startIndex
        
        for rawToken in rawTokens {
            let token = rawToken.trimmingCharacters(in: CharacterSet(charactersIn: "[]{}\"'.,;:!?"))
            guard !token.isEmpty else { continue }
            
            if let chord = ChordTokenParser.parse(token),
               let range = cleaned.range(of: rawToken, range: searchStart..<cleaned.endIndex) {
                let step = cleaned.distance(from: cleaned.startIndex, to: range.lowerBound)
                parsed.append((chord, step))
                searchStart = range.upperBound
            }
        }
        
        guard !parsed.isEmpty else { return nil }
        
        // Heuristic: chord lines usually have mostly chord tokens.
        if parsed.count == 1 && rawTokens.count > 3 {
            return nil
        }
        
        return parsed
    }
    
    private static func parseTitle(fromHTML html: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: #"<title>(.*?)</title>"#, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return nil
        }
        
        let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
        guard let match = regex.firstMatch(in: html, range: nsRange),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        
        var title = html[range].trimmingCharacters(in: .whitespacesAndNewlines)
        if let splitIndex = title.range(of: "CHORDS", options: .caseInsensitive)?.lowerBound {
            title = String(title[..<splitIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let byRange = title.range(of: " by ", options: .caseInsensitive) {
            title = String(title[..<byRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return title.isEmpty ? nil : title
    }
    
    private static func parseSongTitle(from url: URL) -> String? {
        let comps = url.pathComponents
        guard let tabIndex = comps.firstIndex(of: "tab"), tabIndex + 2 < comps.count else { return nil }
        let slug = comps[tabIndex + 2]
        return prettyName(fromSlug: slug)
    }
    
    private static func parseArtist(from url: URL) -> String? {
        let comps = url.pathComponents
        guard let tabIndex = comps.firstIndex(of: "tab"), tabIndex + 1 < comps.count else { return nil }
        return prettyName(fromSlug: comps[tabIndex + 1])
    }
    
    private static func prettyName(fromSlug slug: String) -> String {
        slug.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    private static func htmlToText(_ html: String) -> String {
        var text = html
        text = text.replacingOccurrences(of: "<script\\b[^>]*>[\\s\\S]*?</script>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style\\b[^>]*>[\\s\\S]*?</style>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</p>", with: "\n", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "</div>", with: "\n", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        text = text
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
        
        return text
    }
    
    private static func extractTabContent(fromHTML html: String) -> String? {
        let patterns = [
            #""wiki_tab"\s*:\s*\{[\s\S]*?"content"\s*:\s*"((?:\\.|[^"\\])*)""#,
            #""content"\s*:\s*"((?:\\.|[^"\\])*)"\s*,\s*"revision_id""#
        ]
        
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
            guard let match = regex.firstMatch(in: html, range: nsRange),
                  let range = Range(match.range(at: 1), in: html) else { continue }
            
            let escaped = String(html[range])
            if let decoded = decodeJSONStringLiteral(escaped), decoded.contains("[") {
                return decoded
            }
        }
        
        return nil
    }
    
    private static func decodeJSONStringLiteral(_ escaped: String) -> String? {
        let wrapped = "\"\(escaped)\""
        guard let data = wrapped.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(String.self, from: data)
    }
}

