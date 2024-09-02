import XCTest
@testable import ChaseTask

/// Unit tests for the WeatherResponse struct.
class WeatherResponseTests: XCTestCase {

    /// Tests decoding a WeatherResponse from a JSON string.
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
        """.data(using: .utf8)!  // JSON string representing a typical weather API response.
        
        // When
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: json)  // Decode the JSON into a WeatherResponse object.
        
        // Then
        XCTAssertEqual(weatherResponse.name, "New York")  // Assert that the city name matches.
        XCTAssertEqual(weatherResponse.main.temp, 293.55)  // Assert that the temperature matches.
        XCTAssertEqual(weatherResponse.main.temp_min, 291.15)  // Assert that the minimum temperature matches.
        XCTAssertEqual(weatherResponse.main.temp_max, 295.37)  // Assert that the maximum temperature matches.
        XCTAssertEqual(weatherResponse.main.humidity, 53)  // Assert that the humidity matches.
        XCTAssertEqual(weatherResponse.weather.count, 1)  // Assert that there is one weather detail.
        XCTAssertEqual(weatherResponse.weather[0].main, "Clear")  // Assert that the main weather condition matches.
        XCTAssertEqual(weatherResponse.weather[0].description, "clear sky")  // Assert that the weather description matches.
        XCTAssertEqual(weatherResponse.weather[0].icon, "01d")  // Assert that the weather icon matches.
    }
    
    /// Tests the `iconURL` computed property when an icon is available.
    func testIconURL() {
        // Given
        let weatherDetail = WeatherDetail(id: 800, main: "Clear", description: "clear sky", icon: "01d")  // Create a WeatherDetail with an icon.
        let weatherResponse = WeatherResponse(name: "London", main: Main(temp: 288.15, humidity: 80, temp_min: 285.15, temp_max: 290.15), weather: [weatherDetail])  // Create a WeatherResponse with the WeatherDetail.
        
        // When
        let iconURL = weatherResponse.iconURL  // Get the icon URL from the WeatherResponse.
        
        // Then
        XCTAssertEqual(iconURL, URL(string: "https://openweathermap.org/img/wn/01d@2x.png"))  // Assert that the icon URL is correct.
    }
    
    /// Tests the `iconURL` computed property when the icon is an empty string.
    func testIconURLWhenNoIcon() {
        // Given
        let weatherDetail = WeatherDetail(id: 800, main: "Clear", description: "clear sky", icon: "")  // Create a WeatherDetail with an empty icon.
        let weatherResponse = WeatherResponse(name: "London", main: Main(temp: 288.15, humidity: 80, temp_min: 285.15, temp_max: 290.15), weather: [weatherDetail])  // Create a WeatherResponse with the WeatherDetail.
        
        // When
        let iconURL = weatherResponse.iconURL  // Get the icon URL from the WeatherResponse.
        
        // Then
        XCTAssertNil(iconURL)  // Assert that the icon URL is nil since the icon string is empty.
    }
    
    /// Tests the `iconURL` computed property when there are no weather details.
    func testIconURLWhenNoWeatherDetail() {
        // Given
        let weatherResponse = WeatherResponse(name: "London", main: Main(temp: 288.15, humidity: 80, temp_min: 285.15, temp_max: 290.15), weather: [])  // Create a WeatherResponse with no weather details.
        
        // When
        let iconURL = weatherResponse.iconURL  // Get the icon URL from the WeatherResponse.
        
        // Then
        XCTAssertNil(iconURL)  // Assert that the icon URL is nil since there are no weather details.
    }
}
