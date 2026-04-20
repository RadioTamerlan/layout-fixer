import Foundation

enum Converter {

    // QWERTY → ЙЦУКЕН
    static let enToRu: [Character: Character] = [
        "q": "й", "w": "ц", "e": "у", "r": "к", "t": "е", "y": "н", "u": "г",
        "i": "ш", "o": "щ", "p": "з", "[": "х", "]": "ъ",
        "a": "ф", "s": "ы", "d": "в", "f": "а", "g": "п", "h": "р", "j": "о",
        "k": "л", "l": "д", ";": "ж", "'": "э",
        "z": "я", "x": "ч", "c": "с", "v": "м", "b": "и", "n": "т", "m": "ь",
        ",": "б", ".": "ю",

        "Q": "Й", "W": "Ц", "E": "У", "R": "К", "T": "Е", "Y": "Н", "U": "Г",
        "I": "Ш", "O": "Щ", "P": "З", "{": "Х", "}": "Ъ",
        "A": "Ф", "S": "Ы", "D": "В", "F": "А", "G": "П", "H": "Р", "J": "О",
        "K": "Л", "L": "Д", ":": "Ж", "\"": "Э",
        "Z": "Я", "X": "Ч", "C": "С", "V": "М", "B": "И", "N": "Т", "M": "Ь",
        "<": "Б", ">": "Ю"
    ]

    // ЙЦУКЕН → QWERTY (auto-generated reverse)
    static let ruToEn: [Character: Character] = Dictionary(
        uniqueKeysWithValues: enToRu.map { ($0.value, $0.key) }
    )

    // Detects dominant script and converts accordingly.
    // Latin-majority  → EN→RU (Russian typed with English layout active)
    // Cyrillic-majority → RU→EN (English typed with Russian layout active)
    static func autoConvert(_ text: String) -> String {
        var latinCount = 0
        var cyrillicCount = 0

        for scalar in text.unicodeScalars {
            if scalar.value >= 0x0041 && scalar.value <= 0x007A { // A-Z a-z
                latinCount += 1
            } else if scalar.value >= 0x0400 && scalar.value <= 0x04FF { // Cyrillic block
                cyrillicCount += 1
            }
        }

        if latinCount == 0 && cyrillicCount == 0 { return text }

        if latinCount >= cyrillicCount {
            return apply(enToRu, to: text)
        } else {
            return apply(ruToEn, to: text)
        }
    }

    static func apply(_ mapping: [Character: Character], to text: String) -> String {
        String(text.map { mapping[$0] ?? $0 })
    }
}
