protocol LocationProviding {
    func currentLocation() async throws -> Coordinate
}

protocol WeatherRepository {
    func fetchWeather(for coordinate: Coordinate) async throws -> WeatherSnapshot
}
