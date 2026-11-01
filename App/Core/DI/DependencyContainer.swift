enum DependencyContainer {
    @MainActor
    static func makeWeatherViewModel() -> WeatherViewModel {
        let locationProvider = CoreLocationProvider()
        let apiClient = URLSessionAPIClient()
        let dataSource = WeatherDataSourceImpl(apiClient: apiClient)
        let repository = WeatherRepositoryImpl(dataSource: dataSource)
        let useCase = FetchWeatherUseCase(
            locationProvider: locationProvider,
            weatherRepository: repository
        )

        return WeatherViewModel(fetchWeather: useCase)
    }
}
