import Foundation

struct OpenMeteoResponseDTO: Decodable {
    let current: CurrentDTO
    let daily: DailyDTO
    let timezone: String
}

struct CurrentDTO: Decodable {
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

struct DailyDTO: Decodable {
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
