import Foundation

struct Coordinate: Sendable {
    let latitude: Double
    let longitude: Double
}

enum WeatherCondition: String, Sendable {
    case clear
    case partlyCloudy
    case cloudy
    case fog
    case drizzle
    case rain
    case snow
    case storm
    case unknown

    var title: String {
        switch self {
        case .clear: "Clear"
        case .partlyCloudy: "Partly Cloudy"
        case .cloudy: "Cloudy"
        case .fog: "Fog"
        case .drizzle: "Drizzle"
        case .rain: "Rain"
        case .snow: "Snow"
        case .storm: "Thunderstorm"
        case .unknown: "Unknown"
        }
    }

    var symbolName: String {
        switch self {
        case .clear: "sun.max.fill"
        case .partlyCloudy: "cloud.sun.fill"
        case .cloudy: "cloud.fill"
        case .fog: "cloud.fog.fill"
        case .drizzle, .rain: "cloud.rain.fill"
        case .snow: "cloud.snow.fill"
        case .storm: "cloud.bolt.rain.fill"
        case .unknown: "questionmark.circle.fill"
        }
    }
}

struct CurrentWeather: Sendable {
    let temperatureCelsius: Double
    let feelsLikeCelsius: Double
    let humidityPercentage: Int
    let windSpeedKph: Double
    let condition: WeatherCondition
}

struct DailyForecast: Identifiable, Sendable {
    let id: String
    let dateLabel: String
    let highCelsius: Double
    let lowCelsius: Double
    let condition: WeatherCondition
}

struct WeatherSnapshot: Sendable {
    let locationName: String
    let current: CurrentWeather
    let dailyForecast: [DailyForecast]
}
