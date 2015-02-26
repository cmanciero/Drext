//
//  MainViewController.swift
//  Drext
//
//  Created by Manciero, Christopher on 2/18/15.
//  Copyright (c) 2015 Christopher Manciero. All rights reserved.
//

import UIKit
import iAd
import StoreKit

class MainViewController: UIViewController, UITabBarDelegate, ADBannerViewDelegate, ColorSelectedDelegate, BrushesDelegate, BackgroundDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    let storeVC: SKStoreProductViewController = SKStoreProductViewController()
    var crayonBox: SKProduct!
    var crayonBoxPurchased: Bool = false
    @IBOutlet weak var adBanner: ADBannerView!
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    var colors : [Color] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.adBanner.delegate = self

        // Do any additional setup after loading the view.
        tabBar.delegate = self
        drawView.backgroundColor = UIColor(red: drawView.background.r, green: drawView.background.g, blue: drawView.background.b, alpha: 1.0)
        
        if !(NSUserDefaults.standardUserDefaults().objectForKey("CrayonBox") != nil){
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            self.getProductInfo()
        }
        
        if var status: AnyObject! = NSUserDefaults.standardUserDefaults().objectForKey("CrayonBox"){
            if status as? NSString == "purchased"{
                self.crayonBoxPurchased = true
            }
        }
        
        self.setColors()
    }
    
    func crayonBoxPurchased(isPurchased: Bool) {
        if(isPurchased){
            self.setCrayonBoxPurchased()
            self.setUserDefault()
        }
    }
    
    func crayonBoxBackgroundPurchase(isPurchased: Bool) {
        if(isPurchased){
            self.setCrayonBoxPurchased()
            self.setUserDefault()
        }
    }
    
    // mark it true that crayon box is purchased
    func setCrayonBoxPurchased(){
        colors = CrayonBox().crayonBox
        crayonBoxPurchased = true
    }
    
    // set user defaults to store purchased value
    func setUserDefault(){
        NSUserDefaults.standardUserDefaults().setObject("purchased", forKey: "CrayonBox")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        NSLog("%@", error)
    }
    
    func getProductInfo(){
        if(SKPaymentQueue.canMakePayments()){
            let productId: NSSet = NSSet(object: "com.christophermanciero.Drext.CrayonBox")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productId)
            request.delegate = self
            request.start()
        }
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        let products = response.products
        if(products.count != 0){
            crayonBox = products[0] as SKProduct
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction: AnyObject in transactions{
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState{
                    case .Purchased:
                        crayonBoxPurchased = true
                        self.setColors()
                        SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                        break
                    case .Failed:
                        SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                        break
                    case .Restored:
                        crayonBoxPurchased = true
                        self.setColors()
                        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
                        break
                    default:
                        break
                }
            }
        }
    }
    
    // called when cancel or purchase from in-app purchase
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        storeVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // set the colors to use for color and background
    func setColors(){
        if(crayonBoxPurchased){
            colors = CrayonBox().crayonBox
        } else {
            colors = CrayonBox().basicBox
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Banner Ad methods
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("%@", error)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.adBanner.hidden = false
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        // call before a new banner advertisement is loaded
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        // if your delegate paused activities before allowing an action to run, it should resume those activities when this method is called
    }
    
    // MARK: - Tab Bar methods
    
    // get selected tab in UITabBar
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        var selectedTabTag = tabBar.selectedItem!.tag
        switch(selectedTabTag){
        case 0:
            performSegueWithIdentifier("Colors", sender: self)
        case 1:
            performSegueWithIdentifier("Brushes", sender: self)
        case 2:
            performSegueWithIdentifier("Background", sender: self)
        case 3:
            // save/share image
            if(self.drawView.lines.count > 0){
                UIGraphicsBeginImageContextWithOptions(self.drawView.frame.size, true, 0.0)
                self.drawView.layer.renderInContext(UIGraphicsGetCurrentContext())
                var drawing = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext();
                
                var items: NSArray = [drawing]
                var avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                self.presentViewController(avc, animated: true, completion: self.unselectItem)
            }
        case 4:
            // undo last drawing
            self.undo()
        case 5:
            // clear all drawings
            self.clear()
        default:
            println("default")
        }
    }
    
    // unselect tab bar items
    func unselectItem(){
        self.tabBar.selectedItem = nil
    }
    
    func undo() {
        if(drawView.lines.last != nil){
            var lastLine = drawView.lines.last! as Line
            
            // loop through and delete last drawing
            for index in (stride(from: drawView.lines.count - 1, through: 0, by: -1)){
                if(drawView.lines[index].lineTime == lastLine.lineTime){
                    drawView.lines.removeAtIndex(index)
                }
            }
            
            drawView.setNeedsDisplay()
        }
        
        self.unselectItem()
    }
    
    func clear(){
        drawView.backgroundColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0)
        drawView.reset()
        
        self.unselectItem()
    }
    
    // MARK: - Custom Delegate methods
    
    func colorSelected(color: Color) {
        drawView.drawColor = color
        self.unselectItem()
    }
    
    func doneBrushes(brushSize: Float, opacityLevel: Float) {
        drawView.brushSize = brushSize
        drawView.opacity = opacityLevel
        
        self.unselectItem()
    }
    
    func backgroundSelected(backgroundColor: Color) {
        drawView.background = backgroundColor
        drawView.backgroundColor = UIColor(red: backgroundColor.r/255.0, green: backgroundColor.g/255.0, blue: backgroundColor.b/255.0, alpha: 1.0)
        self.unselectItem()
    }
    
    // take photo selected and add to background
    func photoPicked(image: UIImage) {
        UIGraphicsBeginImageContext(self.drawView.frame.size)
        image.drawInRect(self.drawView.bounds)
        var backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        var imageBackground = UIColor(patternImage: backgroundImage)

        self.drawView.backgroundColor = imageBackground
        
        self.unselectItem()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "Colors"{
            let colorsNav = segue.destinationViewController as UINavigationController
            var colorType = colorsNav.viewControllers[0] as ColorsViewController// ColorsTableViewController
            colorType.selectedColor = drawView.drawColor
            colorType.colors = colors
            colorType.delegate = self
            
            if(crayonBoxPurchased){
                colorType.crayonBoxPurchased = true;
            }
        } else if segue.identifier == "Brushes"{
            let brushesNav = segue.destinationViewController as UINavigationController
            var brushes = brushesNav.viewControllers[0] as BrushesViewController
            brushes.delegate = self
            brushes.selectedBrushSize = drawView.brushSize
//            brushes.selectedOpacity = drawView.opacity
        } else if segue.identifier == "Background"{
            let backNav = segue.destinationViewController as UINavigationController
            var back = backNav.viewControllers[0] as BackgroundViewController
            back.delegate = self
            back.colors = colors
            back.selectedColor = drawView.background
            
            if(crayonBoxPurchased){
                back.crayonBoxPurchased = true;
            }
        }
    }

}
