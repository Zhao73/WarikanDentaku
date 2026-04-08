import SwiftUI

struct HistoryDetailView: View {
    let record: WarikanRecord
    @State private var showCopiedToast = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: iconForType(record.type))
                            .foregroundStyle(Color("PrimaryGreen"))
                        Text(record.type.rawValue)
                            .font(.headline)
                    }

                    Text(dateString(record.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Total
                VStack(spacing: 4) {
                    Text("合計金額")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("¥\(formatNumber(record.totalAmount))")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("PrimaryGreen"))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("PrimaryGreen").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Person Results
                VStack(spacing: 12) {
                    Text("内訳")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(record.personResults) { person in
                        HStack {
                            Text(person.name)
                                .font(.callout)
                            Spacer()
                            Text("¥\(formatNumber(person.amount))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("PrimaryGreen"))
                        }
                        .padding(.vertical, 4)

                        if person.id != record.personResults.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)

                // Share buttons
                HStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.string = record.resultText
                        withAnimation {
                            showCopiedToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showCopiedToast = false
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("結果をコピー")
                        }
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("PrimaryGreen"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color("PrimaryGreen").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    ShareLink(item: record.resultText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("共有")
                        }
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("PrimaryGreen"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color("PrimaryGreen").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .top) {
            if showCopiedToast {
                Text("コピーしました！")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
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
        formatter.dateFormat = "yyyy年M月d日（E）HH:mm"
        return formatter.string(from: date)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
