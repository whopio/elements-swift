import Elements
import SwiftUI

/// Apple Pay with no element mounted: your own button, driving `WhopPaymentRequest` directly.
struct ExpressScreen: View {
    @State private var request = WhopPaymentRequest(
        accountID: Config.accountID,
        charge: .plan(id: Config.planID),
        configuration: Config.elements
    )

    @State private var isAvailable: Bool?
    @State private var token: String?
    @State private var failure: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Express checkout").font(.headline)
                Text(availability).font(.caption).foregroundStyle(.secondary)

                if isAvailable == true {
                    WhopApplePayButton {
                        Task { await pay() }
                    }
                    .frame(height: 48)
                    .disabled(request.isPresenting)
                }

                if let amount = request.resolvedAmount, let currency = request.resolvedCurrency {
                    Text("\(amount) \(currency.uppercased) in minor units").font(.caption).foregroundStyle(.secondary)
                }

                if let token {
                    Text("Confirmation token \(token)").font(.caption).textSelection(.enabled)
                }

                if let failure {
                    Text(failure).font(.caption).foregroundStyle(.red)
                }
            }
            .padding()
        }
        .task { isAvailable = await request.canMakePayment() }
    }

    private var availability: String {
        switch isAvailable {
        case nil: "Checking whether this device can pay."
        case true?: "Apple Pay is available. The sheet stays open until your server confirms."
        case false?: "Apple Pay is unavailable on this device or unconfigured on the account."
        }
    }

    private func pay() async {
        failure = nil
        do {
            let minted = try await request.show()
            token = minted.id
            // your server confirms the token, then the sheet learns what it said
            request.complete(success: true)
        } catch {
            failure = error.localizedDescription
            token = nil
        }
    }
}
