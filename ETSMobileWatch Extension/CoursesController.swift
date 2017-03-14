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
    
    var courses = [Course]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let calendar = Calendar.current
        var aDay = DateComponents()
        aDay.day = 1
        var threeHours = DateComponents()
        threeHours.hour = 3
        var twoHours = DateComponents()
        twoHours.hour = 2
        var endOfTodayComponents = DateComponents()
        endOfTodayComponents.day = 1
        endOfTodayComponents.second = -1
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        let endOfToday = calendar.date(byAdding: endOfTodayComponents, to: startOfToday)!
        let tomorrow = calendar.date(byAdding: aDay, to: startOfToday)!
        let firstCourseEnd = calendar.date(byAdding: threeHours, to: today)!
        let secondCourseStart = calendar.date(byAdding: twoHours, to: firstCourseEnd)!
        let secondCourseEnd = calendar.date(byAdding: threeHours, to: secondCourseStart)!
        
        self.courses.append(contentsOf: [
            Course(acronym: "LOG410", dateStart: today, dateEnd: firstCourseEnd, type: "Activité de cours", location: "A1170"),
            Course(acronym: "ING150", dateStart: secondCourseStart, dateEnd: secondCourseEnd, type: "Laboratoire", location: "A3322"),
            Course(acronym: "MEC200", dateStart: tomorrow, dateEnd: calendar.date(byAdding: twoHours, to: tomorrow)!, type: "Travaux pratiques", location: "B2633")
        ])
        
        let todayCourses = self.courses.filter { (course: Course) -> Bool in
            return today <= course.dateStart && course.dateStart <= endOfToday
        }
        let laterCourses = self.courses.filter { (course: Course) -> Bool in
            return endOfToday < course.dateStart
        }
        
        self.todayCourseTable.setNumberOfRows(todayCourses.count, withRowType: "CourseTableRow")
        self.laterCourseTable.setNumberOfRows(laterCourses.count, withRowType: "CourseTableRow")
        
        for index in 0...self.todayCourseTable.numberOfRows {
            if let controller = self.todayCourseTable.rowController(at: index) as? CourseTableRowController {
                controller.course = todayCourses[index]
            }
        }
        for index in 0...self.laterCourseTable.numberOfRows {
            if let controller = self.laterCourseTable.rowController(at: index) as? CourseTableRowController {
                controller.course = laterCourses[index]
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
