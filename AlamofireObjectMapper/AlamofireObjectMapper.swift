//
//  Request.swift
//  AlamofireObjectMapper
//
//  Created by Tristan Himmelman on 2015-04-30.
//  Copyright (c) 2015 Tristan Himmelman. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import ObjectiveC


extension Request {
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response object (of type Mappable), the raw response data, and any error produced making the request.
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, AnyObject?, ErrorType?) -> Void) -> Self {
        return responseObject(nil, keyPath: nil, completionHandler: completionHandler)
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 2 arguments: the response object (of type Mappable) and any error produced while making the request
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(completionHandler: (T?, ErrorType?) -> Void) -> Self {
        return responseObject(nil, keyPath: nil) { (request, response, object, data, error) -> Void in
            completionHandler(object, error)
        }
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object with support for keypath mapping. The closure takes 2 arguments: the response object (of type Mappable) and any error produced while making the request
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(keyPath: String?, completionHandler: (T?, ErrorType?) -> Void) -> Self {
        return responseObject(nil, keyPath: keyPath) { (request, response, object, data, error) -> Void in
            completionHandler(object, error)
        }
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object with support for keypath mapping. The closure takes 5 arguments: the URL request, the URL response, the response object (of type Mappable), the raw response data, and any error produced making the request.
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(keyPath: String?, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, AnyObject?, ErrorType?) -> Void) -> Self {
        return responseObject(nil, keyPath: keyPath, completionHandler: completionHandler)
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response object (of type Mappable), the raw response data, and any error produced making the request.
     
     - returns: The request.
     */
    
    public func responseObject<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler:(NSURLRequest, NSHTTPURLResponse?, T?, AnyObject?, ErrorType?) -> Void) -> Self {
        
        return response(queue: queue) { (request, response, data, error) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
                let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
                let parsedObject = Mapper<T>().map(keyPath != nil ? result.value?[keyPath!] : result.value)
        
                dispatch_async(queue ?? dispatch_get_main_queue()) {
                    completionHandler(self.request!, self.response, parsedObject, result.value ?? data, result.error)
                }
            }
        }
    }
    

    // MARK: Array responses
    
    /**
    Adds a handler to be called once the request has finished.
    
    - parameter keyPath: The key path where object mapping should be performed
    - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object with support for keypath mapping. The closure takes 5 arguments: the URL request, the URL response, the response array (of type Mappable), the raw response data, and any error produced making the request.
    
    - returns: The request.
    */
    public func responseArray<T: Mappable>(keyPath: String?, completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, AnyObject?, ErrorType?) -> Void) -> Self {
        return responseArray(nil, keyPath: keyPath, completionHandler: completionHandler)
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 2 arguments: the response array (of type Mappable) and any error produced while making the request
     
     - returns: The request.
     */
    public func responseArray<T: Mappable>(completionHandler: ([T]?, ErrorType?) -> Void) -> Self {
        return responseArray(nil, keyPath: nil) { (request, response, object, data, error) -> Void in
            completionHandler(object, error)
        }
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object with support for keypath mapping. The closure takes 2 arguments: the response array (of type Mappable) and any error produced while making the request
     
     - returns: The request.
     */
    public func responseArray<T: Mappable>(keyPath: String?, completionHandler: ([T]?, ErrorType?) -> Void) -> Self {
        return responseArray(nil,keyPath: keyPath) { (request, response, object, data, error) -> Void in
            completionHandler(object, error)
        }
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response array (of type Mappable), the raw response data, and any error produced making the request.
     
     - returns: The request.
     */
    public func responseArray<T: Mappable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, AnyObject?, ErrorType?) -> Void) -> Self {
        return responseArray(nil,keyPath: nil, completionHandler: completionHandler)
    }
    
   
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response array (of type Mappable), the raw response data, and any error produced making the request.
     
     - returns: The request.
     */
    public func responseArray<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, AnyObject?, ErrorType?) -> Void) -> Self {

        return response(queue: queue) { (request, response, data, error) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
                let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
                let parsedObject = Mapper<T>().mapArray(keyPath != nil ? result.value?[keyPath!] : result.value)
                
                dispatch_async(queue ?? dispatch_get_main_queue()) {
                    completionHandler(self.request!, self.response, parsedObject, result.value, result.error)
                }
            }
        }
    }
}
