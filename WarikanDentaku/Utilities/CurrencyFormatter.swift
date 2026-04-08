import Foundation

enum CurrencyFormatter {
    /// 数値を日本円フォーマットに変換
    static func format(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    /// 100円単位に切り捨て
    static func roundDownTo100(_ amount: Int) -> Int {
        (amount / 100) * 100
    }

    /// 100円単位に四捨五入
    static func roundTo100(_ amount: Int) -> Int {
        ((amount + 50) / 100) * 100
    }
}
