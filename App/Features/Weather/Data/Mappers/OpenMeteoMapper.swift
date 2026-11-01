import Foundation

struct OpenMeteoMapper {
    func map(_ response: OpenMeteoResponseDTO) -> WeatherSnapshot {
        let forecasts = zip(
            response.daily.time,
            zip(
                response.daily.temperatureMax,
                zip(response.daily.temperatureMin, response.daily.weatherCode)
            )
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
            locationName: response.timezone.replacingOccurrences(of: "_", with: " "),
            current: CurrentWeather(
                temperatureCelsius: response.current.temperature,
                feelsLikeCelsius: response.current.apparentTemperature,
                humidityPercentage: response.current.humidity,
                windSpeedKph: response.current.windSpeed,
                condition: WeatherCondition(code: response.current.weatherCode)
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
