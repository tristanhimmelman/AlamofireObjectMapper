//
//  ClassFormatter.swift
//  AlamofireObjectMapper
//
//  Created by Jacob Lubecki on 6/15/16.
//  Copyright © 2016 Tristan Himmelman. All rights reserved.
//

import Foundation

public class BaseFormatter: ClassFormatter {
    
    public static let sort: (((key: String, value: AnyObject), (key: String, value: AnyObject)) -> Bool)? = nil
    
    public static func variableName(forKey key: String) -> String {
        return key
    }
    
    public static func classNameForSubstructure(withKey key: String) -> String {
        return key.capitalizedString
    }
    
    public static func typeString(forKey key: String, andValue value: AnyObject) -> String {
        switch value {
        case is String:
            return "String"
            
        case is Int:
            return "Int"
            
        case is Bool:
            return "Bool"
            
        case is Double:
            return "Double"
            
        case is [String : AnyObject]:
            return classNameForSubstructure(withKey: key)
            
        case is [[String : AnyObject]]:
            return "[\(classNameForSubstructure(withKey: key))]"
            
        case is [AnyObject]:
            return "[AnyObject]"
            
        case is [[AnyObject]]:
            return "[[AnyObject]]"
            
        case is NSDate:
            return "NSDate"
            
        default:
            return "AnyObject"
        }
    }
}
