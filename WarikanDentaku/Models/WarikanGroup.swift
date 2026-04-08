import Foundation

struct WarikanGroup: Identifiable {
    var id = UUID()
    var name: String
    var count: Int
    var ratio: Double

    init(name: String = "", count: Int = 1, ratio: Double = 1.0) {
        self.name = name
        self.count = count
        self.ratio = ratio
    }
}
