# Whop Elements for Swift

Native SwiftUI payment components for taking payments on [Whop](https://whop.com):
Stripe-Elements-style building blocks, as real SwiftUI views.

Card fields are hosted by the tokenizer and PCI-isolated. Apple Pay uses the system sheet and
Apple's own button. 3DS and redirect steps open in the system browser.

| | |
|---|---|
| iOS | 18.0+ |
| Toolchain | Swift 6 |
| Install | Swift Package Manager |
| Dependencies | None |
| Setup | None. No Apple Pay merchant id, no `In-App Payments` capability, no API key |

## Install

```swift
dependencies: [
    .package(url: "https://github.com/whopio/elements-swift.git", from: "0.1.1")
]
```

## Usage

Apply the configuration once at the app root. Wrap each charge in a `WhopPayments` container, which
creates a controller and passes it to its content.

```swift
import SwiftUI
import Elements

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            CheckoutScreen()
                .whopElements(environment: .production)
        }
    }
}

struct CheckoutScreen: View {
    var body: some View {
        WhopPayments(accountID: "biz_xxxxxxxx", charge: .plan(id: "plan_xxxxxxxx")) { payments in
            ScrollView {
                VStack(spacing: 16) {
                    WhopEmailElement()
                    WhopAddressElement()
                    WhopPaymentElement()
                    WhopBrandingElement()

                    Button("Pay") {
                        Task {
                            let token = try await payments.createConfirmationToken()
                            // confirm on your server, then pass back the client_secret:
                            // try await payments.handleNextAction(clientSecret: secret)
                        }
                    }
                    .disabled(!payments.isComplete || payments.isBusy)
                }
                .padding()
            }
        }
    }
}
```

## Elements

| View | What it collects |
|---|---|
| `WhopPaymentElement` | The offered payment methods and the selected one's required fields |
| `WhopAddressElement` | A postal address in the selected country's format |
| `WhopCardElement` | Card number, expiry and security code together |
| `WhopCardFields` | The same three fields, placed individually |
| `WhopEmailElement` | The buyer's email, and the sign-in that reveals saved methods |
| `WhopTaxIDElement` | A business tax registration |
| `WhopBrandingElement` | Whop's merchant-of-record notice, required beside any payment surface |
| `WhopPaymentRequest` | Apple Pay alone, with no element mounted |
| `WhopPaymentInstructionsView` | Off-app payment instructions: a voucher, a PIX code, transfer details |

Card, Apple Pay, bank debit, bank transfer, voucher, redirect and crypto all work end to end.

## Docs

https://docs.whop.com/elements/upcoming/getting-started

## About this repository

This is a **read-only release mirror**. Development happens in Whop's monorepo; every published
release is pushed here with the XCFramework it shipped, so releases can be read and diffed in one
place.

- **Issues are welcome.** This is the official issue tracker.
- **Pull requests can't be accepted here.** The source of truth lives elsewhere, so PRs against
  this mirror will be closed.
