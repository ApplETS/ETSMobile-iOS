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
            guard self.supported else {
                observer.on(.error(Errors.NotSupportedError))
                return Disposables.create()
            }
            
            let requestObject = ["type": RequestTypes.CURRENT_COURSES.rawValue]
            
            self.session?.sendMessage(requestObject, replyHandler: { (responseObject: [String : Any]) in
                guard responseObject["type"] as? String == RequestTypes.OK.rawValue else {
                    observer.on(.error(Errors.RequestError))
                    return
                }
                
                observer.on(.next(
                    (responseObject["courses"] as! [Any]).map({ object -> CourseCalendarSession in
                        CourseCalendarSession(dictionary: object as! [String : Any?])!
                    })
                ))
                observer.on(.completed)
            }, errorHandler: { _ in
                observer.on(.error(Errors.RequestError))
            })
            
            return Disposables.create()
        }
    }
    
    
    /// Get the notes of the user for the current session. If the user is in between semesters, an empty array will be received.
    ///
    /// - Returns: An observable of an array of Course elements.
    func notesForCurrentSemester() -> Observable<[ETSCourse]> {
        return Observable.create { observer in
            guard self.supported else {
                observer.on(.error(Errors.NotSupportedError))
                return Disposables.create()
            }
            
            let requestObject = ["type": RequestTypes.CURRENT_NOTES.rawValue]
            
            self.session?.sendMessage(requestObject, replyHandler: { responseObject in
                guard responseObject["type"] as? String == RequestTypes.OK.rawValue else {
                    observer.on(.error(Errors.RequestError))
                    return
                }
                let courses = responseObject["notes"] as! [Dictionary<String, Any>]
                
                observer.on(.next(
                    courses.map { course in ETSCourse(dictionary: course) }
                ))
                observer.on(.completed)
            }, errorHandler: { _ in
                observer.on(.error(Errors.RequestError))
            })
            
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
