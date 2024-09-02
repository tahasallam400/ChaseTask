import Foundation
import Combine

// MARK: - Weather Service Protocol

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error>
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error>
}

protocol URLSessionProtocol {
    func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

protocol URLCreatorProtocol {
    func makeURL(query: [String: String]) -> URL?
}

// Wrapper class around URLSession to conform to URLSessionProtocol
class URLSessionWrapper: URLSessionProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return session.dataTaskPublisher(for: url)
            .eraseToAnyPublisher()
    }
}

class DefaultURLCreator: URLCreatorProtocol {
    private let baseURL: String
    private let apiKey: String
    
    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    func makeURL(query: [String: String]) -> URL? {
        var components = URLComponents(string: baseURL)
        var queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        queryItems.append(URLQueryItem(name: "units", value: "metric"))
        components?.queryItems = queryItems
        return components?.url
    }
}

class WeatherService: WeatherServiceProtocol {
    private let urlSession: URLSessionProtocol
    private let urlCreator: URLCreatorProtocol
    
    init(urlSession: URLSessionProtocol = URLSessionWrapper(), urlCreator: URLCreatorProtocol) {
        self.urlSession = urlSession
        self.urlCreator = urlCreator
    }
    
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error> {
        guard let url = urlCreator.makeURL(query: ["q": city]) else {
            return Fail(error: URLError(.badURL))
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        return fetch(url: url)
    }
    
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error> {
        let query = [
            "lat": "\(latitude)",
            "lon": "\(longitude)"
        ]
        guard let url = urlCreator.makeURL(query: query) else {
            return Fail(error: URLError(.badURL))
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        return fetch(url: url)
    }
    
    private func fetch(url: URL) -> AnyPublisher<WeatherResponse, Error> {
        return urlSession.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
