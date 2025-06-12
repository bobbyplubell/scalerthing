import SwiftUI
import CoreGraphics

@main
struct DisplayScaleToggleApp: App {
    private let modeAWidth = 2560   // e.g. “More Space”
    private let modeBWidth = 2048   // e.g. “Default”

    var body: some Scene {
        MenuBarExtra("ScaleToggle", systemImage: "rectangle.compress.vertical") {
            Button("Toggle Display Scaling", action: toggleScaling)
            Divider()
            Button("Quit") { NSApp.terminate(nil) }
        }
    }

    private func toggleScaling() {
        let displayID = CGMainDisplayID()

        guard let currentMode = CGDisplayCopyDisplayMode(displayID) else {
            NSLog("Unable to read current display mode")
            return
        }

        // Grab every mode, including duplicates…
        let opts: CFDictionary = [
            kCGDisplayShowDuplicateLowResolutionModes as String: kCFBooleanTrue!
        ] as CFDictionary
        guard
            let allModes = CGDisplayCopyAllDisplayModes(displayID, opts) as? [CGDisplayMode]
        else { return }

        // Choose which width to jump to.
        let targetWidth = (currentMode.width == modeAWidth) ? modeBWidth : modeAWidth

        // Prefer crisp HiDPI modes where pixelWidth > width (i.e. 2× backing pixels).
        let hiDPICandidates = allModes.filter {
            $0.width == targetWidth && $0.pixelWidth > $0.width
        }

        // Fallback to *any* match if no HiDPI version exists (unlikely on modern Macs).
        let newMode = hiDPICandidates.first ??
                      allModes.first(where: { $0.width == targetWidth })

        guard let mode = newMode else {
            NSLog("Target mode (width = \(targetWidth)) not found")
            return
        }

        DispatchQueue.main.async {
            let result = CGDisplaySetDisplayMode(displayID, mode, nil)
            if result != .success {
                NSLog("Failed to change display mode: \(result.rawValue)")
            }
        }
    }
}
