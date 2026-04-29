import Foundation

enum MainTab: Hashable, CaseIterable {
    case landing
    case launches
    case products

    /// Order of items in the custom tab bar (must match ``AppShellView`` segments).
    static var tabBarOrder: [MainTab] { Array(allCases) }

    var tabBarTitle: String {
        switch self {
        case .landing: "Landing"
        case .launches: "Launches"
        case .products: "Products"
        }
    }

    var tabBarSystemImage: String {
        switch self {
        case .landing: "house.fill"
        case .launches: "airplane"
        case .products: "shippingbox.fill"
        }
    }
}

enum LandingRoute: Hashable {
    case detailAlpha
    case detailBeta
}

enum LaunchesRoute: Hashable {
    case detailAlpha
    case detailBeta
}

enum ProductsRoute: Hashable {
    case detailAlpha
    case detailBeta
}

/// Associates each flow’s route enum with its tab so ``NavRouter`` can implement navigation generically.
protocol RoutedTab: Hashable {
    static var mainTab: MainTab { get }
}

extension LandingRoute: RoutedTab {
    static var mainTab: MainTab { .landing }
}

extension LaunchesRoute: RoutedTab {
    static var mainTab: MainTab { .launches }
}

extension ProductsRoute: RoutedTab {
    static var mainTab: MainTab { .products }
}

enum AppDeepLink: Hashable {
    case tab(MainTab)
    case landing(LandingRoute)
    case launches(LaunchesRoute)
    case products(ProductsRoute)

    /// Stub parser for `container-example://` URLs. Extend for production universal links.
    /// Examples: `container-example://landing/alpha`, `container-example://tab/launches`.
    static func parse(url: URL) -> AppDeepLink? {
        guard url.scheme?.lowercased() == "container-example" else { return nil }

        let host = url.host?.lowercased() ?? ""
        let tail = url.path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map { String($0).lowercased() }

        if host == "tab", let name = tail.first {
            switch name {
            case "landing": return .tab(.landing)
            case "launches": return .tab(.launches)
            case "products": return .tab(.products)
            default: return nil
            }
        }

        let leaf = tail.first
        switch host {
        case "landing":
            return .landing(parseLandingLeaf(leaf))
        case "launches":
            return .launches(parseLaunchesLeaf(leaf))
        case "products":
            return .products(parseProductsLeaf(leaf))
        default:
            return nil
        }
    }

    private static func parseLandingLeaf(_ leaf: String?) -> LandingRoute {
        switch leaf {
        case "beta": return .detailBeta
        default: return .detailAlpha
        }
    }

    private static func parseLaunchesLeaf(_ leaf: String?) -> LaunchesRoute {
        switch leaf {
        case "beta": return .detailBeta
        default: return .detailAlpha
        }
    }

    private static func parseProductsLeaf(_ leaf: String?) -> ProductsRoute {
        switch leaf {
        case "beta": return .detailBeta
        default: return .detailAlpha
        }
    }
}

extension LandingRoute {
    var flowTitle: String {
        switch self {
        case .detailAlpha: "Landing detail A"
        case .detailBeta: "Landing detail B"
        }
    }
}

extension LaunchesRoute {
    var flowTitle: String {
        switch self {
        case .detailAlpha: "Launches detail A"
        case .detailBeta: "Launches detail B"
        }
    }
}

extension ProductsRoute {
    var flowTitle: String {
        switch self {
        case .detailAlpha: "Products detail A"
        case .detailBeta: "Products detail B"
        }
    }
}
