//
//  WeatherService.swift
//  ChaseTask
//
//  Created by Taha Metwally on 31/8/2024.
//

import Foundation
import Combine
// MARK: - Weather Service Protocol

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error>
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error>
}

// MARK: - Weather Service Implementation

class WeatherService: WeatherServiceProtocol {
    private let apiKey = "9e4d4728a5ebfd6b2bc1eceb7c795f22"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error> {
        guard let url = makeURL(query: ["q": city]) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        return fetch(url: url)
    }
    
    func fetchWeatherForLocation(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error> {
        let query = [
            "lat": "\(latitude)",
            "lon": "\(longitude)"
        ]
        guard let url = makeURL(query: query) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        return fetch(url: url)
    }
    
    private func makeURL(query: [String: String]) -> URL? {
        var components = URLComponents(string: baseURL)
        var queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        queryItems.append(URLQueryItem(name: "units", value: "metric"))
        components?.queryItems = queryItems
        return components?.url
    }
    
    private func fetch(url: URL) -> AnyPublisher<WeatherResponse, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
