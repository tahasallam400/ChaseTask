//
//  LocationManager.swift
//  ChaseTaskTests
//
//  Created by Taha Metwally


import Foundation
import CoreLocation
import Combine

/// A class responsible for managing location services and handling location updates.
class LocationManager: NSObject, ObservableObject {
    let manager = CLLocationManager()  // An instance of CLLocationManager to handle location services.
    
    @Published var location: CLLocationCoordinate2D?  // Publishes the current location coordinates.
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined  // Publishes the current authorization status.
    @Published var locationError: Error?  // Publishes any location-related errors.
    
    /// Initializes the LocationManager and sets up the CLLocationManager delegate and desired accuracy.
    override init() {
        super.init()
        manager.delegate = self  // Set the delegate to self to handle CLLocationManagerDelegate methods.
        manager.desiredAccuracy = kCLLocationAccuracyBest  // Set the desired accuracy for location updates.
    }
    
    /// Requests location permission from the user.
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()  // Request authorization to access location when the app is in use.
        authorizationStatus = manager.authorizationStatus  // Update the authorization status.
    }
    
    /// Requests the user's current location based on the current authorization status.
    func requestLocation() {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()  // Request the current location if authorized.
        case .denied, .restricted:
            print("Location access denied or restricted.")
            // Optionally, show a user prompt to guide them to settings.
        case .notDetermined:
            print("Requesting location permission...")
            manager.requestWhenInUseAuthorization()  // Request location permission if not yet determined.
        default:
            print("Location access is set to 'When I Share' or unknown.")
            // Optionally, guide the user to settings for further action.
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// Handles changes in location authorization status.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus  // Update the authorization status.
        print("Authorization status changed: \(authorizationStatus.rawValue)")
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Authorization granted, requesting location...")
            manager.requestLocation()  // Request the current location if authorized.
        case .denied:
            print("Location permission denied.")
            // Optionally, handle this in the UI (e.g., show an alert).
        default:
            break  // Handle other cases if necessary.
        }
    }

    /// Called when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate  // Update the location with the first available coordinate.
    }
    
    /// Called when there is an error in retrieving the location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error  // Update the locationError with the encountered error.
    }
}
