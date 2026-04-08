import Foundation
import SwiftData

struct KobetsuResult: Identifiable {
    let id = UUID()
    let name: String
    let sharedAmount: Int
    let personalAmount: Int
    var totalAmount: Int { sharedAmount + personalAmount }
}

@MainActor
final class KobetsuWarikanViewModel: ObservableObject {
    @Published var participants: [Participant] = [
        Participant(name: "参加者1"),
        Participant(name: "参加者2")
    ]
    @Published var orderItems: [OrderItem] = []
    @Published var showResult: Bool = false
    @Published var results: [KobetsuResult] = []
    @Published var grandTotal: Int = 0

    var isValid: Bool {
        participants.count >= 2
            && !participants.contains(where: { $0.name.isEmpty })
            && !orderItems.isEmpty
            && orderItems.allSatisfy { $0.price > 0 && !$0.name.isEmpty }
            && orderItems.allSatisfy { item in
                item.isShared || item.assignedPersonIndex != nil
            }
    }

    func addParticipant() {
        let index = participants.count + 1
        participants.append(Participant(name: "参加者\(index)"))
    }

    func removeParticipant(at index: Int) {
        guard participants.count > 2 else { return }
        participants.remove(at: index)
        // assignedPersonIndex の調整
        for i in 0..<orderItems.count {
            if let assigned = orderItems[i].assignedPersonIndex {
                if assigned == index {
                    orderItems[i].assignedPersonIndex = nil
                    orderItems[i].isShared = true
                } else if assigned > index {
                    orderItems[i].assignedPersonIndex = assigned - 1
                }
            }
        }
    }

    func addItem() {
        orderItems.append(OrderItem(name: "", price: 0, isShared: true))
    }

    func removeItem(at index: Int) {
        orderItems.remove(at: index)
    }

    func calculate() {
        guard !participants.isEmpty && !orderItems.isEmpty else { return }

        let sharedItems = orderItems.filter { $0.isShared }
        let personalItems = orderItems.filter { !$0.isShared }

        let sharedTotal = sharedItems.reduce(0) { $0 + $1.price }
        // 共有分を100円単位で割る
        let rawSharedPerPerson = sharedTotal / participants.count
        let sharedPerPerson = (rawSharedPerPerson / 100) * 100
        let sharedRemainder = sharedTotal - (sharedPerPerson * participants.count)

        var personalTotals = Array(repeating: 0, count: participants.count)
        for item in personalItems {
            if let idx = item.assignedPersonIndex, idx < participants.count {
                personalTotals[idx] += item.price
            }
        }

        var calculatedResults: [KobetsuResult] = []
        for (index, participant) in participants.enumerated() {
            let extraForRemainder = index == 0 ? sharedRemainder : 0
            calculatedResults.append(KobetsuResult(
                name: participant.name,
                sharedAmount: sharedPerPerson + extraForRemainder,
                personalAmount: personalTotals[index]
            ))
        }

        grandTotal = orderItems.reduce(0) { $0 + $1.price }
        results = calculatedResults
        showResult = true
    }

    func saveRecord(modelContext: ModelContext) {
        guard showResult else { return }

        let personResults = results.map { result in
            PersonResult(name: result.name, amount: result.totalAmount)
        }

        let record = WarikanRecord(
            type: .kobetsu,
            totalAmount: grandTotal,
            resultText: generateShareText(),
            personResults: personResults
        )
        modelContext.insert(record)
        try? modelContext.save()
    }

    func generateShareText() -> String {
        var text = "今日のお会計💰\n"
        text += "合計: ¥\(formatNumber(grandTotal))\n"
        text += "─────────\n"
        for result in results {
            text += "\(result.name)さん: ¥\(formatNumber(result.totalAmount))\n"
        }
        return text
    }

    func reset() {
        participants = [
            Participant(name: "参加者1"),
            Participant(name: "参加者2")
        ]
        orderItems = []
        showResult = false
        results = []
        grandTotal = 0
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
