import CoreLocation
import Combine
import SwiftUI
import Foundation
import Network

class WeatherViewModel: ObservableObject {
    // Input
    @Published var cityName: String = ""
    @Published var weather: WeatherResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var noDataFound:Bool = false
    @Published var isOffline: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    let weatherService: WeatherServiceProtocol
    let locationManager: LocationManager
    private let reachability = Reachability()
    
    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.locationManager = locationManager
        self.weatherService = weatherService
        loadLastSearchedCity()
        bindLocationUpdates()
        setupReachability()
    }
    
    func searchWeather() {
        guard !cityName.isEmpty else {
            self.errorMessage = "City name cannot be empty."
            return
        }
        isLoading = true
        noDataFound = false
        weatherService.fetchWeather(for: cityName)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.noDataFound = true
                case .finished:
                    self?.saveLastSearchedCity()
                    break
                }
            }, receiveValue: { [weak self] weather in
                if weather.weather.isEmpty {
                    self?.noDataFound = true
                    self?.errorMessage = "No data found for the given city."
                } else {
                    self?.weather = weather
                }
            })
            .store(in: &cancellables)
    }
    
    func searchWeatherByLocation() {
        self.noDataFound = false
        let authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            // Request permission if not determined
            locationManager.requestLocationPermission()
            
        case .restricted, .denied:
            // Provide feedback to the user that permission is required
            self.errorMessage = "Location access is restricted or denied. Please enable location services in settings."
            
        case .authorizedWhenInUse, .authorizedAlways:
            // If authorized, request location
            locationManager.requestLocation()
            
        @unknown default:
            // Handle unexpected cases
            self.errorMessage = "An unknown error occurred with location permissions."
        }
    }
    
    private func bindLocationUpdates() {
        self.noDataFound = false
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                self?.isLoading = true
                self?.weatherService.fetchWeatherForLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    .sink(receiveCompletion: { completion in
                        self?.isLoading = false
                        switch completion {
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                            self?.noDataFound = true
                        case .finished:
                            break
                        }
                    }, receiveValue: { weather in
                        self?.weather = weather
                        self?.cityName = weather.name
                        self?.saveLastSearchedCity()
                    })
                    .store(in: &self!.cancellables)
            }
            .store(in: &cancellables)
    }
    
    private func saveLastSearchedCity() {
        UserDefaults.standard.setValue(cityName, forKey: "LastSearchedCity")
    }
    
    private func loadLastSearchedCity() {
        if let lastCity = UserDefaults.standard.string(forKey: "LastSearchedCity") {
            cityName = lastCity
            searchWeather()
        }
    }
    
    private func setupReachability() {
        reachability.startMonitoring { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .connected:
                    self?.isOffline = false
                    if self?.weather == nil && !(self?.cityName.isEmpty ?? true) {
                        self?.searchWeather()
                    }
                case .notConnected:
                    self?.isOffline = true
                    self?.errorMessage = "No internet connection."
                }
            }
        }
    }
}

class Reachability {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityMonitor")
    
    enum Status {
        case connected
        case notConnected
    }
    
    func startMonitoring(statusChangeHandler: @escaping (Status) -> Void) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                statusChangeHandler(.connected)
            } else {
                statusChangeHandler(.notConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
