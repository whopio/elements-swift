import Elements
import SwiftUI

/// One appearance object applied to a live form. Mounted elements restyle in place.
struct ThemingScreen: View {
    @State private var accent = WhopScaleColor.blue
    @State private var gray = WhopScaleColor.auto
    @State private var scheme: ColorScheme?
    @State private var radius: CGFloat = 8
    @State private var controlHeight: CGFloat = 44
    @State private var thickBorders = false

    private static let accents: [WhopScaleColor] = [.blue, .ruby, .green, .violet, .amber, .teal, .crimson, .gold]
    private static let grays: [WhopScaleColor] = [.auto, .gray, .mauve, .slate, .sage, .olive, .sand]

    private var appearance: WhopElementsAppearance {
        WhopElementsAppearance(
            theme: .init(colorScheme: scheme, accent: accent, gray: gray),
            tokens: .init(radius: radius, controlHeight: controlHeight),
            parts: thickBorders ? [.input: .init(borderWidth: 2)] : [:]
        )
    }

    var body: some View {
        WhopPayments(accountID: Config.accountID, charge: .plan(id: Config.planID)) { _ in
            screen()
        }
    }

    private func screen() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                controls
                Divider()
                WhopEmailElement()
                WhopCardElement()
                WhopAddressElement(scope: .minimal)
                WhopBrandingElement()
            }
            .padding()
        }
        .whopElementsAppearance(appearance)
        .scrollDismissesKeyboard(.interactively)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            picker("Accent", selection: $accent, options: Self.accents)
            picker("Gray", selection: $gray, options: Self.grays)
            Picker("Appearance", selection: $scheme) {
                Text("System").tag(ColorScheme?.none)
                Text("Light").tag(ColorScheme?.some(.light))
                Text("Dark").tag(ColorScheme?.some(.dark))
            }
            .pickerStyle(.segmented)
            slider("Radius", value: $radius, range: 0 ... 24)
            slider("Control height", value: $controlHeight, range: 36 ... 60)
            Toggle("Thick borders", isOn: $thickBorders)
        }
    }

    private func picker(_ title: String, selection: Binding<WhopScaleColor>, options: [WhopScaleColor]) -> some View {
        HStack {
            Text(title).font(.subheadline)
            Spacer()
            Picker(title, selection: selection) {
                ForEach(options, id: \.rawValue) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private func slider(_ title: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>) -> some View {
        HStack {
            Text("\(title) \(Int(value.wrappedValue))").font(.subheadline).frame(width: 150, alignment: .leading)
            Slider(value: value, in: range)
        }
    }
}
