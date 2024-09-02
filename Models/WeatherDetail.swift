//
//  WeatherDetail.swift
//  ChaseTask
//
//  Created by Taha Metwally on 31/8/2024.
//

import Foundation

/// Represents detailed weather information such as condition, description, and icon.
struct WeatherDetail: Codable {
    let id: Int             // The unique identifier for the weather condition.
    let main: String        // A short description of the weather condition (e.g., "Rain", "Clouds").
    let description: String // A more detailed description of the weather condition (e.g., "light rain", "scattered clouds").
    let icon: String        // The icon identifier for the weather condition, used to generate the icon URL.
}
