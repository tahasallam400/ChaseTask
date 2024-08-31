//
//  WeatherViewModel.swift
//  ChaseTask
//
//  Created by Taha Metwally on 31/8/2024.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    // Input
    @Published var cityName: String = ""
    
    // Output
    @Published var weather: WeatherResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let weatherService: WeatherServiceProtocol
    private let locationManager:LocationManager
    
    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.locationManager = locationManager
        self.weatherService = weatherService
        loadLastSearchedCity()
        bindLocationUpdates()
    }
    
    func searchWeather() {
        guard !cityName.isEmpty else {
            self.errorMessage = "City name cannot be empty."
            return
        }
        isLoading = true
        weatherService.fetchWeather(for: cityName)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    self?.saveLastSearchedCity()
                    break
                }
            }, receiveValue: { [weak self] weather in
                self?.weather = weather
            })
            .store(in: &cancellables)
    }
    
    func searchWeatherByLocation() {
        locationManager.requestLocation()
    }
    
    private func bindLocationUpdates() {
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
}

