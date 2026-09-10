import Elements
import Foundation

/// Point the example at your own account. Neither id is a credential: the plan resolves the
/// currency, the amount and the offered methods client-side.
///
/// `environment` selects between two Whop-owned API origins and nothing else. On `production` the
/// offered methods and the confirmation token are real, and a token confirmed server-side there
/// charges a real card.
enum Config {
    static let accountID = ProcessInfo.processInfo.environment["WHOP_DEMO_ACCOUNT_ID"] ?? "biz_eXbHBYXtG8oW1W"
    static let planID = ProcessInfo.processInfo.environment["WHOP_DEMO_PLAN_ID"] ?? "plan_73l9m6aNu586Y"
    static let environment: WhopEnvironment = .production

    /// Where the issuer returns after a 3DS step. Must be https and hosted by you.
    static let returnURL = URL(string: "https://whop.com/")

    /// Everything true of every charge. Applied once at the app root.
    static var elements: WhopElementsConfiguration {
        WhopElementsConfiguration(
            environment: environment,
            returnURL: returnURL
        )
    }
}
