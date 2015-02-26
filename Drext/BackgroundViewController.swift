//
//  BackgroundViewController.swift
//  Drext
//
//  Created by Manciero, Christopher on 2/23/15.
//  Copyright (c) 2015 Christopher Manciero. All rights reserved.
//

import UIKit
import StoreKit
import MobileCoreServices

protocol BackgroundDelegate{
    func backgroundSelected(backgroundColor: Color)
    func photoPicked(image: UIImage)
    func crayonBoxBackgroundPurchase(isPurchased: Bool)
}


class BackgroundViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKStoreProductViewControllerDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let storeVC: SKStoreProductViewController = SKStoreProductViewController()
    var crayonBox: SKProduct!
    var crayonBoxPurchased: Bool = false
    var colors : [Color] = []
    var selectedColor : Color?
    var delegate : BackgroundDelegate? = nil
    var photoChoosePrompt: UIAlertController?
    
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var btnUploadPicture: UIButton!
    @IBOutlet weak var btnPurchaseCrayonBox: UIButton!
    @IBOutlet weak var tblBackground: UITableView!
    
    @IBAction func cancelBackground(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblBackground.delegate = self
        self.tblBackground.dataSource = self
        
        if(crayonBoxPurchased){
            self.buyView.removeFromSuperview()
            self.tblBackground.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addConstraint(NSLayoutConstraint(item: self.tblBackground, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 1.0))
        }
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        self.getProductInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func crayonBoxPurchased(isPurchased: Bool) {
        crayonBoxPurchased = true
    }
    
    // MARK: - Choose/Take picture
    
    @IBAction func takePicture(sender: AnyObject) {
        let takePhotoAction : UIAlertAction = UIAlertAction(title: "Take a photo", style: .Default, handler: takePicture)
        let chooseExistingAction : UIAlertAction = UIAlertAction(title: "Choose an existing", style: .Default, handler: showPhotoLibrary)
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        photoChoosePrompt = UIAlertController (title: "Use photo for background", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        photoChoosePrompt!.addAction(takePhotoAction)
        photoChoosePrompt!.addAction(chooseExistingAction)
        photoChoosePrompt!.addAction(cancelAction)
        
        presentViewController(photoChoosePrompt!, animated: true, completion: nil)
    }
    
    // show ability to take picture
    func takePicture(alert : UIAlertAction!){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // show ability to select existing photo
    func showPhotoLibrary(alert : UIAlertAction!){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        // Code here to work with media
        let mediaType = info[UIImagePickerControllerMediaType] as NSString
        var image: UIImage?
        
        if mediaType.isEqualToString(kUTTypeImage as NSString) {
            // Media is an image
            image = info[UIImagePickerControllerEditedImage] as? UIImage
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if delegate? != nil{
            delegate!.photoPicked(image!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - In-App purchases
    
    @IBAction func purchaseCrayonBox(sender: AnyObject) {
        let payment:SKPayment = SKPayment(product: crayonBox)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
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
                    self.tblBackground.reloadData()
                    if delegate? != nil{
                        delegate!.crayonBoxBackgroundPurchase(true)
                    }
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    break
                case .Failed:
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    break
                case .Restored:
                    self.colors = CrayonBox().crayonBox
                    self.tblBackground.reloadData()
                    if delegate? != nil{
                        delegate!.crayonBoxBackgroundPurchase(true)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("backgroundCell", forIndexPath: indexPath) as UITableViewCell
        
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
            delegate!.backgroundSelected(selectedColor)
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
