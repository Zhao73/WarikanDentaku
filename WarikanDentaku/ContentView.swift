import SwiftUI

struct ContentView: View {
    @StateObject private var adManager = InterstitialAdManager()
    @State private var calculationCount = 0
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // 基本割り勘
                VStack(spacing: 0) {
                    BasicWarikanView(calculationCount: $calculationCount)
                    BannerAdView()
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
                .tabItem {
                    Label("基本", systemImage: "divide.circle")
                }
                .tag(0)

                // 傾斜割り勘
                VStack(spacing: 0) {
                    KeishaWarikanView(calculationCount: $calculationCount)
                    BannerAdView()
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
                .tabItem {
                    Label("傾斜", systemImage: "chart.bar")
                }
                .tag(1)

                // 個別注文
                VStack(spacing: 0) {
                    KobetsuWarikanView(calculationCount: $calculationCount)
                    BannerAdView()
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
                .tabItem {
                    Label("個別", systemImage: "list.bullet.rectangle")
                }
                .tag(2)

                // 履歴
                HistoryListView()
                    .tabItem {
                        Label("履歴", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(3)
            }
            .tint(Color("PrimaryGreen"))
            .onChange(of: calculationCount) { _, newValue in
                adManager.onCalculation(count: newValue)
            }

            // Interstitial広告オーバーレイ
            if adManager.showInterstitial {
                InterstitialAdView(isPresented: $adManager.showInterstitial)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WarikanRecord.self, PersonResult.self], inMemory: true)
}
