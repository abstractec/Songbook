import Foundation

/// Parses a chord symbol (e.g. "Em7", "A7sus4", "D/F#") into the app's `Chord` model.
///
/// Intended to be used by importers (JSON / website / plaintext) before persisting chords.
struct ChordTokenParser {
    static func parse(_ rawToken: String, id: UUID = UUID()) -> Chord? {
        let token = rawToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else { return nil }
        
        // Split optional slash bass (use last slash as separator).
        let (mainToken, bassToken): (String, String?) = {
            guard let slashIndex = token.lastIndex(of: "/") else { return (token, nil) }
            let left = String(token[..<slashIndex])
            let right = String(token[token.index(after: slashIndex)...])
            return (left, right.isEmpty ? nil : right)
        }()
        
        guard let (rootNote, rootAlteration, suffix) = parseRootAndSuffix(mainToken) else {
            return nil
        }
        
        guard hasSupportedAlphabeticComponents(in: suffix) else {
            return nil
        }
        
        var chordType: ChordType = .major
        var seventhType: SeventhType? = nil
        var extendedType: ExtendedType? = nil
        var suspendedType: SuspendedType? = nil
        var addedType: AddedType? = nil
        var addedAlteration: Alteration = .natural
        
        // Preserve original case to disambiguate "M7" vs "m7".
        let suffixOriginal = suffix
        var suffixLower = suffixOriginal.lowercased()
        
        // Normalize a few common notations.
        suffixLower = suffixLower.replacingOccurrences(of: "min", with: "m")
        suffixLower = suffixLower.replacingOccurrences(of: "major", with: "maj")
        
        // 1) Seventh detection (priority order)
        if suffixLower.contains("m7b5") || suffixOriginal.contains("ø7") {
            chordType = .seventh
            seventhType = .halfDimished
        } else if suffixLower.contains("maj7") || suffixOriginal.contains("M7") {
            chordType = .seventh
            seventhType = .major
        } else if suffixLower.contains("m7") {
            chordType = .seventh
            seventhType = .minor
        } else if suffixLower.contains("7") {
            chordType = .seventh
            seventhType = .dominant
        }
        
        // 2) Extensions (do not force seventh by default)
        // Prefer longer matches first.
        if suffixLower.contains("13") {
            extendedType = .thirteenth
        } else if suffixLower.contains("11") {
            extendedType = .eleventh
        } else if suffixLower.contains("9") {
            extendedType = .ninth
        }
        
        // 3) Suspensions
        if suffixLower.contains("sus2") {
            suspendedType = .second
        } else if suffixLower.contains("sus4") || suffixLower.contains("sus") {
            suspendedType = .fourth
        }
        
        // 4) Adds (prefer #/b forms first)
        if suffixLower.contains("add#9") {
            addedType = .ninth
            addedAlteration = .sharp
        } else if suffixLower.contains("addb9") {
            addedType = .ninth
            addedAlteration = .flat
        } else if suffixLower.contains("add9") {
            addedType = .ninth
        } else if suffixLower.contains("add2") {
            addedType = .second
        }
        
        // 5) Triad quality (only when not a seventh chord)
        if seventhType == nil {
            if suffixLower.contains("dim") {
                chordType = .diminished
            } else if suffixLower.contains("aug") || suffixLower.contains("+") {
                chordType = .augmented
            } else if suffixLower.contains("5") {
                chordType = .power
            } else if suffixLower.hasPrefix("m") || suffixLower.contains("m") {
                // Conservative: treat any remaining "m" as minor.
                chordType = .minor
            }
        }
        
        // Slash bass (optional)
        var bassNote: Note? = nil
        var bassAlteration: Alteration? = nil
        if let bassToken, let (bNote, bAlt) = parseNote(bassToken) {
            bassNote = bNote
            bassAlteration = bAlt
        }
        
        return Chord(
            id: id,
            rootNote: rootNote,
            rootNoteAlteration: rootAlteration,
            chordType: chordType,
            seventhType: seventhType,
            extendedType: extendedType,
            suspendedType: suspendedType,
            addedType: addedType,
            addedAlteration: addedAlteration,
            bassNote: bassNote,
            bassNoteAlteration: bassAlteration
        )
    }
    
    private static func hasSupportedAlphabeticComponents(in suffix: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: #"[A-Za-zø]+"#) else {
            return false
        }
        
        let nsRange = NSRange(suffix.startIndex..<suffix.endIndex, in: suffix)
        let matches = regex.matches(in: suffix, range: nsRange)
        let allowed = Set(["m", "maj", "min", "dim", "aug", "sus", "add", "o", "ø"])
        
        for match in matches {
            guard let range = Range(match.range, in: suffix) else { continue }
            let run = String(suffix[range]).lowercased()
            if !allowed.contains(run) {
                return false
            }
        }
        
        return true
    }
    
    private static func parseRootAndSuffix(_ token: String) -> (Note, Alteration, String)? {
        guard let first = token.first else { return nil }
        let rootLetter = String(first)
        guard let rootNote = Note(rawValue: rootLetter) else { return nil }
        
        var alteration: Alteration = .natural
        var idx = token.index(after: token.startIndex)
        
        if idx < token.endIndex {
            let c = token[idx]
            if c == "#" {
                alteration = .sharp
                idx = token.index(after: idx)
            } else if c == "b" {
                alteration = .flat
                idx = token.index(after: idx)
            }
        }
        
        let suffix = String(token[idx...])
        return (rootNote, alteration, suffix)
    }
    
    private static func parseNote(_ token: String) -> (Note, Alteration)? {
        let t = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        
        guard let first = t.first, let note = Note(rawValue: String(first)) else { return nil }
        
        var alteration: Alteration = .natural
        if t.count >= 2 {
            let second = t[t.index(after: t.startIndex)]
            if second == "#" {
                alteration = .sharp
            } else if second == "b" {
                alteration = .flat
            }
        }
        
        return (note, alteration)
    }
}

