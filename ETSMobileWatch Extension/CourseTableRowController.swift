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
    
    var course: Course? {
        didSet {
            if let course = course {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/YY"
                
                self.acronymLabel.setText(course.acronym)
                self.courseDateLabel.setText(formatter.string(from: course.dateStart))
                self.courseTypeLabel.setText(course.type)
                self.locationLabel.setText(course.location)
                
                formatter.dateFormat = "H'h'mm"
                
                self.periodLabel.setText(String(
                    format: "%@ à %@",
                    formatter.string(from: course.dateStart),
                    formatter.string(from: course.dateEnd)
                ))
            }
        }
    }
}
