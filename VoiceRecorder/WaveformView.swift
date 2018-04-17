//
//  WaveformView.swift
//  VoiceRecorder
//
//  Created by hwjoy on 16/04/2018.
//  Copyright © 2018 redant. All rights reserved.
//

import UIKit

class WaveformView: UIView {

    static let SampleRate = 0.2
    var dataSource: Array<Float> = []
    var lineColor = UIColor.black
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard !dataSource.isEmpty else {
            return
        }
        
//        guard let context = UIGraphicsGetCurrentContext() else {
//            return
//        }
        
        lineColor.setStroke()
        
        let yOffset = CGFloat(5)
        var pointArray = Array<CGPoint>()
        for (i, item) in dataSource.enumerated() {
            var yValue: CGFloat = CGFloat(item)
            if item < 110 {
                yValue = 110
            }
            yValue = rect.height - rect.height * (yValue - 110) / 50 - yOffset
            pointArray.append(CGPoint(x: rect.width * CGFloat(i) / 60 * CGFloat(WaveformView.SampleRate), y: yValue))
        }
        
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 1
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        bezierPath.move(to: CGPoint(x: 0, y: rect.height - yOffset))
        for item in pointArray {
            bezierPath.addLine(to: item)
        }
        bezierPath.stroke()
    }

}
