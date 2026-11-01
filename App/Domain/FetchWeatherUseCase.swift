struct FetchWeatherUseCase {
    private let locationProvider: LocationProviding
    private let weatherRepository: WeatherRepository

    init(
        locationProvider: LocationProviding,
        weatherRepository: WeatherRepository
    ) {
        self.locationProvider = locationProvider
        self.weatherRepository = weatherRepository
    }

    func execute() async throws -> WeatherSnapshot {
        let coordinate = try await locationProvider.currentLocation()
        return try await weatherRepository.fetchWeather(for: coordinate)
    }
}
