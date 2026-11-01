import Foundation
import Observation

@MainActor
@Observable
final class WeatherViewModel {
    enum State {
        case idle
        case loading
        case loaded(WeatherSnapshot)
        case failed(String)
    }

    private let fetchWeather: FetchWeatherUseCase
    private(set) var state: State = .idle

    init(fetchWeather: FetchWeatherUseCase) {
        self.fetchWeather = fetchWeather
    }

    func load() async {
        guard case .idle = state else { return }
        await fetch()
    }

    func retry() async {
        await fetch()
    }

    private func fetch() async {
        state = .loading

        do {
            state = .loaded(try await fetchWeather.execute())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
