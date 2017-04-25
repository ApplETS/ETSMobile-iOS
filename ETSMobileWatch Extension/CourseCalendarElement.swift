//
//  Course.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-14.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation


/// Represents a course session in a calendar.
class CourseCalendarSession {
    let course: String
    let start: Date
    let end: Date
    let summary: String
    let room: String
    
    
    /// Default initializer of a CourseCalendarSession.
    ///
    /// - Parameters:
    ///   - course: The abbreviation of the course.
    ///   - start: The start date of the course session.
    ///   - end: The end date of the course session.
    ///   - summary: The summary of the session. Ex: Activité de cours, Laboratoire
    ///   - room: The room where the session takes in.
    init(course: String, start: Date, end: Date, summary: String, room: String) {
        self.course = course
        self.start = start
        self.end = end
        self.summary = summary
        self.room = room
    }
    
    
    /// Convenience initializer from a dictionary. Typically used with WatchConnectivity
    /// or JSON response from an API.
    ///
    /// - Parameter dictionary: The dictionary from which to get the information of the object.
    convenience init?(dictionary: [String: Any]) {
        guard let course = dictionary["course"] as? String,
            let start = dictionary["start"] as? Date,
            let end = dictionary["end"] as? Date,
            let summary = dictionary["summary"] as? String,
            let room = dictionary["room"] as? String else
        {
            return nil
        }
        
        self.init(
            course: course.characters.split(separator: "-").map(String.init).first!,  // Removes the group from the course abbreviation. Ex: LOG550-01 to LOG550
            start: start,
            end: end,
            summary: summary,
            room: room
        )
    }
}
