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

extension DataRequest {
    
    enum ErrorCode: Int {
        case noData = 1
        case dataSerializationFailed = 2
    }
    
    internal static func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "com.alamofireobjectmapper.error"
        
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        
        return returnError
    }
    
    public static func ObjectMapperSerializer<T: BaseMappable>(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            
            let JSONToMap: Any?
            if let keyPath = keyPath , keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
            } else {
                JSONToMap = result.value
            }
            
            if let object = object {
                _ = Mapper<T>().map(JSONObject: JSONToMap, toObject: object)
                return .success(object)
            } else if let parsedObject = Mapper<T>(context: context).map(JSONObject: JSONToMap){
                return .success(parsedObject)
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = newError(.dataSerializationFailed, failureReason: failureReason)
            return .failure(error)
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue:             The queue on which the completion handler is dispatched.
     - parameter keyPath:           The key path where object mapping should be performed
     - parameter object:            An object to perform the mapping on to
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    @discardableResult
    public func responseObject<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperSerializer(keyPath, mapToObject: object, context: context), completionHandler: completionHandler)
    }
    
    public static func ObjectMapperArraySerializer<T: BaseMappable>(_ keyPath: String?, context: MapContext? = nil) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = newError(.dataSerializationFailed, failureReason: failureReason)
                return .failure(error)
            }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            
            let JSONToMap: Any?
            if let keyPath = keyPath, keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
            } else {
                JSONToMap = result.value
            }
            
            if let parsedObject = Mapper<T>(context: context).mapArray(JSONObject: JSONToMap){
                return .success(parsedObject)
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = newError(.dataSerializationFailed, failureReason: failureReason)
            return .failure(error)
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    @discardableResult
    public func responseArray<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperArraySerializer(keyPath, context: context), completionHandler: completionHandler)
    }
}
