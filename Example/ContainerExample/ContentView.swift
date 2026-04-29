import SwiftUI

struct ContentView: View {
    @State private var navRouter = NavRouter()
    @State private var landingModel = Landing.Model()
    @State private var launchTimesModel = LaunchTimes.Model(fetcher: SpaceXLaunchesService())
    @State private var productGalleryModel = ProductGallery.Model()

    var body: some View {
        @Bindable var navRouter = navRouter
        AppShellView(
            navRouter: navRouter,
            landingModel: landingModel,
            launchTimesModel: launchTimesModel,
            productGalleryModel: productGalleryModel
        )
        .onChange(of: landingModel.navigation.showLaunchTimes) { _, _ in
            navRouter.syncCrossTabNavigation(landingModel: landingModel)
        }
        .onOpenURL { url in
            if let link = AppDeepLink.parse(url: url) {
                navRouter.apply(deepLink: link)
            }
        }
    }
}

#Preview {
    ContentView()
}
