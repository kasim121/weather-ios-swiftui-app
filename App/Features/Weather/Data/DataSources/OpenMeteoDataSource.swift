import Foundation

protocol WeatherDataSource {
    func fetchWeather(for coordinate: Coordinate) async throws -> OpenMeteoResponseDTO
}

enum WeatherDataSourceError: LocalizedError {
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The weather service URL is invalid."
        }
    }
}

final class OpenMeteoDataSource: WeatherDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchWeather(for coordinate: Coordinate) async throws -> OpenMeteoResponseDTO {
        var components = URLComponents(string: APIConstants.openMeteoForecastURL)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(
                name: "current",
                value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"
            ),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "forecast_days", value: "5"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components?.url else {
            throw WeatherDataSourceError.invalidURL
        }

        return try await apiClient.get(
            url,
            headers: ["Accept": "application/json"]
        )
    }
}
