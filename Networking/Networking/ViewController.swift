//
//  ViewController.swift
//  Networking
//
//  Created by József Vesza on 09/11/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let networkHandler = NetworkHandler.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressDownload(sender: AnyObject) {
        foregroundDownload()
    }
    
    @IBAction func didPressBackgroundDownload(sender: AnyObject) {
        backgroundDownload()
    }
    
    @IBAction func didPressUpload(sender: AnyObject) {
        upload()
    }
    
    func foregroundDownload() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.google.com")!)
        networkHandler.httpGet(request) { (data, error) -> Void in
            if error != nil {
                println(error)
            } else {
                println(data)
            }
        }
    }
    
    func backgroundDownload() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://tpdb.speed2.hinet.net/test_010m.zip")!)
        networkHandler.startBackgroundDownload(request)
    }
    
    func upload() {
        if let filePath = NSBundle.mainBundle().pathForResource("swift", ofType: "png") {
            let data = NSData(contentsOfFile: filePath)!
            var request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:8000/swift.png")!)
            networkHandler.startUpload(request, data: data) { (responseData, error) -> Void in
                if error != nil {
                    println(error)
                } else {
                    
                }
            }
        }
    }
}