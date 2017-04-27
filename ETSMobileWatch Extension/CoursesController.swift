//
//  CoursesController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-13.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import WatchKit
import Foundation
import RxSwift

private let TABLE_ROW_TYPE = "CourseTableRow"

class CoursesController : WKInterfaceController {
    @IBOutlet var todayCourseTable: WKInterfaceTable!
    @IBOutlet var laterCourseTable: WKInterfaceTable!
    @IBOutlet var todayNoCourseLabel: WKInterfaceLabel!
    @IBOutlet var laterNoCourseLabel: WKInterfaceLabel!
    
    private let disposeBag = DisposeBag()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        self.updateCourses()
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    private func updateCourses() {
        let request = AppRequest()
        
        request.activateSession { error in
            request
                .nextCourseSessionsInCalendar()
                .timeout(5, scheduler: MainScheduler.instance)
                .retry(5)
                .map { elements -> (today: [CourseCalendarSession], later: [CourseCalendarSession]) in
                    let calendar = Calendar.current
                    let startOfToday = calendar.startOfDay(for: Date())
                    var endOfTodayComponents = DateComponents()
                    
                    endOfTodayComponents.day = 1
                    endOfTodayComponents.second = -1
                    
                    let endOfToday = calendar.date(byAdding: endOfTodayComponents, to: startOfToday)!
                    
                    return (
                        today: elements.filter { course in startOfToday <= course.start && course.start <= endOfToday },
                        later: elements.filter { course in endOfToday < course.start }
                    )
                }
                .do(onNext: {[weak self] (courses: (today: [CourseCalendarSession], later: [CourseCalendarSession])) in
                    self?.todayNoCourseLabel.setHidden(courses.today.count > 0)
                    self?.laterNoCourseLabel.setHidden(courses.later.count > 0)
                })
                .subscribe(onNext: {[weak self] courses in
                    self?.todayCourseTable.setNumberOfRows(courses.today.count, withRowType: TABLE_ROW_TYPE)
                    self?.laterCourseTable.setNumberOfRows(courses.later.count, withRowType: TABLE_ROW_TYPE)
                    
                    for index in 0...courses.today.count {
                        if let controller = self?.todayCourseTable.rowController(at: index) as? CourseTableRowController {
                            controller.course = courses.today[index]
                        }
                    }
                    
                    for index in 0...courses.later.count {
                        if let controller = self?.laterCourseTable.rowController(at: index) as? CourseTableRowController {
                            controller.course = courses.later[index]
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
}
