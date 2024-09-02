import SwiftUI

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: createWeatherViewModel())
        }
    }

    private func createWeatherViewModel() -> WeatherViewModel {
        let locationManager = LocationManager()
        let baseURL = "https://api.openweathermap.org/data/2.5/weather"
        let apiKey = "9e4d4728a5ebfd6b2bc1eceb7c795f22" // Replace with your actual API key
        let urlCreator = DefaultURLCreator(baseURL: baseURL, apiKey: apiKey)
        let weatherService = WeatherService(urlCreator: urlCreator)
        return WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
    }
}
