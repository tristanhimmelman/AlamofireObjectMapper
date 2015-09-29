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
		let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/d8bb95982be8a11a2308e779bb9a9707ebe42ede/sample_json"
		let expectation = expectationWithDescription("\(URL)")

		Alamofire.request(.GET, URL, parameters: nil).responseObject { (response: WeatherResponse?, error: ErrorType?) in
			expectation.fulfill()

			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertNotNil(response?.location, "Location should not be nil")
			XCTAssertNotNil(response?.threeDayForecast, "ThreeDayForcast should not be nil")
			
			for forecast in response!.threeDayForecast! {
				XCTAssertNotNil(forecast.day, "day should not be nil")
				XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
				XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
			}
		}
        
		waitForExpectationsWithTimeout(10, handler: { (error: NSError?) -> Void in
			XCTAssertNil(error, "\(error)")
		})
    }
    
    
	func testResponseObject2() {
		// This is an example of a functional test case.
		
		let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/d8bb95982be8a11a2308e779bb9a9707ebe42ede/sample_json"
		let expectation = expectationWithDescription("\(URL)")
		
		Alamofire.request(.GET, URL, parameters: nil).responseObject { (request: NSURLRequest, HTTPURLResponse: NSHTTPURLResponse?, response: WeatherResponse?, data: AnyObject?, error: ErrorType?) in
			
			expectation.fulfill()
			
			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertNotNil(response?.location, "Location should not be nil")
			XCTAssertNotNil(response?.threeDayForecast, "ThreeDayForcast should not be nil")

			for forecast in response!.threeDayForecast! {
				XCTAssertNotNil(forecast.day, "day should not be nil")
				XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
				XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
			}
		}
		
		waitForExpectationsWithTimeout(10, handler: { (error: NSError?) -> Void in
			XCTAssertNil(error, "\(error)")
		})
	}
	
	func testArrayResponseObject() {
		// This is an example of a functional test case.
		let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/f583be1121dbc5e9b0381b3017718a70c31054f7/sample_array_json"
		let expectation = expectationWithDescription("\(URL)")
		
		Alamofire.request(.GET, URL, parameters: nil).responseArray { (response: [Forecast]?, error: ErrorType?) in
			expectation.fulfill()
			
			XCTAssertNotNil(response, "Response should not be nil")
			
			for forecast in response! {
				XCTAssertNotNil(forecast.day, "day should not be nil")
				XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
				XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
			}
		}
		
		waitForExpectationsWithTimeout(10, handler: { (error: NSError?) -> Void in
			XCTAssertNil(error, "\(error)")
		})
	}
	
	func testArrayResponseObject2() {
		// This is an example of a functional test case.
		let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/f583be1121dbc5e9b0381b3017718a70c31054f7/sample_array_json"
		let expectation = expectationWithDescription("\(URL)")
		
		Alamofire.request(.GET, URL, parameters: nil).responseArray { (request: NSURLRequest, HTTPURLResponse: NSHTTPURLResponse?, response: [Forecast]?, data: AnyObject?, error: ErrorType?) in
			expectation.fulfill()
			
			XCTAssertNotNil(response, "Response should not be nil")
			
			for forecast in response! {
				XCTAssertNotNil(forecast.day, "day should not be nil")
				XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
				XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
			}
		}
		
		waitForExpectationsWithTimeout(10, handler: { (error: NSError?) -> Void in
			XCTAssertNil(error, "\(error)")
		})
	}
    
    func testArrayResponseArrayWithKeyPath() {
        // This is an example of a functional test case.
        let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/d8bb95982be8a11a2308e779bb9a9707ebe42ede/sample_json"
        let expectation = expectationWithDescription("\(URL)")
        
        Alamofire.request(.GET, URL, parameters: nil).responseArray ("three_day_forecast", completionHandler: { (request: NSURLRequest, HTTPURLResponse: NSHTTPURLResponse?, response: [Forecast]?, data: AnyObject?, error: ErrorType?) in
            expectation.fulfill()
            
            XCTAssertNotNil(response, "Response should not be nil")
            
            for forecast in response! {
                XCTAssertNotNil(forecast.day, "day should not be nil")
                XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
            }
        })
        
        waitForExpectationsWithTimeout(10, handler: { (error: NSError?) -> Void in
            XCTAssertNil(error, "\(error)")
        })
    }


}

class WeatherResponse: Mappable {
	var location: String?
	var threeDayForecast: [Forecast]?
	
	required init?(_ map: Map){

	}
	
	func mapping(map: Map) {
		location <- map["location"]
		threeDayForecast <- map["three_day_forecast"]
	}
}

class Forecast: Mappable {
	var day: String?
	var temperature: Int?
	var conditions: String?
	
	required init?(_ map: Map){

	}
	
	func mapping(map: Map) { 
		day <- map["day"]
		temperature <- map["temperature"]
		conditions <- map["conditions"]
	}
}
