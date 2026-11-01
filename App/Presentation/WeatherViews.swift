import SwiftUI

@MainActor
struct ContentView: View {
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

struct LoadingWeatherView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Loading Weather", systemImage: "cloud.sun.fill")
        } description: {
            Text("Getting your local forecast…")
        }
    }
}

struct WeatherErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Weather Unavailable", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct WeatherDashboardView: View {
    let snapshot: WeatherSnapshot
    let refresh: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CurrentWeatherCard(snapshot: snapshot)
                ForecastSection(forecast: snapshot.dailyForecast)
            }
            .padding()
        }
        .refreshable {
            refresh()
        }
        .background(Color.secondary.opacity(0.08))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Refresh", systemImage: "arrow.clockwise", action: refresh)
                    .labelStyle(.iconOnly)
            }
        }
    }
}

struct CurrentWeatherCard: View {
    let snapshot: WeatherSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.locationName)
                        .font(.headline)
                    Text("Current conditions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: snapshot.current.condition.symbolName)
                    .font(.system(size: 42))
                    .symbolRenderingMode(.multicolor)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(snapshot.current.temperatureCelsius, format: .number.precision(.fractionLength(0)))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Text("°C")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Text(snapshot.current.condition.title)
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                WeatherMetric(
                    title: "Feels like",
                    value: "\(Int(snapshot.current.feelsLikeCelsius.rounded()))°"
                )
                WeatherMetric(
                    title: "Humidity",
                    value: "\(snapshot.current.humidityPercentage)%"
                )
                WeatherMetric(
                    title: "Wind",
                    value: "\(Int(snapshot.current.windSpeedKph.rounded())) km/h"
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .blue.opacity(0.2), radius: 12, y: 6)
    }
}

struct WeatherMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
            Text(value)
                .font(.headline)
        }
    }
}

struct ForecastSection: View {
    let forecast: [DailyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.title3)
                .fontWeight(.bold)

            ForEach(forecast) { day in
                ForecastRow(forecast: day)
            }
        }
    }
}

struct ForecastRow: View {
    let forecast: DailyForecast

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: forecast.condition.symbolName)
                .frame(width: 28)
                .foregroundStyle(.blue)

            Text(forecast.dateLabel)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(Int(forecast.highCelsius.rounded()))°")
                .fontWeight(.semibold)

            Text("\(Int(forecast.lowCelsius.rounded()))°")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
