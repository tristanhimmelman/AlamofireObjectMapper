AlamofireObjectMapper
============

An extension to [Alamofire](https://github.com/Alamofire/Alamofire) which automatically converts response data into swift objects using [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper/). 

#Usage

Given a URL which returns weather data in the following form:
```
{
    "location": "Toronto, Canada",    
    "conditions": "Partly cloudy",
    "temperature": 20
    "forecast": {
        "1pm" : 21,
        "2pm" : 22,
        "3pm" : 23
    }
}
```

You can use this extension as the follows:
```swift
let URL = "http://weather.com/toronto"
Alamofire.request(.GET, URL, parameters: nil).responseObject { (response: WeatherResponse?, error: NSError?) in
    println(response?.conditions)
    println(response?.temperature)
    println(response?.forecast?["3pm"])   
}
```

The `WeatherResponse` object in the completion handler is a custom object which you define. The only requirement is that the object must conform to [ObjectMapper's](https://github.com/Hearst-DD/ObjectMapper/) `Mappable` protocol. In the above example, the `WeatherResponse` object looks like the following:

```swift
class WeatherResponse: Mappable {
    var location: String?
    var conditions: String?
    var temperature: Int?
    var forecast: [String:Int]?
    
    init() {}
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        location    <- map["location"]
        conditions  <- map["conditions"]
        temperature <- map["temperature"]
        forecast    <- map["forecast"]
    }
}
```

The extension uses Generics to allow you to create your own custom response objects. Below are the three functions which you can use to have your responses mapped to objects. Just replace `T` with your custom response object and the extension handles the rest: 

```swift
func responseObject<T: Mappable>(completionHandler: (T?, NSError?) -> Void) -> Self
```

```swift
func responseObject<T: Mappable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, AnyObject?, NSError?) -> Void) -> Self
```

```swift
func responseObject<T: Mappable>(queue: dispatch_queue_t?, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, AnyObject?, NSError?) -> Void) -> Self
```

#Installation
AlamofireObjectMapper can be added to your project using [Cocoapods](https://cocoapods.org/) by adding the following line to your Podfile:
```
pod 'AlamofireObjectMapper', '~> 0.1'
```

If your using [Carthage](https://github.com/Carthage/Carthage) you can add a dependency on AlamofireObjectMapper by adding it to your Cartfile:
```
github "tristanhimmelman/AlamofireObjectMapper" ~> 0.1
```