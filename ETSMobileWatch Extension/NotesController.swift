//
//  NotesController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-26.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation
import WatchKit
import RxSwift

private let TABLE_ROW_TYPE = "NotesTableRow"

class NotesController : WKInterfaceController {
    @IBOutlet var noNotesLabel: WKInterfaceLabel!
    @IBOutlet var notesTable: WKInterfaceTable!
    
    private let disposeBag = DisposeBag()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        self.updateCourseNotesList()
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    private func updateCourseNotesList() {
        let request = AppRequest()
        
        request.activateSession { error in
            request
                .notesForCurrentSemester()
                .timeout(5, scheduler: MainScheduler.instance)
                .retry(5)
                .do(onNext: {[weak self] courses in
                    self?.noNotesLabel.setHidden(courses.count > 0)
                })
                .subscribe(onNext: {[weak self] courses in
                    self?.notesTable.setNumberOfRows(courses.count, withRowType: TABLE_ROW_TYPE)
                    
                    for index in 0..<courses.count {
                        if let controller = self?.notesTable.rowController(at: index) as? NotesTableRowController {
                            let course = courses[index]
                            let results = course.results?.floatValue
                            let note = course.grade ??
                                (results == nil ? "-" : String(format: "%.1f%%", arguments: [results!]))
                            
                            if course.grade == nil, let currentResult = results {
                                switch true {
                                case 0.0 <= currentResult && currentResult < 50.0:
                                    controller.noteLabel.setTextColor(UIColor.error())
                                    break
                                    
                                case 50.0 <= currentResult && currentResult < 75.0:
                                    controller.noteLabel.setTextColor(UIColor.warning())
                                    break
                                    
                                case currentResult >= 75.0:
                                    controller.noteLabel.setTextColor(UIColor.success())
                                    break
                                    
                                default:
                                    controller.noteLabel.setTextColor(UIColor.white)
                                    break
                                }
                            } else {
                                controller.noteLabel.setTextColor(UIColor.white)
                            }
                            
                            controller.courseLabel.setText(course.acronym)
                            controller.noteLabel.setText(note)
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
}
