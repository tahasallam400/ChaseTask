import XCTest
@testable import ChaseTask

class WeatherResponseTests: XCTestCase {

    func testDecodeWeatherResponse() throws {
        // Given
        let json = """
        {
            "name": "New York",
            "main": {
                "temp": 293.55,
                "temp_min": 291.15,
                "temp_max": 295.37,
                "humidity": 53
            },
            "weather": [
                {
                    "id": 800,
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                }
            ]
        }
        """.data(using: .utf8)!
        
        // When
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: json)
        
        // Then
        XCTAssertEqual(weatherResponse.name, "New York")
        XCTAssertEqual(weatherResponse.main.temp, 293.55)
        XCTAssertEqual(weatherResponse.main.temp_min, 291.15)
        XCTAssertEqual(weatherResponse.main.temp_max, 295.37)
        XCTAssertEqual(weatherResponse.main.humidity, 53)
        XCTAssertEqual(weatherResponse.weather.count, 1)
        XCTAssertEqual(weatherResponse.weather[0].main, "Clear")
        XCTAssertEqual(weatherResponse.weather[0].description, "clear sky")
        XCTAssertEqual(weatherResponse.weather[0].icon, "01d")
    }
    
    func testIconURL() {
        // Given
        let weatherDetail = WeatherDetail(id: 800, main: "Clear", description: "clear sky", icon: "01d")
        let weatherResponse = WeatherResponse(name: "London", main: Main(temp: 288.15, humidity: 80, temp_min: 285.15, temp_max: 290.15), weather: [weatherDetail])
        
        // When
        let iconURL = weatherResponse.iconURL
        
        // Then
        XCTAssertEqual(iconURL, URL(string: "https://openweathermap.org/img/wn/01d@2x.png"))
    }
    
    func testIconURLWhenNoIcon() {
        // Given
        let weatherDetail = WeatherDetail(id: 800, main: "Clear", description: "clear sky", icon: "")
        let weatherResponse = WeatherResponse(name: "London", main: Main(temp: 288.15, humidity: 80, temp_min: 285.15, temp_max: 290.15), weather: [weatherDetail])
        
        // When
        let iconURL = weatherResponse.iconURL
        
        // Then
        XCTAssertNil(iconURL)
    }
    
    func testIconURLWhenNoWeatherDetail() {
        // Given
        let weatherResponse = WeatherResponse(name: "London", main: Main(temp: 288.15, humidity: 80, temp_min: 285.15, temp_max: 290.15), weather: [])
        
        // When
        let iconURL = weatherResponse.iconURL
        
        // Then
        XCTAssertNil(iconURL)
    }
}
