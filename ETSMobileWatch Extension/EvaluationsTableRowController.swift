//
//  EvaluationsTableRowController.swift
//  ETSMobile
//
//  Created by Charles Levesque on 2017-05-01.
//  Copyright © 2017 ApplETS. All rights reserved.
//

import Foundation
import WatchKit

class EvaluationsTableRowController : NSObject {
    @IBOutlet var evaluationTitleLabel: WKInterfaceLabel!
    @IBOutlet var evaluationNoteLabel: WKInterfaceLabel!
    @IBOutlet var evaluationAverageLabel: WKInterfaceLabel!
    @IBOutlet var evaluationMedianLabel: WKInterfaceLabel!
    @IBOutlet var evaluationStdDeviationLabel: WKInterfaceLabel!
    @IBOutlet var evaluationPercentileLabel: WKInterfaceLabel!
    @IBOutlet var evaluationWeightingLabel: WKInterfaceLabel!
    
    var evaluation: ETSEvaluation? {
        didSet {
            if let evaluation = self.evaluation {
                let noteLabel = evaluation.result == nil ? "-" : String(format: "%0.1f%%", arguments: [evaluation.result!.floatValue])
                let averageLabel = evaluation.mean == nil ? "-" : String(format: "%0.1f%%", arguments: [evaluation.mean!.floatValue])
                let medianLabel = evaluation.median == nil ? "-" : String(format: "%0.1f", arguments: [evaluation.median!.floatValue])
                let stdDeviationLabel = evaluation.std == nil ? "-" : String(format: "%0.1f", arguments: [evaluation.std!.floatValue])
                let percentileLabel = evaluation.percentile == nil ? "-" : String(format: "%0.f", arguments: [evaluation.percentile!.floatValue])
                let weightingLabel = evaluation.weighting == nil ? "-" : String(format: "%0.1f%%", arguments: [evaluation.weighting!.floatValue])
                
                self.evaluationTitleLabel.setText(evaluation.name)
                self.evaluationNoteLabel.setText(noteLabel)
                self.evaluationAverageLabel.setText(averageLabel)
                self.evaluationMedianLabel.setText(medianLabel)
                self.evaluationStdDeviationLabel.setText(stdDeviationLabel)
                self.evaluationPercentileLabel.setText(percentileLabel)
                self.evaluationWeightingLabel.setText(weightingLabel)
            }
        }
    }
}
