//
//  Line.swift
//  Drext
//
//  Created by Manciero, Christopher on 2/18/15.
//  Copyright (c) 2015 Christopher Manciero. All rights reserved.
//

import UIKit

class Line{
    var startPoint : CGPoint
    var endPoint: CGPoint
    var rgb: (r:CGFloat, g:CGFloat, b:CGFloat) = (r: 0.00, g: 0.00, b: 0.00)
    var lineTime: NSDate
    var brushSize: CGFloat
    var brushOpacity: CGFloat
    
    init(startPoint: CGPoint, endPoint: CGPoint, rgb: (r:CGFloat, g:CGFloat, b:CGFloat), brushSize: CGFloat, brushOpacity: CGFloat, lineTime: NSDate){
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.rgb = rgb
        self.brushSize = brushSize
        self.brushOpacity = brushOpacity
        self.lineTime = lineTime
    }
}
