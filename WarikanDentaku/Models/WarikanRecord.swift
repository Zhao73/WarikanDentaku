import Foundation
import SwiftData

enum WarikanType: String, Codable {
    case basic = "基本割り勘"
    case keisha = "傾斜割り勘"
    case kobetsu = "個別注文"
}

@Model
final class WarikanRecord {
    var id: UUID
    var date: Date
    var type: WarikanType
    var totalAmount: Int
    var resultText: String
    @Relationship(deleteRule: .cascade) var personResults: [PersonResult]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        type: WarikanType,
        totalAmount: Int,
        resultText: String,
        personResults: [PersonResult] = []
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.totalAmount = totalAmount
        self.resultText = resultText
        self.personResults = personResults
    }
}
