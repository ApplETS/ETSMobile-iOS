//
//  CoursesController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-13.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import WatchKit
import Foundation

class CoursesController : WKInterfaceController {
    @IBOutlet var todayCourseTable: WKInterfaceTable!
    @IBOutlet var laterCourseTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        self.updateCourses()
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    private func updateCourses() {
        let request = AppRequest()
        
        request.activateSession { _ in
            request.nextCourseSessionsInCalendar {
                (courses, error) in
                guard error == nil else {return}  // TODO: Display error message
                guard let courses = courses else {return}
                
                self.todayCourseTable.setNumberOfRows(courses.today.count, withRowType: "CourseTableRow")
                self.laterCourseTable.setNumberOfRows(courses.later.count, withRowType: "CourseTableRow")
                
                for index in 0...courses.today.count {
                    if let controller = self.todayCourseTable.rowController(at: index) as? CourseTableRowController {
                        controller.course = courses.today[index]
                    }
                }
                for index in 0...courses.later.count {
                    if let controller = self.laterCourseTable.rowController(at: index) as? CourseTableRowController {
                        controller.course = courses.later[index]
                    }
                }
            }
        }
    }
}
