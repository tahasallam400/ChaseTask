// WeatherDetailTests.swift

import XCTest
@testable import ChaseTask

/// Unit tests for the WeatherDetail struct.
class WeatherDetailTests: XCTestCase {
    
    /// Tests decoding a WeatherDetail object from a JSON string.
    func testDecodeWeatherDetail() throws {
        // Given
        let json = """
        {
            "id": 800,
            "main": "Clear",
            "description": "clear sky",
            "icon": "01d"
        }
        """.data(using: .utf8)!  // JSON string representing the weather detail data.
        
        // When
        let weatherDetail = try JSONDecoder().decode(WeatherDetail.self, from: json)  // Decode the JSON into a WeatherDetail object.
        
        // Then
        XCTAssertEqual(weatherDetail.id, 800)  // Assert that the weather condition ID matches the expected value.
        XCTAssertEqual(weatherDetail.main, "Clear")  // Assert that the main weather description matches the expected value.
        XCTAssertEqual(weatherDetail.description, "clear sky")  // Assert that the detailed weather description matches the expected value.
        XCTAssertEqual(weatherDetail.icon, "01d")  // Assert that the weather icon code matches the expected value.
    }
    
    /// Tests the initialization of a WeatherDetail object with given values.
    func testWeatherDetailInitialization() {
        // Given
        let id = 800  // Expected weather condition ID.
        let main = "Clouds"  // Expected main weather description.
        let description = "overcast clouds"  // Expected detailed weather description.
        let icon = "04d"  // Expected weather icon code.
        
        // When
        let weatherDetail = WeatherDetail(id: id, main: main, description: description, icon: icon)  // Initialize a WeatherDetail object with the given values.
        
        // Then
        XCTAssertEqual(weatherDetail.id, id)  // Assert that the weather condition ID matches the expected value.
        XCTAssertEqual(weatherDetail.main, main)  // Assert that the main weather description matches the expected value.
        XCTAssertEqual(weatherDetail.description, description)  // Assert that the detailed weather description matches the expected value.
        XCTAssertEqual(weatherDetail.icon, icon)  // Assert that the weather icon code matches the expected value.
    }
}
