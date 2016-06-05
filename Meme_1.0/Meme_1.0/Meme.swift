//
//  Meme.swift
//  Meme_1.0
//
//  Created by Sumra Zafar on 5/31/16.
//  Copyright © 2016 Sumra Zafar. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    
    var topText: String
    var bottomText: String
    var image: UIImage
    var memedImage: UIImage
    
    // Constructor nt needed for struct
   
}


/* Stores font attributes for a meme */
struct FontAttributes {
    var fontSize: CGFloat = 32.0
    var fontName = "HelveticaNeue-CondensedBlack"
    var fontColor = UIColor.whiteColor()
    var borderColor = UIColor.blackColor()
}