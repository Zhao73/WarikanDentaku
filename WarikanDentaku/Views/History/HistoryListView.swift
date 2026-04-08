import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WarikanRecord.date, order: .reverse) private var records: [WarikanRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    recordList
                }
            }
            .navigationTitle("履歴")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(Color(.systemGray3))

            Text("まだ履歴がありません")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("割り勘を計算すると\nここに記録されます")
                .font(.callout)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var recordList: some View {
        List {
            ForEach(groupedByDate, id: \.key) { dateString, dayRecords in
                Section(header: Text(dateString)) {
                    ForEach(dayRecords) { record in
                        NavigationLink {
                            HistoryDetailView(record: record)
                        } label: {
                            recordRow(record)
                        }
                    }
                    .onDelete { indexSet in
                        deleteRecords(dayRecords: dayRecords, at: indexSet)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func recordRow(_ record: WarikanRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: iconForType(record.type))
                        .foregroundStyle(Color("PrimaryGreen"))
                        .font(.caption)
                    Text(record.type.rawValue)
                        .font(.callout)
                        .fontWeight(.semibold)
                }

                Text(timeString(record.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("¥\(formatNumber(record.totalAmount))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color("PrimaryGreen"))
        }
        .padding(.vertical, 4)
    }

    private var groupedByDate: [(key: String, value: [WarikanRecord])] {
        let grouped = Dictionary(grouping: records) { record in
            dateString(record.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private func deleteRecords(dayRecords: [WarikanRecord], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dayRecords[index])
        }
        try? modelContext.save()
    }

    private func iconForType(_ type: WarikanType) -> String {
        switch type {
        case .basic: return "divide.circle.fill"
        case .keisha: return "chart.bar.fill"
        case .kobetsu: return "list.bullet.rectangle.fill"
        }
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日（E）"
        return formatter.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
