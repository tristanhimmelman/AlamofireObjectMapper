//
//  Request.swift
//  AlamofireObjectMapper
//
//  Created by Tristan Himmelman on 2015-04-30.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2015 TristanHimmelman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
     
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a Alamofire Response Object.
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(completionHandler: (Response<T, NSError>) -> Void) -> Self {
        return responseObject(nil, keyPath: nil, completionHandler: completionHandler)
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a Alamofire Response Object with support for keypath mapping.
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(keyPath: String?, completionHandler: (Response<T, NSError>) -> Void) -> Self {
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
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a Alamofire Response Object.
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler:(Response<T, NSError>) -> Void) -> Self {
        
        return response(queue: queue) { (request, response, data, error) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
                let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
                let parsedObject = Mapper<T>().map(keyPath != nil ? result.value?[keyPath!] : result.value)
                
                dispatch_async(queue ?? dispatch_get_main_queue()) {
                    
                    guard let parsedObject = parsedObject else { return }
                    guard let error = error else
                    {
                        completionHandler(Response(request: request, response: response, data: data, result: Result.Success(parsedObject)))
                        return
                    }
                    
                    completionHandler(Response(request: request, response: response, data: data, result: Result.Failure(error)))
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
     
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a Alamofire Response Object.
     
     - returns: The request.
     */
    public func responseArray<T: Mappable>(completionHandler: (Response<[T], NSError>) -> Void) -> Self {
        return responseArray(nil, keyPath: nil, completionHandler: completionHandler)
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a Alamofire Response Object with support for keypath mapping.
     
     - returns: The request.
     */
    public func responseArray<T: Mappable>(keyPath: String?, completionHandler: (Response<[T], NSError>) -> Void) -> Self {
        return responseArray(nil, keyPath: keyPath, completionHandler: completionHandler)
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
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped to a Alamofire Response Object.
     
     - returns: The request.
     */
    public func responseArray<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: (Response<[T], NSError>) -> Void) -> Self {
        
        return response(queue: queue) { (request, response, data, error) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
                let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
                let parsedObject = Mapper<T>().mapArray(keyPath != nil ? result.value?[keyPath!] : result.value)
                
                dispatch_async(queue ?? dispatch_get_main_queue()) {
                    
                    guard let parsedObject = parsedObject else { return }
                    guard let error = error else
                    {
                        completionHandler(Response(request: request, response: response, data: data, result: Result.Success(parsedObject)))
                        return
                    }
                    
                    completionHandler(Response(request: request, response: response, data: data, result: Result.Failure(error)))
                }
            }
        }
    }
}
