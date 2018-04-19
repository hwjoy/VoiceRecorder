//
//  WaveformView.swift
//  VoiceRecorder
//
//  Created by hwjoy on 16/04/2018.
//  Copyright © 2018 redant. All rights reserved.
//

import UIKit

class WaveformView: UIView {

    static let SampleRate = 0.05
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
        
        let displayTime = 1.0;    // min
        let yOffset = CGFloat(5)
        var pointArray = Array<CGPoint>()
        if dataSource.count > Int(displayTime / WaveformView.SampleRate) {
            let xOffset = dataSource.count - Int(displayTime / WaveformView.SampleRate)
            for i in xOffset ..< dataSource.count {
                let item = dataSource[i]
                var yValue: CGFloat = CGFloat(item)
                if item < 110 {
                    yValue = 110
                }
                yValue = rect.height - rect.height * (yValue - 110) / 50 - yOffset
                let xValue = i - xOffset
                pointArray.append(CGPoint(x: rect.width * CGFloat(Double(xValue) / displayTime * WaveformView.SampleRate), y: yValue))
            }
        } else {
            for (i, item) in dataSource.enumerated() {
                var yValue: CGFloat = CGFloat(item)
                if item < 110 {
                    yValue = 110
                }
                yValue = rect.height - rect.height * (yValue - 110) / 50 - yOffset
                pointArray.append(CGPoint(x: rect.width * CGFloat(Double(i) / displayTime * WaveformView.SampleRate), y: yValue))
            }
        }
        
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 2
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        bezierPath.move(to: pointArray.first!)
        for item in pointArray {
            bezierPath.addLine(to: item)
        }
        
//        if dataSource.count > 1 {
//            let transform = CGAffineTransform(translationX: rect.width * CGFloat(Double(dataSource.count) / displayTime * WaveformView.SampleRate), y: 0)
//            bezierPath.apply(transform)
//        }
        
        bezierPath.stroke()
    }

}
