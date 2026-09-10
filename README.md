# Elements

Native SwiftUI components for collecting payments with Whop.

The elements are real SwiftUI views, and card fields are PCI-isolated by the tokenizer's own
hosted inputs. Apple Pay's branded button is PassKit's own, and the system browser a 3DS step opens
in is AuthenticationServices.

Configuration inherits, so set it once at the app root. A charge is a scope, so it is a container.

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
                            // confirm it on your server, then hand back the client_secret:
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

The closure hands back the controller the way `ScrollViewReader` hands back a proxy. When the pay
button lives outside the scope, hold the controller yourself and pass it in instead:

```swift
@State private var payments = WhopPaymentsController(
    accountID: "biz_xxxxxxxx", charge: .plan(id: "plan_xxxxxxxx"))

WhopPayments(payments) { _ in
    WhopPaymentElement()
    WhopBrandingElement()
}
.toolbar {
    Button("Pay") { … }.disabled(!payments.isComplete)
}
```

## Install

```swift
dependencies: [
    .package(url: "https://github.com/whopio/elements-swift.git", from: "0.1.0")
]
```

One package, no other dependencies to add.

## Requirements

| | |
| --- | --- |
| iOS | 18.0+ |
| Toolchain | Swift 6 |
| Install | Swift Package Manager |
| Apple Pay | nothing to set up. The merchant is registered on the Whop account |
| Credentials | none. An account id is not a secret, and a confirmation token is minted from what the buyer typed |

## Elements

| View | What it collects |
| --- | --- |
| `WhopPaymentElement` | The offered payment methods and the selected one's required fields |
| `WhopAddressElement` | A postal address, in the selected country's own format |
| `WhopCardElement` | Card number, expiry and security code, prearranged |
| `WhopCardFields` with `WhopCardNumberElement`, `WhopCardExpiryElement`, `WhopCardCVCElement` | The same three fields, placed individually |
| `WhopEmailElement` | The buyer's email |
| `WhopTaxIDElement` | A business tax registration |
| `WhopBrandingElement` | Whop's merchant-of-record notice |
| `WhopPaymentRequest` with `WhopApplePayButton` | Apple Pay on its own, for an express button that mounts no element |
| `WhopPaymentInstructionsView` | What the buyer still owes off-app: a voucher, a PIX code, a transfer's coordinates |

`WhopBrandingElement` is required beside a payment surface: Whop is the merchant of record on these
sales, so `createConfirmationToken()` refuses with `.brandingNotMounted` without it.

`WhopAddressElement` autocompletes by default from `MKLocalSearchCompleter`, so it needs no API key,
no account, no location permission and no extra dependency. A geocoder with no matches shows nothing
and the buyer types the address by hand, which is where they started: autocomplete never blocks a
checkout. Pass `autocomplete: false` to turn it off.

## `WhopElementsConfiguration`

Everything true of every charge, applied once with `.whopElements(_:)`. It inherits the way `.font`
does, so a nested screen needs no repetition.

| | |
| --- | --- |
| `environment` | Which Whop API. An enum over two Whop-owned origins, never a URL |
| `returnURL` | Where an issuer returns after a redirect or 3DS step |
| `locale` | Unset follows the device |
| `tokenProvider` | Resolves a buyer token per request |

## `WhopPaymentsController`

One charge. `WhopPayments` creates and owns one and hands it to its content; hold your own only when
a pay button lives outside the scope.

| | |
| --- | --- |
| `accountID` | The Whop company the sale belongs to, prefixed `biz_` |
| `charge` | `.plan(id:)`, or `.amount(minorUnits:currency:)` for an ad-hoc charge. Settable, so a coupon or a quantity stepper re-prices a live form |
| `buyer` | Who signed in, once an email sign-in has proven it. `signOut()` forgets them |
| `methodOrder` | The method tile order, with Stripe's `paymentMethodOrder` semantics |
| `isComplete` | True when the mounted surface can mint a token |
| `isBusy`, `phase` | What the controller is doing |
| `lastError` | The last `WhopPaymentsError`, also rendered inline by the element that produced it |
| `createConfirmationToken(billingDetails:billingExtra:)` | Mints the token your server confirms |
| `handleNextAction(clientSecret:returnURL:polling:)` | Runs any pending step and polls the payment to rest |

`returnURL` must be **https** and hosted by you, because the API refuses anything
else, so a custom app scheme will not work. You register no deep link: `handleNextAction` polls the
payment to rest and closes the browser itself.

## Appearance

One object, applied live. Mounted elements restyle in place.

```swift
.whopElementsAppearance(
    WhopElementsAppearance(
        theme: .init(colorScheme: .dark, accent: .blue),
        tokens: .init(radius: 12),
        parts: [.cardNumberField: .init(borderWidth: 2)]
    )
)
```

`theme` takes the shared Elements styling vocabulary, in the two shapes SwiftUI can express:

- `tokens`: a closed, typed map of numbers, not `"8px"` strings.
- `parts`: the `whop-*` part names, each taking a typed `PartStyle`. Flat per-part overrides, no
  cascade.

An unset `theme.colorScheme` follows the device.

## Errors

Everything the SDK throws is one `WhopPaymentsError`, so a caller switches rather than
string-matching:

```swift
catch let error as WhopPaymentsError {
    switch error {
    case .brandingNotMounted: …
    case let .tokenizationFailed(stage, _): …
    case let .api(failure): failure.code
    default: …
    }
}
```

The server's own `error.code` stays a string on `WhopPaymentsError.APIFailure`, because that value
is the backend's and re-enumerating it in a client the backend can outpace would age badly.

## Signing the buyer in

A plausible email is probed against the account directory. A recognized address offers a sign-in,
the code sheet takes six digits, and a verified buyer's stored methods appear above the fresh ones.

```swift
WhopEmailElement()      // probes, offers the sign-in, presents the code sheet itself
WhopPaymentElement()    // shows the stored methods once there is a credential
```

`payments.buyer` is the signed-in buyer, `payments.signOut()` forgets them. The scoped token the
verify mints lasts an hour and does not refresh: when it lapses the saved lane simply comes back
empty and the buyer pays with a fresh method, which is the same path a guest takes.

## Rails

Card, Apple Pay, bank debit, bank transfer, voucher, redirect and crypto all run end to end. A rail
the buyer finishes themselves comes back as `outcome.instructions` from `handleNextAction`, and
`WhopPaymentInstructionsView` draws it. Ledger-balance payment and Google Pay are not here.

## Not in this release

Absent entirely rather than half-present, so nothing renders that cannot work:

- **Phone verification.** A checkout-level ceremony that no surface currently runs: the action
  executor returns `stop` for `verify_phone` and never opens it. Natively it also needs a full
  first-party login token, which `tokenProvider` does not supply. It is not built, and building it
  would need a credential decision first.
- **Ledger-balance payment and Google Pay.** No rail behind either.

Two things are present but worth stating up front, and both are repeated where they matter:

- **The identity document passes through this process.** The card never does. The tokenizer's iOS
  element API can only build an object token and the PSP transformers read this one as a bare
  scalar, so there is no hosted-field shape that produces the right value. The number still goes
  straight to the tokenizer and never reaches Whop.
- **A picked installment plan narrows the address element's country list.** The address element is
  the surface the buyer types into, so narrowing it there is better than letting a refusal at the
  mint be the buyer's first hint that the plan and the country disagree.
