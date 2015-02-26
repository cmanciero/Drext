//
//  BrushesViewController.swift
//  Drext
//
//  Created by Manciero, Christopher on 2/19/15.
//  Copyright (c) 2015 Christopher Manciero. All rights reserved.
//

import UIKit

protocol BrushesDelegate{
    func doneBrushes(brushSize: Float, opacityLevel: Float)
}

class BrushesViewController: UIViewController {

    var delegate : BrushesDelegate? = nil
    @IBOutlet weak var brushSize: UISlider!
    @IBOutlet weak var brushPreview: UIImageView!
    @IBOutlet weak var lblBrushSize: UILabel!
//    @IBOutlet weak var opacityPreview: UIImageView!
//    @IBOutlet weak var opacityLevel: UILabel!
//    @IBOutlet weak var opacitySlider: UISlider!
//    var selectedOpacity: Float?
    var selectedBrushSize: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        brushSize.setValue(selectedBrushSize!, animated: true)
//        opacitySlider.setValue(selectedOpacity!, animated: true)
        self.updateBrushSize()
        self.updateOpacity()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneBrushes(sender: AnyObject) {
        if delegate? != nil{
            delegate!.doneBrushes(self.brushSize.value, opacityLevel: 1.0)//self.opacitySlider.value)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func sizeSliderChange(sender: AnyObject) {
        if(sender.tag == 0){
            self.updateBrushSize()
        } else if(sender.tag == 1){
            self.updateOpacity()
        }
    }
    
    // update size of brush
    func updateBrushSize(){
        self.lblBrushSize.text = NSString(format: "%.0f", self.brushSize.value)
        
        UIGraphicsBeginImageContext(self.brushPreview.frame.size);
        // get context since it's not in a UIView
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context)
        
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(self.brushSize.value));
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 32, 32);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 32, 32);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        // Remember to remove context
        UIGraphicsPopContext()
        
        self.brushPreview.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // update opacity for brush
    func updateOpacity(){
//        self.opacityLevel.text = NSString(format: "%.1f", self.opacitySlider.value)
//        
//        UIGraphicsBeginImageContext(self.opacityPreview.frame.size);
//        // get context since it's not in a UIView
//        var context: CGContextRef = UIGraphicsGetCurrentContext()
//        UIGraphicsPushContext(context)
//        
//        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 20.0);
//        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, CGFloat(self.opacitySlider.value));
//        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 32, 32);
//        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 32, 32);
//        CGContextStrokePath(UIGraphicsGetCurrentContext());
//        
//        // Rememvber to remove context
//        UIGraphicsPopContext()
//        
//        self.opacityPreview.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
    }
    
    @IBAction func cancelBrushes(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
