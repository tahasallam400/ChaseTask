//
//  WeatherResponse.swift
//  ChaseTask
//
//  Created by Taha Metwally on 31/8/2024.
//

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let main: Main
    let weather: [WeatherDetail]
    
    var iconURL: URL? {
        guard let icon = weather.first?.icon, !icon.isEmpty else { return nil }
        return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
}
