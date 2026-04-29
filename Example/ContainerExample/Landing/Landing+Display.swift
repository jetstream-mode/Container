import Container
import SwiftUI

enum Landing {}

extension Landing {
    struct Screen: View {
        @Bindable private var model: Model

        init(model: Model) {
            self.model = model
        }

        var body: some View {
            ScreenContainer(
                model: model,
                mapContent: Landing.buildContent(from:),
                display: makeDisplay(content:)
            )
            .task { await model.loadHeroImage() }
        }

        private func makeDisplay(content: LandingScreenContent) -> Display {
            Display(content: content, model: model)
        }
    }

    struct Display: View {
        let content: LandingScreenContent
        @Bindable var model: Model
        @Environment(\.navRouter) private var navRouter

        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    LoadedImage(data: content.heroImageData, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()

                    if content.isHeroImageLoading {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .horizontal)

                VStack(spacing: 20) {
                    Text(content.title)
                        .font(.largeTitle.weight(.semibold))
                    Text(content.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button(content.buttonTitle) {
                        model.navigation.showLaunchTimes = true
                    }
                    .buttonStyle(.borderedProminent)
                    HStack(spacing: 12) {
                        Button("Detail A") { navRouter?.push(LandingRoute.detailAlpha) }
                            .buttonStyle(.bordered)
                        Button("Detail B") { navRouter?.push(LandingRoute.detailBeta) }
                            .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
