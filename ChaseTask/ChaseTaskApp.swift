//
//  ChaseTaskApp.swift
//  ChaseTask
//
//  Created by Taha Metwally on 30/8/2024.
//

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
        let weatherService = WeatherService()
        return WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
    }
}
