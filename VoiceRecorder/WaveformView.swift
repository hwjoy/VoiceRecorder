//
//  WaveformView.swift
//  VoiceRecorder
//
//  Created by hwjoy on 16/04/2018.
//  Copyright © 2018 redant. All rights reserved.
//

import UIKit

class WaveformView: UIView {

    var dataSource: Array<Float> = []
    var lineColor = UIColor.black
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard dataSource.count != 0 else {
            return
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setLineWidth(1)
        context.setStrokeColor(lineColor.cgColor)
        var pointArray = Array<CGPoint>()
        for (i, item) in dataSource.enumerated() {
            if item > 0 {
                pointArray.append(CGPoint(x: CGFloat(i), y: CGFloat(item)))
            }
        }
        context.addLines(between: pointArray)
        context.drawPath(using: .stroke)
    }

}
