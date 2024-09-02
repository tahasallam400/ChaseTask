//
//  Main.swift
//  ChaseTask
//
//  Created by Taha Metwally on 31/8/2024.
//

import Foundation

/// Represents the main weather data, including temperature and humidity.
struct Main: Codable {
    let temp: Double        // The current temperature in degrees Celsius.
    let humidity: Int       // The current humidity percentage.
    let temp_min: Double    // The minimum temperature recorded during the day in degrees Celsius.
    let temp_max: Double    // The maximum temperature recorded during the day in degrees Celsius.
}
