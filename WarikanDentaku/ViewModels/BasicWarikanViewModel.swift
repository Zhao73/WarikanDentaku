import Foundation
import SwiftData

@MainActor
final class BasicWarikanViewModel: ObservableObject {
    @Published var totalAmountText: String = ""
    @Published var numberOfPeopleText: String = ""
    @Published var showResult: Bool = false

    // Results
    @Published var perPersonAmount: Int = 0
    @Published var remainder: Int = 0
    @Published var extraPayPersonCount: Int = 0

    var totalAmount: Int {
        Int(totalAmountText) ?? 0
    }

    var numberOfPeople: Int {
        Int(numberOfPeopleText) ?? 0
    }

    var isValid: Bool {
        totalAmount > 0 && numberOfPeople > 0
    }

    func calculate() {
        guard isValid else { return }

        let rawPerPerson = totalAmount / numberOfPeople
        // 100円単位に丸める（切り捨て）
        let roundedDown = (rawPerPerson / 100) * 100
        let totalIfRoundedDown = roundedDown * numberOfPeople
        let shortfall = totalAmount - totalIfRoundedDown

        if shortfall == 0 {
            perPersonAmount = roundedDown
            remainder = 0
            extraPayPersonCount = 0
        } else {
            // 端数分は何人が100円多く払うか
            let extraCount = (shortfall + 99) / 100
            perPersonAmount = roundedDown
            remainder = shortfall
            extraPayPersonCount = extraCount
        }

        showResult = true
    }

    func saveRecord(modelContext: ModelContext) {
        guard showResult else { return }

        var results: [PersonResult] = []
        let baseCount = numberOfPeople - extraPayPersonCount
        if baseCount > 0 {
            for i in 1...baseCount {
                results.append(PersonResult(name: "参加者\(i)", amount: perPersonAmount))
            }
        }
        if extraPayPersonCount > 0 {
            for i in 1...extraPayPersonCount {
                results.append(PersonResult(name: "参加者\(baseCount + i)", amount: perPersonAmount + 100))
            }
        }

        let record = WarikanRecord(
            type: .basic,
            totalAmount: totalAmount,
            resultText: generateShareText(),
            personResults: results
        )
        modelContext.insert(record)
        try? modelContext.save()
    }

    func generateShareText() -> String {
        var text = "今日のお会計💰\n"
        text += "合計: ¥\(formatNumber(totalAmount))\n"
        text += "人数: \(numberOfPeople)人\n"
        text += "─────────\n"
        text += "一人あたり: ¥\(formatNumber(perPersonAmount))\n"
        if extraPayPersonCount > 0 {
            text += "※ \(extraPayPersonCount)人は¥\(formatNumber(perPersonAmount + 100))（端数調整）\n"
        }
        return text
    }

    func reset() {
        totalAmountText = ""
        numberOfPeopleText = ""
        showResult = false
        perPersonAmount = 0
        remainder = 0
        extraPayPersonCount = 0
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
