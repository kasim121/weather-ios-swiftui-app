final class WeatherRepositoryImpl: WeatherRepository {
    private let dataSource: WeatherDataSource
    private let mapper: OpenMeteoMapper

    init(
        dataSource: WeatherDataSource,
        mapper: OpenMeteoMapper = OpenMeteoMapper()
    ) {
        self.dataSource = dataSource
        self.mapper = mapper
    }

    func fetchWeather(for coordinate: Coordinate) async throws -> WeatherSnapshot {
        let response = try await dataSource.fetchWeather(for: coordinate)
        return mapper.map(response)
    }
}
