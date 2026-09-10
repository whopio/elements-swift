import Elements
import SwiftUI

/// Every element on its own, with live controls for the props that change what it renders.
struct GalleryScreen: View {
    @State private var cardLayout = WhopCardElement.Layout.stacked
    @State private var cardState = WhopCardState(isComplete: false, brand: nil)
    @State private var addressScope = WhopAddressElement.Scope.full
    @State private var addressNames = WhopAddressElement.NameFields.combined
    @State private var autocomplete = true
    @State private var address = PostalAddress()
    @State private var addressComplete = false
    @State private var email = ""
    @State private var taxID: WhopTaxID?
    @State private var selection = WhopPaymentSelection(isComplete: false, type: nil, displayName: nil, category: nil)

    var body: some View {
        WhopPayments(accountID: Config.accountID, charge: .plan(id: Config.planID)) { payments in
            screen(payments)
        }
    }

    private func screen(_ payments: WhopPaymentsController) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                section("PaymentElement", note: selection.displayName.map { "\($0), complete \(selection.isComplete)" }) {
                    WhopPaymentElement(selection: $selection)
                }

                section("CardElement", note: "\(cardState.brand ?? "no brand"), complete \(cardState.isComplete)") {
                    Picker("Layout", selection: $cardLayout) {
                        Text("Stacked").tag(WhopCardElement.Layout.stacked)
                        Text("Compact").tag(WhopCardElement.Layout.compact)
                    }
                    .pickerStyle(.segmented)
                    WhopCardElement(layout: cardLayout, state: $cardState)
                }

                section("CardFields", note: "the same three fields, placed one by one") {
                    WhopCardFields {
                        WhopCardNumberElement()
                        HStack(alignment: .top, spacing: 8) {
                            WhopCardExpiryElement()
                            WhopCardCVCElement()
                        }
                    }
                }

                section("AddressElement", note: "\(address.country), complete \(addressComplete)") {
                    Picker("Scope", selection: $addressScope) {
                        Text("Full").tag(WhopAddressElement.Scope.full)
                        Text("Minimal").tag(WhopAddressElement.Scope.minimal)
                    }
                    .pickerStyle(.segmented)
                    Picker("Name", selection: $addressNames) {
                        Text("Combined").tag(WhopAddressElement.NameFields.combined)
                        Text("Split").tag(WhopAddressElement.NameFields.split)
                        Text("None").tag(WhopAddressElement.NameFields.none)
                    }
                    .pickerStyle(.segmented)
                    Toggle("Autocomplete", isOn: $autocomplete)
                    WhopAddressElement(
                        address: $address,
                        isComplete: $addressComplete,
                        scope: addressScope,
                        name: addressNames,
                        autocomplete: autocomplete
                    )
                    .id("\(addressScope)\(addressNames)\(autocomplete)")
                }

                section("EmailElement", note: emailNote(payments)) {
                    WhopEmailElement(email: $email)
                }

                section("TaxIDElement", note: taxID.map { "\($0.type.rawValue) \($0.value)" }) {
                    WhopTaxIDElement(taxID: $taxID, country: address.country)
                }

                section("BrandingElement", note: "required beside any payment surface") {
                    WhopBrandingElement()
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    /// A recognized address offers the sign-in here, and a verified one unlocks the saved methods
    /// in the payment element above.
    private func emailNote(_ payments: WhopPaymentsController) -> String? {
        if let buyer = payments.buyer { return buyer.isSignedIn ? "signed in as \(buyer.email)" : buyer.email }
        return email.isEmpty ? nil : email
    }

    private func section(_ title: String, note: String?, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            if let note {
                Text(note).font(.caption).foregroundStyle(.secondary)
            }
            content()
        }
    }
}
