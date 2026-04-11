import SwiftUI

struct WelcomeOverlayView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                    Image(systemName: "bubble.left.and.text.bubble.right")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 64, height: 64)

                Text("Welcome to apfel-quick")
                    .font(.system(size: 22, weight: .bold))

                Text("Press Ctrl+Space anywhere to ask anything. The answer streams in and copies to your clipboard automatically. Everything runs on your Mac — no internet needed.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 8) {
                    featureBullet("airplane", "Works completely offline")
                    featureBullet("lock.shield", "Nothing leaves your Mac")
                    featureBullet("bolt", "Instant — no sign-up, no account")
                }
                .padding(.top, 4)
            }
            .padding(32)

            Divider()

            Button("Get Started") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(20)
        }
        .frame(width: 440)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func featureBullet(_ systemImage: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }
}
