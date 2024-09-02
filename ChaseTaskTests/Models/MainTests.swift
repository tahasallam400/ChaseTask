// MainTests.swift

import XCTest
@testable import ChaseTask

/// Unit tests for the Main struct.
class MainTests: XCTestCase {
    
    /// Tests decoding a Main object from a JSON string.
    func testDecodeMain() throws {
        // Given
        let json = """
        {
            "temp": 293.55,
            "humidity": 53,
            "temp_min": 291.15,
            "temp_max": 295.37
        }
        """.data(using: .utf8)!  // JSON string representing the main weather data.
        
        // When
        let main = try JSONDecoder().decode(Main.self, from: json)  // Decode the JSON into a Main object.
        
        // Then
        XCTAssertEqual(main.temp, 293.55)  // Assert that the temperature matches the expected value.
        XCTAssertEqual(main.humidity, 53)  // Assert that the humidity matches the expected value.
        XCTAssertEqual(main.temp_min, 291.15)  // Assert that the minimum temperature matches the expected value.
        XCTAssertEqual(main.temp_max, 295.37)  // Assert that the maximum temperature matches the expected value.
    }
    
    /// Tests the initialization of a Main object with given values.
    func testMainInitialization() {
        // Given
        let temp = 288.15  // Expected temperature value.
        let humidity = 80  // Expected humidity value.
        let temp_min = 285.15  // Expected minimum temperature value.
        let temp_max = 290.15  // Expected maximum temperature value.
        
        // When
        let main = Main(temp: temp, humidity: humidity, temp_min: temp_min, temp_max: temp_max)  // Initialize a Main object with the given values.
        
        // Then
        XCTAssertEqual(main.temp, temp)  // Assert that the temperature matches the expected value.
        XCTAssertEqual(main.humidity, humidity)  // Assert that the humidity matches the expected value.
        XCTAssertEqual(main.temp_min, temp_min)  // Assert that the minimum temperature matches the expected value.
        XCTAssertEqual(main.temp_max, temp_max)  // Assert that the maximum temperature matches the expected value.
    }
}
