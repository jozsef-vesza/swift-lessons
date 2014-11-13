//
//  LocationService.swift
//  Location
//
//  Created by József Vesza on 26/10/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    var completionHandler: ((newLocation: CLLocation) -> ())?
    var errorHandler: ((error: NSError) -> ())?
    let locationManager = CLLocationManager()
    
    func startUpdatingLocation(
        #completion: ((newLocation: CLLocation) -> ())?,
        error: ((error: NSError) -> ())?) {
            if let compl = completion {
                completionHandler = compl
            }
            if let err = error {
                errorHandler = err
            }
            
            let status = CLLocationManager.authorizationStatus()
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            if status == CLAuthorizationStatus.NotDetermined {
                if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                    locationManager.requestWhenInUseAuthorization()
                }
            }
            
            locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let compl = completionHandler {
            compl(newLocation: locations.last! as CLLocation)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if let err = errorHandler {
            err(error: error)
            locationManager.stopUpdatingLocation()
        }
    }
}