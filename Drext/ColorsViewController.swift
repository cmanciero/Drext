//
//  ColorsViewController.swift
//  Drext
//
//  Created by Manciero, Christopher on 2/23/15.
//  Copyright (c) 2015 Christopher Manciero. All rights reserved.
//

import UIKit
import StoreKit

protocol ColorSelectedDelegate{
    func colorSelected(color : Color)
    func crayonBoxPurchased(isPurchased: Bool)
}

class ColorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKStoreProductViewControllerDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    let storeVC: SKStoreProductViewController = SKStoreProductViewController()
    var crayonBox: SKProduct!
    var crayonBoxPurchased: Bool = false
    var colors: [Color] = []
    var selectedColor : Color?
    var delegate: ColorSelectedDelegate? = nil
    
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var btnPurchaseCrayonBox: UIButton!
    @IBOutlet weak var tblColors: UITableView!
    
    @IBAction func cancelColors(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func purchaseCrayonBox(sender: AnyObject) {
        let payment:SKPayment = SKPayment(product: crayonBox)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(crayonBoxPurchased){
            self.buyView.removeFromSuperview()
            
            self.tblColors.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addConstraint(NSLayoutConstraint(item: self.tblColors, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 1.0))
        }

        // Do any additional setup after loading the view.
        self.tblColors.delegate = self
        self.tblColors.dataSource = self
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        self.getProductInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - In-App purchases
    
    // get In-App purchase items
    func getProductInfo(){
        if(SKPaymentQueue.canMakePayments()){
            let productId: NSSet = NSSet(object: "com.christophermanciero.Drext.CrayonBox")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productId)
            request.delegate = self
            request.start()
        }
    }
    
    // check to make sure Apple returned info
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        let products = response.products
        if(products.count != 0){
            crayonBox = products[0] as SKProduct
        }
    }
    
    // request failed
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("error - " + error.description)
    }
    
    
    // make purchase
    func checkForPurchase(){
        let payment:SKPayment = SKPayment(product: crayonBox)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    // update if payment was successful, failed or restored
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction: AnyObject in transactions{
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState{
                case .Purchased:
                    self.colors = CrayonBox().crayonBox
                    self.tblColors.reloadData()
                    if delegate? != nil{
                        delegate!.crayonBoxPurchased(true)
                    }
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    break
                case .Failed:
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    break
                case .Restored:
                    self.colors = CrayonBox().crayonBox
                    self.tblColors.reloadData()
                    if delegate? != nil{
                        delegate!.crayonBoxPurchased(true)
                    }
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

    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.colors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("colorCell", forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = colors[indexPath.row].colorName
        
        cell.backgroundColor = UIColor(red: colors[indexPath.row].r/255.0, green: colors[indexPath.row].g/255.0, blue: colors[indexPath.row].b/255.0, alpha: 1.0)
        if( colors[indexPath.row].colorName == "Black" ){
                cell.textLabel?.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if delegate? != nil{
            var selectedColor = colors[indexPath.row]
            delegate!.colorSelected(selectedColor)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
