//
//  CoursesController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-13.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

class CoursesController : WKInterfaceController, WCSessionDelegate {
    @IBOutlet var todayCourseTable: WKInterfaceTable!
    @IBOutlet var laterCourseTable: WKInterfaceTable!
    
    var session: WCSession?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            self.session = WCSession.default()
            self.session?.delegate = self
            self.session?.activate()
        }
    }
    
    override func willActivate() {
        self.updateCourses()
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    // MARK: Watch Connectivity
    
    /// From WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else {
            return
        }
        
        self.updateCourses()
    }
    
    private func updateCourses() {
        guard session?.activationState == .activated else {
            return
        }
        
        let message = [
            "type": "CurrentCourses"
        ]
        self.session?.sendMessage(message, replyHandler: { response in
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            var endOfTodayComponents = DateComponents()
            
            endOfTodayComponents.day = 1
            endOfTodayComponents.second = -1
            
            let endOfToday = calendar.date(byAdding: endOfTodayComponents, to: startOfToday)!
            let courses: [Course] = (response["courses"] as! [Any]).map { object -> Course in
                let dict = object as! [String : Any]
                return Course(
                    acronym: (dict["course"] as! String).components(separatedBy: "-").first!,
                    dateStart: dict["start"] as! Date,
                    dateEnd: dict["end"] as! Date,
                    type: dict["summary"] as! String,
                    location: dict["room"] as! String
                )
            }
            let (todayCourses, laterCourses) = (
                courses.filter({ course -> Bool in
                    return startOfToday <= course.dateStart && course.dateStart <= endOfToday
                }),
                courses.filter({ course -> Bool in
                    return endOfToday < course.dateStart
                })
            )
            
            self.todayCourseTable.setNumberOfRows(todayCourses.count, withRowType: "CourseTableRow")
            self.laterCourseTable.setNumberOfRows(laterCourses.count, withRowType: "CourseTableRow")
            
            for index in 0...todayCourses.count {
                if let controller = self.todayCourseTable.rowController(at: index) as? CourseTableRowController {
                    controller.course = todayCourses[index]
                }
            }
            for index in 0...laterCourses.count {
                if let controller = self.laterCourseTable.rowController(at: index) as? CourseTableRowController {
                    controller.course = laterCourses[index]
                }
            }
        }, errorHandler: nil)
    }
}
