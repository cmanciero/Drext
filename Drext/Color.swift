//
//  Color.swift
//  Drext
//
//  Created by Manciero, Christopher on 2/19/15.
//  Copyright (c) 2015 Christopher Manciero. All rights reserved.
//

import UIKit


class Color{
    var colorName : String
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    
    init(colorName : String, r: CGFloat, g: CGFloat, b: CGFloat){
        self.colorName = colorName
        self.r = r
        self.g = g
        self.b = b
    }
}