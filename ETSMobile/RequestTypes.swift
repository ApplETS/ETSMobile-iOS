//
//  RequestTypes.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-27.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation

/// Request types for watch requests.
enum RequestTypes : String, CustomStringConvertible {
    case CURRENT_COURSES = "CurrentCourses"
    case CURRENT_NOTES = "CurrentNotes"
    case ERROR = "error"
    case OK = "OK"
    
    var description: String {
        return self.rawValue
    }
}
