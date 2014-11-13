//
//  ColorViewController.swift
//  Split
//
//  Created by József Vesza on 13/11/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import UIKit

class ColorViewController: UIViewController {
    
    var color = Color(displayName: "White", color: UIColor.whiteColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(color.displayName) Color"
        view.backgroundColor = color.color
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
    }
}
