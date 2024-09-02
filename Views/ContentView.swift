import Combine
import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WeatherViewModel
    @State private var isAnimating: Bool = true // State to control ActivityIndicator

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
                                ActivityIndicator(isAnimating: $isAnimating, style: .large) // Replaced ProgressView with ActivityIndicator
                                    .scaleEffect(1.5)
                                    .padding()
                                
                            } else if viewModel.noDataFound {
                                noResultsMessage
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
                        ActivityIndicator(isAnimating: $isAnimating, style: .medium) // Replaced ProgressView with ActivityIndicator
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

    private var noResultsMessage: some View {
        Text("No results found for the given city. Please try another search.")
            .foregroundColor(.gray)
            .padding()
            .multilineTextAlignment(.center)
    }
}


