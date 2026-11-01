import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: AppContainer.makeWeatherViewModel())
        }
    }
}

enum AppContainer {
    @MainActor
    static func makeWeatherViewModel() -> WeatherViewModel {
        let locationProvider = CoreLocationProvider()
        let repository = OpenMeteoWeatherRepository()
        let useCase = FetchWeatherUseCase(
            locationProvider: locationProvider,
            weatherRepository: repository
        )

        return WeatherViewModel(fetchWeather: useCase)
    }
}
