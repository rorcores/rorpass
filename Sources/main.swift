import Cocoa
import SwiftUI

func generatePassword(length: Int, uppercase: Bool, lowercase: Bool, numbers: Bool, symbols: Bool) -> String {
    var charset = ""
    if uppercase { charset += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    if lowercase { charset += "abcdefghijklmnopqrstuvwxyz" }
    if numbers { charset += "0123456789" }
    if symbols { charset += "!@#$%^&*()-_=+[]{}|;:',.<>?/" }
    guard !charset.isEmpty else { return "" }
    let chars = Array(charset)
    return String((0..<length).map { _ in chars[Int.random(in: 0..<chars.count)] })
}

struct ContentView: View {
    @State private var length: Double = 22
    @State private var uppercase = true
    @State private var lowercase = true
    @State private var numbers = true
    @State private var symbols = true
    @State private var password = ""
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("rorpass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Text(password)
                    .font(.system(size: 12.5, weight: .medium, design: .monospaced))
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: copy) {
                    Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundColor(copied ? .green : .secondary)
                }
                .buttonStyle(.borderless)
                .help("Copy to clipboard")
            }
            .padding(8)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(6)

            HStack {
                Text("Length")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 42, alignment: .leading)
                Slider(value: $length, in: 1...35, step: 1)
                Text("\(Int(length))")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .frame(width: 22, alignment: .trailing)
            }

            HStack(spacing: 14) {
                Toggle("A-Z", isOn: $uppercase)
                Toggle("a-z", isOn: $lowercase)
                Toggle("0-9", isOn: $numbers)
                Toggle("!@#", isOn: $symbols)
            }
            .toggleStyle(.checkbox)
            .font(.system(size: 12))

            HStack {
                Button(action: regenerate) {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)

                Spacer()

                Button("Quit") { NSApp.terminate(nil) }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 11))
        }
        .padding(14)
        .frame(width: 300)
        .onAppear { regenerate() }
        .onChange(of: length) { regenerate() }
        .onChange(of: uppercase) { regenerate() }
        .onChange(of: lowercase) { regenerate() }
        .onChange(of: numbers) { regenerate() }
        .onChange(of: symbols) { regenerate() }
    }

    private func regenerate() {
        password = generatePassword(
            length: Int(length),
            uppercase: uppercase,
            lowercase: lowercase,
            numbers: numbers,
            symbols: symbols
        )
        copied = false
    }

    private func copy() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(password, forType: .string)
        withAnimation { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { copied = false }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: "RorPass")
            image?.isTemplate = true
            button.image = image
            button.action = #selector(togglePopover)
        }

        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
