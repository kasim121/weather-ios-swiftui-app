protocol WeatherRepository {
    func fetchWeather(for coordinate: Coordinate) async throws -> WeatherSnapshot
}
