import Foundation

/// Detects whether a user's input is a pure math expression
/// that can be evaluated locally without the AI.
enum MathExpressionDetector {

    private static let functions: Set<String> = [
        "sqrt", "sin", "cos", "tan", "log", "ln",
        "abs", "floor", "ceil", "round"
    ]

    private static let constants: Set<String> = ["pi", "e"]

    static func isMathExpression(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        let tokens = tokenize(trimmed)
        guard !tokens.isEmpty else { return false }

        var hasOperatorOrFunction = false

        for token in tokens {
            switch token {
            case .number, .leftParen, .rightParen, .constant:
                break
            case .operator_:
                hasOperatorOrFunction = true
            case .function:
                hasOperatorOrFunction = true
            case .unknown:
                return false
            }
        }

        return hasOperatorOrFunction
    }

    // MARK: — Tokenisation

    private enum Token {
        case number
        case `operator_`
        case leftParen
        case rightParen
        case function
        case constant
        case unknown
    }

    private static func tokenize(_ input: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(input)
        var i = 0

        while i < chars.count {
            let ch = chars[i]

            // Whitespace — skip
            if ch.isWhitespace { i += 1; continue }

            // Number (digit or leading decimal point)
            if ch.isNumber || ch == "." {
                while i < chars.count && (chars[i].isNumber || chars[i] == ".") { i += 1 }
                tokens.append(.number)
                continue
            }

            // Comma — decimal separator only when between digits
            if ch == "," {
                let prevDigit = i > 0 && chars[i - 1].isNumber
                let nextDigit = i + 1 < chars.count && chars[i + 1].isNumber
                if prevDigit && nextDigit {
                    i += 1
                    continue   // absorbed into preceding number token
                } else {
                    tokens.append(.unknown)
                    i += 1
                    continue
                }
            }

            // Operators
            if "+-*/^%".contains(ch) {
                tokens.append(.operator_)
                i += 1
                continue
            }

            // Parentheses
            if ch == "(" { tokens.append(.leftParen); i += 1; continue }
            if ch == ")" { tokens.append(.rightParen); i += 1; continue }

            // Identifier → function, constant, or unknown word
            if ch.isLetter {
                var ident = ""
                while i < chars.count && chars[i].isLetter { ident.append(chars[i]); i += 1 }
                if functions.contains(ident) {
                    tokens.append(.function)
                } else if constants.contains(ident) {
                    tokens.append(.constant)
                } else {
                    tokens.append(.unknown)
                }
                continue
            }

            // Anything else (e.g. ':', '@', '?', letters not handled above)
            tokens.append(.unknown)
            i += 1
        }

        return tokens
    }
}
