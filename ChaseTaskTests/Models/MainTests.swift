// MainTests.swift

import XCTest
@testable import ChaseTask

class MainTests: XCTestCase {
    
    func testDecodeMain() throws {
        // Given
        let json = """
        {
            "temp": 293.55,
            "humidity": 53,
            "temp_min": 291.15,
            "temp_max": 295.37
        }
        """.data(using: .utf8)!
        
        // When
        let main = try JSONDecoder().decode(Main.self, from: json)
        
        // Then
        XCTAssertEqual(main.temp, 293.55)
        XCTAssertEqual(main.humidity, 53)
        XCTAssertEqual(main.temp_min, 291.15)
        XCTAssertEqual(main.temp_max, 295.37)
    }
    
    func testMainInitialization() {
        // Given
        let temp = 288.15
        let humidity = 80
        let temp_min = 285.15
        let temp_max = 290.15
        
        // When
        let main = Main(temp: temp, humidity: humidity, temp_min: temp_min, temp_max: temp_max)
        
        // Then
        XCTAssertEqual(main.temp, temp)
        XCTAssertEqual(main.humidity, humidity)
        XCTAssertEqual(main.temp_min, temp_min)
        XCTAssertEqual(main.temp_max, temp_max)
    }
}
