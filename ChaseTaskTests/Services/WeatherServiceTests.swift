//
//  WeatherServiceTests.swift
//  ChaseTaskTests
//
//  Created by Taha Metwally on 31/8/2024.
//

import XCTest
import Combine
import Foundation

@testable import ChaseTask

/// Unit tests for the WeatherService class.
class WeatherServiceTests: XCTestCase {
    
    var weatherService: WeatherService!     // The WeatherService instance being tested.
    var mockURLSession: MockURLSession!     // Mock of URLSessionProtocol to simulate network requests.
    var mockURLCreator: MockURLCreator!     // Mock of URLCreatorProtocol to simulate URL creation.
    var cancellables: Set<AnyCancellable>!  // Set to hold any Combine cancellables.
    
    /// Setup method called before each test method in the class.
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()  // Initialize the mock URL session.
        mockURLCreator = MockURLCreator()  // Initialize the mock URL creator.
        weatherService = WeatherService(urlSession: mockURLSession, urlCreator: mockURLCreator)  // Initialize the weather service with mocks.
        cancellables = []  // Initialize the cancellables set.
    }
    
    /// Teardown method called after each test method in the class.
    override func tearDown() {
        weatherService = nil  // Cleanup the weather service instance.
        mockURLSession = nil  // Cleanup the mock URL session.
        mockURLCreator = nil  // Cleanup the mock URL creator.
        cancellables = nil  // Cleanup the cancellables set.
        super.tearDown()
    }
    
    /// Tests successful fetching of weather data for a city.
    func testFetchWeatherForCity_Success() {
        // Given
        let city = "London"
        let expectedWeather = WeatherResponse.stub()  // Create a stubbed weather response.
        mockURLCreator.stubbedURL = URL(string: "https://api.weather.com")  // Stub the URL creation.
        mockURLSession.stubbedResult = .success((data: try! JSONEncoder().encode(expectedWeather), response: URLResponse()))  // Stub the successful network response.
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for city")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeather(for: city)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error  // Capture any error received.
                }
                expectation.fulfill()  // Fulfill the expectation once the request completes.
            }, receiveValue: { weather in
                receivedWeather = weather  // Capture the weather data received.
            })
            .store(in: &cancellables)  // Store the cancellable to manage memory.
        
        // Then
        wait(for: [expectation], timeout: 5.0)  // Wait for the expectation to be fulfilled.
        XCTAssertNotNil(receivedWeather)  // Assert that weather data was received.
        XCTAssertNil(receivedError)  // Assert that no error was received.
        
        // Verify the received weather data matches the expected data.
        XCTAssertEqual(receivedWeather?.iconURL, expectedWeather.iconURL)
        XCTAssertEqual(receivedWeather?.name, expectedWeather.name)
        XCTAssertEqual(receivedWeather?.main.humidity, expectedWeather.main.humidity)
        XCTAssertEqual(receivedWeather?.main.temp, expectedWeather.main.temp)
        XCTAssertEqual(receivedWeather?.main.temp_max, expectedWeather.main.temp_max)
        XCTAssertEqual(receivedWeather?.main.temp_min, expectedWeather.main.temp_min)
        XCTAssertEqual(receivedWeather?.weather.count, expectedWeather.weather.count)
    }
    
    /// Tests failure when fetching weather data for a city with an invalid URL.
    func testFetchWeatherForCity_Failure() {
        // Given
        let city = "UnknownCity"
        let expectedError = URLError(.badURL)  // Expected error for an invalid URL.
        mockURLCreator.stubbedURL = nil  // Stub the URL creation to return nil.
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for city failure")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeather(for: city)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error  // Capture any error received.
                }
                expectation.fulfill()  // Fulfill the expectation once the request completes.
            }, receiveValue: { weather in
                receivedWeather = weather  // Capture the weather data received.
            })
            .store(in: &cancellables)  // Store the cancellable to manage memory.
        
        // Then
        wait(for: [expectation], timeout: 5.0)  // Wait for the expectation to be fulfilled.
        XCTAssertNil(receivedWeather)  // Assert that no weather data was received.
        XCTAssertNotNil(receivedError)  // Assert that an error was received.
        XCTAssertEqual(receivedError as? URLError, expectedError)  // Verify the received error matches the expected error.
    }
    
    /// Tests successful fetching of weather data for a specific location.
    func testFetchWeatherForLocation_Success() {
        // Given
        let latitude = 51.5074
        let longitude = -0.1278
        let expectedWeather = WeatherResponse.stub()  // Create a stubbed weather response.
        mockURLCreator.stubbedURL = URL(string: "https://api.weather.com")  // Stub the URL creation.
        mockURLSession.stubbedResult = .success((data: try! JSONEncoder().encode(expectedWeather), response: URLResponse()))  // Stub the successful network response.
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for location")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeatherForLocation(latitude: latitude, longitude: longitude)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error  // Capture any error received.
                }
                expectation.fulfill()  // Fulfill the expectation once the request completes.
            }, receiveValue: { weather in
                receivedWeather = weather  // Capture the weather data received.
            })
            .store(in: &cancellables)  // Store the cancellable to manage memory.
        
        // Then
        wait(for: [expectation], timeout: 5.0)  // Wait for the expectation to be fulfilled.
        XCTAssertNotNil(receivedWeather)  // Assert that weather data was received.
        XCTAssertNil(receivedError)  // Assert that no error was received.
        
        // Verify the received weather data matches the expected data.
        XCTAssertEqual(receivedWeather?.iconURL, expectedWeather.iconURL)
        XCTAssertEqual(receivedWeather?.name, expectedWeather.name)
        XCTAssertEqual(receivedWeather?.main.humidity, expectedWeather.main.humidity)
        XCTAssertEqual(receivedWeather?.main.temp, expectedWeather.main.temp)
        XCTAssertEqual(receivedWeather?.main.temp_max, expectedWeather.main.temp_max)
        XCTAssertEqual(receivedWeather?.main.temp_min, expectedWeather.main.temp_min)
        XCTAssertEqual(receivedWeather?.weather.count, expectedWeather.weather.count)
    }
    
    /// Tests failure when fetching weather data for a location with an invalid URL.
    func testFetchWeatherForLocation_Failure() {
        // Given
        let latitude = 0.0
        let longitude = 0.0
        let expectedError = URLError(.badURL)  // Expected error for an invalid URL.
        mockURLCreator.stubbedURL = nil  // Stub the URL creation to return nil.
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for location failure")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeatherForLocation(latitude: latitude, longitude: longitude)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error  // Capture any error received.
                }
                expectation.fulfill()  // Fulfill the expectation once the request completes.
            }, receiveValue: { weather in
                receivedWeather = weather  // Capture the weather data received.
            })
            .store(in: &cancellables)  // Store the cancellable to manage memory.
        
        // Then
        wait(for: [expectation], timeout: 5.0)  // Wait for the expectation to be fulfilled.
        XCTAssertNil(receivedWeather)  // Assert that no weather data was received.
        XCTAssertNotNil(receivedError)  // Assert that an error was received.
        XCTAssertEqual(receivedError as? URLError, expectedError)  // Verify the received error matches the expected error.
    }
}
// Define a protocol that your mock will conform to

/// A mock implementation of URLSessionProtocol for testing purposes.
class MockURLSession: URLSessionProtocol {
    var stubbedResult: Result<(data: Data, response: URLResponse), URLError>?  // The result to return when a data task is requested.

    /// Mocks the data task publisher for a given URL.
    /// - Parameter url: The URL to create the data task for.
    /// - Returns: A publisher that outputs the stubbed result or an error.
    func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        // Ensure the stubbed result is set before using the mock.
        guard let result = stubbedResult else {
            fatalError("Stub result not set!")
        }

        // Return the appropriate publisher based on the stubbed result.
        switch result {
        case .success(let (data, response)):
            return Just((data: data, response: response))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()  // Return a successful result.
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()  // Return a failure with the given error.
        }
    }
}

/// A mock implementation of URLCreatorProtocol for testing purposes.
class MockURLCreator: URLCreatorProtocol {
    var stubbedURL: URL?  // The URL to return when making a URL with query parameters.
    
    /// Mocks the creation of a URL based on the given query parameters.
    /// - Parameter query: A dictionary of query parameters.
    /// - Returns: The stubbed URL or nil if not set.
    func makeURL(query: [String : String]) -> URL? {
        return stubbedURL  // Return the stubbed URL.
    }
}

// MARK: - Stub Data

/// Extension to provide stub data for WeatherResponse.
extension WeatherResponse {
    /// Creates a stubbed instance of `WeatherResponse` for testing purposes.
    /// - Returns: A `WeatherResponse` object with predefined data.
    static func stub() -> WeatherResponse {
        return WeatherResponse(
            name: "London",  // The name of the city in the stubbed response.
            main: Main(temp: 20.0, humidity: 65, temp_min: 18.0, temp_max: 22.0),  // Stubbed main weather data.
            weather: [
                WeatherDetail(id: 800, main: "Clear", description: "Clear sky", icon: "01d")  // Stubbed weather detail.
            ]
        )
    }
}
