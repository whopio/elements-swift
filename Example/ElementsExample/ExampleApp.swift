import Elements
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .whopElements(Config.elements)
        }
    }
}

struct RootView: View {
    private enum Tab: String, CaseIterable, Identifiable {
        case checkout = "Checkout"
        case gallery = "Gallery"
        case express = "Express"
        case theming = "Theming"

        var id: String {
            rawValue
        }
    }

    @State private var tab = Tab.checkout

    var body: some View {
        VStack(spacing: 0) {
            Picker("Screen", selection: $tab) {
                ForEach(Tab.allCases) { entry in Text(entry.rawValue).tag(entry) }
            }
            .pickerStyle(.segmented)
            .padding()

            switch tab {
            case .checkout: CheckoutScreen()
            case .gallery: GalleryScreen()
            case .express: ExpressScreen()
            case .theming: ThemingScreen()
            }
        }
    }
}
