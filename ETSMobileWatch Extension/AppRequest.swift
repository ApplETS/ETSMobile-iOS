///
///  AppRequest.swift
///  ETSMobile
///
///  Created by Charles Levesque on 2017-04-12.
///  Copyright © 2017 ApplETS. All rights reserved.
///

import Foundation
import WatchConnectivity

/// Represents a request made to the iOS application via Watch Connectivity Framework
class AppRequest : NSObject, WCSessionDelegate {
    static let NEXT_COURSE_SESSIONS = "CurrentCourses"
    
    private let session: WCSession?
    private let supported: Bool
    
    private var onActivatedClosure: (_ error: Error?) -> Void = {_ in }
    
    
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
    ///   - onActivatedClosure: Closure called when the session has been activated.
    func activateSession(_ onActivatedClosure: @escaping ((_ error: Error?) -> Void) = {_ in }) {
        guard self.supported else {
            onActivatedClosure(Errors.NotActivatedError)
            return
        }
        
        guard self.session?.activationState != .activated else {
            onActivatedClosure(nil)
            return
        }
        
        self.onActivatedClosure = onActivatedClosure
        self.session?.activate()
    }
    
    
    /// Get the next course sessions in the current calendar. If there's no current semester, sessions for next semesters are returned.
    ///
    /// - Parameters:
    ///   - onReceiveMessageClosure: Closure called when a response comes in.
    func nextCourseSessionsInCalendar(_ onReceiveMessageClosure: @escaping (((today: [CourseCalendarElement], later: [CourseCalendarElement])?, _ error: Error?) -> Void) = { _, _ in }) {
        guard self.supported else {
            onReceiveMessageClosure(nil, Errors.NotSupportedError)
            return
        }
        
        let requestObject = [
            "type": AppRequest.NEXT_COURSE_SESSIONS
        ]
        
        self.session?.sendMessage(requestObject, replyHandler: { (responseObject: [String : Any]) in
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            var endOfTodayComponents = DateComponents()
            
            endOfTodayComponents.day = 1
            endOfTodayComponents.second = -1
            
            let endOfToday = calendar.date(byAdding: endOfTodayComponents, to: startOfToday)!
            let courses: [CourseCalendarElement] = (responseObject["courses"] as! [Any]).map { object -> CourseCalendarElement in
                CourseCalendarElement.fromDictionary(object as! [String : Any])!
            }
            
            onReceiveMessageClosure((
                today: courses.filter({ course -> Bool in
                    return startOfToday <= course.start && course.start <= endOfToday
                }),
                later: courses.filter({ course -> Bool in
                    return endOfToday < course.start
                })
            ), nil)
        }, errorHandler: { _ in
            onReceiveMessageClosure(nil, Errors.RequestError)
        })
    }
    
    // MARK: Watch Connectivity
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else {
            self.onActivatedClosure(Errors.NotActivatedError)
            return
        }
        
        self.onActivatedClosure(nil)
    }
}
