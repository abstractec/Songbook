//
//  PlainTextChordRenderer.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

class PlainTextChordRenderer: ChordRenderer {
    func renderShortName(chord: Chord) -> String {
        var shortName = "";
        if let root = chord.root {
            shortName += root
        }
        
        if let type = chord.chordType {
            switch type {
                case .major:
                shortName += ""
                case .minor:
                shortName += "m"
                case .seventh:
                shortName += "7"
            default:
                break
            }
        }
        
        if chord.altered, let alteration = chord.alteration {
            if let alterationType = chord.alterationType {
                switch alterationType {
                case .flat:
                    shortName += "b"
                case .sharp:
                    shortName += "#"
                case .natural:
                    break
                }
            }
            shortName += "\(alteration)"
        }
        
        if chord.suspended, let suspendedBy = chord.suspendedBy {
            shortName += "sus\(suspendedBy)"
        }
        
        if let bassNote = chord.bassNote {
            shortName += "/\(bassNote)"
        }
        
        return shortName
    }
    
    func render(chord: Chord) -> String {
        var name = "";
        if let root = chord.root {
            name += root
        }
        
        if let type = chord.chordType {
            switch type {
                case .major:
                name += " major"
                case .minor:
                name += " minor"
                case .seventh:
                name += " dominant 7th"
            default:
                break
            }
        }

        if chord.altered, let alteration = chord.alteration {
            if let alterationType = chord.alterationType {
                name += " with"
                switch alterationType {
                case .flat:
                    name += " flat"
                case .sharp:
                    name += " sharp"
                case .natural:
                    break
                }
            }

            name += " \(alteration)"
        }
        
        if chord.suspended, let suspendedBy = chord.suspendedBy {
            name += " suspended \(suspendedBy)"
        }

        if let bassNote = chord.bassNote {
            name += " with \(bassNote) bass"
        }

        return name
    }
}
