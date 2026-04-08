import Foundation

enum PaymentLinkHelper {
    /// 支払いリンク付きのシェアテキストを生成
    static func appendPaymentLink(to text: String, payPayLink: String? = nil, linePayLink: String? = nil) -> String {
        var result = text

        if let payPayLink, !payPayLink.isEmpty {
            result += "\n💳 PayPay送金はこちら:\n\(payPayLink)\n"
        }

        if let linePayLink, !linePayLink.isEmpty {
            result += "\n💚 LINE Pay送金はこちら:\n\(linePayLink)\n"
        }

        return result
    }
}
