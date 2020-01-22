//
//  AppDelegate.swift
//  APICallingExample
//
//  Created by Bhavesh Chavda on 22/01/20.
//  Copyright © 2020 BhaveshChavda. All rights reserved.
//

import UIKit
@_exported import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var latitude: Double? // location
    var longitude: Double? // location
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        APIManager.shared.setApiEnviornment(type: .development)
        return true
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    // Print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            print("Background Location Access Disabled")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
        latitude = nil
        longitude = nil
    }
}

