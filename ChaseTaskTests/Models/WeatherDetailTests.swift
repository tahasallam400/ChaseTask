// WeatherDetailTests.swift

import XCTest
@testable import ChaseTask

class WeatherDetailTests: XCTestCase {
    
    func testDecodeWeatherDetail() throws {
        // Given
        let json = """
        {
            "id": 800,
            "main": "Clear",
            "description": "clear sky",
            "icon": "01d"
        }
        """.data(using: .utf8)!
        
        // When
        let weatherDetail = try JSONDecoder().decode(WeatherDetail.self, from: json)
        
        // Then
        XCTAssertEqual(weatherDetail.id, 800)
        XCTAssertEqual(weatherDetail.main, "Clear")
        XCTAssertEqual(weatherDetail.description, "clear sky")
        XCTAssertEqual(weatherDetail.icon, "01d")
    }
    
    func testWeatherDetailInitialization() {
        // Given
        let id = 800
        let main = "Clouds"
        let description = "overcast clouds"
        let icon = "04d"
        
        // When
        let weatherDetail = WeatherDetail(id: id, main: main, description: description, icon: icon)
        
        // Then
        XCTAssertEqual(weatherDetail.id, id)
        XCTAssertEqual(weatherDetail.main, main)
        XCTAssertEqual(weatherDetail.description, description)
        XCTAssertEqual(weatherDetail.icon, icon)
    }
}
