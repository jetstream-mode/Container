import SwiftUI

/// Hosts per-flow `NavigationStack`s and a custom tab bar (avoids `TabView`’s springy system transition).
struct AppShellView: View {
    @Bindable var navRouter: NavRouter
    var landingModel: Landing.Model
    var launchTimesModel: LaunchTimes.Model
    var productGalleryModel: ProductGallery.Model

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                landingFlow
                    .opacity(navRouter.selectedTab == .landing ? 1 : 0)
                    .allowsHitTesting(navRouter.selectedTab == .landing)
                    .accessibilityHidden(navRouter.selectedTab != .landing)

                launchesFlow
                    .opacity(navRouter.selectedTab == .launches ? 1 : 0)
                    .allowsHitTesting(navRouter.selectedTab == .launches)
                    .accessibilityHidden(navRouter.selectedTab != .launches)

                productsFlow
                    .opacity(navRouter.selectedTab == .products ? 1 : 0)
                    .allowsHitTesting(navRouter.selectedTab == .products)
                    .accessibilityHidden(navRouter.selectedTab != .products)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .opacity(0.35)

            tabBar
        }
        .environment(\.navRouter, navRouter)
    }

    private var tabBar: some View {
        let order = MainTab.tabBarOrder
        return HStack(spacing: 0) {
            ForEach(order, id: \.self) { tab in
                tabBarButton(tab: tab, title: tab.tabBarTitle, systemImage: tab.tabBarSystemImage)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity)
        .background(alignment: .topLeading) {
            GeometryReader { geo in
                let count = CGFloat(order.count)
                let segment = geo.size.width / count
                let index = CGFloat(order.firstIndex(of: navRouter.selectedTab) ?? 0)
                let horizontalInset: CGFloat = 4
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.18))
                    .frame(width: max(0, segment - horizontalInset * 2), height: geo.size.height - 8)
                    .offset(x: segment * index + horizontalInset, y: 4)
            }
            .allowsHitTesting(false)
        }
        .background {
            Rectangle()
                .fill(.bar)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var landingFlow: some View {
        NavigationStack(path: $navRouter.landingPath) {
            Landing.Screen(model: landingModel)
                .navigationDestination(for: LandingRoute.self) { route in
                    FlowPlaceholderDetailView(
                        title: route.flowTitle,
                        subtitle: "Stub detail in the landing flow."
                    )
                }
        }
    }

    private var launchesFlow: some View {
        NavigationStack(path: $navRouter.launchesPath) {
            LaunchTimes.Screen(model: launchTimesModel)
                .navigationDestination(for: LaunchesRoute.self) { route in
                    FlowPlaceholderDetailView(
                        title: route.flowTitle,
                        subtitle: "Stub detail in the launches flow."
                    )
                }
        }
    }

    private var productsFlow: some View {
        NavigationStack(path: $navRouter.productsPath) {
            ProductGallery.Screen(model: productGalleryModel)
                .navigationDestination(for: ProductsRoute.self) { route in
                    FlowPlaceholderDetailView(
                        title: route.flowTitle,
                        subtitle: "Stub detail in the products flow."
                    )
                }
        }
    }

    private func tabBarButton(tab: MainTab, title: String, systemImage: String) -> some View {
        Button {
            navRouter.selectTab(tab)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(navRouter.selectedTab == tab ? Color.accentColor : Color.secondary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
