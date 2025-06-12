import Foundation

struct Strings {
    static let amountLabelTitle = NSLocalizedString("amount_label_title", bundle: .main, comment: "")
    static let zero = NSLocalizedString("zero", bundle: .main, comment: "")
    static let rateLabelTitle = NSLocalizedString("rate_label_title", bundle: .main, comment: "")
    static let converterNavigationTitle = NSLocalizedString("converter_navigation_title", bundle: .main, comment: "")
    static let errorInvalidAmount = NSLocalizedString("error_invalid_amount", bundle: .main, comment: "")
    static let historyNavigationTitle = NSLocalizedString("history_navigation_title", bundle: .main, comment: "")
    static let searchPlaceholder = NSLocalizedString("search_placeholder", bundle: .main, comment: "")
    
    static func errorRateNotFound(_ currency: String) -> String {
        String(format: NSLocalizedString("error_rate_not_found", bundle: .main, comment: ""), currency)
    }
}

