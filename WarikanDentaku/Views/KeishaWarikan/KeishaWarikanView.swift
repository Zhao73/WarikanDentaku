import SwiftUI
import SwiftData

struct KeishaWarikanView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = KeishaWarikanViewModel()
    @State private var showCopiedToast = false
    @Binding var calculationCount: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    totalAmountSection
                    groupsSection
                    calculateButton

                    if viewModel.showResult {
                        resultSection
                    }

                    Spacer(minLength: 80)
                }
                .padding()
            }
            .navigationTitle("傾斜割り勘")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("リセット") {
                        viewModel.reset()
                    }
                    .foregroundStyle(Color("PrimaryGreen"))
                }
            }
            .overlay(alignment: .top) {
                if showCopiedToast {
                    copiedToast
                }
            }
        }
    }

    // MARK: - Total Amount

    private var totalAmountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("合計金額", systemImage: "yensign.circle.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("¥")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("PrimaryGreen"))
                TextField("例: 32400", text: $viewModel.totalAmountText)
                    .keyboardType(.numberPad)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Groups

    private var groupsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Label("グループ設定", systemImage: "person.3.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    withAnimation {
                        viewModel.addGroup()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("追加")
                    }
                    .font(.callout)
                    .foregroundStyle(Color("PrimaryGreen"))
                }
            }

            ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { index, _ in
                groupRow(index: index)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func groupRow(index: Int) -> some View {
        VStack(spacing: 8) {
            HStack {
                TextField("グループ名", text: $viewModel.groups[index].name)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                if viewModel.groups.count > 1 {
                    Button {
                        withAnimation {
                            viewModel.removeGroup(at: index)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }

            HStack(spacing: 12) {
                HStack {
                    Text("人数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("人数", value: $viewModel.groups[index].count, format: .number)
                        .keyboardType(.numberPad)
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(width: 40)
                        .multilineTextAlignment(.center)
                    Text("人")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack {
                    Text("比率")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("比率", value: $viewModel.groups[index].ratio, format: .number)
                        .keyboardType(.decimalPad)
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                    Text("倍")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if index < viewModel.groups.count - 1 {
                Divider()
            }
        }
    }

    // MARK: - Calculate Button

    private var calculateButton: some View {
        Button {
            viewModel.calculate()
            if viewModel.showResult {
                viewModel.saveRecord(modelContext: modelContext)
                calculationCount += 1
            }
        } label: {
            HStack {
                Image(systemName: "equal.circle.fill")
                Text("計算する")
            }
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isValid ? Color("PrimaryGreen") : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.isValid)
    }

    // MARK: - Result Section

    private var resultSection: some View {
        VStack(spacing: 16) {
            Text("計算結果")
                .font(.headline)
                .foregroundStyle(Color("PrimaryGreen"))

            ForEach(viewModel.results) { result in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.groupName)
                            .font(.callout)
                            .fontWeight(.semibold)
                        Text("\(result.count)人 × \(String(format: "%.1f", result.ratio))倍")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("¥\(formatNumber(result.perPersonAmount))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("PrimaryGreen"))
                        Text("小計: ¥\(formatNumber(result.subtotal))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)

                if result.id != viewModel.results.last?.id {
                    Divider()
                }
            }

            if !viewModel.adjustmentNote.isEmpty {
                Text(viewModel.adjustmentNote)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }

            Divider()

            HStack(spacing: 12) {
                Button {
                    UIPasteboard.general.string = viewModel.generateShareText()
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

                ShareLink(item: viewModel.generateShareText()) {
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var copiedToast: some View {
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

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
