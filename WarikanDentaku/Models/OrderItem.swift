import Foundation

struct OrderItem: Identifiable {
    var id = UUID()
    var name: String
    var price: Int
    var isShared: Bool
    var assignedPersonIndex: Int?

    init(name: String = "", price: Int = 0, isShared: Bool = true, assignedPersonIndex: Int? = nil) {
        self.name = name
        self.price = price
        self.isShared = isShared
        self.assignedPersonIndex = assignedPersonIndex
    }
}

struct Participant: Identifiable {
    var id = UUID()
    var name: String

    init(name: String = "") {
        self.name = name
    }
}
