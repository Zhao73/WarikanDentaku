import SwiftUI
import SwiftData

struct KobetsuWarikanView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = KobetsuWarikanViewModel()
    @State private var showCopiedToast = false
    @Binding var calculationCount: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    participantsSection
                    orderItemsSection
                    calculateButton

                    if viewModel.showResult {
                        resultSection
                    }

                    Spacer(minLength: 80)
                }
                .padding()
            }
            .navigationTitle("個別注文")
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

    // MARK: - Participants

    private var participantsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Label("参加者", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    withAnimation {
                        viewModel.addParticipant()
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

            ForEach(Array(viewModel.participants.enumerated()), id: \.element.id) { index, _ in
                HStack {
                    TextField("名前", text: $viewModel.participants[index].name)
                        .font(.callout)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    if viewModel.participants.count > 2 {
                        Button {
                            withAnimation {
                                viewModel.removeParticipant(at: index)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Order Items

    private var orderItemsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Label("注文項目", systemImage: "list.clipboard.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    withAnimation {
                        viewModel.addItem()
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

            if viewModel.orderItems.isEmpty {
                Text("注文項目を追加してください")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
            }

            ForEach(Array(viewModel.orderItems.enumerated()), id: \.element.id) { index, _ in
                orderItemRow(index: index)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func orderItemRow(index: Int) -> some View {
        VStack(spacing: 8) {
            HStack {
                TextField("品名", text: $viewModel.orderItems[index].name)
                    .font(.callout)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack {
                    Text("¥")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("金額", value: $viewModel.orderItems[index].price, format: .number)
                        .keyboardType(.numberPad)
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(width: 70)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Button {
                    withAnimation {
                        viewModel.removeItem(at: index)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                }
            }

            HStack {
                Picker("負担方法", selection: $viewModel.orderItems[index].isShared) {
                    Text("みんなで割る").tag(true)
                    Text("個人負担").tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.orderItems[index].isShared) { _, newValue in
                    if newValue {
                        viewModel.orderItems[index].assignedPersonIndex = nil
                    } else if viewModel.orderItems[index].assignedPersonIndex == nil {
                        viewModel.orderItems[index].assignedPersonIndex = 0
                    }
                }
            }

            if !viewModel.orderItems[index].isShared {
                Picker("負担者", selection: Binding(
                    get: { viewModel.orderItems[index].assignedPersonIndex ?? 0 },
                    set: { viewModel.orderItems[index].assignedPersonIndex = $0 }
                )) {
                    ForEach(Array(viewModel.participants.enumerated()), id: \.offset) { pIndex, participant in
                        Text(participant.name).tag(pIndex)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color("PrimaryGreen"))
            }

            if index < viewModel.orderItems.count - 1 {
                Divider()
            }
        }
    }

    // MARK: - Calculate

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

    // MARK: - Result

    private var resultSection: some View {
        VStack(spacing: 16) {
            Text("計算結果")
                .font(.headline)
                .foregroundStyle(Color("PrimaryGreen"))

            Text("合計: ¥\(formatNumber(viewModel.grandTotal))")
                .font(.title3)
                .fontWeight(.semibold)

            ForEach(viewModel.results) { result in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.name)
                            .font(.callout)
                            .fontWeight(.semibold)
                        HStack(spacing: 8) {
                            Text("共有: ¥\(formatNumber(result.sharedAmount))")
                            if result.personalAmount > 0 {
                                Text("個人: ¥\(formatNumber(result.personalAmount))")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("¥\(formatNumber(result.totalAmount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color("PrimaryGreen"))
                }
                .padding(.vertical, 4)

                if result.id != viewModel.results.last?.id {
                    Divider()
                }
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
