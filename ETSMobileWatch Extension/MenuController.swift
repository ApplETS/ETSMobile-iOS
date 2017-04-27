//
//  InterfaceController.swift
//  ETSMobileWatch Extension
//
//  Created by Charles Levesque on 2017-03-13.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import WatchKit
import Foundation


class MenuController: WKInterfaceController {
    @IBOutlet var firstGroup: WKInterfaceGroup!
    @IBOutlet var secondGroup: WKInterfaceGroup!
    @IBOutlet var coursesButton: WKInterfaceImage!
    @IBOutlet var notesButton: WKInterfaceButton!
    @IBOutlet var profileButton: WKInterfaceButton!
    @IBOutlet var importantDatesButton: WKInterfaceButton!
    @IBOutlet var mainGroup: WKInterfaceGroup!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        let deviceBounds = WKInterfaceDevice.current().screenBounds
        let buttonsSize = CGSize(width: deviceBounds.width / 2, height: 70)
        
        self.firstGroup.setHeight(buttonsSize.height)
        self.secondGroup.setHeight(buttonsSize.height)
        self.coursesButton.setWidth(buttonsSize.width)
        self.notesButton.setWidth(buttonsSize.width)
        self.profileButton.setWidth(buttonsSize.width)
        self.importantDatesButton.setWidth(buttonsSize.width)
        self.coursesButton.setHeight(buttonsSize.height)
        self.notesButton.setHeight(buttonsSize.height)
        self.profileButton.setHeight(buttonsSize.height)
        self.importantDatesButton.setHeight(buttonsSize.height)
        self.mainGroup.sizeToFitHeight()
        
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
