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

    // data: [second]
    public func setBarData(_ data: [Int]) {
        _ = subviews.map({ $0.removeFromSuperview() })
        
        guard !data.isEmpty else {
            self.frame = CGRect(x: 0, y: 0, width: frame.width, height: 0)
            return
        }
        
        let barGap = CGFloat(8)
        let barHeight = CGFloat(20)
        for (i, item) in data.enumerated() {
            let barWidth = CGFloat(item) / 60 * frame.width
            
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: CGFloat(i) * barHeight + CGFloat(i + 1) * barGap, width: barWidth, height: barHeight)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor(red: 0, green: 122.0 / 255, blue: 255.0 / 255, alpha: 1.0)), for: .normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor(red: 197.0 / 255, green: 224.0 / 255, blue: 255.0 / 255, alpha: 1.0)), for: .focused)
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            addSubview(button)
        }
        self.frame = CGRect(x: 0, y: 0, width: frame.width, height: (barHeight + barGap) * CGFloat(data.count) + barGap)
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
