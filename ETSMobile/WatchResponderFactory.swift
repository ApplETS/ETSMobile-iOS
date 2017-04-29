//
//  WatchResponderFactory.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-26.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation
import CoreData

/// Factory that builds the responders and their successors.
@objc class WatchResponderFactory : NSObject {
    private let managedObjectContext: NSManagedObjectContext
    
    /// Default responder for a watch request.
    lazy var defaultResponder: WatchResponder = {[unowned self] in
        let courseCalendarResponder = CourseCalendarResponder(managedObjectContext: self.managedObjectContext)
        let notesResponder = NotesResponder(managedObjectContext: self.managedObjectContext)
        
        courseCalendarResponder.successor = notesResponder
        
        return courseCalendarResponder
    }()
    
    /// Initializer of the factory. It needs all the dependency objects of all the responders.
    ///
    /// - Parameter managedObjectContext: The managed object context of Core Data.
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
}
