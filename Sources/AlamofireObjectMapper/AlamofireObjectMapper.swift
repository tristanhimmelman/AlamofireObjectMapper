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
    
    /// Utility function for extracting JSON from response
    internal static func processResponse(request: URLRequest?, response: HTTPURLResponse?, data: Data?, keyPath: String?) -> Any? {
        
        let jsonResponseSerializer = JSONResponseSerializer(options: .allowFragments)
        if let result = try? jsonResponseSerializer.serialize(request: request, response: response, data: data, error: nil) {
            
            let JSON: Any?
            if let keyPath = keyPath , keyPath.isEmpty == false {
                JSON = (result as AnyObject?)?.value(forKeyPath: keyPath)
            } else {
                JSON = result
            }
            
            return JSON
        }
        
        return nil
    }
    
    internal static func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "com.alamofireobjectmapper.error"
        
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        
        return returnError
    }
    
    /// Utility function for checking for errors in response
    internal static func checkResponseForError(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) -> Error? {
        if let error = error {
            return error
        }
        guard let _ = data else {
            let failureReason = "Data could not be serialized. Input data was nil."
            let error = newError(.noData, failureReason: failureReason)
            return error
        }
        return nil
    }
    
    
    /// BaseMappable Object Serializer
    public static func ObjectMapperSerializer<T: BaseMappable>(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil) -> MappableResponseSerializer<T> {
        
        return MappableResponseSerializer(keyPath, mapToObject: object, context: context, serializeCallback: {
            request, response, data, error in

            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            
            if let object = object {
                _ = Mapper<T>(context: context, shouldIncludeNilValues: false).map(JSONObject: JSONObject, toObject: object)
                return object
            } else if let parsedObject = Mapper<T>(context: context, shouldIncludeNilValues: false).map(JSONObject: JSONObject){
                return parsedObject
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
            
        })
    }
    
    /// ImmutableMappable Array Serializer
    public static func ObjectMapperImmutableSerializer<T: ImmutableMappable>(_ keyPath: String?, context: MapContext? = nil) -> MappableResponseSerializer<T> {
        
        return MappableResponseSerializer(keyPath, context: context, serializeCallback: {
            request, response, data, error in
            
            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            
            if let JSONObject = JSONObject,
                let parsedObject = (try? Mapper<T>(context: context, shouldIncludeNilValues: false).map(JSONObject: JSONObject) as T) {
                return parsedObject
            } else {
                let failureReason = "ObjectMapper failed to serialize response."
                throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
            }
        })
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
    public func responseObject<T: BaseMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperSerializer(keyPath, mapToObject: object, context: context), completionHandler: completionHandler)
    }
    
    @discardableResult
    public func responseObject<T: ImmutableMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableSerializer(keyPath, context: context), completionHandler: completionHandler)
    }
    
    /// BaseMappable Array Serializer
    public static func ObjectMapperArraySerializer<T: BaseMappable>(_ keyPath: String?, context: MapContext? = nil) -> MappableArrayResponseSerializer<T> {
        
        
        
        return MappableArrayResponseSerializer(keyPath, context: context, serializeCallback: {
            request, response, data, error in
            
            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            
            if let parsedObject = Mapper<T>(context: context, shouldIncludeNilValues: false).mapArray(JSONObject: JSONObject){
                return parsedObject
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
        })
    }
    
    
    /// ImmutableMappable Array Serializer
    public static func ObjectMapperImmutableArraySerializer<T: ImmutableMappable>(_ keyPath: String?, context: MapContext? = nil) -> MappableArrayResponseSerializer<T> {
        return MappableArrayResponseSerializer(keyPath, context: context, serializeCallback: {
             request, response, data, error in
            
            if let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath){
                
                if let parsedObject = try? Mapper<T>(context: context, shouldIncludeNilValues: false).mapArray(JSONObject: JSONObject) as [T] {
                    return parsedObject
                }
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
        })
    }
    
    /**
     Adds a handler to be called once the request has finished. T: BaseMappable
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    @discardableResult
    public func responseArray<T: BaseMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<[T]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperArraySerializer(keyPath, context: context), completionHandler: completionHandler)
    }
    
    /**
     Adds a handler to be called once the request has finished. T: ImmutableMappable
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    @discardableResult
    public func responseArray<T: ImmutableMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<[T]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableArraySerializer(keyPath, context: context), completionHandler: completionHandler)
    }
}

public final class MappableResponseSerializer<T: BaseMappable>: ResponseSerializer {
    /// The `JSONDecoder` instance used to decode responses.
    public let decoder: DataDecoder = JSONDecoder()
    /// HTTP response codes for which empty responses are allowed.
    public let emptyResponseCodes: Set<Int>
    /// HTTP request methods for which empty responses are allowed.
    public let emptyRequestMethods: Set<HTTPMethod>
    
    public let keyPath: String?
    public let context: MapContext?
    public let object: T?

    public let serializeCallback: (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> T

    /// Creates an instance using the values provided.
    ///
    /// - Parameters:
    ///   - keyPath:
    ///   - object:
    ///   - context:
    ///   - emptyResponseCodes:  The HTTP response codes for which empty responses are allowed. Defaults to
    ///                          `[204, 205]`.
    ///   - emptyRequestMethods: The HTTP request methods for which empty responses are allowed. Defaults to `[.head]`.
    ///   - serializeCallback: 
    public init(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil,
                emptyResponseCodes: Set<Int> = MappableResponseSerializer.defaultEmptyResponseCodes,
                emptyRequestMethods: Set<HTTPMethod> = MappableResponseSerializer.defaultEmptyRequestMethods, serializeCallback: @escaping (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> T) {

        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
        
        self.keyPath = keyPath
        self.context = context
        self.object = object
        self.serializeCallback = serializeCallback
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        guard error == nil else { throw error! }
        
        guard let data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }
            
            guard let emptyValue = Empty.value as? T else {
                throw AFError.responseSerializationFailed(reason: .invalidEmptyResponse(type: "\(T.self)"))
            }
            
            return emptyValue
        }
        return try self.serializeCallback(request, response, data, error)
    }
}

public final class MappableArrayResponseSerializer<T: BaseMappable>: ResponseSerializer {
    /// The `JSONDecoder` instance used to decode responses.
    public let decoder: DataDecoder = JSONDecoder()
    /// HTTP response codes for which empty responses are allowed.
    public let emptyResponseCodes: Set<Int>
    /// HTTP request methods for which empty responses are allowed.
    public let emptyRequestMethods: Set<HTTPMethod>
    
    public let keyPath: String?
    public let context: MapContext?

    public let serializeCallback: (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> [T]
    /// Creates an instance using the values provided.
    ///
    /// - Parameters:
    ///   - keyPath:
    ///   - context:
    ///   - emptyResponseCodes:  The HTTP response codes for which empty responses are allowed. Defaults to
    ///                          `[204, 205]`.
    ///   - emptyRequestMethods: The HTTP request methods for which empty responses are allowed. Defaults to `[.head]`.
    ///   - serializeCallback:
    public init(_ keyPath: String?, context: MapContext? = nil, serializeCallback: @escaping (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> [T],
                emptyResponseCodes: Set<Int> = MappableArrayResponseSerializer.defaultEmptyResponseCodes,
                emptyRequestMethods: Set<HTTPMethod> = MappableArrayResponseSerializer.defaultEmptyRequestMethods) {
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
        
        self.keyPath = keyPath
        self.context = context
        self.serializeCallback = serializeCallback
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> [T] {
        guard error == nil else { throw error! }
        
        guard let data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }
            
            // TODO / FIX - Empty Response JSON Decodable Array Fix - "Cast from empty always fails..."
            guard let emptyValue = Empty.value as? [T] else {
                throw AFError.responseSerializationFailed(reason: .invalidEmptyResponse(type: "\(T.self)"))
            }
            
            return emptyValue
        }
        return try self.serializeCallback(request, response, data, error)
    }
}
