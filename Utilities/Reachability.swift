//
//  Reachability.swift
//  ChaseTaskTests
//
//  Created by Taha Metwally on 1/9/2024.
//

import Foundation
import Network

/// A class to monitor the network reachability status.
class Reachability {
    // An instance of NWPathMonitor used to monitor network status changes.
    private let monitor = NWPathMonitor()
    
    // A dispatch queue to handle network monitoring tasks.
    private let queue = DispatchQueue(label: "ReachabilityMonitor")
    
    /// Enum representing the network status.
    enum Status {
        case connected      // Indicates that the device is connected to a network.
        case notConnected   // Indicates that the device is not connected to a network.
    }
    
    /// Starts monitoring the network status.
    /// - Parameter statusChangeHandler: A closure that is called whenever the network status changes.
    func startMonitoring(statusChangeHandler: @escaping (Status) -> Void) {
        // Set the pathUpdateHandler to respond to network status changes.
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Network is connected.
                statusChangeHandler(.connected)
            } else {
                // Network is not connected.
                statusChangeHandler(.notConnected)
            }
        }
        // Start monitoring on the specified queue.
        monitor.start(queue: queue)
    }
    
    /// Stops monitoring the network status.
    func stopMonitoring() {
        // Cancel the network monitoring.
        monitor.cancel()
    }
}
