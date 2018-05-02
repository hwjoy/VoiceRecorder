//
//  BarPlotView.swift
//  VoiceRecorder
//
//  Created by hwjoy on 25/04/2018.
//  Copyright © 2018 redant. All rights reserved.
//

import UIKit

class BarPlotView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    public func setBarData(_ data: [Int]) {
        _ = subviews.map({ $0.removeFromSuperview() })
        
        guard !data.isEmpty else {
            return
        }
        
        let barGap = 8
        let barWidth = (frame.width - CGFloat(barGap * (data.count + 1))) / CGFloat(data.count)
        for (i, item) in data.enumerated() {
            let barHeight = CGFloat(item) / 60 * frame.height
            
            let button = UIButton(type: .system)
            button.frame = CGRect(x: CGFloat(i) * barWidth + CGFloat((i + 1) * barGap), y: frame.height - barHeight, width: barWidth, height: barHeight)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor(red: 0, green: 122.0 / 255, blue: 255.0 / 255, alpha: 1.0)), for: .normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor(red: 197.0 / 255, green: 224.0 / 255, blue: 255.0 / 255, alpha: 1.0)), for: .focused)
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            addSubview(button)
        }
    }
    
}

extension UIImage {
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
