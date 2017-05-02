//
//  Logger.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import ObjectMapper

public class Logger: NSObject {
    
    static func log(_ object: BaseMappable?) {
        
        guard let object = object else {
            print("object nil")
            return
        }
        
        print (object.toJSONString(prettyPrint: true) ?? "Unable to prettyPrint JSON ")
    }
 
    static func log(_ objects: [BaseMappable]?) {
        
        guard let objects = objects else {
            print("array nil")
            return
        }
        
        if objects.count == 0 {
            print("array empty")
        }
        
        for iterator in objects {
            print (iterator.toJSONString(prettyPrint: true) ?? "Unable to prettyPrint JSON ")
        }
        
    }
}
