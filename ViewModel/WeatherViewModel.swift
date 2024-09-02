import CoreLocation
import Combine
import SwiftUI
import Foundation

/// ViewModel responsible for handling weather data and location updates.
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties (Input)
    
    @Published var cityName: String = ""              // The name of the city to search weather for.
    @Published var weather: WeatherResponse?          // The weather data returned from the API.
    @Published var isLoading: Bool = false            // Indicates if the weather data is being loaded.
    @Published var errorMessage: String?              // Error message to be displayed in case of an error.
    @Published var noDataFound: Bool = false          // Flag indicating if no data was found for the search.
    @Published var isOffline: Bool = false            // Flag indicating if the device is offline.

    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()  // A set to store Combine's cancellables.
    let weatherService: WeatherServiceProtocol        // Service responsible for fetching weather data.
    let locationManager: LocationManager              // Manages location-related operations.
    private let reachability = Reachability()         // Monitors the network reachability.

    // MARK: - Initialization
    
    /// Initializes the ViewModel with the required services.
    /// - Parameters:
    ///   - weatherService: A service that conforms to `WeatherServiceProtocol` for fetching weather data.
    ///   - locationManager: A `LocationManager` instance for handling location updates.
    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.locationManager = locationManager
        self.weatherService = weatherService
        loadLastSearchedCity()         // Load the last searched city, if available.
        bindLocationUpdates()          // Bind location updates to weather search.
        setupReachability()            // Setup network reachability monitoring.
    }

    // MARK: - Weather Search
    
    /// Searches for weather data based on the provided city name.
    func searchWeather() {
        guard !cityName.isEmpty else {
            self.errorMessage = "City name cannot be empty."
            return
        }
        isLoading = true
        noDataFound = false
        
        // Fetch weather data using the weather service.
        weatherService.fetchWeather(for: cityName)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    // Handle error if the fetch fails.
                    self?.errorMessage = error.localizedDescription
                    self?.noDataFound = true
                case .finished:
                    self?.saveLastSearchedCity() // Save the city name after a successful fetch.
                }
            }, receiveValue: { [weak self] weather in
                if weather.weather.isEmpty {
                    // Handle case where no weather data is found.
                    self?.noDataFound = true
                    self?.errorMessage = "No data found for the given city."
                } else {
                    // Update the weather property with the fetched data.
                    self?.weather = weather
                }
            })
            .store(in: &cancellables) // Store the cancellable to manage memory.
    }

    // MARK: - Weather Search by Location
    
    /// Initiates weather search based on the current location.
    func searchWeatherByLocation() {
        self.noDataFound = false
        let authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            // Request permission if the location authorization is not determined.
            locationManager.requestLocationPermission()
            
        case .restricted, .denied:
            // Provide feedback if location access is restricted or denied.
            self.errorMessage = "Location access is restricted or denied. Please enable location services in settings."
            
        case .authorizedWhenInUse, .authorizedAlways:
            // If authorized, request the current location.
            locationManager.requestLocation()
            
        @unknown default:
            // Handle any unexpected authorization statuses.
            self.errorMessage = "An unknown error occurred with location permissions."
        }
    }
    
    // MARK: - Location Updates Binding
    
    /// Binds location updates to the weather search functionality.
    private func bindLocationUpdates() {
        self.noDataFound = false
        
        // Listen for location updates from the location manager.
        locationManager.$location
            .compactMap { $0 } // Ensure the location is not nil.
            .sink { [weak self] coordinate in
                self?.isLoading = true
                
                // Fetch weather data based on the location's coordinates.
                self?.weatherService.fetchWeatherForLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    .sink(receiveCompletion: { completion in
                        self?.isLoading = false
                        switch completion {
                        case .failure(let error):
                            // Handle error if the fetch fails.
                            self?.errorMessage = error.localizedDescription
                            self?.noDataFound = true
                        case .finished:
                            break
                        }
                    }, receiveValue: { weather in
                        // Update the weather property and save the city name.
                        self?.weather = weather
                        self?.cityName = weather.name
                        self?.saveLastSearchedCity()
                    })
                    .store(in: &self!.cancellables) // Store the cancellable to manage memory.
            }
            .store(in: &cancellables) // Store the cancellable to manage memory.
    }

    // MARK: - User Defaults
    
    /// Saves the last searched city name to UserDefaults.
    private func saveLastSearchedCity() {
        UserDefaults.standard.setValue(cityName, forKey: "LastSearchedCity")
    }
    
    /// Loads the last searched city name from UserDefaults and performs a search.
    private func loadLastSearchedCity() {
        if let lastCity = UserDefaults.standard.string(forKey: "LastSearchedCity") {
            cityName = lastCity
            searchWeather() // Perform a weather search for the last searched city.
        }
    }
    
    // MARK: - Reachability Setup
    
    /// Sets up network reachability monitoring to handle online/offline status.
    func setupReachability() {
        reachability.startMonitoring { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .connected:
                    // When connected, clear offline status and fetch weather data if needed.
                    self?.isOffline = false
                    if self?.weather == nil && !(self?.cityName.isEmpty ?? true) {
                        self?.searchWeather()
                    }
                case .notConnected:
                    // When not connected, set offline status and show an error message.
                    self?.isOffline = true
                    self?.errorMessage = "No internet connection."
                }
            }
        }
    }
}
