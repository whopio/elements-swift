# Changelog

All notable changes to the Whop Payment Elements SDK are documented here.

## [0.1.2] - 2026-09-10

- Adds a runnable example app under `Example/`, building against the release it ships with.
- No code changes. The framework is identical to 0.1.1.

## [0.1.1] - 2026-09-10

- Rewrote the README. No code changes.

## [0.1.0] - 2026-09-10

First release.

- `WhopPaymentElement`, `WhopAddressElement`, `WhopCardElement`, `WhopCardFields` with
  `WhopCardNumberElement` / `WhopCardExpiryElement` / `WhopCardCVCElement`, `WhopEmailElement`,
  `WhopTaxIDElement` and `WhopBrandingElement`.
- Card fields are the tokenizer's own PCI-isolated inputs; the number never enters SDK code.
- Apple Pay with nothing to configure: no merchant identifier and no `In-App Payments` capability, behind a real `PKPaymentButton`.
- Redirect and 3DS steps open in the system browser through `ASWebAuthenticationSession`.
- Street autocomplete from `MKLocalSearchCompleter`: no API key, no account, no permission.
- `WhopElementsAppearance` with the same theme vocabulary as the web and React Native elements.

[0.1.2]: https://github.com/whopio/elements-swift/releases/tag/0.1.2
[0.1.1]: https://github.com/whopio/elements-swift/releases/tag/0.1.1
[0.1.0]: https://github.com/whopio/elements-swift/releases/tag/0.1.0
