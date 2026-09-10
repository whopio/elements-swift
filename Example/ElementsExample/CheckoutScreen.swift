import Elements
import SwiftUI

/// The realistic assembly: the closest thing to how an integrator writes it.
struct CheckoutScreen: View {
    @State private var result: String?
    @State private var failure: String?
    @State private var instructions: WhopPaymentInstructions?

    var body: some View {
        WhopPayments(accountID: Config.accountID, charge: .plan(id: Config.planID)) { payments in
            checkout(payments)
        }
    }

    private func checkout(_ payments: WhopPaymentsController) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                WhopEmailElement()
                WhopAddressElement()
                WhopPaymentElement()
                WhopBrandingElement()

                if let buyer = payments.buyer {
                    HStack {
                        Text(buyer.isSignedIn ? "Signed in as \(buyer.email)" : buyer.email)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Sign out") { payments.signOut() }
                            .font(.caption)
                    }
                }

                Button { confirm(payments) } label: {
                    Text(payments.isBusy ? "Working…" : "Pay")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!payments.isComplete || payments.isBusy)

                if let instructions {
                    WhopPaymentInstructionsView(instructions)
                }
                if let result {
                    ResultBox(tone: .success, text: result)
                }
                if let failure {
                    ResultBox(tone: .failure, text: failure)
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func confirm(_ payments: WhopPaymentsController) {
        result = nil
        failure = nil
        instructions = nil
        Task {
            do {
                let token = try await payments.createConfirmationToken()
                // your server confirms this and hands back the payment's client_secret; then
                // handleNextAction runs the pending step and reports where it came to rest:
                //   let outcome = try await payments.handleNextAction(clientSecret: secret)
                //   instructions = outcome.instructions
                result = "confirmation token \(token.id) for \(token.paymentMethodType.rawValue)"
            } catch {
                failure = error.localizedDescription
            }
        }
    }
}

struct ResultBox: View {
    enum Tone { case success, failure }

    let tone: Tone
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, design: .monospaced))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill((tone == .success ? Color.green : Color.red).opacity(0.12))
            )
    }
}
