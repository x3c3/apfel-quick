import Testing
import Foundation
@testable import apfel_quick

// Tests for SSEParser — static enum that parses Server-Sent Events lines.
// SSEParser does not yet exist (RED phase). Tests define the intended API.
//
// API:
//   SSEParser.parse(line: String) -> StreamDelta?
//   SSEParser.parseError(line: String) -> SSEError?
//
// SSEError: struct with `message: String`

@Suite("SSEParser")
struct SSEParserTests {

    // MARK: - 1. Text content parsed from data line

    @Test func testParseDataLineWithText() {
        let line = #"data: {"choices":[{"delta":{"content":"hello"},"finish_reason":null}]}"#
        let delta = SSEParser.parse(line: line)
        #expect(delta != nil)
        #expect(delta?.text == "hello")
        #expect(delta?.finishReason == nil)
    }

    // MARK: - 2. [DONE] sentinel returns nil

    @Test func testParseDataDone() {
        let line = "data: [DONE]"
        let delta = SSEParser.parse(line: line)
        #expect(delta == nil)
    }

    // MARK: - 3. Empty line returns nil

    @Test func testParseEmptyLine() {
        let delta = SSEParser.parse(line: "")
        #expect(delta == nil)
    }

    // MARK: - 4. Comment / keep-alive line returns nil

    @Test func testParseCommentLine() {
        let delta = SSEParser.parse(line: ": keep-alive")
        #expect(delta == nil)
    }

    // MARK: - 5. finish_reason parsed correctly

    @Test func testParseFinishReason() {
        let line = #"data: {"choices":[{"delta":{},"finish_reason":"stop"}]}"#
        let delta = SSEParser.parse(line: line)
        #expect(delta != nil)
        #expect(delta?.text == nil)
        #expect(delta?.finishReason == "stop")
    }

    // MARK: - 6. Both text content and finish_reason present

    @Test func testParseTextAndFinishReason() {
        let line = #"data: {"choices":[{"delta":{"content":"last token"},"finish_reason":"stop"}]}"#
        let delta = SSEParser.parse(line: line)
        #expect(delta != nil)
        #expect(delta?.text == "last token")
        #expect(delta?.finishReason == "stop")
    }

    // MARK: - 7. Invalid JSON returns nil

    @Test func testParseInvalidJSON() {
        let line = "data: not json at all {{"
        let delta = SSEParser.parse(line: line)
        #expect(delta == nil)
    }

    // MARK: - 8. Non-data line (event field) returns nil

    @Test func testParseNonDataLine() {
        let delta = SSEParser.parse(line: "event: message")
        #expect(delta == nil)
    }

    // MARK: - 9. Error object in SSE line parsed by parseError

    @Test func testParseErrorLine() {
        let line = #"data: {"error":{"message":"rate limited","type":"rate_limit"}}"#
        let error = SSEParser.parseError(line: line)
        #expect(error != nil)
        #expect(error?.message == "rate limited")
    }

    // MARK: - 10. null content produces StreamDelta with nil text

    @Test func testParseNullContent() {
        let line = #"data: {"choices":[{"delta":{"content":null},"finish_reason":null}]}"#
        let delta = SSEParser.parse(line: line)
        // null content should either return nil or a delta with nil text
        if let delta {
            #expect(delta.text == nil)
        }
        // returning nil for null content is also acceptable
    }

    // MARK: - Additional edge cases

    // 11. Whitespace-only line returns nil
    @Test func testParseWhitespaceOnlyLine() {
        let delta = SSEParser.parse(line: "   ")
        #expect(delta == nil)
    }

    // 12. data: prefix with extra whitespace after colon is handled
    @Test func testParseDataLineWithLeadingSpaceAfterColon() {
        // SSE spec allows "data: " (space after colon) — content includes everything after the single space
        let line = #"data:  {"choices":[{"delta":{"content":"hi"},"finish_reason":null}]}"#
        // Either parsed or nil — parser should not crash
        _ = SSEParser.parse(line: line)
    }

    // 13. Multiple choices — first choice delta is used
    @Test func testParseFirstChoiceDeltaUsed() {
        let line = #"data: {"choices":[{"delta":{"content":"first"},"finish_reason":null},{"delta":{"content":"second"},"finish_reason":null}]}"#
        let delta = SSEParser.parse(line: line)
        #expect(delta?.text == "first")
    }

    // 14. Empty choices array returns nil
    @Test func testParseEmptyChoicesArray() {
        let line = #"data: {"choices":[]}"#
        let delta = SSEParser.parse(line: line)
        #expect(delta == nil)
    }

    // 15. parseError on non-error line returns nil
    @Test func testParseErrorOnNonErrorLineReturnsNil() {
        let line = #"data: {"choices":[{"delta":{"content":"hello"},"finish_reason":null}]}"#
        let error = SSEParser.parseError(line: line)
        #expect(error == nil)
    }

    // 16. parseError on empty line returns nil
    @Test func testParseErrorOnEmptyLineReturnsNil() {
        let error = SSEParser.parseError(line: "")
        #expect(error == nil)
    }

    // 17. finish_reason "length" is also a valid finish reason
    @Test func testParseFinishReasonLength() {
        let line = #"data: {"choices":[{"delta":{},"finish_reason":"length"}]}"#
        let delta = SSEParser.parse(line: line)
        #expect(delta?.finishReason == "length")
    }
}
