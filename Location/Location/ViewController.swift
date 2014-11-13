//
//  ViewController.swift
//  Location
//
//  Created by József Vesza on 26/10/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var locationlabel: UILabel!
    let locationService = LocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressGetLocation(sender: AnyObject) {
        locationService.startUpdatingLocation(completion: { [unowned self] (newLocation) -> () in
            println("\(newLocation)")
            self.locationlabel.text! = "\(newLocation)"
        }) { [unowned self] (error) -> () in
            println("\(error)")
            self.locationlabel.text! = "\(error)"
        }
    }
}

