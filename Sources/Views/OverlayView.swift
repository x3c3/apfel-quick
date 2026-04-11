import SwiftUI

struct OverlayView: View {
    @Bindable var viewModel: QuickViewModel
    @FocusState private var inputFocused: Bool
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Input row
            HStack(spacing: 8) {
                TextField("Ask anything…", text: $viewModel.input)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .focused($inputFocused)
                    .onSubmit { Task { await viewModel.submit() } }
                    .disabled(viewModel.isStreaming)

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 15))
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // Divider + result (only shown when there's output or streaming)
            if !viewModel.output.isEmpty || viewModel.isStreaming {
                Divider()
                ScrollView {
                    Text(viewModel.output + (viewModel.isStreaming ? "▋" : ""))
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(20)
                }
                .frame(maxHeight: 380)
            }

            // Error message
            if let error = viewModel.errorMessage {
                Divider()
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear { inputFocused = true }
        .onKeyPress(.escape) {
            if viewModel.isStreaming {
                viewModel.cancel()
            }
            // AppDelegate handles actual window dismissal
            NotificationCenter.default.post(name: .dismissOverlay, object: nil)
            return .handled
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
}

extension Notification.Name {
    static let dismissOverlay = Notification.Name("ApfelQuick.dismissOverlay")
}
