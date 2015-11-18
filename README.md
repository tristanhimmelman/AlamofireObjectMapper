AlamofireObjectMapper
============
[![Build Status](https://travis-ci.org/tristanhimmelman/AlamofireObjectMapper.svg?branch=master)](https://travis-ci.org/tristanhimmelman/AlamofireObjectMapper)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlamofireObjectMapper.svg)](https://github.com/tristanhimmelman/AlamofireObjectMapper)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


An extension to [Alamofire](https://github.com/Alamofire/Alamofire) which automatically converts JSON response data into swift objects using [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper/). 

#Usage

Given a URL which returns weather data in the following form:
```
{
    "location": "Toronto, Canada",    
    "three_day_forecast": [
        { 
            "conditions": "Partly cloudy",
            "day" : "Monday",
            "temperature": 20 
        },
        { 
            "conditions": "Showers",
            "day" : "Tuesday",
            "temperature": 22 
        },
        { 
            "conditions": "Sunny",
            "day" : "Wednesday",
            "temperature": 28 
        }
    ]
}
```

You can use this extension as the follows:
```swift
let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/d8bb95982be8a11a2308e779bb9a9707ebe42ede/sample_json"
Alamofire.request(.GET, URL).responseObject("data") { (response: Response<WeatherResponse, NSError>) in

    let weatherResponse = response.result.value
    print(weatherResponse?.location)
    
    if let threeDayForecast = weatherResponse?.threeDayForecast {
        for forecast in threeDayForecast {
            print(forecast.day)
            print(forecast.temperature)           
        }
    }
}
```

The `WeatherResponse` object in the completion handler is a custom object which you define. The only requirement is that the object must conform to [ObjectMapper's](https://github.com/Hearst-DD/ObjectMapper/) `Mappable` protocol. In the above example, the `WeatherResponse` object looks like the following:

```swift
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
```

The extension uses Generics to allow you to create your own custom response objects. Below are four functions which you can use to have your responses mapped to objects. Just replace `T` with your custom response object and the extension handles the rest: 
```swift
public func responseObject<T: Mappable>(completionHandler: Response<T, NSError> -> Void) -> Self
```

```swift
public func responseObject<T: Mappable>(keyPath: String, completionHandler: Response<T, NSError> -> Void) -> Self
```

```swift
public func responseObject<T: Mappable>(queue: dispatch_queue_t?, completionHandler: Response<T, NSError> -> Void) -> Self
```

```swift
public func responseObject<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<T, NSError> -> Void) -> Self
```

###KeyPath

The `keyPath` variable in the functions above is used to drill down in a JSON response and only map the data at that `keyPath`. It also supports nested values such as `data.weather` to drill down several levels in a JSON response.

#Array Responses
If you have an endpoint that returns data in `Array` form you can map it with the following functions:
```swift
public func responseArray<T: Mappable>(completionHandler: Response<[T], NSError> -> Void) -> Self
```

```swift
public func responseArray<T: Mappable>(keyPath: String, completionHandler: Response<[T], NSError> -> Void) -> Self
```

```swift
public func responseArray<T: Mappable>(queue: dispatch_queue_t?, completionHandler: Response<[T], NSError> -> Void) -> Self
```

```swift
public func responseArray<T: Mappable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<[T], NSError> -> Void) -> Self
```

For example, if your endpoint returns the following:
```
[
    { 
        "conditions": "Partly cloudy",
        "day" : "Monday",
        "temperature": 20 
    },
    { 
        "conditions": "Showers",
        "day" : "Tuesday",
        "temperature": 22 
    },
    { 
        "conditions": "Sunny",
        "day" : "Wednesday",
        "temperature": 28 
    }
]
```
You can request and map it as follows:
```swift
let URL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/f583be1121dbc5e9b0381b3017718a70c31054f7/sample_array_json"
Alamofire.request(.GET, URL).responseArray { (response: Response<[Forecast], NSError>) in

    let forecastArray = response.result.value
    
    if let forecastArray = forecastArray {
        for forecast in forecastArray {
            print(forecast.day)
            print(forecast.temperature)           
        }
    }
}

```

#Installation
AlamofireObjectMapper can be added to your project using [Cocoapods](https://cocoapods.org/) by adding the following line to your Podfile:
```
pod 'AlamofireObjectMapper', '~> 2.0'
```

If your using [Carthage](https://github.com/Carthage/Carthage) you can add a dependency on AlamofireObjectMapper by adding it to your Cartfile:
```
github "tristanhimmelman/AlamofireObjectMapper" ~> 2.0
```
