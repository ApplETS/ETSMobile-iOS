//
//  NotesResponder.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-27.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation
import CoreData

/// Responds to a request for notes
@objc class NotesResponder : WatchResponder {
    private let managedObjectContext: NSManagedObjectContext
    
    override var type: String { return RequestTypes.CURRENT_NOTES.rawValue }
    
    /// Initializer of a NotesResponder. It needs to access the Core Date context.
    ///
    /// - Parameter managedObjectContext: The app's Core Date managed object context.
    init(managedObjectContext context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    override func handleRequest(_ request: [String : Any]) -> [String : Any] {
        let errorResponse = ["type": RequestTypes.ERROR.rawValue]
        guard request["type"] as! String == self.type else { return errorResponse }
        
        var response: [String: Any] = ["type": RequestTypes.OK.rawValue]
        let now = Date()
        let calendar = Calendar.current
        var threeMonthsEarlierComponents = DateComponents()
        
        threeMonthsEarlierComponents.month = -3
        
        let threeMonthsEarlier = calendar.date(byAdding: threeMonthsEarlierComponents, to: now)!
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        var predicate = NSPredicate(format: "start <= %@", argumentArray: [threeMonthsEarlier])
        let currentSession: ETSSession
        
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            guard let potentialSession = try (self.managedObjectContext.fetch(request) as! [ETSSession]).first else {
                response["notes"] = []
                return response
            }
            
            currentSession = potentialSession
        } catch {
            return errorResponse
        }
        
        request = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        predicate = NSPredicate(format: "session == %@", argumentArray: ["H2017"])
        let currentCoursesNotes: [ETSCourse]
        
        request.predicate = predicate
        
        do {
            currentCoursesNotes = try self.managedObjectContext.fetch(request) as! [ETSCourse]
        } catch {
            return errorResponse
        }
        
        response["notes"] = currentCoursesNotes.map { course in course.dictionary() }
        return response
    }
}
