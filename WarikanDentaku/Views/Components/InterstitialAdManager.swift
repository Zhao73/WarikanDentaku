import SwiftUI

/// Interstitial広告管理（AdMobプレースホルダー）
/// 本番環境ではGoogle Mobile Ads SDKに置き換えてください
@MainActor
final class InterstitialAdManager: ObservableObject {
    @Published var showInterstitial = false

    private let showEvery = 3

    func onCalculation(count: Int) {
        if count > 0 && count % showEvery == 0 {
            showInterstitial = true
        }
    }
}

/// Interstitial広告のプレースホルダービュー
struct InterstitialAdView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "megaphone.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color("PrimaryGreen"))

                    Text("広告")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("ここにインタースティシャル広告が表示されます")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Text("（AdMob プレースホルダー）")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Button {
                    isPresented = false
                } label: {
                    Text("閉じる")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color("PrimaryGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(32)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
            .padding(40)
        }
    }
}
