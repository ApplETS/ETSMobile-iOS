//
//  Course.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-14.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation

struct Course {
    let acronym: String
    let dateStart: Date
    let dateEnd: Date
    let type: String
    let location: String
    
    init(acronym: String, dateStart: Date, dateEnd: Date, type: String, location: String) {
        self.acronym = acronym
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.type = type
        self.location = location
    }
}
