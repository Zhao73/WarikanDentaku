import Foundation
import SwiftData

@Model
final class PersonResult {
    var id: UUID
    var name: String
    var amount: Int
    var record: WarikanRecord?

    init(
        id: UUID = UUID(),
        name: String,
        amount: Int
    ) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}
