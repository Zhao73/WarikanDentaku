import SwiftUI
import SwiftData

struct BasicWarikanView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = BasicWarikanViewModel()
    @State private var showCopiedToast = false
    @Binding var calculationCount: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 入力セクション
                    inputSection

                    // 計算ボタン
                    calculateButton

                    // 結果セクション
                    if viewModel.showResult {
                        resultSection
                    }

                    Spacer(minLength: 80)
                }
                .padding()
            }
            .navigationTitle("基本割り勘")
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

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 16) {
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

            VStack(alignment: .leading, spacing: 8) {
                Label("人数", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    TextField("例: 5", text: $viewModel.numberOfPeopleText)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("人")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
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

            VStack(spacing: 8) {
                Text("一人あたり")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("¥\(formatNumber(viewModel.perPersonAmount))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("PrimaryGreen"))

                if viewModel.extraPayPersonCount > 0 {
                    VStack(spacing: 4) {
                        Divider()
                        HStack {
                            Image(systemName: "info.circle")
                            Text("\(viewModel.extraPayPersonCount)人は ¥\(formatNumber(viewModel.perPersonAmount + 100))（端数調整 ¥\(viewModel.remainder)）")
                        }
                        .font(.callout)
                        .foregroundStyle(.orange)
                        .padding(.top, 4)
                    }
                }
            }

            Divider()

            // シェアボタン
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

    // MARK: - Toast

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
