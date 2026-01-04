//
//  PlainTextChordRenderer.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

class PlainTextChordRenderer: ChordRenderer {
    func renderShortName(chord: Chord) -> String {
        var shortName = "";
        shortName += chord.rootNote.rawValue
        
        switch chord.rootNoteAlteration {
        case .natural:
            shortName += ""
        case .flat:
            shortName += "b"
        case .sharp:
            shortName += "#"
        }
        
        switch chord.chordType {
        case .major:
            shortName += ""
        case .minor:
            shortName += "m"
        case .seventh:
            if let quality = chord.seventhType {
                switch quality {
                case .major:
                    shortName += "maj7"
                case .minor:
                    shortName += "m7"
                case .dominant:
                    shortName += "7"
                case .halfDimished:
                    shortName += "m7(b5)"
                }
                
            }
        case .augmented:
            shortName += "aug"
        case .diminished:
            shortName += "dim"
        case .power:
            shortName += "5"
            
        }
        
        if let addedType = chord.addedType {
            var alteration = ""
            
            switch chord.addedAlteration {
            case .flat:
                alteration = "b"
            case .sharp:
                alteration = "#"
            default:
                break
            }
            
            switch addedType {
            case .ninth:
                shortName += "\(alteration)9"
            case .second:
                shortName += "\(alteration)9"
            }
        }
        
        if let extendedType = chord.extendedType {
            switch extendedType {
            case .eleventh:
                shortName += "(add11)"
            case .ninth:
                shortName += "(add9)"
            case .thirteenth:
                shortName += "(add13)"
            }
        }
        
        if let suspendedType = chord.suspendedType {
            switch suspendedType {
            case .fourth:
                shortName += "sus4"
            case .second:
                shortName += "sus2"
            }
        }
        
        if let bassNote = chord.bassNote {
            shortName += "/\(bassNote.rawValue)"
            if let bassNoteAlteration = chord.bassNoteAlteration {
                switch bassNoteAlteration {
                case .flat:
                    shortName += "b"
                case .sharp:
                    shortName += "#"
                default:
                    break
                }
            }
        }


        return shortName
    }
    
    func render(chord: Chord) -> String {
        var name = "";
        name += chord.rootNote.rawValue

        switch chord.rootNoteAlteration {
        case .natural:
            name += ""
        case .flat:
            name += " flat"
        case .sharp:
            name += " sharp"
        }

        switch chord.chordType {
        case .major:
            name += " major"
        case .minor:
            name += " minor"
        case .seventh:
            if let quality = chord.seventhType {
                switch quality {
                case .major:
                    name += " major 7th"
                case .minor:
                    name += " minor 7th"
                case .dominant:
                    name += " dominant 7th"
                case .halfDimished:
                    name += " half dimished 7th"
                }
                
            }
        case .augmented:
            name += " augmented"
        case .diminished:
            name += " diminished"
        case .power:
            name += " power chord"
        }
        
        if let addedType = chord.addedType {
            var alteration = ""
            
            switch chord.addedAlteration {
            case .flat:
                alteration = " flat "
            case .sharp:
                alteration = " sharp "
            default:
                break
            }
            
            switch addedType {
            case .ninth:
                name += "\(alteration)9"
            case .second:
                name += "\(alteration)9"
            }
        }
        
        if let extendedType = chord.extendedType {
            switch extendedType {
            case .eleventh:
                name += " eleventh"
            case .ninth:
                name += " ninth"
            case .thirteenth:
                name += " thirteenth"
            }
        }
        
        if let suspendedType = chord.suspendedType {
            switch suspendedType {
            case .fourth:
                name += " suspended fourth"
            case .second:
                name += " suspended second"
            }
        }
        
        if let bassNote = chord.bassNote {
            var alteration = " "
            if let bassNoteAlteration = chord.bassNoteAlteration {
                switch bassNoteAlteration {
                case .flat:
                    alteration = "b "
                case .sharp:
                    alteration = "# "
                default:
                    break
                }
            }

            name += " with \(bassNote.rawValue)\(alteration)bass"
        }


        return name
    }
}
