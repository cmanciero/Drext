//
//  DrawView.swift
//  Drext
//
//  Created by Manciero, Christopher on 2/18/15.
//  Copyright (c) 2015 Christopher Manciero. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var lines: [Line] = []
    var strokes : [Line] = []
    var lastPoint: CGPoint!
    var drawColor: Color = Color(colorName: "Black", r: 0.0, g: 0.0, b: 0.0)
    var background: Color = Color(colorName: "White", r: 255.0, g: 255.0, b: 255.0)
    var drawTime: NSDate?
    var brushSize : Float? = 10.0
    var opacity : Float? = 1.0
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        drawTime = NSDate()
        lastPoint = touches.anyObject()?.locationInView(self)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var newPoint = touches.anyObject()?.locationInView(self)
        lines.append(Line(startPoint: lastPoint, endPoint: newPoint!, rgb:(r:drawColor.r, g:drawColor.g, b:drawColor.b), brushSize: CGFloat(brushSize!), brushOpacity: CGFloat(opacity!), lineTime: drawTime!))
        lastPoint = newPoint
        
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var newPoint = touches.anyObject()?.locationInView(self)
        lines.append(Line(startPoint: lastPoint, endPoint: newPoint!, rgb:(r:drawColor.r, g:drawColor.g, b:drawColor.b), brushSize: CGFloat(brushSize!), brushOpacity: CGFloat(opacity!), lineTime: drawTime!))
        lastPoint = newPoint
        
        self.setNeedsDisplay()
    }
    
    // reset drawing canvas
    func reset(){
        self.brushSize = 10.0
        self.opacity = 1.0
        self.drawColor = Color(colorName: "Black", r: 0.0, g: 0.0, b: 0.0)
        self.background = Color(colorName: "White", r: 255.0, g: 255.0, b: 255.0)
        self.lines = []
        self.setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(context, kCGLineCapRound)

        for line in lines{
            CGContextBeginPath(context)
            CGContextSetLineWidth(context, CGFloat(line.brushSize))
            CGContextMoveToPoint(context, line.startPoint.x, line.startPoint.y)
            CGContextAddLineToPoint(context, line.endPoint.x, line.endPoint.y)
            CGContextSetRGBStrokeColor(context, line.rgb.r/255.0, line.rgb.g/255.0, line.rgb.b/255.0, line.brushOpacity)
            CGContextStrokePath(context)
        }

    }
}
