import SwiftUI

/// AdMob Banner広告のプレースホルダー
/// 本番環境ではGoogle Mobile Ads SDKに置き換えてください
struct BannerAdView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 2) {
                Image(systemName: "megaphone.fill")
                    .font(.caption)
                Text("広告")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(height: 50)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
