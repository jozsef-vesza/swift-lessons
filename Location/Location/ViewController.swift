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
            self.locationlabel.text! = "\(newLocation)"
        }) { [unowned self] (error) -> () in
            self.showAlertControllerWithMessage(error)
        }
    }
    
    func showAlertControllerWithMessage(error: ErrorType) {
        var title = ""
        var detail = ""
        var openAction: UIAlertAction?
        
        switch error {
        case .Regular(let message):
            title = "There Was An Error Accessing Your Location"
            detail = message
        case .Permission:
            title = "Background Location Access Disabled"
            detail = "For this tutorial to work, please open settings"
            openAction = setupOpenAction()
        }
        
        let alertController = UIAlertController(title: title, message: detail, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        if let open = openAction {
            alertController.addAction(open)
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setupOpenAction() -> UIAlertAction {
        return UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
}

