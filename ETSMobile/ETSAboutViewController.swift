//
//  ETSAboutViewController.swift
//  ETSMobile
//
//  Created by Samuel Bellerose on 2015-11-11.
//  Copyright © 2015 ApplETS. All rights reserved.
//

import Crashlytics
import UIKit

class ETSAboutViewController: UIViewController{
    
    @IBOutlet weak var aboutTextLabel: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Answers.logContentViewWithName("About ETSMobile", contentType: "About", contentId: "ETS-About", customAttributes: nil)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
}
