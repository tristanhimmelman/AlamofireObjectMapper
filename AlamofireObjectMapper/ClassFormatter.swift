//
//  ClassFormatter.swift
//  AlamofireObjectMapper
//
//  Created by Jacob Lubecki on 6/15/16.
//  Copyright © 2016 Tristan Himmelman. All rights reserved.
//

import Foundation

public protocol ClassFormatter {
    static var sort: (((key: String, value: AnyObject), (key: String, value: AnyObject)) -> Bool)? { get }
    static func variableName(forKey key: String) -> String
    static func typeString(forKey key: String, andValue value: AnyObject) -> String
    static func classNameForSubstructure(withKey key: String) -> String
}

extension ClassFormatter {
    
    public static func serialize(json rootJson: [String : AnyObject], withRootClassName className: String, shouldIncludeSubstructures includeSubstructures: Bool) -> String {
        var out: String = ""
        let allSubstructures: [(key: String, value: [String : AnyObject])] = includeSubstructures ? findSubstructures(withRootKey: className, inJson: rootJson) : [ (className, rootJson) ]
        
        for substructure in allSubstructures {
            out += formatJsonAsMappableObjectClass(named: substructure.key, forJson: substructure.value)
            out += "\n\n"
        }
        
        return out
    }
    
    /**
     Formats JSON content as a String representing a Mappable Swift class file.
     
     - parameter className: The name for the class that will be generated.
     - parameter json: The JSON that should define the class to be created.
     - parameter sort: How to sort the JSON. Response will not sort JSON if nil.
     
     - returns: The formatted class file as a String.
     */
    public static func formatJsonAsMappableObjectClass(named className: String, forJson json: [String : AnyObject]) -> String {
        let longestKey = longestKeyLength(inJson: json)
        let formattedJson = sortedVariables(forJson: json)
        
        var out: String = "\n\n" // Add space to begin relevant logging on a new line
        
        out += "import ObjectMapper\n\nclass \(className): Mappable {\n\n" // Declare class name and implement Mappable
        out += "// MARK: - Properties\n\n".indent(1)
        
        for (key, value) in formattedJson {
            out += "var \(variableName(forKey: key)): \(typeString(forKey: key, andValue: value))?\n".indent(1)
        }
        
        out += "\n\n"
        out += "// MARK: - Init\n\n".indent(1)
        out += "required init?(map: Map) { }\n\n\n".indent(1) // end init
        
        out += "// MARK: - Mappable\n\n".indent(1)
        out += "func mapping(map: Map) {\n".indent(1)
        
        for (key, _) in formattedJson {
            let varName = variableName(forKey: key)
            out += "\(varName + Self.spaces(longestKey - varName.characters.count)) <- map[\"\(key)\"]\n".indent(2)
        }
        
        out += "}\n".indent(1)
        out += "}"
        
        return out
    }
    
    public static func sortedVariables(forJson json: [String : AnyObject]) -> [(key: String, value: AnyObject)] {
        var formattedJson: [(key: String, value: AnyObject)]
        
        if let sort = sort {
            formattedJson = json.sorted(by: sort)
        } else {
            formattedJson = json.map({ (pair: (key: String, value: AnyObject)) -> (key: String, value: AnyObject) in
                return (key: pair.key, value: pair.value)
            })
        }
        
        return formattedJson
    }
    
    public static func findSubstructures(withRootKey rootKey: String, inJson json: [String : AnyObject]) -> [(key: String, value: [String : AnyObject])] {
        var structures: [(key: String, value: [String : AnyObject])] = [ (rootKey, json) ]
        
        let substructures = json.filter { (pair: (key: String, value: AnyObject)) -> Bool in
            return pair.value is [String : AnyObject] || pair.value is [[String : AnyObject]]
            }.map { (pair: (key: String, value: AnyObject)) -> (key: String, value: [String : AnyObject]) in
                let formattedKey = Self.classNameForSubstructure(withKey: pair.key)
                
                if pair.value is [String : AnyObject] {
                    return (formattedKey, pair.value as! [String : AnyObject])
                } else if let jsonArray = pair.value as? [[String : AnyObject]], jsonArray.count > 0 {
                    return (formattedKey, jsonArray[0])
                } else {
                    return (formattedKey, [:])
                }
        }
        
        for structure in substructures {
            structures.append(contentsOf: findSubstructures(withRootKey: structure.key, inJson: structure.value))
        }
        
        return structures
    }
    
    /**
     Helper method to format the outputted class file String.
     
     - parameter numSpaces: The number of spaces to return
     
     - returns: A String consisting of the specified number of spaces
     */
    static func spaces(_ numSpaces: Int) -> String {
        
        var spaces = ""
        
        for _ in 0 ... numSpaces {
            spaces += " "
        }
        
        return spaces
    }
    
    /**
     Helper method to format the outputted class file String.
     
     - parameter json: The JSON that will be checked for key lengths.
     
     - returns: The length of the longest key in the JSON after formatting as a variable name.
     */
    static func longestKeyLength(inJson json: [String : AnyObject]) -> Int {
        var longestCount = 0
        
        for (key, _) in json {
            let newCount = variableName(forKey: key).characters.count
            
            if newCount > longestCount {
                longestCount = newCount
            }
        }
        
        return longestCount
    }
}

public class BaseFormatter: ClassFormatter {
    
    public static let sort: (((key: String, value: AnyObject), (key: String, value: AnyObject)) -> Bool)? = nil
    
    public static func variableName(forKey key: String) -> String {
        return key
    }
    
    public static func classNameForSubstructure(withKey key: String) -> String {
        return key.capitalized
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

extension String {
    
    /**
     Helper method to format the outputted class file String.
     
     - parameter size: The number of tabs that should be appended to the beginning of the String.
     
     - returns: A String with the specified number of tabs appended to the beginning of the String.
     */
    internal func indent(_ size: Int) -> String {
        var out: String = ""
        
        for _ in 0 ... size {
            out += "\t"
        }
        
        return out + self
    }
}
