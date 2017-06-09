//
//  CourseTableRowController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-14.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import WatchKit
import Foundation

class CourseTableRowController : NSObject {
    @IBOutlet var acronymLabel: WKInterfaceLabel!
    @IBOutlet var courseDateLabel: WKInterfaceLabel!
    @IBOutlet var courseTypeLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!
    @IBOutlet var periodLabel: WKInterfaceLabel!
    
    var course: CourseCalendarSession? {
        didSet {
            if let course = course {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/YY"
                
                self.acronymLabel.setText(course.course)
                self.courseDateLabel.setText(formatter.string(from: course.start))
                self.courseTypeLabel.setText(course.summary)
                self.locationLabel.setText(course.room)
                
                formatter.dateFormat = "H'h'mm"
                
                self.periodLabel.setText(String(
                    format: "%@ à %@",
                    formatter.string(from: course.start),
                    formatter.string(from: course.end)
                ))
            }
        }
    }
}
