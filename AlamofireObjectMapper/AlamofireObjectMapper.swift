//
//  Request.swift
//  AlamofireObjectMapper
//
//  Created by Tristan Himmelman on 2015-04-30.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2015 Tristan Himmelman
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

extension Request {
    
    public static func ObjectMapperSerializer<T: Mappable>(keyPath: String?) -> ResponseSerializer<T, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
        
            let JSONToMap: AnyObject?
            if let keyPath = keyPath where keyPath.isEmpty == false {
                JSONToMap = result.value?.valueForKeyPath(keyPath)
            } else {
                JSONToMap = result.value
            }
            
            if let parsedObject = Mapper<T>().map(JSONToMap){
                return .Success(parsedObject)
            }

            let failureReason = "ObjectMapper failed to serialize response."
            let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
            return .Failure(error)
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter keyPath:           The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(keyPath: String? = nil, completionHandler: Response<T, NSError> -> Void) -> Self {
        return responseObject(nil, keyPath: keyPath, completionHandler: completionHandler)
    }

    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue:             The queue on which the completion handler is dispatched.
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    public func responseObject<T: Mappable>(queue: dispatch_queue_t?, completionHandler: Response<T, NSError> -> Void) -> Self {
        return responseObject(queue, keyPath: nil, completionHandler: completionHandler)
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue:             The queue on which the completion handler is dispatched.
     - parameter keyPath:           The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
    */
    public func responseObject<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<T, NSError> -> Void) -> Self {
        return response(queue: queue, responseSerializer: Request.ObjectMapperSerializer(keyPath), completionHandler: completionHandler)
    }
    
    public static func ObjectMapperArraySerializer<T: Mappable>(keyPath: String?) -> ResponseSerializer<[T], NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            let JSONToMap: AnyObject?
            if let keyPath = keyPath where keyPath.isEmpty == false {
                JSONToMap = result.value?.valueForKeyPath(keyPath)
            } else {
                JSONToMap = result.value
            }
            
            if let parsedObject = Mapper<T>().mapArray(JSONToMap){
                return .Success(parsedObject)
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
            return .Failure(error)
        }
    }

    /**
     Adds a handler to be called once the request has finished.
     
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
    */
    public func responseArray<T: Mappable>(keyPath: String? = nil, completionHandler: Response<[T], NSError> -> Void) -> Self {
        return responseArray(nil, keyPath: keyPath, completionHandler: completionHandler)
    }

    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
    */
    public func responseArray<T: Mappable>(queue: dispatch_queue_t?, completionHandler: Response<[T], NSError> -> Void) -> Self {
        return responseArray(queue, keyPath: nil, completionHandler: completionHandler)
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
    */
    public func responseArray<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<[T], NSError> -> Void) -> Self {
        return response(queue: queue, responseSerializer: Request.ObjectMapperArraySerializer(keyPath), completionHandler: completionHandler)
    }
}
