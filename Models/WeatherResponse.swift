//
//  WeatherResponse.swift
//  ChaseTask
//
//  Created by Taha Metwally on 31/8/2024.
//

import Foundation

/// Represents the response received from the weather API.
struct WeatherResponse: Codable {
    let name: String              // The name of the city or location.
    let main: Main                // The main weather information (e.g., temperature, humidity).
    let weather: [WeatherDetail]  // An array of weather details (e.g., description, icon).

    /// Computed property to generate the URL for the weather icon.
    /// - Returns: A URL for the weather icon, or nil if the icon data is unavailable.
    var iconURL: URL? {
        guard let icon = weather.first?.icon, !icon.isEmpty else { return nil }
        return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
}
