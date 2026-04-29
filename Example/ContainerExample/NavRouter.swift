import Observation
import SwiftUI

@MainActor
@Observable
final class NavRouter {
    var selectedTab: MainTab = .landing

    private var pathStorage: [MainTab: NavigationPath] = Dictionary(
        uniqueKeysWithValues: MainTab.allCases.map { ($0, NavigationPath()) }
    )

    var landingPath: NavigationPath {
        get { pathStorage[.landing] ?? NavigationPath() }
        set { pathStorage[.landing] = newValue }
    }

    var launchesPath: NavigationPath {
        get { pathStorage[.launches] ?? NavigationPath() }
        set { pathStorage[.launches] = newValue }
    }

    var productsPath: NavigationPath {
        get { pathStorage[.products] ?? NavigationPath() }
        set { pathStorage[.products] = newValue }
    }

    /// Tab switches use a short ease-in-out curve only (no spring / bounce).
    func selectTab(_ tab: MainTab) {
        selectTab(tab, animation: .easeInOut(duration: 0.22))
    }

    /// Pass `animation: nil` to change tabs without `withAnimation`.
    func selectTab(_ tab: MainTab, animation: Animation?) {
        guard tab != selectedTab else { return }
        if let animation {
            withAnimation(animation) {
                selectedTab = tab
            }
        } else {
            selectedTab = tab
        }
    }

    /// Push a route onto the stack for its tab (user is expected to already be on that tab).
    func push<R: RoutedTab>(_ route: R) {
        mutatePath(for: R.mainTab) { $0.append(route) }
    }

    /// Switch to the route’s tab, then push (no stack reset).
    func open<R: RoutedTab>(_ route: R) {
        selectTab(R.mainTab)
        mutatePath(for: R.mainTab) { $0.append(route) }
    }

    /// Switch to the route’s tab, clear that stack, then push (deep link / single-destination flows).
    func replaceStack<R: RoutedTab>(with route: R) {
        let tab = R.mainTab
        selectTab(tab)
        var path = NavigationPath()
        path.append(route)
        pathStorage[tab] = path
    }

    func apply(deepLink: AppDeepLink) {
        switch deepLink {
        case .tab(let tab):
            selectTab(tab)
        case .landing(let route):
            replaceStack(with: route)
        case .launches(let route):
            replaceStack(with: route)
        case .products(let route):
            replaceStack(with: route)
        }
    }

    func syncCrossTabNavigation(landingModel: Landing.Model) {
        if landingModel.navigation.showLaunchTimes {
            selectTab(.launches)
            landingModel.navigation.showLaunchTimes = false
        }
    }

    private func mutatePath(for tab: MainTab, _ body: (inout NavigationPath) -> Void) {
        var path = pathStorage[tab] ?? NavigationPath()
        body(&path)
        pathStorage[tab] = path
    }
}

private enum NavRouterKey: EnvironmentKey {
    static let defaultValue: NavRouter? = nil
}

extension EnvironmentValues {
    /// Set from ``AppShellView``; feature displays push routes via optional chaining if absent (e.g. previews).
    var navRouter: NavRouter? {
        get { self[NavRouterKey.self] }
        set { self[NavRouterKey.self] = newValue }
    }
}
