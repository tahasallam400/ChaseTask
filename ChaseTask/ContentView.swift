import CoreLocation
import Combine
import SwiftUI
import Foundation





class LocationManager: NSObject, ObservableObject {
    let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestLocation() {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
            // Show a user prompt to guide them to settings
        case .notDetermined:
            print("Requesting location permission...")
            manager.requestWhenInUseAuthorization()
        default:
            print("Location access is set to 'When I Share' or unknown.")
            // You might want to guide the user to settings
        }
    }


}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Authorization status changed: \(authorizationStatus.rawValue)")
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Authorization granted, requesting location...")
            manager.requestLocation()
        case .denied:
            print("Location permission denied.")
            // Optionally handle this in the UI
        default:
            break
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
    }
}



import SwiftUI
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WeatherViewModel
    
    init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack {
                        Spacer()
                        if viewModel.isOffline {
                            noInternetBanner
                        } else {
                            searchBar
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding()
                            } else if let weather = viewModel.weather {
                                weatherInfo(weather: weather, geometry: geometry)
                            } else {
                                Spacer()
                            }
                            Spacer()
                            locationButton
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width * 0.9)
                    .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
                    .navigationTitle("Weather App")
                    .navigationViewStyle(StackNavigationViewStyle())
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Enter US city name", text: $viewModel.cityName, onCommit: {
                if viewModel.cityName.count <= 100 {
                    viewModel.searchWeather()
                } else {
                    // Handle text length exceeding limit (optional)
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .onChange(of: viewModel.cityName) {
                if viewModel.cityName.count > 100 {
                    viewModel.cityName = String(viewModel.cityName.prefix(100))
                }
            }
            
            Button(action: {
                viewModel.searchWeather()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .padding(.top)
    }
    
    private func weatherInfo(weather: WeatherResponse, geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Text(weather.name)
                .font(.largeTitle)
                .bold()
            VStack(spacing: 10) {
                if let iconURL = weather.iconURL {
                    AsyncImage(url: iconURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                    .padding(.bottom)
                }
                
                Text("\(Int(weather.main.temp))°C")
                    .font(.system(size: geometry.size.width * 0.15))
                    .bold()
                
                Text(weather.weather.first?.description.capitalized ?? "")
                    .font(.title2)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("High: \(Int(weather.main.temp_max))°C")
                    Text("Low: \(Int(weather.main.temp_min))°C")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Humidity: \(weather.main.humidity)%")
                    Text("Condition: \(weather.weather.first?.main ?? "")")
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(radius: 5))
    }
    
    private var locationButton: some View {
        Button(action: {
            if viewModel.locationManager.authorizationStatus == .notDetermined {
                viewModel.locationManager.requestLocationPermission()
            } else {
                viewModel.searchWeatherByLocation()
            }
        }) {
            HStack {
                Image(systemName: "location.fill")
                Text("Use Current Location")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private var noInternetBanner: some View {
        Text("No internet connection. Please check your network settings.")
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
            .padding()
    }
}



import CoreLocation
import Combine
import SwiftUI
import Foundation
import Network

class WeatherViewModel: ObservableObject {
    // Input
    @Published var cityName: String = ""
    @Published var weather: WeatherResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOffline: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    let weatherService: WeatherServiceProtocol
    let locationManager: LocationManager
    private let reachability = Reachability()
    
    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.locationManager = locationManager
        self.weatherService = weatherService
        loadLastSearchedCity()
        bindLocationUpdates()
        setupReachability()
    }
    
    func searchWeather() {
        guard !cityName.isEmpty else {
            self.errorMessage = "City name cannot be empty."
            return
        }
        isLoading = true
        weatherService.fetchWeather(for: cityName)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    self?.saveLastSearchedCity()
                    break
                }
            }, receiveValue: { [weak self] weather in
                if weather.weather.isEmpty {
                    self?.errorMessage = "No data found for the given city."
                } else {
                    self?.weather = weather
                }
            })
            .store(in: &cancellables)
    }
    
    func searchWeatherByLocation() {
        let authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            // Request permission if not determined
            locationManager.requestLocationPermission()
            
        case .restricted, .denied:
            // Provide feedback to the user that permission is required
            self.errorMessage = "Location access is restricted or denied. Please enable location services in settings."
            
        case .authorizedWhenInUse, .authorizedAlways:
            // If authorized, request location
            locationManager.requestLocation()
            
        @unknown default:
            // Handle unexpected cases
            self.errorMessage = "An unknown error occurred with location permissions."
        }
    }
    
    private func bindLocationUpdates() {
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                self?.isLoading = true
                self?.weatherService.fetchWeatherForLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    .sink(receiveCompletion: { completion in
                        self?.isLoading = false
                        switch completion {
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                        case .finished:
                            break
                        }
                    }, receiveValue: { weather in
                        self?.weather = weather
                        self?.cityName = weather.name
                        self?.saveLastSearchedCity()
                    })
                    .store(in: &self!.cancellables)
            }
            .store(in: &cancellables)
    }
    
    private func saveLastSearchedCity() {
        UserDefaults.standard.setValue(cityName, forKey: "LastSearchedCity")
    }
    
    private func loadLastSearchedCity() {
        if let lastCity = UserDefaults.standard.string(forKey: "LastSearchedCity") {
            cityName = lastCity
            searchWeather()
        }
    }
    
    private func setupReachability() {
        reachability.startMonitoring { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .connected:
                    self?.isOffline = false
                    if self?.weather == nil && !(self?.cityName.isEmpty ?? true) {
                        self?.searchWeather()
                    }
                case .notConnected:
                    self?.isOffline = true
                    self?.errorMessage = "No internet connection."
                }
            }
        }
    }
}

class Reachability {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityMonitor")
    
    enum Status {
        case connected
        case notConnected
    }
    
    func startMonitoring(statusChangeHandler: @escaping (Status) -> Void) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                statusChangeHandler(.connected)
            } else {
                statusChangeHandler(.notConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

// LocationManager remains unchanged
