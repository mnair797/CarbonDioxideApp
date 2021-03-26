//
//  LocationManager.swift
//  CarbonDioxideApp
//
//  Created by Meenakshi Nair on 3/25/21.
//

import Foundation
import UIKit
import CoreLocation

class LocationManager: NSObject,CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    static var currentLocation:CLLocation?
    

    
    func initializeLocation() {
 
        
        determineMyCurrentLocation()
        // This doesnt really belong here, just putting it here for testing
        GoogleSheetsIntegration.getSheet()
    }
    
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        

        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        LocationManager.currentLocation=CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
       manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location Manager Error: \(error)")
    }
}
