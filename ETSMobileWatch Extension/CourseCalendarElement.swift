//
//  Course.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-14.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation

class CourseCalendarElement {
    let course: String
    let start: Date
    let end: Date
    let summary: String
    let room: String
    
    init(course: String, start: Date, end: Date, summary: String, room: String) {
        self.course = course
        self.start = start
        self.end = end
        self.summary = summary
        self.room = room
    }
    
    class func fromDictionary(_ dictionary: [String: Any]) -> CourseCalendarElement? {
        guard let course = dictionary["course"] as? String,
            let start = dictionary["start"] as? Date,
            let end = dictionary["end"] as? Date,
            let summary = dictionary["summary"] as? String,
            let room = dictionary["room"] as? String else
        {
            return nil
        }
        
        return CourseCalendarElement(
            course: course,
            start: start,
            end: end,
            summary: summary,
            room: room
        )
    }
}
