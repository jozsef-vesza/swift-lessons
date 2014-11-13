//
//  LogItem.swift
//  MyLog
//
//  Created by József Vesza on 08/11/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import Foundation
import CoreData

class LogItem: NSManagedObject {
    @NSManaged var itemText: String
    @NSManaged var title: String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, text: String) -> LogItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LogItem", inManagedObjectContext: moc) as LogItem
        newItem.title = title
        newItem.itemText = text
        
        return newItem
    }
}
