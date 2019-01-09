//
//  ViewController.swift
//  Location
//
//  Created by József Vesza on 26/10/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var locationlabel: UILabel!
    
    private let locationService = LocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationService.completionHandler = { [weak self] location in
            self?.locationlabel.text = "\(location)"
        }
        locationService.errorHandler = { [weak self] error in
            self?.showAlertFor(error)
        }
    }
    
    @IBAction private func didPressGetLocation(_ sender: UIButton) {
        locationService.updateLocation()
    }
    
    func showAlertFor(_ error: LocationServiceError) {
        guard case .locationUpdateError(let message) = error else { return }
        
        let alertController = UIAlertController(title: "Couldn't access your location",
                                                message: message,
                                                preferredStyle: .alert)
        present(alertController, animated: true)
    }
}
