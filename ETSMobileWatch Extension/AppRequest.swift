///
///  AppRequest.swift
///  ETSMobile
///
///  Created by Charles Levesque on 2017-04-12.
///  Copyright © 2017 ApplETS. All rights reserved.
///

import Foundation
import WatchConnectivity
import RxSwift

typealias ActivationCompletedCallback = (Error?) -> Void

private let NEXT_COURSES_IN_SESSION = "CurrentCourses"
private let TYPE = "type"

/// Represents a request made to the iOS application via Watch Connectivity Framework
class AppRequest : NSObject, WCSessionDelegate {
    private let session: WCSession?
    private let supported: Bool
    private var activationCompletedCallback: ActivationCompletedCallback?
    
    /// Possible errors for `AppRequest`.
    ///
    /// - NotActivatedError: Session is not activated.
    /// - RequestError: There has been an error with the request.
    /// - NotSupportedError: Watch Connectivity sessions are not supported.
    enum Errors : Error {
        case NotActivatedError
        case RequestError
        case NotSupportedError
    }
    
    // MARK: Init
    
    override init() {
        if WCSession.isSupported() {
            self.supported = true
            self.session = WCSession.default()
        } else {
            self.supported = false
            self.session = nil
        }
        
        super.init()
        self.session?.delegate = self
    }
    
    /// Activates the WCSession.
    ///
    /// - Parameters:
    ///     - callback: Callback clojure when activation is completed.
    func activateSession(_ callback: ActivationCompletedCallback? = {_ in}) {
        guard self.supported else {
            callback?(Errors.NotActivatedError)
            return
        }
        
        guard self.session?.activationState != .activated else {
            callback?(nil)
            return
        }
        
        self.activationCompletedCallback = callback
        self.session?.activate()
    }
    
    
    /// Get the next course sessions in the current calendar. If there's no current semester, sessions for next semesters are returned.
    ///
    /// - returns: An observable of the list of CourseCalendarElement elements.
    func nextCourseSessionsInCalendar() -> Observable<[CourseCalendarSession]> {
        return Observable.create { observer in
            if !self.supported {
                observer.on(.error(Errors.NotSupportedError))
            } else {
                let requestObject = [TYPE: NEXT_COURSES_IN_SESSION]
                
                self.session?.sendMessage(requestObject, replyHandler: { (responseObject: [String : Any]) in
                    observer.on(.next(
                        (responseObject["courses"] as! [Any]).map({ object -> CourseCalendarSession in
                            CourseCalendarSession(dictionary: object as! [String : Any])!
                        })
                    ))
                    observer.on(.completed)
                }, errorHandler: { _ in
                    observer.on(.error(Errors.RequestError))
                })
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: Watch Connectivity
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else {
            self.activationCompletedCallback?(Errors.NotActivatedError)
            return
        }
        
        self.activationCompletedCallback?(nil)
    }
}
