//
//  CourseCalendarResponder.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-26.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc class CourseCalendarResponder : WatchResponder {
    private let managedObjectContext: NSManagedObjectContext
    
    override var type: String { return "CurrentCourses" }
    
    /// Initializer of a CourseCalendarResponder. It needs to access the Core Date context.
    ///
    /// - Parameter managedObjectContext: The app's Core Date managed object context.
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    override func handleRequest(_ request: [String : Any]) -> [String : Any] {
        let errorResponse = ["type": "error"]
        guard request["type"] as! String == self.type else { return errorResponse }
        
        var response: [String: Any] = ["type": "OK"]
        
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        var fourMonthsEarlierComponents = DateComponents()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        let sessions: [ETSSession]
        
        fourMonthsEarlierComponents.month = -4
        
        let fourMonthsEarlier = calendar.date(byAdding: fourMonthsEarlierComponents, to: now)!
        let predicate = NSPredicate(format: "start >= %@", argumentArray: [fourMonthsEarlier])
        
        request.predicate = predicate
        
        do {
            sessions = try self.managedObjectContext.fetch(request) as! [ETSSession]
        } catch {
            return errorResponse
        }
        
        var courses = [ETSCalendar]()
        GetCalendarLoop: for session in sessions {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Calendar")
            let predicate = NSPredicate(format: "session == %@ AND start >= %@", argumentArray: [session.acronym, startOfToday])
            
            request.predicate = predicate
            request.fetchLimit = 10
            request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
            
            do {
                let fetchedCourses = try self.managedObjectContext.fetch(request) as! [ETSCalendar]
                let diff = 10 - courses.count
                    
                courses.append(contentsOf: fetchedCourses.prefix(diff))
                
                if courses.count >= 10 {
                    break GetCalendarLoop
                }
            } catch {
                return errorResponse
            }
        }
        
        response["courses"] = courses.map { course in course.dictionary() }
        return response
    }
}
