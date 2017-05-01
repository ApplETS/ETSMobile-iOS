//
//  NotesDetailsController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-30.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation
import WatchKit

fileprivate let STATUS_GROUP_CONTAINER_SIZE = CGSize(width: 150, height: 15)

class NotesDetailsController : WKInterfaceController {
    @IBOutlet var statusGroupContainer: WKInterfaceGroup!
    @IBOutlet var statusGroup: WKInterfaceGroup!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var noteImage: WKInterfaceImage!
    
    private var course: ETSCourse!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let course = context as? ETSCourse else { return }
        
        self.course = course
        self.setTitle(self.course.acronym)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func didAppear() {
        super.didAppear()
        let statusColor = self.course.grade == nil ? UIColor.warning() : UIColor.success()
        let statusText = self.course.grade == nil ? "En cours" : "Complété"
        var note = self.course.results?.floatValue ?? 0
        
        note.round()
        self.statusLabel.setText(statusText)
        self.statusGroup.setBackgroundColor(statusColor)
        
        let roundedNote = Int(note)
        
        self.animate(withDuration: 0.3) {
            self.statusGroup.setWidth(STATUS_GROUP_CONTAINER_SIZE.width)
            self.statusGroup.setHeight(STATUS_GROUP_CONTAINER_SIZE.height)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.noteImage.setImageNamed("progressArc")
            self.noteImage.startAnimatingWithImages(in: NSRange(location: 0, length: roundedNote), duration: 0.5, repeatCount: 1)
        }
    }
}
