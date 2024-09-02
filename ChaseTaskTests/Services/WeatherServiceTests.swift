import XCTest
import Combine
@testable import ChaseTask

class WeatherServiceTests: XCTestCase {
    
    var weatherService: WeatherService!
    var mockURLSession: MockURLSession!
    var mockURLCreator: MockURLCreator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        mockURLCreator = MockURLCreator()
        weatherService = WeatherService(urlSession: mockURLSession, urlCreator: mockURLCreator)
        cancellables = []
    }
    
    override func tearDown() {
        weatherService = nil
        mockURLSession = nil
        mockURLCreator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchWeatherForCity_Success() {
        // Given
        let city = "London"
        let expectedWeather = WeatherResponse.stub()
        mockURLCreator.stubbedURL = URL(string: "https://api.weather.com")
        mockURLSession.stubbedResult = .success((data: try! JSONEncoder().encode(expectedWeather), response: URLResponse()))
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for city")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeather(for: city)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { weather in
                receivedWeather = weather
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(receivedWeather)
        XCTAssertNil(receivedError)
        
        XCTAssertEqual(receivedWeather?.iconURL, expectedWeather.iconURL)
        XCTAssertEqual(receivedWeather?.name, expectedWeather.name)
        XCTAssertEqual(receivedWeather?.main.humidity, expectedWeather.main.humidity)
        XCTAssertEqual(receivedWeather?.main.temp, expectedWeather.main.temp)
        XCTAssertEqual(receivedWeather?.main.temp_max, expectedWeather.main.temp_max)
        XCTAssertEqual(receivedWeather?.main.temp_min, expectedWeather.main.temp_min)
        XCTAssertEqual(receivedWeather?.weather.count, expectedWeather.weather.count)
    }
    
    func testFetchWeatherForCity_Failure() {
        // Given
        let city = "UnknownCity"
        let expectedError = URLError(.badURL)
        mockURLCreator.stubbedURL = nil
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for city failure")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeather(for: city)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { weather in
                receivedWeather = weather
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNil(receivedWeather)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError as? URLError, expectedError)
    }
    
    func testFetchWeatherForLocation_Success() {
        // Given
        let latitude = 51.5074
        let longitude = -0.1278
        let expectedWeather = WeatherResponse.stub()
        mockURLCreator.stubbedURL = URL(string: "https://api.weather.com")
        mockURLSession.stubbedResult = .success((data: try! JSONEncoder().encode(expectedWeather), response: URLResponse()))
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for location")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeatherForLocation(latitude: latitude, longitude: longitude)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { weather in
                receivedWeather = weather
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(receivedWeather)
        XCTAssertNil(receivedError)
        
        
        XCTAssertEqual(receivedWeather?.iconURL, expectedWeather.iconURL)
        XCTAssertEqual(receivedWeather?.name, expectedWeather.name)
        XCTAssertEqual(receivedWeather?.main.humidity, expectedWeather.main.humidity)
        XCTAssertEqual(receivedWeather?.main.temp, expectedWeather.main.temp)
        XCTAssertEqual(receivedWeather?.main.temp_max, expectedWeather.main.temp_max)
        XCTAssertEqual(receivedWeather?.main.temp_min, expectedWeather.main.temp_min)
        XCTAssertEqual(receivedWeather?.weather.count, expectedWeather.weather.count)
    }
    
    func testFetchWeatherForLocation_Failure() {
        // Given
        let latitude = 0.0
        let longitude = 0.0
        let expectedError = URLError(.badURL)
        mockURLCreator.stubbedURL = nil
        
        // When
        let expectation = XCTestExpectation(description: "Fetch weather for location failure")
        var receivedWeather: WeatherResponse?
        var receivedError: Error?
        
        weatherService.fetchWeatherForLocation(latitude: latitude, longitude: longitude)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { weather in
                receivedWeather = weather
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNil(receivedWeather)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError as? URLError, expectedError)
    }
}

// MARK: - Mock Classes

import Combine
import Foundation

import Combine
import Foundation

// Define a protocol that your mock will conform to

class MockURLSession: URLSessionProtocol {
    var stubbedResult: Result<(data: Data, response: URLResponse), URLError>?

    func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        guard let result = stubbedResult else {
            fatalError("Stub result not set!")
        }

        switch result {
        case .success(let (data, response)):
            return Just((data: data, response: response))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

class MockURLCreator: URLCreatorProtocol {
    var stubbedURL: URL?
    
    func makeURL(query: [String : String]) -> URL? {
        return stubbedURL
    }
}

// MARK: - Stub Data

extension WeatherResponse {
    static func stub() -> WeatherResponse {
        return WeatherResponse(
            name: "London",
            main: Main(temp: 20.0, humidity: 65, temp_min: 18.0, temp_max: 22.0),
            weather: [
                WeatherDetail(id: 800, main: "Clear", description: "Clear sky", icon: "01d")
            ]
        )
    }
}

