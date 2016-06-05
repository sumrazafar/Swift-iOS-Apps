//
//  TextPopoverViewController.swift
//  Meme_1.0
//
//  Created by Sumra Zafar on 6/1/16.
//  Copyright © 2016 Sumra Zafar. All rights reserved.
//

import UIKit

class TextPopoverViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    // MARK: Objects
    @IBOutlet weak var FontSlider: UISlider!
    @IBOutlet weak var FontPicker: UIPickerView!
    
    var fontAttributes: FontAttributes!
    var pickerData = [String]()
    let fontFamily = UIFont.familyNames()
    
    // MARK: Standard Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill array with font names
        for family in fontFamily {
            pickerData.appendContentsOf((UIFont.fontNamesForFamilyName(family)))
        }
        
        /* Set picker data source and delegate */
        FontPicker.dataSource = self
        FontPicker.delegate = self
        
        /* Set default row selection of picker */
        setFontAttributeDefaults(fontAttributes.fontSize, fontName: fontAttributes.fontName, fontColor: fontAttributes.fontColor)
        setValuesOfUIElementsForFontAttributes()
    }

    // MARK: Font Methods
    
    @IBAction func sliderUpdated(sender: UISlider) {
        let fontSize = CGFloat(FontSlider.value)
        fontAttributes.fontSize = fontSize
        
        updateMemeText()
    }

    
    // Set default font attibutes
    func setFontAttributeDefaults(fontSize: CGFloat = 32.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor()){
        fontAttributes.fontSize = fontSize
        fontAttributes.fontName = fontName
        fontAttributes.fontColor = fontColor
    }
    
    // Set UI Elements based on stored font attributes
    func setValuesOfUIElementsForFontAttributes() {
        /* Set font slider's value to the font size */
        FontSlider.value = Float(fontAttributes.fontSize)
        
        /* Set picker to the font that is stored */
        let index = pickerData.indexOf(fontAttributes.fontName)
        if let index = index {
            FontPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    //Update Meme
    func updateMemeText(){
        let parent = presentingViewController as! MemeEditorViewController
        parent.fontAttributes.fontSize = fontAttributes.fontSize
        parent.fontAttributes.fontName = fontAttributes.fontName
        parent.setupTextField([parent.TopText, parent.BottomText], partial: true)
    }
    
    // MARK: Delegate Methods
    
    // Picker data source methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //Picker Delegate Methods
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fontAttributes.fontName = pickerData[row]
        updateMemeText()
    }


}
