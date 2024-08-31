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
            let locationManager = LocationManager()
            let weatherService = WeatherService()
            let weatherViewModel = WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
            ContentView(viewModel: weatherViewModel)
        }
    }
}
