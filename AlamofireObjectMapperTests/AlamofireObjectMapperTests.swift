//
//  AlamofireObjectMapperTests.swift
//  AlamofireObjectMapperTests
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
        
        Alamofire.request(.GET, URL).responseObject { (response: Response<WeatherResponse, NSError>) in
            expectation.fulfill()
            
            let mappedObject = response.result.value
            
            XCTAssertNotNil(mappedObject, "Response should not be nil")
            XCTAssertNotNil(mappedObject?.location, "Location should not be nil")
            XCTAssertNotNil(mappedObject?.threeDayForecast, "ThreeDayForcast should not be nil")
            
            for forecast in mappedObject!.threeDayForecast! {
                XCTAssertNotNil(forecast.day, "day should not be nil")
                XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
            }
        }
        
        waitForExpectationsWithTimeout(10) { (error: NSError?) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testResponseObjectWithKeyPath() {
        // This is an example of a functional test case.
        let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/2ee8f34d21e8febfdefb2b3a403f18a43818d70a/sample_keypath_json"
        let expectation = expectationWithDescription("\(URL)")
        
        Alamofire.request(.GET, URL).responseObject("data") { (response: Response<WeatherResponse, NSError>) in
            expectation.fulfill()
            
            let mappedObject = response.result.value
            
            XCTAssertNotNil(mappedObject, "Response should not be nil")
            XCTAssertNotNil(mappedObject?.location, "Location should not be nil")
            XCTAssertNotNil(mappedObject?.threeDayForecast, "ThreeDayForcast should not be nil")
            
            for forecast in mappedObject!.threeDayForecast! {
                XCTAssertNotNil(forecast.day, "day should not be nil")
                XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
            }
        }
        
        waitForExpectationsWithTimeout(10) { (error: NSError?) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testResponseObjectWithNestedKeyPath() {
        // This is an example of a functional test case.
        let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/97231a04e6e4970612efcc0b7e0c125a83e3de6e/sample_keypath_json"
        let expectation = expectationWithDescription("\(URL)")
        
        Alamofire.request(.GET, URL).responseObject("response.data") { (response: Response<WeatherResponse, NSError>) in
            expectation.fulfill()
            
            let mappedObject = response.result.value
            
            XCTAssertNotNil(mappedObject, "Response should not be nil")
            XCTAssertNotNil(mappedObject?.location, "Location should not be nil")
            XCTAssertNotNil(mappedObject?.threeDayForecast, "ThreeDayForcast should not be nil")
            
            for forecast in mappedObject!.threeDayForecast! {
                XCTAssertNotNil(forecast.day, "day should not be nil")
                XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
            }
        }
        
        waitForExpectationsWithTimeout(10) { (error: NSError?) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testResponseArray() {
        // This is an example of a functional test case.
        let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/f583be1121dbc5e9b0381b3017718a70c31054f7/sample_array_json"
        let expectation = expectationWithDescription("\(URL)")

        Alamofire.request(.GET, URL).responseArray { (response: Response<[Forecast], NSError>) in
            expectation.fulfill()
            
            let mappedArray = response.result.value
            
            XCTAssertNotNil(mappedArray, "Response should not be nil")
            
            for forecast in mappedArray! {
                XCTAssertNotNil(forecast.day, "day should not be nil")
                XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
            }
        }

        waitForExpectationsWithTimeout(10) { (error: NSError?) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testArrayResponseArrayWithKeyPath() {
        // This is an example of a functional test case.
        let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/d8bb95982be8a11a2308e779bb9a9707ebe42ede/sample_json"
        let expectation = expectationWithDescription("\(URL)")
        
        Alamofire.request(.GET, URL).responseArray("three_day_forecast") { (response: Response<[Forecast], NSError>) in
        
            expectation.fulfill()
            
            let mappedArray = response.result.value
            
            XCTAssertNotNil(mappedArray, "Response should not be nil")
            
            for forecast in mappedArray! {
                XCTAssertNotNil(forecast.day, "day should not be nil")
                XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
            }
        }
        
        waitForExpectationsWithTimeout(10) { (error: NSError?) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testArrayResponseArrayWithNestedKeyPath() {
        // This is an example of a functional test case.
        let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/97231a04e6e4970612efcc0b7e0c125a83e3de6e/sample_keypath_json"
        let expectation = expectationWithDescription("\(URL)")
        
        Alamofire.request(.GET, URL).responseArray("response.data.three_day_forecast") { (response: Response<[Forecast], NSError>) in
            
            expectation.fulfill()
            
            let mappedArray = response.result.value
            
            XCTAssertNotNil(mappedArray, "Response should not be nil")
            
            for forecast in mappedArray! {
                XCTAssertNotNil(forecast.day, "day should not be nil")
                XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
            }
        }
        
        waitForExpectationsWithTimeout(10) { (error: NSError?) -> Void in
            XCTAssertNil(error, "\(error)")
        }
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
