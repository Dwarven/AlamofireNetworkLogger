# AlamofireNetworkLogger

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AlamofireNetworkLogger.svg)](https://img.shields.io/cocoapods/v/AlamofireNetworkLogger.svg)
[![Platform](https://img.shields.io/cocoapods/p/AlamofireNetworkLogger.svg)](http://cocoadocs.org/docsets/AlamofireNetworkLogger)
[![Twitter](https://img.shields.io/badge/twitter-@DwarvenYang-blue.svg)](http://twitter.com/DwarvenYang)
[![License](https://img.shields.io/github/license/Dwarven/AlamofireNetworkLogger.svg)](https://img.shields.io/github/license/Dwarven/AlamofireNetworkLogger.svg)

Network Logger for Alamofire

# Requirements
- iOS 9.0+ / macOS 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Swift 3.0+
- [Alamofire 4.0+](https://github.com/Alamofire/Alamofire)

# Podfile
To integrate AlamofireNetworkLogger into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AlamofireNetworkLogger'
```
# Preview
![](https://raw.githubusercontent.com/Dwarven/AlamofireNetworkLogger/master/log.gif)

# How to use
```swift
import AlamofireNetworkLogger
```

Add the following code to `AppDelegate.swift application:didFinishLaunchingWithOptions:`:

```swift
AlamofireNetworkLogger.shared.startLogging()
AlamofireNetworkLogger.shared.level = .debug // or .info .error .off
```

