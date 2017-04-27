//
//  NotesController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-26.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation
import WatchKit

private let TABLE_ROW_TYPE = "NotesTableRow"

class NotesController : WKInterfaceController {
    @IBOutlet var noNotesLabel: WKInterfaceLabel!
    @IBOutlet var notesTable: WKInterfaceTable!
    
    private let notesList = [
        [
            "note": 97,
            "course": "LOG550"
        ],
        [
            "note": 67,
            "course": "ING150"
        ],
        [
            "note": 48,
            "course": "MAT472"
        ]
    ]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        self.notesTable.setNumberOfRows(self.notesList.count, withRowType: TABLE_ROW_TYPE)
        
        for index in 0...self.notesList.count {
            if let controller = self.notesTable.rowController(at: index) as? NotesTableRowController {
                let note = self.notesList[index]
                let percentage = note["note"] as! Int
                
                switch true {
                case percentage < 50:
                    controller.noteLabel.setTextColor(UIColor.error())
                    break
                
                case 50 <= percentage && percentage < 75:
                    controller.noteLabel.setTextColor(UIColor.warning())
                    break
                    
                case percentage >= 75:
                    controller.noteLabel.setTextColor(UIColor.success())
                    break
                
                default:
                    controller.noteLabel.setTextColor(UIColor.white)
                    break
                }
                
                controller.courseLabel.setText(note["course"] as? String)
                controller.noteLabel.setText("\(percentage) %")
            }
        }
        
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
