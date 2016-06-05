//
//  MemeEditorViewController.swift
//  Meme_1.0
//
//  Created by Sumra Zafar on 5/23/16.
//  Copyright © 2016 Sumra Zafar. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate  {
    // MARK: Objects
    @IBOutlet weak var ImagePicker: UIImageView!
    @IBOutlet weak var TopText: UITextField!
    @IBOutlet weak var BottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var fontAttributes: FontAttributes!
    
    // MARK: Standard Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let textFieldArray = [TopText, BottomText]
        fontAttributes = FontAttributes() //initialize to default
        setupTextField(textFieldArray)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if camera is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if ImagePicker.image == nil {
            shareButton.enabled = false
        } else {
            shareButton.enabled = true
        }
        
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Image Picker Functions
    
    func setupImage(source: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        presentViewController(imagePicker, animated: true, completion:nil)
        
    }
    
    @IBAction func PickAnImageFromAlbum(sender: AnyObject) {
        setupImage(.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        setupImage(.Camera)
    }
    
   //display the image - using delegate function
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ImagePicker.image = image
            //to avoid image distortion
            ImagePicker.contentMode = UIViewContentMode.ScaleAspectFit
            dismissViewControllerAnimated(true, completion: nil)
            shareButton.enabled = true
        }
    }
    
    //dismiss on cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Text Field Functions - partial sent true from popover
    func setupTextField(txtFields: [UITextField!], partial: Bool = false){
        //attiributes for text fields
        let memeTextAttributes = [
            NSStrokeColorAttributeName : fontAttributes.borderColor, //outline
            NSForegroundColorAttributeName : fontAttributes.fontColor, //fill
            NSFontAttributeName : UIFont(name: fontAttributes.fontName, size: fontAttributes.fontSize)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        
        for textField in txtFields{
            textField.delegate = self
            
            if(partial == false){
                if (textField == TopText){
                    textField.text = "TOP"
                }else{
                    textField.text = "BOTTOM"
                }
            }
           
            textField.defaultTextAttributes = memeTextAttributes
            textField.textAlignment = .Center
        }
    }

    //empty field on typing
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == TopText && textField.text! == "TOP") || (textField == BottomText && textField.text! == "BOTTOM") {
            textField.text = ""
        }
    }
    
    //reset to default
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField.text! == ""){
            if(textField == TopText){
                textField.text = "TOP"
            }else{
                textField.text = "BOTTOM"
            }
        }
    }
    
    //allow return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    //uppercase
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
        
        return false
    }

    //  MARK: Navigation Functions
    
    /* Alert the user if something is missing from the meme when they try to save */
    func alertUser(mytitle: String! = "Title", mymessage: String?) {
        let alertController = UIAlertController(title: mytitle, message:
            mymessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func isMemeValid() -> Bool {
        if (TopText.text == "TOP" || BottomText.text == "BOTTOM" || ImagePicker.image == nil) {
            return false
        } else {
            return true
        }
    }

    
    //hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true     // status bar should be hidden
    }
    
    @IBAction func resetView(sender: AnyObject) {
        ImagePicker.image = nil
        shareButton.enabled = false
        let textFieldArray = [TopText, BottomText]
        fontAttributes = FontAttributes() //initialize to default
        setupTextField(textFieldArray)
        
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        if(self.isMemeValid()){
            let memedImage = generateMemedImage()
            let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
                activityController.completionWithItemsHandler = { activity, success, items, error in
                    if(!success){
                        return
                    }
                    
                    self.saveMeme()
                    self.dismissViewControllerAnimated(true, completion: nil)
            }
            presentViewController(activityController, animated: true, completion: nil)
        }else{
            alertUser("Meme share failed!", mymessage: "Something is missing in meme")
        }
    }
    
    func saveMeme() {
     //Create the meme
     let memedImage = generateMemedImage()
            
     let meme = Meme(topText: TopText.text!, bottomText: BottomText.text!,
                        image: ImagePicker.image!, memedImage: memedImage)
            
     // Add it to the memes array in the Application Delegate
     (UIApplication.sharedApplication().delegate as!
                AppDelegate).memes.append(meme)
        
    }
    
    // Create a UIImage that combines the Image View and the Textfields
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        navBar.hidden = true
        toolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        navBar.hidden = false
        toolBar.hidden = false
        
        return memedImage
    }


    //  MARK: keyboard Functions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if BottomText.isFirstResponder() {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Unsubscribe
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
    // MARK: Enhancements - Popover
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fontPopoverSegue" {
            let popoverVC = segue.destinationViewController as! TextPopoverViewController
            popoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverVC.popoverPresentationController!.delegate = self
            //assign the default values
            popoverVC.fontAttributes = fontAttributes
        }
    }
    
    // Popover delegate method - Set to None
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
}

