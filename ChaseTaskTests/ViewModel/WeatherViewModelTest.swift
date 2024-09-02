import XCTest
import Combine
import CoreLocation
@testable import ChaseTask

class WeatherViewModelTests: XCTestCase {
    
    var viewModel: WeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var mockLocationManager: MockLocationManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        mockLocationManager = MockLocationManager()
        viewModel = WeatherViewModel(weatherService: mockWeatherService, locationManager: mockLocationManager)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockWeatherService = nil
        mockLocationManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSearchWeatherWithValidCity() {
        // Given
        let city = "London"
        let expectedWeather = WeatherResponse.stub()
        mockWeatherService.weatherResponse = expectedWeather
        
        // When
        viewModel.cityName = city
        viewModel.searchWeather()
        
        // Then
        let expectation = XCTestExpectation(description: "Fetch weather for valid city")
        viewModel.$weather
            .sink { weather in
                XCTAssertEqual(weather?.name, expectedWeather.name)
                XCTAssertEqual(weather?.main.temp, expectedWeather.main.temp)
              
                XCTAssertEqual(weather?.iconURL, expectedWeather.iconURL)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSearchWeatherWithInvalidCity() {
        // Given
        let city = "UnknownCity"
        mockWeatherService.shouldReturnError = true
        
        // When
        viewModel.cityName = city
        viewModel.searchWeather()
        
        // Then
        let expectation = XCTestExpectation(description: "Handle error for invalid city")
        viewModel.$errorMessage
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                XCTAssertEqual(self.viewModel.noDataFound, true)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSearchWeatherByLocationSuccess() {
        // Given
        let expectedWeather = WeatherResponse.stub()
        mockWeatherService.weatherResponse = expectedWeather
        mockLocationManager.location = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        
        // When
        viewModel.searchWeatherByLocation()
        
        // Then
        let expectation = XCTestExpectation(description: "Fetch weather for location")
        viewModel.$weather
            .sink { weather in
                if weather == nil {
                    print("Weather is nil")
                } else {
                    print("Weather fetched: \(String(describing: weather?.name)), expected: \(expectedWeather.name)")
                    XCTAssertEqual(weather?.name, expectedWeather.name, "City names do not match")
                    XCTAssertEqual(weather?.main.temp, expectedWeather.main.temp, "Temperatures do not match")
                    XCTAssertEqual(weather?.iconURL, expectedWeather.iconURL, "Icon URLs do not match")
                }
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }

    
    func testSearchWeatherByLocationFailure() {
        // Given
        mockWeatherService.shouldReturnError = true
        
        // When
        viewModel.searchWeatherByLocation()
        
        // Then
        let expectation = XCTestExpectation(description: "Handle error for location failure")
        viewModel.$errorMessage
            .sink { errorMessage in
                print("Received errorMessage: \(String(describing: errorMessage))")
                XCTAssertNotNil(errorMessage, "errorMessage should not be nil")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }

    
    func testLocationPermissionNotDetermined() {
        // Given
        mockLocationManager.authorizationStatus = .notDetermined
        
        // When
        viewModel.searchWeatherByLocation()
        
        // Then
        XCTAssertEqual(mockLocationManager.didRequestLocationPermission, true)
    }
    
    func testLocationPermissionDenied() {
        // Given
        mockLocationManager.authorizationStatus = .denied
        
        // When
        viewModel.searchWeatherByLocation()
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Location access is restricted or denied. Please enable location services in settings.")
    }
    
}

// MARK: - Mock Classes

class MockWeatherService: WeatherServiceProtocol {
    var shouldReturnError = false
    var weatherResponse: WeatherResponse?
    
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        } else if let weatherResponse = weatherResponse {
            return Just(weatherResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            // Handle the case where weatherResponse is nil
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
    }
    
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        } else if let weatherResponse = weatherResponse {
            return Just(weatherResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            // Handle the case where weatherResponse is nil
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
    }
}


import CoreLocation

class MockLocationManager: LocationManager {
    private var _authorizationStatus: CLAuthorizationStatus = .notDetermined
    var didRequestLocationPermission = false
    
    var _location: CLLocationCoordinate2D?
    override var location: CLLocationCoordinate2D? {
        get {
            return _location
        }
        set {
            _location = newValue
        }
    }
    
    override var authorizationStatus: CLAuthorizationStatus {
        get {
            return _authorizationStatus
        }
        set {
            _authorizationStatus = newValue
        }
    }
    
    override func requestLocationPermission() {
        didRequestLocationPermission = true
        // Simulate permission change, e.g., to .authorizedWhenInUse
        _authorizationStatus = .authorizedWhenInUse
    }
    
    override func requestLocation() {
        // Simulate location update
        _location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        // This can trigger any mechanism you use to notify the view model about the location update
    }
}

// MockReachability.swift

import Foundation


import Foundation

// Enum to represent the network connectivity status
enum ReachabilityStatus {
    case connected
    case notConnected
}

// Base Reachability class, which might have other properties or methods
class Reachability {
    // Placeholder for any common functionality in the real Reachability class
}

// Mock version of Reachability for testing purposes
class MockReachability: Reachability {
    // Property to simulate whether the network is connected or not
    var isConnected: Bool = true
    
    // Method to simulate the start of monitoring network status
    func startMonitoring(_ statusChangeHandler: @escaping (ReachabilityStatus) -> Void) {
        DispatchQueue.main.async {
            let status: ReachabilityStatus = self.isConnected ? .connected : .notConnected
            statusChangeHandler(status)
        }
    }
    
    // Method to simulate stopping the monitoring of network status
    func stopMonitoring() {
        // Implement stop monitoring behavior if needed
    }
}
