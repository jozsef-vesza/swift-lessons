//
//  LocationService.swift
//  Location
//
//  Created by József Vesza on 26/10/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import Foundation
import CoreLocation

enum ErrorType {
    case Regular(String)
    case Permission
}

class LocationService: NSObject, CLLocationManagerDelegate {
    var completionHandler: ((newLocation: CLLocation) -> ())?
    var errorHandler: ((error: ErrorType) -> ())?
    let locationManager = CLLocationManager()
    
    func startUpdatingLocation(
        #completion: ((newLocation: CLLocation) -> ())?,
        error: ((error: ErrorType) -> ())?) {
            if let compl = completion {
                completionHandler = compl
            }
            if let err = error {
                errorHandler = err
            }
            
            if let error = checkPermissions() {
                errorHandler?(error: error)
            }
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
    }
    
    func checkPermissions() -> ErrorType? {
        let status = CLLocationManager.authorizationStatus()
        
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            }
        case .Restricted, .Denied:
            return .Permission
        default:
            return nil
        }
        
        return nil
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let compl = completionHandler {
            compl(newLocation: locations.last! as CLLocation)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if let err = errorHandler {
            err(error: .Regular(error.localizedDescription))
            locationManager.stopUpdatingLocation()
        }
    }
}