import Foundation
import Combine

// MARK: - Weather Service Protocol

/// Protocol defining the interface for a weather service.
protocol WeatherServiceProtocol {
    /// Fetches weather data for a given city.
    /// - Parameter city: The name of the city to fetch weather data for.
    /// - Returns: A publisher that outputs a `WeatherResponse` or an error.
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error>
    
    /// Fetches weather data for a given location (latitude and longitude).
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    /// - Returns: A publisher that outputs a `WeatherResponse` or an error.
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error>
}

/// Protocol defining an interface for a URLSession to be used in network requests.
protocol URLSessionProtocol {
    /// Creates a data task publisher for the given URL.
    /// - Parameter url: The URL to create a data task for.
    /// - Returns: A publisher that outputs a tuple containing the data and the response, or a URLError.
    func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

/// Protocol defining an interface for creating URLs based on query parameters.
protocol URLCreatorProtocol {
    /// Creates a URL based on the given query parameters.
    /// - Parameter query: A dictionary containing query parameters.
    /// - Returns: An optional URL constructed from the base URL and query parameters.
    func makeURL(query: [String: String]) -> URL?
}

// MARK: - URLSessionWrapper

/// A wrapper class around URLSession to conform to `URLSessionProtocol`.
class URLSessionWrapper: URLSessionProtocol {
    private let session: URLSession
    
    /// Initializes the wrapper with a URLSession instance.
    /// - Parameter session: The URLSession instance to use. Defaults to the shared session.
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Creates a data task publisher for the given URL.
    /// - Parameter url: The URL to create a data task for.
    /// - Returns: A publisher that outputs a tuple containing the data and the response, or a URLError.
    func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return session.dataTaskPublisher(for: url)
            .eraseToAnyPublisher()
    }
}

// MARK: - DefaultURLCreator

/// A default implementation of `URLCreatorProtocol` that creates URLs for weather API requests.
class DefaultURLCreator: URLCreatorProtocol {
    private let baseURL: String
    private let apiKey: String
    
    /// Initializes the URL creator with a base URL and API key.
    /// - Parameters:
    ///   - baseURL: The base URL of the weather API.
    ///   - apiKey: The API key required for authentication.
    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    /// Creates a URL based on the given query parameters.
    /// - Parameter query: A dictionary containing query parameters.
    /// - Returns: An optional URL constructed from the base URL and query parameters.
    func makeURL(query: [String: String]) -> URL? {
        var components = URLComponents(string: baseURL)
        var queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Append the API key and units to the query items.
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        queryItems.append(URLQueryItem(name: "units", value: "metric"))
        components?.queryItems = queryItems
        
        return components?.url
    }
}

// MARK: - WeatherService

/// A concrete implementation of `WeatherServiceProtocol` that fetches weather data.
class WeatherService: WeatherServiceProtocol {
    private let urlSession: URLSessionProtocol
    private let urlCreator: URLCreatorProtocol
    
    /// Initializes the weather service with a URLSession and URLCreator.
    /// - Parameters:
    ///   - urlSession: An instance conforming to `URLSessionProtocol` for making network requests.
    ///   - urlCreator: An instance conforming to `URLCreatorProtocol` for creating URLs.
    init(urlSession: URLSessionProtocol = URLSessionWrapper(), urlCreator: URLCreatorProtocol) {
        self.urlSession = urlSession
        self.urlCreator = urlCreator
    }
    
    /// Fetches weather data for a given city.
    /// - Parameter city: The name of the city to fetch weather data for.
    /// - Returns: A publisher that outputs a `WeatherResponse` or an error.
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error> {
        guard let url = urlCreator.makeURL(query: ["q": city]) else {
            // Return a failed publisher if the URL is invalid.
            return Fail(error: URLError(.badURL))
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        return fetch(url: url)
    }
    
    /// Fetches weather data for a given location (latitude and longitude).
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    /// - Returns: A publisher that outputs a `WeatherResponse` or an error.
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error> {
        let query = [
            "lat": "\(latitude)",
            "lon": "\(longitude)"
        ]
        guard let url = urlCreator.makeURL(query: query) else {
            // Return a failed publisher if the URL is invalid.
            return Fail(error: URLError(.badURL))
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        return fetch(url: url)
    }
    
    /// Fetches weather data from a given URL.
    /// - Parameter url: The URL to fetch weather data from.
    /// - Returns: A publisher that outputs a `WeatherResponse` or an error.
    private func fetch(url: URL) -> AnyPublisher<WeatherResponse, Error> {
        return urlSession.dataTaskPublisher(for: url)
            .map { $0.data } // Extract the data from the response.
            .decode(type: WeatherResponse.self, decoder: JSONDecoder()) // Decode the data into a `WeatherResponse` object.
            .receive(on: DispatchQueue.main) // Ensure the result is received on the main thread.
            .mapError { $0 as Error } // Map any errors to a generic error type.
            .eraseToAnyPublisher() // Erase the type to `AnyPublisher`.
    }
}
