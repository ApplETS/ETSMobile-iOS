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
fileprivate let EVALUATIONS_TABLE_ROW_ID = "EvaluationsTableRow"

class NotesDetailsController : WKInterfaceController {
    @IBOutlet var statusGroupContainer: WKInterfaceGroup!
    @IBOutlet var statusGroup: WKInterfaceGroup!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var noteImage: WKInterfaceImage!
    
    // MARK: Detailed notes elements
    @IBOutlet var gradeLabel: WKInterfaceLabel!
    @IBOutlet var averageLabel: WKInterfaceLabel!
    @IBOutlet var medianLabel: WKInterfaceLabel!
    @IBOutlet var stdDeviationLabel: WKInterfaceLabel!
    @IBOutlet var percentileLabel: WKInterfaceLabel!
    @IBOutlet var evaluationsTable: WKInterfaceTable!
    
    private var course: ETSCourse!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let course = context as? ETSCourse else { return }
        
        self.course = course
        self.setTitle(self.course.acronym)
        self.gradeLabel.setText(self.course.grade ?? "-")
        self.averageLabel.setText(self.course.mean == nil ? "-" : String(format: "%0.1f%%", arguments: [self.course.mean!.floatValue]))
        self.medianLabel.setText(self.course.median == nil ? "-" : String(format: "%0.1f", arguments: [self.course.median!.floatValue]))
        self.stdDeviationLabel.setText(self.course.std == nil ? "-" : String(format: "%0.1f", arguments: [self.course.std!.floatValue]))
        self.percentileLabel.setText(self.course.percentile == nil ? "-" : String(format: "%0.f", arguments: [self.course.percentile!.floatValue]))
        
        if let evaluations = self.course.evaluations {
            self.evaluationsTable.setNumberOfRows(evaluations.count, withRowType: EVALUATIONS_TABLE_ROW_ID)
            
            for (index, evaluation) in evaluations.enumerated() {
                if let controller = self.evaluationsTable.rowController(at: index) as? EvaluationsTableRowController {
                    controller.evaluation = evaluation
                }
            }
        }
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
