import SwiftUI
import Combine
import CoreLocation

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
    }
}



struct ContentView: View {
    @StateObject private var viewModel: WeatherViewModel
    
    init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Spacer()
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
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
                .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
                .navigationTitle("Weather App")
                .navigationViewStyle(StackNavigationViewStyle())
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Enter US city name", text: $viewModel.cityName, onCommit: {
                viewModel.searchWeather()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
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
            viewModel.searchWeatherByLocation()
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
}
