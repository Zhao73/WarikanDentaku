import Foundation
import SwiftData

struct KeishaResult: Identifiable {
    let id = UUID()
    let groupName: String
    let count: Int
    let ratio: Double
    let perPersonAmount: Int
    let subtotal: Int
}

@MainActor
final class KeishaWarikanViewModel: ObservableObject {
    @Published var totalAmountText: String = ""
    @Published var groups: [WarikanGroup] = [
        WarikanGroup(name: "幹事", count: 1, ratio: 1.5),
        WarikanGroup(name: "一般", count: 3, ratio: 1.0),
        WarikanGroup(name: "新人", count: 1, ratio: 0.5)
    ]
    @Published var showResult: Bool = false
    @Published var results: [KeishaResult] = []
    @Published var adjustmentNote: String = ""

    var totalAmount: Int {
        Int(totalAmountText) ?? 0
    }

    var totalPeople: Int {
        groups.reduce(0) { $0 + $1.count }
    }

    var isValid: Bool {
        totalAmount > 0 && totalPeople > 0 && groups.allSatisfy { $0.count > 0 && $0.ratio > 0 && !$0.name.isEmpty }
    }

    func addGroup() {
        groups.append(WarikanGroup(name: "", count: 1, ratio: 1.0))
    }

    func removeGroup(at index: Int) {
        guard groups.count > 1 else { return }
        groups.remove(at: index)
    }

    func calculate() {
        guard isValid else { return }

        // 加重合計を計算: Σ(人数 × 比率)
        let weightedTotal = groups.reduce(0.0) { $0 + Double($1.count) * $1.ratio }
        // 基準単価
        let baseUnit = Double(totalAmount) / weightedTotal

        var calculatedResults: [KeishaResult] = []
        var runningTotal = 0

        for (index, group) in groups.enumerated() {
            let rawAmount = baseUnit * group.ratio
            // 100円単位に丸める
            let roundedAmount: Int
            if index == groups.count - 1 {
                // 最後のグループで調整
                let remainingTotal = totalAmount - runningTotal
                roundedAmount = (remainingTotal / group.count / 100) * 100
            } else {
                roundedAmount = (Int(rawAmount) / 100) * 100
            }

            let subtotal = roundedAmount * group.count
            runningTotal += subtotal

            calculatedResults.append(KeishaResult(
                groupName: group.name,
                count: group.count,
                ratio: group.ratio,
                perPersonAmount: roundedAmount,
                subtotal: subtotal
            ))
        }

        // 端数調整
        let diff = totalAmount - runningTotal
        if diff != 0 {
            adjustmentNote = "※ 端数 ¥\(formatNumber(abs(diff))) は幹事が調整してください"
        } else {
            adjustmentNote = ""
        }

        results = calculatedResults
        showResult = true
    }

    func saveRecord(modelContext: ModelContext) {
        guard showResult else { return }

        var personResults: [PersonResult] = []
        for result in results {
            for i in 1...result.count {
                let name = result.count == 1 ? result.groupName : "\(result.groupName)\(i)"
                personResults.append(PersonResult(name: name, amount: result.perPersonAmount))
            }
        }

        let record = WarikanRecord(
            type: .keisha,
            totalAmount: totalAmount,
            resultText: generateShareText(),
            personResults: personResults
        )
        modelContext.insert(record)
        try? modelContext.save()
    }

    func generateShareText() -> String {
        var text = "今日のお会計💰\n"
        text += "合計: ¥\(formatNumber(totalAmount))\n"
        text += "─────────\n"
        for result in results {
            text += "【\(result.groupName)】\(result.count)人 × ¥\(formatNumber(result.perPersonAmount)) = ¥\(formatNumber(result.subtotal))\n"
        }
        if !adjustmentNote.isEmpty {
            text += "\(adjustmentNote)\n"
        }
        return text
    }

    func reset() {
        totalAmountText = ""
        groups = [
            WarikanGroup(name: "幹事", count: 1, ratio: 1.5),
            WarikanGroup(name: "一般", count: 3, ratio: 1.0),
            WarikanGroup(name: "新人", count: 1, ratio: 0.5)
        ]
        showResult = false
        results = []
        adjustmentNote = ""
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
