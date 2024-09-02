import SwiftUI

@main
struct WeatherApp: App {
    // The body property defines the content and behavior of the app's main scene.
    var body: some Scene {
        WindowGroup {
            // The main view of the app, initialized with a WeatherViewModel.
            ContentView(viewModel: createWeatherViewModel())
        }
    }

    // A helper function to create and configure a WeatherViewModel instance.
    private func createWeatherViewModel() -> WeatherViewModel {
        // Initialize the location manager to handle location-related tasks.
        let locationManager = LocationManager()
        
        // Define the base URL for the weather API.
        let baseURL = "https://api.openweathermap.org/data/2.5/weather"
        
        // Define the API key for accessing the weather service.
        let apiKey = "9e4d4728a5ebfd6b2bc1eceb7c795f22" // Replace with your actual API key
        
        // Create a URL creator instance using the base URL and API key.
        let urlCreator = DefaultURLCreator(baseURL: baseURL, apiKey: apiKey)
        
        // Initialize the weather service with the URL creator.
        let weatherService = WeatherService(urlCreator: urlCreator)
        
        // Return a WeatherViewModel instance initialized with the weather service and location manager.
        return WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
    }
}
