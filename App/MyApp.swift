import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherScreen(
                viewModel: DependencyContainer.makeWeatherViewModel()
            )
        }
    }
}
