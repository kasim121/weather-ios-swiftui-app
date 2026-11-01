import SwiftUI

@MainActor
struct WeatherScreen: View {
    @State private var viewModel: WeatherViewModel

    init(viewModel: WeatherViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingWeatherView()
                case .loaded(let snapshot):
                    WeatherDashboardView(snapshot: snapshot) {
                        Task { await viewModel.retry() }
                    }
                case .failed(let message):
                    WeatherErrorView(message: message) {
                        Task { await viewModel.retry() }
                    }
                }
            }
            .navigationTitle("Weather")
            .task {
                await viewModel.load()
            }
        }
    }
}
