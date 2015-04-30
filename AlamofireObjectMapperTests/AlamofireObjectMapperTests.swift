//
//  AlamofireObjectMapperTests.swift
//  AlamofireObjectMapperTests
//
//  Created by Tristan Himmelman on 2015-04-30.
//  Copyright (c) 2015 Tristan Himmelman. All rights reserved.
//

import Foundation
import XCTest
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class AlamofireObjectMapperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResponseObject() {
        // This is an example of a functional test case.
		
		let URL = "http://httpbin.org/get"
		let parameters = ["param1": "hello", "param2": "goodbye"]
		let expectation = expectationWithDescription("\(URL)")

		Alamofire.request(.GET, URL, parameters: parameters).responseObject { (response: Response?, error: NSError?) in
			expectation.fulfill()

			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertNotNil(response?.arguments, "Arguents should not be nil")
			XCTAssertEqual(response!.arguments!, parameters, "Arguments should equal parameters that were passed into request")
			XCTAssertNotNil(response?.origin, "Origin should not be nil")
			XCTAssertNotNil(response?.url, "URL should not be nil")
			XCTAssertNotNil(response?.header, "Header should not be nil")
			XCTAssertNotNil(response?.header?.host, "Host should not be nil")
			XCTAssertNotNil(response?.header?.userAgent, "User Agent should not be nil")
		}
		
		waitForExpectationsWithTimeout(10, handler: { (error: NSError!) -> Void in
			XCTAssertNil(error, "\(error)")
		})
    }
	
	func testResponseObject2() {
		// This is an example of a functional test case.
		
		let URL = "http://httpbin.org/get"
		let parameters = ["param1":"hello", "param2": "goodbye"]
		let expectation = expectationWithDescription("\(URL)")
		
		Alamofire.request(.GET, URL, parameters: parameters).responseObject { (request: NSURLRequest, HTTPURLResponse: NSHTTPURLResponse?, response: Response?, data: AnyObject?, error: NSError?) in
			
			expectation.fulfill()
			
			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertNotNil(response?.arguments, "Arguents should not be nil")
			XCTAssertEqual(response!.arguments!, parameters, "Arguments should equal parameters that were passed into request")
			XCTAssertNotNil(response?.origin, "Origin should not be nil")
			XCTAssertNotNil(response?.url, "URL should not be nil")
			XCTAssertNotNil(response?.header, "Header should not be nil")
			XCTAssertNotNil(response?.header?.host, "Host should not be nil")
			XCTAssertNotNil(response?.header?.userAgent, "User Agent should not be nil")
		}
		
		waitForExpectationsWithTimeout(10, handler: { (error: NSError!) -> Void in
			XCTAssertNil(error, "\(error)")
		})
	}
}

class Response: Mappable {
	var header: Header?
	var origin: String?
	var url: NSURL?
	var arguments: [String:String]?
	
	init() {}
	
	required init?(_ map: Map) {
		mapping(map)
	}
	
	func mapping(map: Map) {
		header		<- map["headers"]
		origin		<- map["origin"]
		url			<- (map["url"], URLTransform())
		arguments	<- map["args"]
	}
}

class Header: Mappable {
	var host: String?
	var userAgent: String?
	
	init() {}
	
	required init?(_ map: Map) {
		mapping(map)
	}
	
	func mapping(map: Map) {
		host			<- map["Host"]
		userAgent		<- map["User-Agent"]
	}
}
