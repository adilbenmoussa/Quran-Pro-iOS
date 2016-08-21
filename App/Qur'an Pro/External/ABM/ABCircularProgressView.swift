//
//  ABCircularProgressView.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

class ABCircularProgressView: UIView {
    
    /*
    *  ABCircularProgressView Config
    */
    
    /**
    * The width of the line used to draw the progress view.
    **/
    let lineWidth: CGFloat = 1.0
    
    /**
    * The color of the progress view and the stop icon
    */
    let tintCGColor: CGColor = UIColor.blueColor().CGColor
    
    /**
    * Size ratio of the stop button related to the progress view
    * @default 1/3 of the progress view
    */
    let stopSizeRatio: CGFloat = 0.3
    
    /**
    * The Opacity of the progress background layer
    */
    let progressBackgroundOpacity: Float = 0.1
    
    
    //define the chape layers
    private let progressBackgroundLayer = CAShapeLayer()
    private let circlePathLayer = CAShapeLayer()
    private let iconLayer = CAShapeLayer()
    
    
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
                clearStopIcon()
            } else {
                circlePathLayer.strokeEnd = newValue
                drawStopIcon()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    private func setup() {
        progress = 0
        
        progressBackgroundLayer.frame = bounds
        progressBackgroundLayer.strokeColor = tintCGColor
        progressBackgroundLayer.fillColor = nil
        progressBackgroundLayer.lineCap = kCALineCapRound
        progressBackgroundLayer.lineWidth = lineWidth
        progressBackgroundLayer.opacity = progressBackgroundOpacity
        layer.addSublayer(progressBackgroundLayer)
        
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = lineWidth
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = tintCGColor
        layer.addSublayer(circlePathLayer)
        
        iconLayer.frame = bounds
        iconLayer.lineWidth = lineWidth
        iconLayer.lineCap = kCALineCapButt
        iconLayer.fillColor = nil
        layer.addSublayer(iconLayer)
        
        backgroundColor = UIColor.whiteColor()
    }
    
    private  func circlePath() -> UIBezierPath {
        let circleRadius = (self.bounds.size.width - lineWidth)/2
        var cgRect = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        cgRect.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(cgRect)
        cgRect.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(cgRect)
        return UIBezierPath(ovalInRect: cgRect)
    }
    
    private  func stopPath() -> UIBezierPath {
        let radius = bounds.size.width/2
        let sideSize = bounds.size.width * stopSizeRatio
        let stopPath : UIBezierPath = UIBezierPath()
        stopPath.moveToPoint(CGPointMake(0, 0))
        stopPath.addLineToPoint(CGPointMake(sideSize, 0.0))
        stopPath.addLineToPoint(CGPointMake(sideSize, sideSize))
        stopPath.addLineToPoint(CGPointMake(0.0, sideSize))
        stopPath.closePath()
        stopPath.applyTransform(CGAffineTransformMakeTranslation((radius * (1-stopSizeRatio)), (radius * (1-stopSizeRatio))))
        return stopPath;
    }
    
    private  func drawStopIcon() {
        iconLayer.fillColor = tintCGColor
        iconLayer.path = stopPath().CGPath
    }
    
    private  func clearStopIcon() {
        iconLayer.fillColor = nil
        iconLayer.path = nil
    }
    
    private  func backgroundCirclePath() -> UIBezierPath{
        let startAngle: CGFloat = -(CGFloat)(M_PI / 2); // 90 degrees
        let endAngle: CGFloat = CGFloat(2 * M_PI) + startAngle
        let center: CGPoint = CGPointMake(bounds.size.width/2, bounds.size.height/2)
        let radius: CGFloat = (bounds.size.width - lineWidth)/2
        
        // Draw background
        let processBackgroundPath: UIBezierPath = UIBezierPath()
        processBackgroundPath.lineWidth = lineWidth
        processBackgroundPath.lineCapStyle  = CGLineCap.Round
        processBackgroundPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        return processBackgroundPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressBackgroundLayer.path = backgroundCirclePath().CGPath
        circlePathLayer.path = circlePath().CGPath
        
    }
}