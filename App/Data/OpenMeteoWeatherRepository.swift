import Foundation

enum WeatherRepositoryError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The weather service URL is invalid."
        case .invalidResponse:
            "The weather service returned an unexpected response."
        case .decodingFailed:
            "The weather data could not be read."
        }
    }
}

final class OpenMeteoWeatherRepository: WeatherRepository {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchWeather(for coordinate: Coordinate) async throws -> WeatherSnapshot {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
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
            throw WeatherRepositoryError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw WeatherRepositoryError.invalidResponse
        }

        do {
            return try decoder.decode(OpenMeteoResponse.self, from: data).snapshot
        } catch {
            throw WeatherRepositoryError.decodingFailed
        }
    }
}

private struct OpenMeteoResponse: Decodable {
    let current: CurrentPayload
    let daily: DailyPayload
    let timezone: String

    var snapshot: WeatherSnapshot {
        let forecasts = zip(
            daily.time,
            zip(daily.temperatureMax, zip(daily.temperatureMin, daily.weatherCode))
        ).map { date, values in
            DailyForecast(
                id: date,
                dateLabel: formatDate(date),
                highCelsius: values.0,
                lowCelsius: values.1.0,
                condition: WeatherCondition(code: values.1.1)
            )
        }

        return WeatherSnapshot(
            locationName: timezone.replacingOccurrences(of: "_", with: " "),
            current: CurrentWeather(
                temperatureCelsius: current.temperature,
                feelsLikeCelsius: current.apparentTemperature,
                humidityPercentage: current.humidity,
                windSpeedKph: current.windSpeed,
                condition: WeatherCondition(code: current.weatherCode)
            ),
            dailyForecast: forecasts
        )
    }

    private func formatDate(_ value: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: value + "T00:00:00Z") else {
            return value
        }

        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}

private struct CurrentPayload: Decodable {
    let temperature: Double
    let humidity: Int
    let apparentTemperature: Double
    let weatherCode: Int
    let windSpeed: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case humidity = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case weatherCode = "weather_code"
        case windSpeed = "wind_speed_10m"
    }
}

private struct DailyPayload: Decodable {
    let time: [String]
    let weatherCode: [Int]
    let temperatureMax: [Double]
    let temperatureMin: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
    }
}

private extension WeatherCondition {
    init(code: Int) {
        switch code {
        case 0: self = .clear
        case 1: self = .partlyCloudy
        case 2...3: self = .cloudy
        case 45, 48: self = .fog
        case 51...57: self = .drizzle
        case 61...67, 80...82: self = .rain
        case 71...77, 85...86: self = .snow
        case 95...99: self = .storm
        default: self = .unknown
        }
    }
}
