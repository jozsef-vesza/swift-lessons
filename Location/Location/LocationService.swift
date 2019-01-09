//
//  LocationService.swift
//  Location
//
//  Created by József Vesza on 26/10/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationServiceError {
    case locationUpdateError(String)
}

class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    
    var completionHandler: ((String) -> ())?
    var errorHandler: ((LocationServiceError) -> ())?
    
    func updateLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    /// Extract the city name from a given location.
    ///
    /// [Source](https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names)
    ///
    private func reportCityFrom(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorHandler?(.locationUpdateError(error.localizedDescription))
            }
            
            guard let city = placemarks?.first?.locality else {
                self.completionHandler?("")
                return
            }
            
            self.completionHandler?(city)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        reportCityFrom(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        errorHandler?(.locationUpdateError(error.localizedDescription))
    }
}
