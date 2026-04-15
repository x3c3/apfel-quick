// LightModeEnforcementTests — regression test for issue #1
//
// User-facing overlays must lock their color scheme to .light. Without this,
// dark-mode users see `.foregroundStyle(.secondary)` (which resolves to a
// light colour in dark mode) rendered on top of an explicit `.background(.white)`,
// producing invisible text on the Welcome, Settings, and Overlay surfaces.
//
// https://github.com/Arthur-Ficial/apfel-quick/issues/1

import Foundation
import Testing

@Suite("LightModeEnforcement")
struct LightModeEnforcementTests {
    private static let viewsDir: URL = {
        var url = URL(fileURLWithPath: #filePath)
        url.deleteLastPathComponent() // Tests/
        url.deleteLastPathComponent() // repo root
        return url.appendingPathComponent("Sources/Views", isDirectory: true)
    }()

    private static let viewsRequiringLightMode = [
        "WelcomeOverlayView.swift",
        "SettingsView.swift",
        "OverlayView.swift",
    ]

    @Test("Every user-facing view declares .preferredColorScheme(.light)",
          arguments: viewsRequiringLightMode)
    func viewLocksLightMode(name: String) throws {
        let url = Self.viewsDir.appendingPathComponent(name)
        let source = try String(contentsOf: url, encoding: .utf8)
        #expect(
            source.contains(".preferredColorScheme(.light)"),
            "\(name) must declare .preferredColorScheme(.light) so dark-mode users don't see invisible text on the explicit white background"
        )
    }
}
