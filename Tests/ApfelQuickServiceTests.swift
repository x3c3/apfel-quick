import Testing
import Foundation
@testable import apfel_quick

// TDD (RED phase) — ApfelQuickService does not yet exist.
// Tests define the intended API for the buildRequest(prompt:) helper.
//
// Intended shape:
//   struct ApfelQuickService: QuickService {
//       let baseURL: URL       // e.g. http://127.0.0.1:11450
//       let modelName: String
//
//       func buildRequest(prompt: String) throws -> URLRequest
//       func send(prompt: String) -> AsyncThrowingStream<StreamDelta, Error>
//       func healthCheck() async throws -> Bool
//   }

@Suite("ApfelQuickService")
struct ApfelQuickServiceTests {

    private func makeService(port: Int = 11450) -> ApfelQuickService {
        let url = URL(string: "http://127.0.0.1:\(port)")!
        return ApfelQuickService(baseURL: url, modelName: "test-model")
    }

    // MARK: - 1. HTTP method is POST

    @Test func testBuildRequestMethod() throws {
        let service = makeService()
        let request = try service.buildRequest(prompt: "hello")
        #expect(request.httpMethod == "POST")
    }

    // MARK: - 2. URL ends with /v1/chat/completions

    @Test func testBuildRequestURL() throws {
        let service = makeService()
        let request = try service.buildRequest(prompt: "hello")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.hasSuffix("/v1/chat/completions"))
    }

    // MARK: - 3. Content-Type header is application/json

    @Test func testBuildRequestContentType() throws {
        let service = makeService()
        let request = try service.buildRequest(prompt: "hello")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    // MARK: - 4. Body JSON has messages array with user role and prompt content

    @Test func testBuildRequestBodyContainsPrompt() throws {
        let service = makeService()
        let request = try service.buildRequest(prompt: "my test prompt")
        let body = try #require(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        let messages = try #require(json?["messages"] as? [[String: Any]])
        #expect(!messages.isEmpty)
        let hasPrompt = messages.contains { msg in
            (msg["content"] as? String) == "my test prompt"
        }
        #expect(hasPrompt)
    }

    // MARK: - 5. Body JSON has "stream": true

    @Test func testBuildRequestBodyHasStream() throws {
        let service = makeService()
        let request = try service.buildRequest(prompt: "hello")
        let body = try #require(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        let stream = try #require(json?["stream"] as? Bool)
        #expect(stream == true)
    }

    // MARK: - 6. Body JSON has "model" key

    @Test func testBuildRequestBodyHasModel() throws {
        let service = makeService()
        let request = try service.buildRequest(prompt: "hello")
        let body = try #require(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        #expect(json?["model"] != nil)
    }

    // MARK: - 7. messages[0].role == "user"

    @Test func testBuildRequestBodyUserRole() throws {
        let service = makeService()
        let request = try service.buildRequest(prompt: "hello")
        let body = try #require(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        let messages = try #require(json?["messages"] as? [[String: Any]])
        let firstMessage = try #require(messages.first)
        #expect((firstMessage["role"] as? String) == "user")
    }

    // MARK: - 8. messages[0].content == the prompt string passed in

    @Test func testBuildRequestBodyUserContent() throws {
        let service = makeService()
        let prompt = "what is the meaning of life?"
        let request = try service.buildRequest(prompt: prompt)
        let body = try #require(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        let messages = try #require(json?["messages"] as? [[String: Any]])
        let firstMessage = try #require(messages.first)
        #expect((firstMessage["content"] as? String) == prompt)
    }

    // MARK: - 9. Empty string prompt builds a valid request (no throw)

    @Test func testBuildRequestEmptyPromptStillBuilds() throws {
        let service = makeService()
        // Should not throw — empty string is valid input
        let request = try service.buildRequest(prompt: "")
        #expect(request.httpMethod == "POST")
    }

    // MARK: - 10. Initialised with port 11451 → URL contains "11451"

    @Test func testBuildRequestDifferentPort() throws {
        let service = makeService(port: 11451)
        let request = try service.buildRequest(prompt: "hello")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("11451"))
    }
}
