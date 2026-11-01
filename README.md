# Weather iOS App

A native SwiftUI weather app that shows current conditions and a five-day forecast for the user’s location.

## Features

- Current temperature, condition, humidity, wind, and feels-like temperature
- Five-day forecast
- Core Location permission handling
- Refresh and retry states
- Open-Meteo weather data over HTTPS

## Architecture

The app follows Clean Architecture with SOLID-oriented dependency inversion:

- `Domain`: weather models, service protocols, and the fetch-weather use case
- `Data`: Core Location and Open-Meteo implementations
- `Presentation`: SwiftUI views and an `@Observable` view model
- `MyApp.swift`: composition root and dependency injection

## Requirements

- Xcode 26 or later
- macOS 26 or later for the current project target
- Location Services enabled for the app

The project uses the Open-Meteo API and does not require an API key.
