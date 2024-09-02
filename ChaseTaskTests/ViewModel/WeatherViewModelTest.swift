import XCTest
import Combine
import CoreLocation
import Foundation
@testable import ChaseTask

/// Unit tests for the WeatherViewModel class.
class WeatherViewModelTests: XCTestCase {
    
    var viewModel: WeatherViewModel!               // The WeatherViewModel instance being tested.
    var mockWeatherService: MockWeatherService!    // Mock of WeatherServiceProtocol to simulate weather data fetching.
    var mockLocationManager: MockLocationManager!  // Mock of LocationManager to simulate location-related operations.
    var cancellables: Set<AnyCancellable>!         // Set to hold any Combine cancellables.
    
    /// Setup method called before each test method in the class.
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()   // Initialize the mock weather service.
        mockLocationManager = MockLocationManager() // Initialize the mock location manager.
        viewModel = WeatherViewModel(weatherService: mockWeatherService, locationManager: mockLocationManager) // Initialize the view model with mocks.
        cancellables = []  // Initialize the cancellables set.
    }
    
    /// Teardown method called after each test method in the class.
    override func tearDown() {
        viewModel = nil  // Cleanup the view model instance.
        mockWeatherService = nil  // Cleanup the mock weather service.
        mockLocationManager = nil  // Cleanup the mock location manager.
        cancellables = nil  // Cleanup the cancellables set.
        super.tearDown()
    }
    
    /// Tests searching for weather with a valid city name.
    func testSearchWeatherWithValidCity() {
        // Given
        let city = "London"
        let expectedWeather = WeatherResponse.stub()  // Create a stubbed weather response.
        mockWeatherService.weatherResponse = expectedWeather  // Set the expected weather in the mock service.
        
        // When
        viewModel.cityName = city  // Set the city name in the view model.
        viewModel.searchWeather()  // Trigger the weather search.
        
        // Then
        let expectation = XCTestExpectation(description: "Fetch weather for valid city")
        viewModel.$weather
            .sink { weather in
                XCTAssertEqual(weather?.name, expectedWeather.name)  // Assert that the city names match.
                XCTAssertEqual(weather?.main.temp, expectedWeather.main.temp)  // Assert that the temperatures match.
                XCTAssertEqual(weather?.iconURL, expectedWeather.iconURL)  // Assert that the icon URLs match.
                expectation.fulfill()
            }
            .store(in: &cancellables)  // Store the cancellable to manage memory.
        
        wait(for: [expectation], timeout: 2.0)  // Wait for the expectation to be fulfilled.
    }
    
    /// Tests searching for weather with an invalid city name, expecting an error.
    func testSearchWeatherWithInvalidCity() {
        // Given
        let city = "UnknownCity"
        mockWeatherService.shouldReturnError = true  // Set the mock service to return an error.
        
        // When
        viewModel.cityName = city  // Set the city name in the view model.
        viewModel.searchWeather()  // Trigger the weather search.
        
        // Then
        let expectation = XCTestExpectation(description: "Handle error for invalid city")
        viewModel.$errorMessage
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)  // Assert that an error message was received.
                XCTAssertEqual(self.viewModel.noDataFound, true)  // Assert that no data was found.
                expectation.fulfill()
            }
            .store(in: &cancellables)  // Store the cancellable to manage memory.
        
        wait(for: [expectation], timeout: 2.0)  // Wait for the expectation to be fulfilled.
    }
    
    /// Tests searching for weather by location, expecting failure due to an error.
    func testSearchWeatherByLocationFailure() {
        // Given
        mockWeatherService.shouldReturnError = true  // Set the mock service to return an error.
        
        // When
        viewModel.searchWeatherByLocation()  // Trigger the weather search by location.
        
        // Then
        let expectation = XCTestExpectation(description: "Handle error for location failure")
        viewModel.$errorMessage
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage, "errorMessage should not be nil")  // Assert that an error message was received.
                expectation.fulfill()
            }
            .store(in: &cancellables)  // Store the cancellable to manage memory.
        
        wait(for: [expectation], timeout: 5.0)  // Wait for the expectation to be fulfilled.
    }
    
    /// Tests that the view model requests location permission when the authorization status is not determined.
    func testLocationPermissionNotDetermined() {
        // Given
        mockLocationManager.authorizationStatus = .notDetermined  // Set the mock location manager's authorization status to not determined.
        
        // When
        viewModel.searchWeatherByLocation()  // Trigger the weather search by location.
        
        // Then
        XCTAssertEqual(mockLocationManager.didRequestLocationPermission, true)  // Assert that location permission was requested.
    }
    
    /// Tests that the view model handles denied location permission correctly.
    func testLocationPermissionDenied() {
        // Given
        mockLocationManager.authorizationStatus = .denied  // Set the mock location manager's authorization status to denied.
        
        // When
        viewModel.searchWeatherByLocation()  // Trigger the weather search by location.
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Location access is restricted or denied. Please enable location services in settings.")  // Assert that the correct error message was set.
    }
}

// MARK: - Mock Classes

/// Mock implementation of WeatherServiceProtocol for testing purposes.
class MockWeatherService: WeatherServiceProtocol {
    var shouldReturnError = false  // Flag to indicate whether the mock should return an error.
    var weatherResponse: WeatherResponse?  // The weather response to return in the mock service.
    
    /// Mocks fetching weather data for a given city.
    /// - Parameter city: The city to fetch weather for.
    /// - Returns: A publisher that outputs the stubbed weather response or an error.
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()  // Return an error.
        } else if let weatherResponse = weatherResponse {
            return Just(weatherResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()  // Return the stubbed weather response.
        } else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()  // Handle the case where weatherResponse is nil.
        }
    }
    
    /// Mocks fetching weather data for a given location.
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    /// - Returns: A publisher that outputs the stubbed weather response or an error.
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()  // Return an error.
        } else if let weatherResponse = weatherResponse {
            return Just(weatherResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()  // Return the stubbed weather response.
        } else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()  // Handle the case where weatherResponse is nil.
        }
    }
}



/// Mock implementation of LocationManager for testing purposes.
class MockLocationManager: LocationManager {
    private var _authorizationStatus: CLAuthorizationStatus = .notDetermined  // The mock authorization status, initialized to .notDetermined.
    var didRequestLocationPermission = false  // Flag to track if location permission was requested.
    
    var _location: CLLocationCoordinate2D?  // The mock location, which can be set for testing.
    
    /// Overrides the `location` property to return the mock location.
    override var location: CLLocationCoordinate2D? {
        get {
            return _location  // Return the mock location.
        }
        set {
            _location = newValue  // Set the mock location.
        }
    }
    
    /// Overrides the `authorizationStatus` property to return and set the mock authorization status.
    override var authorizationStatus: CLAuthorizationStatus {
        get {
            return _authorizationStatus  // Return the mock authorization status.
        }
        set {
            _authorizationStatus = newValue  // Set the mock authorization status.
        }
    }
    
    /// Mocks the request for location permission.
    override func requestLocationPermission() {
        didRequestLocationPermission = true  // Indicate that location permission was requested.
        _authorizationStatus = .authorizedWhenInUse  // Simulate the user granting permission.
    }
    
    /// Mocks the request for the current location.
    override func requestLocation() {
        _location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)  // Simulate a location update to San Francisco.
        // This can trigger any mechanism used to notify the view model about the location update.
    }
}




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
