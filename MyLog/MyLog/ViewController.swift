//
//  ViewController.swift
//  MyLog
//
//  Created by József Vesza on 08/11/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    let logTableView = UITableView(frame: CGRectZero, style: .Plain)
    var logItems = [LogItem]()
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        addButton.setTitle("+", forState: .Normal)
        addButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        addButton.addTarget(self, action: "addNewItem", forControlEvents: .TouchUpInside)
        view.addSubview(addButton)
        
        var viewFrame = self.view.frame
        viewFrame.origin.y += 20
        viewFrame.size.height -= (20 + addButton.frame.size.height)
        
        logTableView.frame = viewFrame
        view.addSubview(logTableView)
        
        logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "LogCell")
        logTableView.dataSource = self
        logTableView.delegate = self
        
        fetchLog()
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "LogItem")
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LogItem] {
            logItems = fetchResults
        }
    }
    
    func addNewItem() {
        var titlePrompt = UIAlertView(title: "Enter Title", message: "Enter Text", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        titlePrompt.alertViewStyle = .PlainTextInput
        titlePrompt.tag = addItemAlertViewTag
        titlePrompt.show()
    }
    
    func saveNewItem(title: String) {
        var newLogItem = LogItem.createInManagedObjectContext(managedObjectContext!, title: title, text: "")
        
        fetchLog()
        
        if let newItemIndex = find(logItems, newLogItem) {
            let newLogItemIndexPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            logTableView.insertRowsAtIndexPaths([newLogItemIndexPath], withRowAnimation: .Automatic)
            save()
        }
    }
    
    func save() {
        var error: NSError? = nil
        if(!managedObjectContext!.save(&error)) {
            println(error?.localizedDescription)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogCell") as UITableViewCell
        let logItem = logItems[indexPath.row]
        cell.textLabel.text = logItem.title
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let logItem = logItems[indexPath.row]
        let alert = UIAlertView(title: logItem.title, message: logItem.itemText, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alert.show()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let logItemToDelete = logItems[indexPath.row]
            managedObjectContext?.deleteObject(logItemToDelete)
            self.fetchLog()
            logTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            save()
        }
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let cancelButtonIndex = 0
        let saveButtonIndex = 1
        
        switch(buttonIndex, alertView.tag) {
        case (saveButtonIndex, addItemAlertViewTag):
            if let alertTextField = alertView.textFieldAtIndex(0) {
                println("Save new item \(alertTextField.text)")
                saveNewItem(alertTextField.text)
            }
        default:
            println("Default case, do nothing")
        }
    }
}

