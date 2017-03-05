//
//  AlamofireNetworkLogger.swift
//  https://github.com/Dwarven/AlamofireNetworkLogger
//
//  MIT License
//
//  Copyright (c) 2017 Dwarven Yang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Alamofire
import Foundation

/// The level of logging detail.
public enum AlamofireNetworkLoggerLevel {
    /// Do not log requests or responses.
    case off
    
    /// Logs HTTP method, URL, header fields, & request body for requests, and status code, URL, header fields, response string, & elapsed time for responses.
    case debug
    
    /// Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses.
    case info
    
    /// Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses, but only for failed requests.
    case error
}

/// `AlamofireNetworkLogger` logs requests and responses made by Alamofire.SessionManager, with an adjustable level of detail.
public class AlamofireNetworkLogger {
    // MARK: - Properties
    
    /// The shared network activity logger for the system.
    public static let shared = AlamofireNetworkLogger()
    
    /// The level of logging detail. See AlamofireNetworkLoggerLevel enum for possible values. .info by default.
    public var level: AlamofireNetworkLoggerLevel
    
    /// Omit requests which match the specified predicate, if provided.
    public var filterPredicate: NSPredicate?
    
    private var startDates: [URLSessionTask: Date]
    
    // MARK: - Internal - Initialization
    
    init() {
        level = .info
        startDates = [URLSessionTask: Date]()
    }
    
    deinit {
        stopLogging()
    }
    
    // MARK: - Logging
    
    /// Start logging requests and responses.
    public func startLogging() {
        stopLogging()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(AlamofireNetworkLogger.networkRequestDidStart(notification:)),
            name: Notification.Name.Task.DidResume,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(AlamofireNetworkLogger.networkRequestDidComplete(notification:)),
            name: Notification.Name.Task.DidComplete,
            object: nil
        )
    }
    
    /// Stop logging requests and responses.
    public func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private - Notifications
    
    @objc private func networkRequestDidStart(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else {
                return
        }
        
        
        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }
        
        startDates[task] = Date()
        
        switch level {
        case .debug:
            var log: String
            if let httpHeadersFields = request.allHTTPHeaderFields, httpHeadersFields.keys.count > 0 {
                log = String(format: "%@ \'%@\': %@ ", httpMethod, requestURL.absoluteString, request.allHTTPHeaderFields!)
            } else {
                log = "\(httpMethod) '\(requestURL.absoluteString)' "
            }
            
            if let httpBody = request.httpBody, let httpBodyString = String(data: httpBody, encoding: .utf8) {
                log.append(httpBodyString)
            }
            print(log)
        case .info:
            print("\(httpMethod) '\(requestURL.absoluteString)'")
        default:
            break
        }
    }
    
    @objc private func networkRequestDidComplete(notification: Notification) {
        guard let sessionDelegate = notification.object as? SessionDelegate,
            let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else {
                return
        }
        
        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }
        
        var elapsedTime: TimeInterval = 0.0
        
        if let startDate = startDates[task] {
            elapsedTime = Date().timeIntervalSince(startDate)
            startDates[task] = nil
        }
        
        if let error = task.error {
            switch level {
            case .debug,
                 .info,
                 .error:
                print("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                print(error)
            default:
                break
            }
        } else {
            guard let response = task.response as? HTTPURLResponse else {
                return
            }
            
            switch level {
            case .debug:
                var log = String(format: "%d \'%@\' [%.04f s]: %@ ", response.statusCode, requestURL.absoluteString, elapsedTime, response.allHeaderFields)
                
                guard let data = sessionDelegate[task]?.delegate.data else { break }
                    
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    
                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        log.append(prettyString)
                    }
                } catch {
                    if let string = String(data: data, encoding: .utf8) {
                        log.append(string)
                    }
                }
                print(log)
            case .info:
                print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]")
            default:
                break
            }
        }
    }
}
