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
    @IBOutlet var coursesButton: WKInterfaceImage!
    @IBOutlet var notesButton: WKInterfaceButton!
    @IBOutlet var mainGroup: WKInterfaceGroup!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        let deviceBounds = WKInterfaceDevice.current().screenBounds
        let buttonsSize = CGSize(width: (deviceBounds.width / 2) - 2, height: 70)
        
        self.firstGroup.setHeight(buttonsSize.height)
        self.coursesButton.setWidth(buttonsSize.width)
        self.notesButton.setWidth(buttonsSize.width)
        self.coursesButton.setHeight(buttonsSize.height)
        self.notesButton.setHeight(buttonsSize.height)
        
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
