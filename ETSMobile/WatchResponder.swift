//
//  WatchResponder.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-26.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation

/// Any object that responds to a watch request should implement this protocol. You're right. This is not a protocol, but a class. This is because one can't bridge a protocol extension to objective-c. The only way is to define a class like so and implementing it in the old fashioned way.
@objc class WatchResponder : NSObject {
    /// Optional. If the object cannot handle the request, call its successor.
    var successor: WatchResponder?
    
    /// The request type handled by the responder.
    var type: String { fatalError("Not implemented") }
    
    /// Handles a request and returns the result to pass to the watch.
    ///
    /// - Parameter request: The request from the watch to be processed.
    /// - Returns: A dictionary to be passed to the watch which represents the response.
    func handleRequest(_ request: [String: Any]) -> [String: Any] {
        fatalError("Not implemented")
    }

    /// Checks if the responder can handle the request. If it can't, it calls its successor.
    ///
    /// - Parameter request: The request to be handled checked.
    /// - Returns: A dictionary containing the response to be passed to the watch. If no responder can handle the request, nil is returned.
    func processRequest(_ request: [String: Any]) -> [String: Any]? {
        guard request["type"] as! String == self.type else {
            return self.successor?.processRequest(request)
        }
        
        return self.handleRequest(request)
    }
}
