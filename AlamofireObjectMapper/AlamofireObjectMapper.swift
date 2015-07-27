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

extension Request {
	
	/**
	Adds a handler to be called once the request has finished.
	
	:param: completionHandler A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 2 arguments: the response object (of type Mappable) and any error produced while making the request
	
	:returns: The request.
	*/
	public func responseObject<T: Mappable>(completionHandler: (T?, NSError?) -> Void) -> Self {
		return responseObject(nil) { (request, response, object, data, error) -> Void in
			completionHandler(object, error)
		}
	}
	
	/**
	Adds a handler to be called once the request has finished.
	
	:param: completionHandler A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response object (of type Mappable), the raw response data, and any error produced making the request.
	
	:returns: The request.
	*/
	public func responseObject<T: Mappable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, AnyObject?, NSError?) -> Void) -> Self {
		return responseObject(nil, completionHandler: completionHandler)
	}
	
	/**
	Adds a handler to be called once the request has finished.
	
	:param: queue The queue on which the completion handler is dispatched.
	:param: completionHandler A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response object (of type Mappable), the raw response data, and any error produced making the request.
	
	:returns: The request.
	*/
	public func responseObject<T: Mappable>(queue: dispatch_queue_t?, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, AnyObject?, NSError?) -> Void) -> Self {
		
		return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: NSJSONReadingOptions.AllowFragments)) { (request, response, data, error) -> Void in
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

				let parsedObject = Mapper<T>().map(data)
				
				dispatch_async(queue ?? dispatch_get_main_queue()) {
					completionHandler(self.request, self.response, parsedObject, data, error)
				}
			}
		}
	}
	
	// MARK: Array responses
	
	/**
	Adds a handler to be called once the request has finished.
	
	:param: completionHandler A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 2 arguments: the response array (of type Mappable) and any error produced while making the request
	
	:returns: The request.
	*/
	public func responseArray<T: Mappable>(completionHandler: ([T]?, NSError?) -> Void) -> Self {
		return responseArray(nil) { (request, response, object, data, error) -> Void in
			completionHandler(object, error)
		}
	}
	
	/**
	Adds a handler to be called once the request has finished.
	
	:param: completionHandler A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response array (of type Mappable), the raw response data, and any error produced making the request.
	
	:returns: The request.
	*/
	public func responseArray<T: Mappable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, AnyObject?, NSError?) -> Void) -> Self {
		return responseArray(nil, completionHandler: completionHandler)
	}
	
	/**
	Adds a handler to be called once the request has finished.
	
	:param: queue The queue on which the completion handler is dispatched.
	:param: completionHandler A closure to be executed once the request has finished and the data has been mapped to a swift Object. The closure takes 5 arguments: the URL request, the URL response, the response array (of type Mappable), the raw response data, and any error produced making the request.
	
	:returns: The request.
	*/
	public func responseArray<T: Mappable>(queue: dispatch_queue_t?, completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, AnyObject?, NSError?) -> Void) -> Self {
		
		return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: NSJSONReadingOptions.AllowFragments)) { (request, response, data, error) -> Void in
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
				
				let parsedObject = Mapper<T>().mapArray(data)
				
				dispatch_async(queue ?? dispatch_get_main_queue()) {
					completionHandler(self.request, self.response, parsedObject, data, error)
				}
			}
		}
	}
}